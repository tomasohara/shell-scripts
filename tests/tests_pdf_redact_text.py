"""Tests for pdf_redact_text."""

# Standard modules
from pathlib import Path
import tempfile

# Installed modules
import pymupdf
import pytest

# Local modules
from mezcla import debug
from mezcla import system
from mezcla.unittest_wrapper import TestWrapper, invoke_tests

THE_MODULE = None
try:
    import pdf_redact_text as THE_MODULE
except Exception:
    system.print_exception_info("pdf_redact_text import")


class TestIt(TestWrapper):
    """Tests for PDF redaction helper."""

    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)

    @staticmethod
    def _create_pdf(path: Path) -> None:
        """Create a small text PDF for testing."""
        doc = pymupdf.open()
        page = doc.new_page()
        page.insert_text((72, 72), "Name: Example Person")
        page.insert_text((72, 100), "Email: example@example.com")
        page.insert_text((72, 128), "Keep this line")
        doc.save(str(path))
        doc.close()

    def test_01_redacts_matching_line(self):
        """Matching line is gone; unrelated text remains."""
        debug.trace(4, f"TestIt.test_01_redacts_matching_line(); self={self}")

        with tempfile.TemporaryDirectory() as temp_dir:
            input_pdf = Path(temp_dir) / "input.pdf"
            output_pdf = Path(temp_dir) / "output.pdf"
            self._create_pdf(input_pdf)

            count = THE_MODULE.Helper().redact(
                str(input_pdf), str(output_pdf), r"example@example\.com"
            )

            self.do_assert(count == 1, f"Expected 1 redacted line, got {count}")
            doc = pymupdf.open(str(output_pdf))
            text = "\n".join(page.get_text() for page in doc)
            doc.close()

            self.do_assert("example@example.com" not in text, "Email remains")
            self.do_assert("Name: Example Person" in text, "Name was changed")
            self.do_assert("Keep this line" in text, "Unrelated line was changed")

    def test_02_no_match_does_not_write_output(self):
        """No match raises an error and does not create the output PDF."""
        debug.trace(4, f"TestIt.test_02_no_match_does_not_write_output(); self={self}")

        with tempfile.TemporaryDirectory() as temp_dir:
            input_pdf = Path(temp_dir) / "input.pdf"
            output_pdf = Path(temp_dir) / "output.pdf"
            self._create_pdf(input_pdf)

            with pytest.raises(ValueError, match="No matching text lines"):
                THE_MODULE.Helper().redact(
                    str(input_pdf), str(output_pdf), r"not-present"
                )

            self.do_assert(not output_pdf.exists(), "Output unexpectedly exists")

    def test_03_rejects_same_input_and_output(self):
        """Input and output must be different files."""
        debug.trace(4, f"TestIt.test_03_rejects_same_input_and_output(); self={self}")

        with tempfile.TemporaryDirectory() as temp_dir:
            input_pdf = Path(temp_dir) / "input.pdf"
            self._create_pdf(input_pdf)

            with pytest.raises(ValueError, match="must be different"):
                THE_MODULE.Helper().redact(
                    str(input_pdf), str(input_pdf), r"example"
                )


if __name__ == "__main__":
    debug.trace_current_context()
    invoke_tests(__file__)
