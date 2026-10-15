#! /usr/bin/env python3
##
## Postprocesses Jupyter notebook tests after they have been run.
## NOTE: Added with assistance from GitHub Copilot CLI using GPT-5.6 Terra.
##..............................................................................

"""
Strip per-cell execution metadata from Jupyter notebook tests and refresh their
BatsPP equivalents.

The postprocessor preserves all notebook-level metadata and all cell metadata
other than ``execution``. It writes generated BatsPP files to ``tests/output``
by default.

Usage:
    {script} [--notebook-dir DIRECTORY] [--output-dir DIRECTORY]
"""

# Standard modules
import json
from pathlib import Path
import subprocess
import sys
from typing import Any

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main

debug.trace(5, f"global __doc__: {__doc__}")
debug.assertion(__doc__)

# Command-line labels
NOTEBOOK_DIR = "notebook-dir"
OUTPUT_DIR = "output-dir"

# Defaults
DEFAULT_NOTEBOOK_DIR = "tests"
DEFAULT_OUTPUT_DIR = "tests/output"
JUPYTER_EXTENSION = ".ipynb"
BATSPP_EXTENSION = ".batspp"
TL = debug.TL


class NotebookPostprocessor:
    """Normalizes notebook cell metadata and generates BatsPP test files."""

    def __init__(self, notebook_dir: Path, output_dir: Path,
                 converter: Path) -> None:
        """Initialize processing paths and the Jupyter-to-BatsPP converter."""
        self.notebook_dir = notebook_dir
        self.output_dir = output_dir
        self.converter = converter

    def find_notebooks(self) -> list[Path]:
        """Return the immediate notebook files in the configured test directory."""
        if not self.notebook_dir.is_dir():
            raise FileNotFoundError(f"Notebook directory not found: {self.notebook_dir}")
        notebooks = sorted(self.notebook_dir.glob(f"*{JUPYTER_EXTENSION}"))
        debug.trace_expr(TL.DETAILED, notebooks, prefix="find_notebooks(): ")
        return notebooks

    @staticmethod
    def strip_cell_execution_metadata(notebook: dict[str, Any]) -> None:
        """Remove execution metadata from every cell without changing notebook metadata."""
        cells = notebook.get("cells")
        if not isinstance(cells, list):
            raise ValueError("Notebook is missing a cells array")
        for cell in cells:
            if not isinstance(cell, dict):
                raise ValueError("Notebook contains a non-object cell")
            cell.pop("execution_count", None)
            metadata = cell.get("metadata")
            if metadata is not None:
                if not isinstance(metadata, dict):
                    raise ValueError("Notebook cell metadata is not an object")
                metadata.pop("execution", None)

    def postprocess_notebook(self, notebook_path: Path) -> None:
        """Strip execution metadata from NOTEBOOK_PATH while retaining its contents."""
        try:
            notebook = json.loads(notebook_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            raise ValueError(f"Invalid JSON notebook: {notebook_path}") from exc
        if not isinstance(notebook, dict):
            raise ValueError(f"Notebook is not an object: {notebook_path}")
        self.strip_cell_execution_metadata(notebook)
        notebook_path.write_text(
            json.dumps(notebook, indent=1, ensure_ascii=True) + "\n",
            encoding="utf-8")

    def update_batspp_output(self, notebook_path: Path) -> None:
        """Generate the BatsPP equivalent of NOTEBOOK_PATH in the output directory."""
        output_path = self.output_dir / f"{notebook_path.stem}{BATSPP_EXTENSION}"
        subprocess.run(
            [sys.executable, str(self.converter), "--output", str(output_path),
             str(notebook_path)],
            check=True)

    def process_all(self) -> int:
        """Normalize all test notebooks and refresh their generated BatsPP files."""
        if not self.converter.is_file():
            raise FileNotFoundError(f"Jupyter-to-BatsPP converter not found: {self.converter}")
        self.output_dir.mkdir(parents=True, exist_ok=True)
        notebooks = self.find_notebooks()
        for notebook_path in notebooks:
            debug.trace(TL.DETAILED, f"Processing notebook: {notebook_path}")
            self.postprocess_notebook(notebook_path)
            self.update_batspp_output(notebook_path)
        return len(notebooks)


class Script(Main):
    """Command-line interface for notebook postprocessing."""

    notebook_dir = DEFAULT_NOTEBOOK_DIR
    output_dir = DEFAULT_OUTPUT_DIR

    def setup(self) -> None:
        """Read and validate command-line options."""
        self.notebook_dir = self.get_parsed_option(NOTEBOOK_DIR, self.notebook_dir)
        self.output_dir = self.get_parsed_option(OUTPUT_DIR, self.output_dir)

    def run_main_step(self) -> None:
        """Postprocess notebooks and report the number of refreshed test files."""
        processor = NotebookPostprocessor(
            Path(self.notebook_dir),
            Path(self.output_dir),
            Path(__file__).with_name("jupyter_to_batspp.py"))
        count = processor.process_all()
        print(f"Postprocessed {count} notebook test files.")


def main() -> None:
    """Run the notebook postprocessor."""
    app = Script(
        description=__doc__.format(script=gh.basename(__file__)),
        manual_input=True,
        auto_help=False,
        text_options=[
            (NOTEBOOK_DIR, "Directory containing Jupyter notebook tests"),
            (OUTPUT_DIR, "Directory for generated BatsPP tests"),
        ])
    app.run()


if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    main()
