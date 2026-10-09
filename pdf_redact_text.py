#!/usr/bin/env python3
"""
Permanently redact PDF text lines matching a regular expression.

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

DEFAULT_PATTERN = (
    r"\w+@\w+\.com"
)

RGB_FILL = system.getenv_text(
    "RGB_FILL", "1, 1, 1",
    desc="RGB tuple for redaction rectangle")

class Helper:
    """Find matching text lines and permanently redact them from a PDF."""

    def redact(self, input_pdf: str, output_pdf: str, pattern: str) -> int:
        """Redact every extracted text line matching PATTERN; return line count."""
        debug.trace_expr(
            TL.VERBOSE, input_pdf, output_pdf, pattern,
            prefix="in Helper.redact: "
        )

        if Path(input_pdf).resolve() == Path(output_pdf).resolve():
            raise ValueError("Input and output paths must be different.")

        regex = re.compile(pattern, re.IGNORECASE)
        doc = pymupdf.open(input_pdf)
        redacted_count = 0
        RGB_TUPLE = tuple(map(system.to_float,
                              misc_utils.extract_string_list(RGB_FILL)))

        try:
            for page in doc:
                rects = []

                # Group spans into PDF text lines, then match the complete line.
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

                for rect in rects:
                    page.add_redact_annot(
                        ## OLD: rect, fill=(1, 1, 1), cross_out=False
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
    helper: Optional[Helper] = None

    def setup(self) -> None:
        """Read and validate command-line arguments."""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")

        self.input_pdf = str(self.get_parsed_argument(INPUT_PDF))
        self.output_pdf = str(self.get_parsed_argument(OUTPUT_PDF))
        self.pattern = str(
            self.get_parsed_option(PATTERN_ARG, self.pattern)
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
            self.input_pdf, self.output_pdf, self.pattern
        )
        print(f"Redacted {count} line(s) -> {self.output_pdf}")


def main() -> None:
    """Entry point."""
    debug.trace(TL.DETAILED, f"main(): script={system.real_path(__file__)}")

    app = Script(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        positional_arguments=[INPUT_PDF, OUTPUT_PDF],
        text_options=[
            (PATTERN_ARG, "Regex identifying a text line to redact")
        ],
        float_options=None,
    )
    app.run()


if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    main()
