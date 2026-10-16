#! /usr/bin/env python3
#
# Tests for ../postprocess_notebooks.py
#
# note:
# - Warning: this currently just mocks the BatsPP invocation.
# - It also tests over synthetic data (i.e., not real notebook tests)
#
## UPDATE 2026-10-15: fixup to use preferred output-files
## TODO1: Test for specific BatsPP output

"""Tests for postprocess_notebooks module."""

# Standard modules
import json
from pathlib import Path
import subprocess

# Installed modules
import pytest

# Local modules
from mezcla import debug
from mezcla.unittest_wrapper import TestWrapper

import postprocess_notebooks as THE_MODULE


NOTEBOOK = {
    "cells": [
        {
            "cell_type": "code",
            "execution_count": 7,
            "metadata": {
                "execution": {"iopub.status.busy": "timestamp"},
                "preserved": "cell metadata",
            },
            "outputs": [],
            "source": ["echo test\n"],
        },
        {
            "cell_type": "markdown",
            "execution_count": None,
            "metadata": {"execution": {"ignored": True}},
            "source": ["# Test notebook\n"],
        },
    ],
    "metadata": {
        "kernelspec": {"name": "bash"},
        "preserved": "notebook metadata",
    },
    "nbformat": 4,
    "nbformat_minor": 5,
}


class TestIt(TestWrapper):
    """Tests notebook metadata postprocessing and BatsPP conversion."""

    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)

    def _make_processor(self) -> tuple[THE_MODULE.NotebookPostprocessor, Path]:
        """Create an isolated notebook and postprocessor for one test."""
        notebook_dir = Path(self.temp_file).with_suffix("")
        notebook_dir.mkdir()
        notebook_path = notebook_dir / "example.ipynb"
        notebook_path.write_text(json.dumps(NOTEBOOK), encoding="utf-8")
        converter = notebook_dir / "jupyter_to_batspp.py"
        converter.write_text("", encoding="utf-8")
        processor = THE_MODULE.NotebookPostprocessor(
            notebook_dir, notebook_dir / "output-files", converter)
        return processor, notebook_path

    def test_postprocess_preserves_notebook_metadata(self):
        """Strip only execution metadata from cells."""
        debug.trace(4, f"TestIt.test_postprocess_preserves_notebook_metadata(); self={self}")
        processor, notebook_path = self._make_processor()
        processor.postprocess_notebook(notebook_path)
        result = json.loads(notebook_path.read_text(encoding="utf-8"))

        assert result["metadata"] == NOTEBOOK["metadata"]
        assert "execution_count" not in result["cells"][0]
        assert "execution" not in result["cells"][0]["metadata"]
        assert result["cells"][0]["metadata"]["preserved"] == "cell metadata"
        assert "execution_count" not in result["cells"][1]
        assert "execution" not in result["cells"][1]["metadata"]

    def test_process_all_updates_batspp_output(self):
        """Generate a BatsPP file for each normalized notebook."""
        debug.trace(4, f"TestIt.test_process_all_updates_batspp_output(); self={self}")
        processor, notebook_path = self._make_processor()
        invocations = []
        original_run = subprocess.run

        def fake_run(command, check=False, **kwargs):
            """Record the converter invocation without starting a subprocess."""
            if not isinstance(command, list):
                return original_run(command, check=check, **kwargs)
            invocations.append((command, check))
            return subprocess.CompletedProcess(command, 0)

        self.monkeypatch.setattr(THE_MODULE.subprocess, "run", fake_run)
        assert processor.process_all() == 1
        assert processor.output_dir.is_dir()
        assert invocations == [(
            [THE_MODULE.sys.executable, str(processor.converter), "--output",
             str(processor.output_dir / "example.batspp"), str(notebook_path)],
            True)]


if __name__ == '__main__':
    pytest.main([__file__])
