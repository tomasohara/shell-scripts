#! /usr/bin/env python3
#
# Interactive xrandr monitor calibrator with iterative feedback.
#
# note: via Copilot/Codex-5.3
#

"""
Interactive xrandr monitor calibrator with an iterative feedback loop.

Examples:
    {script} --output eDP-1 --gamma 0.8:0.7:0.5 --brightness 0.75
    {script} --dry-run
"""

from __future__ import annotations

# Standard modules
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass, field

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import system

debug.trace(5, f"global __doc__: {__doc__}")
debug.assertion(__doc__)

# Constants
TL = debug.TL

OUTPUT_ARG = "output"
GAMMA_ARG = "gamma"
BRIGHTNESS_ARG = "brightness"
CLI_ARG = "cli"
DRY_RUN_ARG = "dry-run"
VERBOSE_ARG = "verbose"

DEFAULT_OUTPUT = "eDP-1"
DEFAULT_GAMMA = (0.8, 0.7, 0.5)
DEFAULT_BRIGHTNESS = 0.75

# Adaptive coarse-to-fine step control for feedback loop.
# Starts aggressively, then shrinks on uncertainty/overshoot.
INITIAL_GAMMA_STEP = 0.16
INITIAL_BRIGHTNESS_STEP = 0.24
MIN_GAMMA_STEP = 0.01
MAX_GAMMA_STEP = 0.35
MIN_BRIGHTNESS_STEP = 0.02
MAX_BRIGHTNESS_STEP = 0.60
BETTER_GROW_FACTOR = 1.10
NOT_SURE_SHRINK_FACTOR = 0.75
WORSE_SHRINK_FACTOR = 0.50
WORSE_RETRY_SCALE = 0.50

MIN_GAMMA = 0.30
MAX_GAMMA = 1.50
MIN_BRIGHTNESS = 0.20
MAX_BRIGHTNESS = 1.50

STATUS_OPTIONS = ["better", "worse", "not-sure"]
COLOR_OPTIONS = [
    "not-sure",
    "too-red",
    "too-green",
    "too-blue",
    "too-magenta",
    "too-cyan",
    "too-yellow",
]
BRIGHTNESS_OPTIONS = ["not-sure", "too-bright", "too-dim"]

STATUS_CHOICES = [
    ("better", "Better"),
    ("worse", "Worse"),
    ("not-sure", "Not sure"),
]
COLOR_CHOICES = [
    ("not-sure", "Not sure"),
    ("too-red", "Too red"),
    ("too-green", "Too green"),
    ("too-blue", "Too blue"),
    ("too-magenta", "Too magenta"),
    ("too-cyan", "Too cyan"),
    ("too-yellow", "Too yellow"),
]
BRIGHTNESS_CHOICES = [
    ("not-sure", "Not sure"),
    ("too-bright", "Too bright"),
    ("too-dim", "Too dim"),
]


def clamp(value: float, minimum: float, maximum: float) -> float:
    """Clamp numeric VALUE into an inclusive range [MINIMUM, MAXIMUM]."""
    return max(minimum, min(maximum, value))


def parse_gamma(gamma_text: str) -> tuple[float, float, float]:
    """Parse xrandr gamma text like '0.8:0.7:0.5'."""
    values = gamma_text.split(":")
    if len(values) != 3:
        raise ValueError("Gamma must be in R:G:B format (for example 0.8:0.7:0.5)")
    red, green, blue = (float(part) for part in values)
    return red, green, blue


def gamma_to_text(gamma: tuple[float, float, float]) -> str:
    """Return xrandr gamma text with fixed precision."""
    red, green, blue = gamma
    return f"{red:.2f}:{green:.2f}:{blue:.2f}"


def build_xrandr_command(
    output: str, gamma: tuple[float, float, float], brightness: float
) -> list[str]:
    """Build an xrandr command list suitable for subprocess.run()."""
    return [
        "xrandr",
        "--output",
        output,
        "--gamma",
        gamma_to_text(gamma),
        "--brightness",
        f"{brightness:.2f}",
    ]


def parse_options() -> dict[str, object]:
    """Parse command-line options through mezcla.main.Main."""
    main_app = Main(
        description=__doc__.format(script=gh.basename(__file__)),
        ## OLD: skip_input=True,
        skip_input=False,
        manual_input=True,
        auto_help=False,
        boolean_options=[
            (CLI_ARG, "Force CLI mode even if PyQt is available"),
            (DRY_RUN_ARG, "Print intended xrandr command without applying it"),
            (VERBOSE_ARG, "Verbose prompting mode"),
        ],
        text_options=[
            (OUTPUT_ARG, "xrandr output name", DEFAULT_OUTPUT),
            (GAMMA_ARG, "Initial gamma in R:G:B form", gamma_to_text(DEFAULT_GAMMA)),
        ],
        float_options=[(BRIGHTNESS_ARG, "Initial software brightness", DEFAULT_BRIGHTNESS)],
    )

    # Defensive fallback: in some invocation contexts parsed_args can be unset.
    if not getattr(main_app, "parsed_args", None):
        main_app.check_arguments(sys.argv[1:])

    parsed_args = (main_app.parsed_args or {})

    def option_value(label: str, default):
        """Return parsed option or DEFAULT without relying on parsed_args truthiness."""
        option_name = main_app.get_option_name(label)
        return parsed_args.get(option_name, default)

    options = {
        OUTPUT_ARG: option_value(OUTPUT_ARG, DEFAULT_OUTPUT),
        GAMMA_ARG: option_value(GAMMA_ARG, gamma_to_text(DEFAULT_GAMMA)),
        BRIGHTNESS_ARG: option_value(BRIGHTNESS_ARG, DEFAULT_BRIGHTNESS),
        CLI_ARG: bool(option_value(CLI_ARG, False)),
        DRY_RUN_ARG: bool(option_value(DRY_RUN_ARG, False)),
        VERBOSE_ARG: bool(option_value(VERBOSE_ARG, False)),
    }
    debug.trace_expr(TL.DETAILED, options, prefix="parse_options(): ")
    return options


def channel_to_byte(value: float) -> int:
    """Convert gamma channel value in [MIN_GAMMA, MAX_GAMMA] to [0,255]."""
    normalized = (value - MIN_GAMMA) / (MAX_GAMMA - MIN_GAMMA)
    return int(round(clamp(normalized, 0.0, 1.0) * 255.0))


def channel_to_unit(value: float) -> float:
    """Convert gamma channel value in [MIN_GAMMA, MAX_GAMMA] to [0,1]."""
    return clamp((value - MIN_GAMMA) / (MAX_GAMMA - MIN_GAMMA), 0.0, 1.0)


def picker_color_to_gamma(
    red: float, green: float, blue: float, current_gamma: tuple[float, float, float]
) -> tuple[float, float, float]:
    """Map a picked color to gamma balance while preserving current average gamma."""
    uses_integral = max(red, green, blue) > 1.0
    scale = 255.0 if uses_integral else 1.0
    color_values = [max(component / scale, 0.05) for component in (red, green, blue)]
    color_mean = sum(color_values) / 3.0
    normalized = [component / color_mean for component in color_values]
    gamma_mean = sum(current_gamma) / 3.0
    return tuple(
        clamp(gamma_mean * component, MIN_GAMMA, MAX_GAMMA) for component in normalized
    )


def preprocess_feedback_tuple(raw_feedback: str) -> tuple[str, str, str]:
    """Parse tuple-like feedback into (status, color, brightness).

    Accepts forms such as:
      - better, too-blue, too-bright
      - <better too-blue too-bright>
      - 1. better 2. too-blue 3. too-bright

    If improvement/status is omitted, any "too-*" input implies "worse".
    """
    status = "not-sure"
    color_feedback = "not-sure"
    brightness_feedback = "not-sure"
    status_explicit = False
    implied_worse = False

    normalized = raw_feedback.strip().lower()
    normalized = re.sub(r"[<>\(\)\[\]]", " ", normalized)
    normalized = re.sub(r"\b[123]\.\s*", " ", normalized)
    normalized = re.sub(r"[,;/|]+", " ", normalized)
    tokens = [tok.strip() for tok in normalized.split() if tok.strip()]

    if not tokens:
        return status, color_feedback, brightness_feedback

    aliases = {
        "unsure": "not-sure",
        "notsure": "not-sure",
        "same": "not-sure",
        "no-change": "not-sure",
        "nochange": "not-sure",
        "none": "not-sure",
        "color-ok": "not-sure",
        "brightness-ok": "not-sure",
        "too-dark": "too-dim",
        "dark": "too-dim",
        "dim": "too-dim",
        "bright": "too-bright",
    }

    for token in tokens:
        token = aliases.get(token, token)

        if token in STATUS_OPTIONS:
            status = token
            status_explicit = True
            continue

        if token in COLOR_OPTIONS:
            color_feedback = token
            if token.startswith("too-"):
                implied_worse = True
            continue

        if token in BRIGHTNESS_OPTIONS:
            brightness_feedback = token
            if token.startswith("too-"):
                implied_worse = True
            continue

        # Allow shorthand color names in tuple input.
        if token in {"red", "green", "blue", "magenta", "cyan", "yellow"}:
            color_feedback = f"too-{token}"
            implied_worse = True
            continue

        raise ValueError(
            f"Unsupported feedback token: {token}. "
            "Use status (better/worse/not-sure), color (too-blue, ...), "
            "and/or brightness (too-bright/too-dim)."
        )

    if (not status_explicit) and implied_worse:
        status = "worse"

    return status, color_feedback, brightness_feedback


@dataclass
class CalibrationState:
    """Current calibration settings and feedback history."""

    output: str
    gamma: tuple[float, float, float]
    brightness: float
    gamma_step: float = INITIAL_GAMMA_STEP
    brightness_step: float = INITIAL_BRIGHTNESS_STEP
    last_delta: tuple[float, float, float, float] = (0.0, 0.0, 0.0, 0.0)
    iteration: int = 0
    history: list[str] = field(default_factory=list)

    def apply_feedback(
        self, status: str, color_feedback: str, brightness_feedback: str
    ) -> tuple[str, tuple[float, float, float, float]]:
        """Apply one feedback step and return summary and resulting delta."""
        if status not in STATUS_OPTIONS:
            raise ValueError(f"Unsupported status: {status}")
        if color_feedback not in COLOR_OPTIONS:
            raise ValueError(f"Unsupported color feedback: {color_feedback}")
        if brightness_feedback not in BRIGHTNESS_OPTIONS:
            raise ValueError(f"Unsupported brightness feedback: {brightness_feedback}")

        red, green, blue = self.gamma
        color_changed = color_feedback != "not-sure"
        brightness_changed = brightness_feedback != "not-sure"

        if status == "worse":
            d_red, d_green, d_blue, d_brightness = self.last_delta
            red = clamp(red - d_red, MIN_GAMMA, MAX_GAMMA)
            green = clamp(green - d_green, MIN_GAMMA, MAX_GAMMA)
            blue = clamp(blue - d_blue, MIN_GAMMA, MAX_GAMMA)
            self.brightness = clamp(
                self.brightness - d_brightness, MIN_BRIGHTNESS, MAX_BRIGHTNESS
            )
            if any(abs(delta) > 1e-9 for delta in (d_red, d_green, d_blue)):
                self.gamma_step = clamp(
                    self.gamma_step * WORSE_SHRINK_FACTOR, MIN_GAMMA_STEP, MAX_GAMMA_STEP
                )
            if abs(d_brightness) > 1e-9:
                self.brightness_step = clamp(
                    self.brightness_step * WORSE_SHRINK_FACTOR,
                    MIN_BRIGHTNESS_STEP,
                    MAX_BRIGHTNESS_STEP,
                )

        step_scale = 1.0 if status == "better" else 0.5
        if status == "worse":
            # Avoid no-op loops from revert-then-reapply at minimum step.
            step_scale = WORSE_RETRY_SCALE
        d_red = 0.0
        d_green = 0.0
        d_blue = 0.0
        d_brightness = 0.0

        color_step = self.gamma_step * step_scale
        if color_feedback == "too-red":
            d_red -= color_step
        elif color_feedback == "too-green":
            d_green -= color_step
        elif color_feedback == "too-blue":
            d_blue -= color_step
        elif color_feedback == "too-magenta":
            d_red -= color_step
            d_blue -= color_step
        elif color_feedback == "too-cyan":
            d_green -= color_step
            d_blue -= color_step
        elif color_feedback == "too-yellow":
            d_red -= color_step
            d_green -= color_step

        brightness_step = self.brightness_step * step_scale
        if brightness_feedback == "too-bright":
            d_brightness -= brightness_step
        elif brightness_feedback == "too-dim":
            d_brightness += brightness_step

        red = clamp(red + d_red, MIN_GAMMA, MAX_GAMMA)
        green = clamp(green + d_green, MIN_GAMMA, MAX_GAMMA)
        blue = clamp(blue + d_blue, MIN_GAMMA, MAX_GAMMA)
        self.brightness = clamp(
            self.brightness + d_brightness, MIN_BRIGHTNESS, MAX_BRIGHTNESS
        )
        self.gamma = (red, green, blue)
        self.last_delta = (d_red, d_green, d_blue, d_brightness)
        self.iteration += 1

        if status == "better":
            if color_changed:
                self.gamma_step = clamp(
                    self.gamma_step * BETTER_GROW_FACTOR, MIN_GAMMA_STEP, MAX_GAMMA_STEP
                )
            if brightness_changed:
                self.brightness_step = clamp(
                    self.brightness_step * BETTER_GROW_FACTOR,
                    MIN_BRIGHTNESS_STEP,
                    MAX_BRIGHTNESS_STEP,
                )
        elif status == "not-sure":
            if color_changed:
                self.gamma_step = clamp(
                    self.gamma_step * NOT_SURE_SHRINK_FACTOR,
                    MIN_GAMMA_STEP,
                    MAX_GAMMA_STEP,
                )
            if brightness_changed:
                self.brightness_step = clamp(
                    self.brightness_step * NOT_SURE_SHRINK_FACTOR,
                    MIN_BRIGHTNESS_STEP,
                    MAX_BRIGHTNESS_STEP,
                )

        summary = (
            f"iter={self.iteration}, status={status}, color={color_feedback}, "
            f"brightness={brightness_feedback} -> gamma={gamma_to_text(self.gamma)}, "
            f"brightness={self.brightness:.2f}, steps(gamma={self.gamma_step:.3f}, "
            f"brightness={self.brightness_step:.3f})"
        )
        self.history.append(summary)
        return summary, self.last_delta


def apply_xrandr(state: CalibrationState, dry_run: bool, _verbose: bool = False) -> str:
    """Apply the current state to xrandr and return the exact command text."""
    command = build_xrandr_command(state.output, state.gamma, state.brightness)
    printable = " ".join(command)
    if dry_run:
        return f"[dry-run] {printable}"
    completed = subprocess.run(command, check=False, capture_output=True, text=True)
    if completed.returncode != 0:
        message = completed.stderr.strip() or completed.stdout.strip()
        raise RuntimeError(f"xrandr failed: {message}")
    return printable


def run_cli_loop(state: CalibrationState, dry_run: bool, verbose: bool) -> int:
    """CLI fallback loop when PyQt is unavailable."""
    print("Using CLI mode. Type 'quit' to exit.")
    print("Iteration feedback format: <improvement, color, brightness>")
    print("Example: better, too-blue, too-bright")
    print("Note: if improvement is omitted, any too-* implies worse.\n")
    while True:
        print(
            f"Current: gamma={gamma_to_text(state.gamma)}, "
            f"brightness={state.brightness:.2f}, output={state.output}, "
            f"steps(gamma={state.gamma_step:.3f}, brightness={state.brightness_step:.3f})"
        )
        if verbose:
            choices_spec = " ".join(
                system.unique_items(STATUS_OPTIONS + COLOR_OPTIONS + BRIGHTNESS_OPTIONS)
            )
            print(f"choices:\n\t{choices_spec}")
        raw_feedback = input("Iteration feedback: ").strip()
        if raw_feedback.lower() == "quit":
            break
        try:
            status, color_feedback, brightness_feedback = preprocess_feedback_tuple(
                raw_feedback
            )
        except ValueError as err:
            print(f"{err}\n")
            continue

        summary, _ = state.apply_feedback(status, color_feedback, brightness_feedback)
        try:
            command_text = apply_xrandr(state, dry_run=dry_run, _verbose=verbose)
        except RuntimeError as err:
            print(str(err))
            return 1
        print(summary)
        print(f"Applied: {command_text}\n")
    return 0


def build_pyqt_ui(state: CalibrationState, dry_run: bool, _verbose: bool):
    """Create and return a PyQt window class instance."""
    # pylint: disable=import-outside-toplevel
    try:
        from PyQt6.QtCore import Qt
        from PyQt6.QtGui import QColor
        from PyQt6.QtWidgets import (
            QApplication,
            QButtonGroup,
            QCheckBox,
            QColorDialog,
            QDoubleSpinBox,
            QFormLayout,
            QGridLayout,
            QGroupBox,
            QHBoxLayout,
            QLabel,
            QLineEdit,
            QMessageBox,
            QPushButton,
            QRadioButton,
            QSlider,
            QTextEdit,
            QVBoxLayout,
            QWidget,
        )
        pyqt_version = 6
        horizontal_orientation = Qt.Orientation.Horizontal
    except ImportError:
        from PyQt5.QtCore import Qt  # type: ignore
        from PyQt5.QtGui import QColor  # type: ignore
        from PyQt5.QtWidgets import (  # type: ignore
            QApplication,
            QButtonGroup,
            QCheckBox,
            QColorDialog,
            QDoubleSpinBox,
            QFormLayout,
            QGridLayout,
            QGroupBox,
            QHBoxLayout,
            QLabel,
            QLineEdit,
            QMessageBox,
            QPushButton,
            QRadioButton,
            QSlider,
            QTextEdit,
            QVBoxLayout,
            QWidget,
        )
        pyqt_version = 5
        horizontal_orientation = Qt.Horizontal

    class CalibratorWindow(QWidget):
        """Feedback-driven calibration window with direct RGB controls."""

        def __init__(self):
            super().__init__()
            self.setWindowTitle("xrandr Calibrator")
            self.resize(920, 700)
            self.syncing_controls = False

            self.output_edit = QLineEdit(state.output)
            self.status_buttons = {}
            self.color_buttons = {}
            self.brightness_buttons = {}
            self.rgb_sliders = {}
            self.rgb_spins = {}
            self._picker_baseline_gamma = state.gamma
            self._picker_original_gamma = state.gamma

            self.current_output_value = QLabel("")
            self.current_gamma_value = QLabel("")
            self.current_brightness_value = QLabel("")
            self.current_delta_value = QLabel("")
            for label in (
                self.current_output_value,
                self.current_gamma_value,
                self.current_brightness_value,
                self.current_delta_value,
            ):
                label.setStyleSheet("font-family: monospace; font-size: 14px;")
                label.setTextInteractionFlags(Qt.TextSelectableByMouse)

            self.command_label = QLabel("")
            self.command_label.setWordWrap(True)
            self.command_label.setStyleSheet("font-family: monospace;")
            self.command_label.setTextInteractionFlags(Qt.TextSelectableByMouse)

            self.history_box = QTextEdit()
            self.history_box.setReadOnly(True)

            self.auto_apply_box = QCheckBox("Auto-apply direct/color edits")
            self.auto_apply_box.setChecked(True)
            self.color_preview = QLabel("      ")
            self.color_preview.setFixedWidth(80)
            self.color_preview.setStyleSheet("border: 1px solid #666;")
            self.color_preview_value = QLabel("")
            self.color_preview_value.setStyleSheet("font-family: monospace;")
            self.color_preview_value.setTextInteractionFlags(Qt.TextSelectableByMouse)

            manual_box = QGroupBox(
                "Direct RGB / brightness controls (alternative to feedback loop)"
            )
            manual_layout = QGridLayout()
            for row, channel in enumerate(("R", "G", "B")):
                slider = QSlider(horizontal_orientation)
                slider.setRange(int(MIN_GAMMA * 100), int(MAX_GAMMA * 100))
                spin = QDoubleSpinBox()
                spin.setRange(MIN_GAMMA, MAX_GAMMA)
                spin.setSingleStep(0.01)
                spin.setDecimals(2)
                self.rgb_sliders[channel] = slider
                self.rgb_spins[channel] = spin
                slider.valueChanged.connect(
                    lambda value, key=channel: self.on_rgb_slider_changed(key, value)
                )
                spin.valueChanged.connect(
                    lambda value, key=channel: self.on_rgb_spin_changed(key, value)
                )
                manual_layout.addWidget(QLabel(f"{channel}:"), row, 0)
                manual_layout.addWidget(slider, row, 1)
                manual_layout.addWidget(spin, row, 2)

            self.brightness_slider = QSlider(horizontal_orientation)
            self.brightness_slider.setRange(
                int(MIN_BRIGHTNESS * 100), int(MAX_BRIGHTNESS * 100)
            )
            self.brightness_spin = QDoubleSpinBox()
            self.brightness_spin.setRange(MIN_BRIGHTNESS, MAX_BRIGHTNESS)
            self.brightness_spin.setSingleStep(0.01)
            self.brightness_spin.setDecimals(2)
            self.brightness_slider.valueChanged.connect(self.on_brightness_slider_changed)
            self.brightness_spin.valueChanged.connect(self.on_brightness_spin_changed)
            manual_layout.addWidget(QLabel("Brightness:"), 3, 0)
            manual_layout.addWidget(self.brightness_slider, 3, 1)
            manual_layout.addWidget(self.brightness_spin, 3, 2)

            pick_color_button = QPushButton("Pick balance color...")
            pick_color_button.clicked.connect(self.on_pick_color)
            apply_manual_button = QPushButton("Apply RGB/brightness controls")
            apply_manual_button.clicked.connect(self.on_apply_manual_controls)
            manual_layout.addWidget(pick_color_button, 4, 0)
            manual_layout.addWidget(self.color_preview, 4, 1)
            manual_layout.addWidget(self.color_preview_value, 4, 2)
            manual_layout.addWidget(self.auto_apply_box, 5, 0, 1, 3)
            manual_layout.addWidget(apply_manual_button, 6, 0, 1, 3)
            manual_box.setLayout(manual_layout)

            apply_feedback_button = QPushButton("Apply feedback step")
            reapply_button = QPushButton("Reapply current settings")
            reset_button = QPushButton("Reset to defaults")
            copy_snapshot_button = QPushButton("Copy form snapshot")
            apply_feedback_button.clicked.connect(self.on_apply_feedback)
            reapply_button.clicked.connect(self.on_reapply)
            reset_button.clicked.connect(self.on_reset_defaults)
            copy_snapshot_button.clicked.connect(self.on_copy_snapshot)

            form_layout = QFormLayout()
            form_layout.addRow("Output:", self.output_edit)

            status_box = self.build_radio_box(
                "1) Overall result",
                STATUS_CHOICES,
                self.status_buttons,
                default_key="better",
                columns=3,
            )
            color_box = self.build_radio_box(
                "2) Color balance",
                COLOR_CHOICES,
                self.color_buttons,
                default_key="not-sure",
                columns=3,
            )
            brightness_box = self.build_radio_box(
                "3) Brightness",
                BRIGHTNESS_CHOICES,
                self.brightness_buttons,
                default_key="not-sure",
                columns=3,
            )

            current_layout = QFormLayout()
            current_layout.addRow("Output:", self.current_output_value)
            current_layout.addRow("Gamma (R:G:B):", self.current_gamma_value)
            current_layout.addRow("Brightness:", self.current_brightness_value)
            current_layout.addRow("Last delta:", self.current_delta_value)
            current_box = QGroupBox("Current settings")
            current_box.setLayout(current_layout)

            feedback_buttons = QHBoxLayout()
            feedback_buttons.addWidget(apply_feedback_button)
            feedback_buttons.addWidget(reapply_button)
            feedback_buttons.addWidget(reset_button)
            feedback_buttons.addWidget(copy_snapshot_button)

            top = QVBoxLayout()
            top.addLayout(form_layout)
            top.addWidget(manual_box)
            top.addWidget(status_box)
            top.addWidget(color_box)
            top.addWidget(brightness_box)
            top.addLayout(feedback_buttons)
            top.addWidget(current_box)
            top.addWidget(QLabel("Last command:"))
            top.addWidget(self.command_label)
            top.addWidget(QLabel("History:"))
            top.addWidget(self.history_box)
            self.setLayout(top)

            self.sync_controls_from_state()
            self.refresh_labels("Ready.")

        def build_radio_box(self, title, choices, destination, default_key, columns=3):
            """Build one-click radio group and save controls in DESTINATION."""
            box = QGroupBox(title)
            layout = QGridLayout()
            group = QButtonGroup(self)
            for index, (key, label) in enumerate(choices):
                button = QRadioButton(label)
                group.addButton(button)
                destination[key] = button
                row = index // columns
                col = index % columns
                layout.addWidget(button, row, col)
            destination[default_key].setChecked(True)
            box.setLayout(layout)
            return box

        def selected_key(self, button_map, fallback):
            """Return selected key from BUTTON_MAP."""
            for key, button in button_map.items():
                if button.isChecked():
                    return key
            return fallback

        def update_color_preview(self, red: int, green: int, blue: int):
            """Refresh color swatch for selected/direct RGB balance."""
            self.color_preview.setStyleSheet(
                f"background-color: rgb({red}, {green}, {blue}); border: 1px solid #666;"
            )
            self.color_preview_value.setText(
                f"rgb={red}:{green}:{blue}  "
                f"rgbf={red/255.0:.2f}:{green/255.0:.2f}:{blue/255.0:.2f}"
            )

        def sync_controls_from_state(self):
            """Update direct controls from current state values."""
            self.syncing_controls = True
            red, green, blue = state.gamma
            for channel, value in [("R", red), ("G", green), ("B", blue)]:
                self.rgb_spins[channel].setValue(value)
                self.rgb_sliders[channel].setValue(int(round(value * 100)))
            self.brightness_spin.setValue(state.brightness)
            self.brightness_slider.setValue(int(round(state.brightness * 100)))
            self.update_color_preview(
                channel_to_byte(red), channel_to_byte(green), channel_to_byte(blue)
            )
            self.syncing_controls = False

        def apply_state_from_controls(self):
            """Copy direct control values into calibration state."""
            red = self.rgb_spins["R"].value()
            green = self.rgb_spins["G"].value()
            blue = self.rgb_spins["B"].value()
            state.gamma = (red, green, blue)
            state.brightness = self.brightness_spin.value()
            output = self.output_edit.text().strip()
            state.output = output or DEFAULT_OUTPUT

        def apply_and_refresh(self, summary: str, add_to_history: bool = True):
            """Run xrandr with current state and refresh UI."""
            try:
                command_text = apply_xrandr(state, dry_run=dry_run, _verbose=_verbose)
            except RuntimeError as err:
                QMessageBox.critical(self, "xrandr error", str(err))
                self.refresh_labels(summary if add_to_history else "")
                return
            self.command_label.setText(command_text)
            self.refresh_labels(summary if add_to_history else "")

        def maybe_auto_apply(self, summary: str):
            """Apply direct changes immediately when auto-apply is on."""
            if self.auto_apply_box.isChecked() and (not self.syncing_controls):
                self.on_apply_manual_controls(summary)

        def on_rgb_slider_changed(self, channel: str, value: int):
            """Sync spin box from slider and optionally auto-apply."""
            if self.syncing_controls:
                return
            self.syncing_controls = True
            self.rgb_spins[channel].setValue(value / 100.0)
            self.syncing_controls = False
            self.maybe_auto_apply(f"Adjusted {channel} channel via slider.")

        def on_rgb_spin_changed(self, channel: str, value: float):
            """Sync slider from spin box and optionally auto-apply."""
            if self.syncing_controls:
                return
            self.syncing_controls = True
            self.rgb_sliders[channel].setValue(int(round(value * 100)))
            self.syncing_controls = False
            self.maybe_auto_apply(f"Adjusted {channel} channel via spin control.")

        def on_brightness_slider_changed(self, value: int):
            """Sync brightness spin from slider and optionally auto-apply."""
            if self.syncing_controls:
                return
            self.syncing_controls = True
            self.brightness_spin.setValue(value / 100.0)
            self.syncing_controls = False
            self.maybe_auto_apply("Adjusted brightness via slider.")

        def on_brightness_spin_changed(self, value: float):
            """Sync brightness slider from spin and optionally auto-apply."""
            if self.syncing_controls:
                return
            self.syncing_controls = True
            self.brightness_slider.setValue(int(round(value * 100)))
            self.syncing_controls = False
            self.maybe_auto_apply("Adjusted brightness via spin control.")

        def on_picker_color_changed(self, picked):
            """Apply live color-picker crosshair movement to xrandr immediately."""
            baseline_gamma = self._picker_baseline_gamma
            redf = picked.redF()
            greenf = picked.greenF()
            bluef = picked.blueF()
            new_gamma = picker_color_to_gamma(
                redf, greenf, bluef, baseline_gamma
            )
            state.gamma = new_gamma
            self.sync_controls_from_state()
            self.apply_state_from_controls()
            self.apply_and_refresh(
                "Live color picker -> "
                f"rgb={picked.red()}:{picked.green()}:{picked.blue()}, "
                f"rgbf={redf:.2f}:{greenf:.2f}:{bluef:.2f}, "
                f"gamma={gamma_to_text(state.gamma)}",
                add_to_history=False,
            )

        def on_pick_color(self):
            """Use color picker to set RGB balance with live xrandr updates."""
            red, green, blue = state.gamma
            initial_color = QColor.fromRgbF(
                channel_to_unit(red), channel_to_unit(green), channel_to_unit(blue)
            )
            self._picker_baseline_gamma = state.gamma
            self._picker_original_gamma = state.gamma
            dialog = QColorDialog(initial_color, self)
            dialog.setWindowTitle("Pick color balance")
            dialog.currentColorChanged.connect(self.on_picker_color_changed)
            accepted = bool(dialog.exec())
            if accepted:
                picked = dialog.selectedColor()
                redf = picked.redF()
                greenf = picked.greenF()
                bluef = picked.blueF()
                state.gamma = picker_color_to_gamma(
                    redf,
                    greenf,
                    bluef,
                    self._picker_baseline_gamma,
                )
                self.sync_controls_from_state()
                self.apply_state_from_controls()
                self.apply_and_refresh(
                    "Applied color-picker balance -> "
                    f"rgb={picked.red()}:{picked.green()}:{picked.blue()}, "
                    f"rgbf={redf:.2f}:{greenf:.2f}:{bluef:.2f}, "
                    f"gamma={gamma_to_text(state.gamma)}"
                )
            else:
                ## OLD:
                ## keep the last live-preview color on cancel
                state.gamma = self._picker_original_gamma
                self.sync_controls_from_state()
                self.apply_state_from_controls()
                self.apply_and_refresh("Cancelled color picker; restored previous gamma.")

        def on_apply_manual_controls(self, summary="Applied direct RGB/brightness controls."):
            """Apply current direct controls."""
            self.apply_state_from_controls()
            self.sync_controls_from_state()
            self.apply_and_refresh(summary)

        def on_apply_feedback(self):
            """Apply one feedback iteration then run xrandr."""
            output = self.output_edit.text().strip()
            state.output = output or DEFAULT_OUTPUT
            status = self.selected_key(self.status_buttons, "better")
            color_feedback = self.selected_key(self.color_buttons, "not-sure")
            brightness_feedback = self.selected_key(
                self.brightness_buttons, "not-sure"
            )
            summary, _ = state.apply_feedback(status, color_feedback, brightness_feedback)
            self.sync_controls_from_state()
            self.apply_and_refresh(summary)

        def on_reapply(self):
            """Reapply current state without changing values."""
            self.apply_state_from_controls()
            self.apply_and_refresh("Reapplied current values.")

        def on_reset_defaults(self):
            """Restore defaults and apply them."""
            state.gamma = DEFAULT_GAMMA
            state.brightness = DEFAULT_BRIGHTNESS
            state.gamma_step = INITIAL_GAMMA_STEP
            state.brightness_step = INITIAL_BRIGHTNESS_STEP
            state.last_delta = (0.0, 0.0, 0.0, 0.0)
            state.iteration = 0
            self.output_edit.setText(DEFAULT_OUTPUT)
            state.output = DEFAULT_OUTPUT
            self.status_buttons["better"].setChecked(True)
            self.color_buttons["not-sure"].setChecked(True)
            self.brightness_buttons["not-sure"].setChecked(True)
            self.sync_controls_from_state()
            self.apply_and_refresh("Defaults restored and applied.")

        def build_snapshot_text(self) -> str:
            """Return a concise, copy-friendly snapshot of current form values."""
            red, green, blue = state.gamma
            red_i, green_i, blue_i = (
                channel_to_byte(red),
                channel_to_byte(green),
                channel_to_byte(blue),
            )
            red_u, green_u, blue_u = (
                channel_to_unit(red),
                channel_to_unit(green),
                channel_to_unit(blue),
            )
            d_red, d_green, d_blue, d_brightness = state.last_delta
            status = self.selected_key(self.status_buttons, "better")
            color_feedback = self.selected_key(self.color_buttons, "not-sure")
            brightness_feedback = self.selected_key(self.brightness_buttons, "not-sure")
            history = self.history_box.toPlainText().strip()
            if not history:
                history = "(empty)"
            return "\n".join(
                [
                    f"Output: {state.output}",
                    (
                        f"Gamma (R:G:B): {red:.2f}:{green:.2f}:{blue:.2f} "
                        f"(rgb={red_i}:{green_i}:{blue_i}, "
                        f"rgbf={red_u:.2f}:{green_u:.2f}:{blue_u:.2f})"
                    ),
                    f"Brightness: {state.brightness:.2f}",
                    (
                        f"Selected feedback: status={status}, color={color_feedback}, "
                        f"brightness={brightness_feedback}"
                    ),
                    (
                        f"Last delta: R={d_red:+.2f}, G={d_green:+.2f}, B={d_blue:+.2f}, "
                        f"brightness={d_brightness:+.2f}; step={state.gamma_step:.2f}/"
                        f"{state.brightness_step:.2f}; iter={state.iteration}"
                    ),
                    f"Last command: {self.command_label.text()}",
                    "History:",
                    history,
                ]
            )

        def on_copy_snapshot(self):
            """Copy the entire form snapshot to clipboard."""
            QApplication.clipboard().setText(self.build_snapshot_text())
            self.history_box.append("Copied form snapshot to clipboard.")

        def refresh_labels(self, last_message: str):
            """Refresh labels and append status text."""
            red, green, blue = state.gamma
            red_i, green_i, blue_i = (
                channel_to_byte(red),
                channel_to_byte(green),
                channel_to_byte(blue),
            )
            red_u, green_u, blue_u = (
                channel_to_unit(red),
                channel_to_unit(green),
                channel_to_unit(blue),
            )
            d_red, d_green, d_blue, d_brightness = state.last_delta
            self.current_output_value.setText(state.output)
            self.current_gamma_value.setText(
                f"{red:.2f}:{green:.2f}:{blue:.2f}  "
                f"(rgb={red_i}:{green_i}:{blue_i}, "
                f"rgbf={red_u:.2f}:{green_u:.2f}:{blue_u:.2f})"
            )
            self.current_brightness_value.setText(f"{state.brightness:.2f}")
            self.current_delta_value.setText(
                f"R={d_red:+.2f}, G={d_green:+.2f}, B={d_blue:+.2f}, "
                f"brightness={d_brightness:+.2f}; "
                f"step={state.gamma_step:.2f}/{state.brightness_step:.2f}; iter={state.iteration}"
            )
            if last_message:
                self.history_box.append(last_message)

    return QApplication, CalibratorWindow, pyqt_version


def main() -> int:
    """Entry point."""
    debug.trace(TL.DETAILED, f"main(): script={system.real_path(__file__)}")
    options = parse_options()
    output = str(options[OUTPUT_ARG] or DEFAULT_OUTPUT)
    gamma_text = str(options[GAMMA_ARG] or gamma_to_text(DEFAULT_GAMMA))
    brightness_text = options[BRIGHTNESS_ARG]
    cli_mode = bool(options[CLI_ARG])
    dry_run = bool(options[DRY_RUN_ARG])
    verbose = bool(options[VERBOSE_ARG])

    try:
        gamma = parse_gamma(gamma_text)
    except ValueError as err:
        print(f"Error: {err}")
        return 2
    brightness = clamp(float(brightness_text), MIN_BRIGHTNESS, MAX_BRIGHTNESS)
    state = CalibrationState(output=output, gamma=gamma, brightness=brightness)

    if shutil.which("xrandr") is None and not dry_run:
        print("Error: xrandr was not found in PATH. Use --dry-run to test logic.")
        return 2

    if cli_mode:
        return run_cli_loop(state, dry_run=dry_run, verbose=verbose)

    try:
        qapplication, window_class, pyqt_version = build_pyqt_ui(
            state, dry_run=dry_run, _verbose=verbose
        )
    except ImportError:
        print("PyQt5/PyQt6 not installed; switching to CLI mode.\n")
        return run_cli_loop(state, dry_run=dry_run, verbose=verbose)

    app = qapplication(sys.argv)
    window = window_class()
    window.show()
    print(f"Running with PyQt{pyqt_version}.")
    return app.exec()


if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    raise SystemExit(main())
