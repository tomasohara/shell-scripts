#! /usr/bin/env python
# 
# DATE: 2023-07-28 (08:44 +05:45 GMT) | INDEV: batspp_to_jupyter_EXPERIMENTAL.py
# DATE: 2023-11-01 (22:00 +05:45 GMT) | batspp_to_jupyter.py

# Converts batspp based testfiles to Jupyter Notebook 
# Uses nbformat for batspp_to_ipynb conversion (https://pypi.org/project/nbformat/)
# TLDR: Reverses the work of jupyter_to_batspp.py
# Author: Aviyan Acharya (avyn.xyz@gmail.com)

"""
Converts batspp based testfiles to Jupyter Notebook 
Uses nbformat for txt2ipynb conversion (https://pypi.org/project/nbformat/)
"""

# Standard packages
import os

# Installed packages
import nbformat

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system

# Constants 0 (Command Line Labels)
BATSPP_FILE = "batspp-file"
OUTPUT = "output"
VERBOSE = "verbose"
SOURCE = "source"
TXT = "txt"

# Constants I (Script Initials)
TL = debug.TL

# Constants II (Other Constants)
EXTENSION_JUPYTER = "ipynb"
EXTENSION_BATSPP = "batspp"
EXTENSION_TESTFILES = ["batspp", "test", "txt"]
DIR_JUPYTER_STORE = "test-to-jupyter"
KERNEL_NOTEBOOK = "bash_kernel"

# Environment Variables
output_path = system.getenv_text("OUTPUT_PATH", ".",
                description=f"Target output .{EXTENSION_BATSPP} file path (Default: .)")

class BatsppToJupyter(Main):
    """Converts Batspp tests to Jupyter tests"""
    output = ""
    batspp_file = ""
    verbose = None
    txt = None

    def get_entered_text(self, label: str, default: str = "") -> str:
        """
        Return entered LABEL var/arg text by command-line or environment variable,
        also can be specified a DEFAULT value
        """
        result = (self.get_parsed_argument(label=label.lower()) or
                system.getenv_text(var=label.upper()))
        result = result if result else default
        debug.trace(7, f'BatsppToJupyter.get_entered_text(label={label}) => {result}')
        return result

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(TL.DETAILED, "Script.setup(): self={s}", s=self)
        self.batspp_file = self.get_entered_text(BATSPP_FILE, self.batspp_file)
        self.output = self.get_parsed_argument(OUTPUT, self.output)
        self.verbose = self.get_parsed_option(VERBOSE, not self.verbose) 
        self.txt = self.get_parsed_option(TXT, self.txt) 
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def jupyter_store_exists(self):
        """Checks if directory to store Jupyter file exists"""
        result =  gh.file_exists(DIR_JUPYTER_STORE)
        debug.trace(7, f'BatsppToJupyter.jupyter_store_exists() => {result}')
        return result
    
    def get_seperating_index(self, arr, source=False):
        """Seperates the index of given array acc. to source (bool)"""
        result = []
        for index, line in enumerate(arr):
            if source:
                if line and line[0] in ["$", "#"]:
                    result.append(index)
            else:
                if not line or line[0] not in ["$", "#"]:
                    result.append(index)
        debug.trace(7, f"BatsppToJupyter.get_seperating_index({arr, source}) => {result}")
        return result
    
    def group_cell_items(self, arr):
        """Performs grouping of cell items"""
        result = []
        current_group = [arr[0]]

        for i in range(1, len(arr)):
            if arr[i] - arr[i-1] == 1:
                current_group.append(arr[i])
            else:
                result.append(current_group)
                current_group = [arr[i]]
        result.append(current_group)
        debug.trace(7, f"BatsppToJupyter.group_cell_items({arr}) => {result}")
        return result
    
    def remove_prompt_sign(self, line:str, source=True):
        """Remove any prompt sign ($) present from the line"""
        result = line[2:] if (line.startswith("$") and source) else line
        debug.trace(7, f"BatsppToJupyter.remove_prompt_sign({line, source}) => {result}")
        return result
    
    def return_test_basename(self, test:str, add_ipynb_extension=True):
        """Returns basename of the testfile"""
        basename = os.path.splitext(test)[0]
        result = basename if not add_ipynb_extension else (basename+".ipynb")
        debug.trace(7, f"BatsppToJupyter.remove_prompt_sign({test, add_ipynb_extension}) => {result}")
        return result
    
    def append_batspp_to_jupyter_dict(self, dict:dict, group_arr, temp_arr, source=True):
        """Appends data to SOURCE or OUTPUT of Jupyter Notebook"""
        dict_init = dict.copy()
        dict_key = SOURCE if source else OUTPUT
        for index_arr in group_arr:
            if not isinstance(index_arr, (list, tuple)):
                continue
            index_content = []
            for i in index_arr:
                content = self.remove_prompt_sign(temp_arr[i], source) + "\n"
                index_content.append(content)
            dict[dict_key].append(index_content)
        debug.trace(7, f"BatsppToJupyter.append_batspp_to_jupyter_dict({dict_key}, {dict_init}) => {dict}")
        # return dict
    
    def is_equal_length_dict(self, dict):
        """Checks if the length of dictionary is equal to dict values"""
        length_arr = [len(value) for value in dict.values()]
        result = all(length == length_arr[0] for length in length_arr)
        debug.trace(7, f"BatsppToJupyter.is_equal_length_dict({dict}) => {result}")
        return result

    def return_cell_count(self, dict):
        """Returns count of the Jupyter cells"""
        result = len(dict[SOURCE]) if self.is_equal_length_dict(dict) else -1
        debug.trace(7, f"BatsppToJupyter.return_cell_count({dict}) => {result}")
        return result

    def add_cell_contents(self, notebook, source, output):
        """Adds contents to the cells of Jupyter notebook"""
        code_cell = nbformat.v4.new_code_cell(source=source)
        notebook.cells.append(code_cell)
        result = nbformat.v4.new_output(output_type="display_data",
                                        data={"text/plain":output})
        code_cell.outputs.append(result)
        debug.trace(7, f"BatsppToJupyter.add_cell_contents{notebook}, {source}, {output}) => {code_cell}")

    def msg_success_convert(self, str_test_init:str, str_test_final:str):
        result = f"Converted {str_test_init} to {str_test_final} successfully."
        debug.trace(7, f"BatsppToJupyter.msg_success_convert({str_test_init}, {str_test_final}) => {result}")
        return result
    
    def return_output_path(self):
        """Returns appropriate Jupyter testfile path acc. to given options"""
        temp = self.return_test_basename(self.output, True) if self.output else self.return_test_basename(self.batspp_file, True)
        result = str(os.path.splitext(temp)[0]+ "_" + EXTENSION_JUPYTER + "." + EXTENSION_TESTFILES[-1]) if self.txt else temp
        debug.trace(7, f"BatsppToJupyter.return_output_path() => {result}\n({self.batspp_file}, output={self.output}, txt={self.txt})")
        return result

    def process_nb(self):
        """Assembles the functions and performs the processing"""
        batspp_path = self.batspp_file
        output_path = self.return_output_path()
        text_lines = gh.read_lines(batspp_path)
        
        b2j_dict = {SOURCE:[], OUTPUT:[]}
        nb = nbformat.v4.new_notebook()

        text_lines_temp1 = text_lines.copy()
        text_lines_temp2 = text_lines.copy()
        arr_output_index = self.get_seperating_index(text_lines_temp1, source=False)
        arr_source_index = self.get_seperating_index(text_lines_temp1, source=True)
        arr_output_group = self.group_cell_items(arr_output_index)
        arr_source_group = self.group_cell_items(arr_source_index)

        self.append_batspp_to_jupyter_dict(b2j_dict, arr_output_group, text_lines_temp2, source=False)
        self.append_batspp_to_jupyter_dict(b2j_dict, arr_source_group, text_lines_temp2, source=True)
        
        cell_count = self.return_cell_count(dict=b2j_dict)
        
        if self.is_equal_length_dict(b2j_dict):
            for index in range(cell_count):
                self.add_cell_contents(notebook=nb, source=b2j_dict[SOURCE][index], output=b2j_dict[OUTPUT][index])
            nbformat.write(nb, output_path)

        print(self.msg_success_convert(batspp_path, output_path))

    def run_main_step(self):
        """Process main script"""
        batspp_content = system.read_file(self.batspp_file)
        debug.trace_expr(5, batspp_content)
        debug.assertion(batspp_content != '', f'Error: {self.batspp_file} not found or is empty')
        try:
            is_batspp_file = any(self.batspp_file.endswith(ext) for ext in EXTENSION_BATSPP)
        except:
            is_batspp_file = False
            # Returns extension of self.batspp_file
            ext = os.path.splitext(self.batspp_file)[-1][1:]
            system.print_exception_info(f"Invalid Extension: {ext}, not a BATSPP testfile")
        if is_batspp_file:
            self.process_nb()
        if self.verbose:
            final_stdout = f"Resulting ipynb file saved on {self.return_output_path()}"
            system.print_stderr("=" * len(final_stdout))
            system.print_stderr(final_stdout)

def main():
    """Entry point"""
    app = BatsppToJupyter(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        auto_help=False,
        multiple_files=False,
        text_options=[(OUTPUT, "Target output .ipynb file path")],
        boolean_options=[(VERBOSE, "Show verbose debug"),
                         (TXT, "Returns output in text file")],
        positional_arguments=[(BATSPP_FILE, "Test batspp path")]
        )
    app.run()

#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    main()