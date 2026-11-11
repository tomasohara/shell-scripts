#!/usr/bin/env python3
"""
Permanently redact PDF text matching a regular expression.

Example:
   pdf_redact_text.py tpo-resume-sept26.pdf upwork-resume-sept26.pdf --pattern 'tomasohara@gmail\\.com|linkedin\\.com/in/tom-o-hara-980132398|github\\.com/tomasohara'
"""

# Standard modules
import re
from pathlib import Path
from typing import Optional

# Installed modules
import pymupdf

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import misc_utils
from mezcla import system

debug.trace(5, f"global __doc__: {__doc__}")
debug.assertion(__doc__)

# Constants
TL = debug.TL

INPUT_PDF = "input-pdf"
OUTPUT_PDF = "output-pdf"
PATTERN_ARG = "pattern"
SCOPE_ARG = "scope"

DEFAULT_PATTERN = (
    r"\w+@\w+\.com"
)

RGB_FILL = system.getenv_text(
    "RGB_FILL", "1, 1, 1",
    desc="RGB tuple for redaction rectangle")

## UPDATE: Added line, span, and match scopes; facilitated by OpenAI assistant.
REDACTION_SCOPES = ("line", "span", "match")


class Helper:
    """Find matching text and permanently redact it from a PDF."""

    def redact(
        self, input_pdf: str, output_pdf: str, pattern: str,
        scope: str = "line"
    ) -> int:
        """Redact matching text at the requested scope; return the redaction count."""
        debug.trace_expr(
            TL.VERBOSE, input_pdf, output_pdf, pattern, scope,
            prefix="in Helper.redact: "
        )

        if Path(input_pdf).resolve() == Path(output_pdf).resolve():
            raise ValueError("Input and output paths must be different.")
        if scope not in REDACTION_SCOPES:
            raise ValueError(
                f"Invalid scope {scope!r}; choose one of {REDACTION_SCOPES}."
            )

        regex = re.compile(pattern, re.IGNORECASE)
        doc = pymupdf.open(input_pdf)
        redacted_count = 0
        RGB_TUPLE = tuple(map(system.to_float,
                              misc_utils.extract_string_list(RGB_FILL)))

        try:
            for page in doc:
                rects = []

                if scope == "line":
                    for block in page.get_text("dict")["blocks"]:
                        for line in block.get("lines", []):
                            text = "".join(
                                span["text"] for span in line.get("spans", [])
                            )
                            if not regex.search(text):
                                continue

                            rect = pymupdf.Rect(line["bbox"])
                            debug.trace(5, f"matches {text} at {rect}")
                            # Add a small margin so glyph edges are covered too.
                            rect.x0 = max(page.rect.x0, rect.x0 - 2)
                            rect.y0 = max(page.rect.y0, rect.y0 - 1)
                            rect.x1 = min(page.rect.x1, rect.x1 + 2)
                            rect.y1 = min(page.rect.y1, rect.y1 + 1)
                            rects.append(rect)
                else:
                    for block in page.get_text("rawdict")["blocks"]:
                        for line in block.get("lines", []):
                            spans = line.get("spans", [])

                            if scope == "span":
                                for span in spans:
                                    text = "".join(
                                        char["c"]
                                        for char in span.get("chars", [])
                                    )
                                    if regex.search(text):
                                        rects.append(
                                            pymupdf.Rect(span["bbox"])
                                        )
                                continue

                            # Match the regex against the line while retaining
                            # the bounding box for each character.
                            char_data = []
                            for span in spans:
                                for char in span.get("chars", []):
                                    value = char["c"]
                                    char_rect = pymupdf.Rect(char["bbox"])
                                    for character in value:
                                        char_data.append((character, char_rect))

                            text = "".join(value for value, _ in char_data)
                            for match in regex.finditer(text):
                                matched_chars = char_data[
                                    match.start():match.end()
                                ]
                                if not matched_chars:
                                    continue

                                rect = pymupdf.Rect(matched_chars[0][1])
                                for _, char_rect in matched_chars[1:]:
                                    rect |= char_rect
                                rects.append(rect)

                for rect in rects:
                    page.add_redact_annot(
                        rect, fill=RGB_TUPLE, cross_out=False
                    )

                if rects:
                    page.apply_redactions()
                    redacted_count += len(rects)

            if redacted_count == 0:
                raise ValueError(
                    "No matching text lines found; output PDF was not written."
                )

            doc.save(output_pdf, garbage=4, deflate=True)
        finally:
            doc.close()

        return redacted_count


class Script(Main):
    """Redact identifying text from a PDF."""

    input_pdf: Optional[str] = None
    output_pdf: Optional[str] = None
    pattern: str = DEFAULT_PATTERN
    scope: str = "line"
    helper: Optional[Helper] = None

    def setup(self) -> None:
        """Read and validate command-line arguments."""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")

        self.input_pdf = str(self.get_parsed_argument(INPUT_PDF))
        self.output_pdf = str(self.get_parsed_argument(OUTPUT_PDF))
        self.pattern = str(
            self.get_parsed_option(PATTERN_ARG, self.pattern)
        )
        self.scope = str(self.get_parsed_option(SCOPE_ARG, self.scope))
        if self.scope not in REDACTION_SCOPES:
            raise ValueError(
                f"Invalid scope {self.scope!r}; "
                f"choose one of {REDACTION_SCOPES}."
            )
        self.helper = Helper()

        # Validate the regex before starting PDF processing.
        re.compile(self.pattern)

    def run_main_step(self) -> None:
        """Process the specified PDF files."""
        debug.trace(TL.VERBOSE, "Script.run_main_step()")

        assert self.input_pdf is not None
        assert self.output_pdf is not None
        assert self.helper is not None

        count = self.helper.redact(
            self.input_pdf, self.output_pdf, self.pattern, scope=self.scope
        )
        print(f"Redacted {count} item(s) -> {self.output_pdf}")


def main() -> None:
    """Entry point."""
    debug.trace(TL.DETAILED, f"main(): script={system.real_path(__file__)}")

    app = Script(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        positional_arguments=[INPUT_PDF, OUTPUT_PDF],
        text_options=[
            (PATTERN_ARG, "Regex identifying text to redact"),
            (SCOPE_ARG, "Redaction scope: line, span, or match"),
        ],
        float_options=None,
    )
    app.run()


if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    main()
