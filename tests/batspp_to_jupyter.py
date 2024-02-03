#! /usr/bin/env python
# 
# 2023-07-28 (08:44 +05:45 GMT) | INDEV: batspp_to_jupyter_EXPERIMENTAL.py
# 2023-11-01 (22:00 +05:45 GMT) | BAD: batspp_to_jupyter.py
# | IMPROVEMENT-VERSION: batspp_to_jupyter.py

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
# from mezcla.my_regex import my_re (NOT USED) 
from mezcla import system

# Constants 0 (Command Line Labels)
OPT_BATSPP_FILE = "batspp-file"
OPT_OUTPUT = "output"
OPT_VERBOSE = "verbose"
OPT_SOURCE = "source"
OPT_TXT = "txt"

# Constants I (Script Initials)
TL = debug.TL

# Constants II (Other Constants)
EXTENSION_JUPYTER = "ipynb"
EXTENSION_BATSPP = "batspp"
EXTENSION_TESTFILES = ["batspp", "test", "txt"]
DIR_JUPYTER_STORE = "test-to-jupyter"
KERNEL_NOTEBOOK = "bash_kernel"
SOURCE = OPT_SOURCE
OUTPUT = OPT_OUTPUT

# Environment Variables
OUTPUT_PATH = system.getenv_text("OUTPUT_PATH", ".",
                                description=f"Target output .{EXTENSION_BATSPP} file path (Default: .)")
JUPYTER_STORAGE = system.getenv_text("JUPYTER_STORAGE", DIR_JUPYTER_STORE,
                                    description=f"Directory to store Jupyter testfile (.{EXTENSION_JUPYTER})output")

class BatsppToJupyter:
    """Consists of functions necessary for the creation of Jupyter notebook from BATSPP testfiles"""
    
    def __init__(
        self,
        OPT_BATSPP_FILE,
        OPT_OUTPUT,
        OPT_VERBOSE,
        OPT_SOURCE,
        OPT_TXT
    ):
        """Initializer for class: BatsppToJupyter"""
        self.OPT_BATSPP_FILE = OPT_BATSPP_FILE
        self.OPT_OUTPUT = OPT_OUTPUT
        self.OPT_VERBOSE = OPT_VERBOSE
        self.OPT_SOURCE = OPT_SOURCE
        self.OPT_TXT = OPT_TXT

    def jupyter_store_exists(self):
        """Checks if directory to store Jupyter file exists"""
        result =  gh.file_exists(JUPYTER_STORAGE)
        debug.trace(7, f'BatsppToJupyter.jupyter_store_exists() => {result}')
        return result
    
    ## OLD/BAD
    # def get_seperating_index(self, arr_batspp_contents:list[str], source:bool=False):
    #     """Returns an array of line indices for cell source or output based on the 'source' argument
    #     Example:
    #         arr = ['# Simple alias test', '', '# Global Setup', "$ alias count-words='wc -w'", '', '$ echo abc def ght | count-words', '3', '', '$ echo "Hi Mom"', 'Hi Mom']
    #         get_seperating_index(arr, True) => [0, 2, 3, 5, 8] // CELL SOURCE (INPUT)
    #         get_seperating_index(arr, False) => [1, 4, 6, 7, 9] // CELL OUTPUT
    #     """
    #     result = []
    #     for index, line in enumerate(arr_batspp_contents):
    #         if source:
    #             if line and line[0] in ["$", "#"]:
    #                 result.append(index)
    #         else:
    #             if not line or line[0] not in ["$", "#"]:
    #                 result.append(index)
    #     debug.trace(7, f"BatsppToJupyter.get_seperating_index({arr_batspp_contents}, {source}) => {result}")
    #     return result
    
    # def group_cell_items(self, line_indices:list[int]):
    #     """Returns array of sublists of consecutive indices, seperating them when a gap is present
    #     Example:
    #         arr = [0,1,2,4,5,6,7,9,11,12,15]
    #         group_cell_items(arr) => [[0,1,2],[4,5,6,7],[9],[11,12],[15]]
    #     """
    #     result = []
    #     current_group = [line_indices[0]]
    #     for i in range(1, len(line_indices)):
    #         if line_indices[i] - line_indices[i-1] == 1:
    #             current_group.append(line_indices[i])
    #         else:
    #             result.append(current_group)
    #             current_group = [line_indices[i]]
    #     result.append(current_group)
    #     debug.trace(7, f"BatsppToJupyter.group_cell_items({line_indices}) => {result}")
    #     return result
    
    def remove_prompt_sign(self, line:str, source:bool=True):
        """Remove any prompt sign ($) present from the line
        Example:
            line = "$ alias count-words='wc -w'" 
            remove_prompt_sign(line, True) => "alias count-words='wc -w'"
        - Note: Designed for command lines only (actually removes "$ " from the line)
        """
        result = line[2:] if (line.startswith("$ ") and source) else line
        debug.trace(7, f"BatsppToJupyter.remove_prompt_sign({line, source}) => {result}")
        return result

    ## OLD/BAD
        
    # ## BAD: Fixme
    # def append_batspp_to_jupyter_dict(self, batspp_to_jyputer_dict:dict, group_arr:list, temp_arr:list, source:bool=True):
    #     """Appends data to SOURCE or OUTPUT of Jupyter Notebook"""
    #     dict_init = batspp_to_jyputer_dict.copy()
    #     dict_key = SOURCE if source else OUTPUT
    #     for index_arr in group_arr:
    #         index_content = []
    #         for i in index_arr:
    #             content = self.remove_prompt_sign(temp_arr[i], source) + "\n"
    #             index_content.append(content)
    #         batspp_to_jyputer_dict[dict_key].append(index_content)
    #     debug.trace(7, f"BatsppToJupyter.append_batspp_to_jupyter_dict({dict_key}, {dict_init}) => {batspp_to_jyputer_dict}")
    
    def is_equal_length_dict(self, batspp_to_jupyter_dict:dict):
        """Checks if the length of dictionary is equal to dict values
        Created to check if each cell source had their respective output
        """
        length_arr = [len(value) for value in batspp_to_jupyter_dict.values()]
        result = all(length == length_arr[0] for length in length_arr)
        debug.trace(7, f"BatsppToJupyter.is_equal_length_dict({batspp_to_jupyter_dict}) => {result}")
        return result

    def return_cell_count(self, batspp_to_jupyter_dict:dict):
        """Returns count of the Jupyter cells"""
        result = len(batspp_to_jupyter_dict[SOURCE]) if self.is_equal_length_dict(batspp_to_jupyter_dict) else -1
        debug.trace(7, f"BatsppToJupyter.return_cell_count({batspp_to_jupyter_dict}) => {result}")
        return result

    def add_cell_contents(self, notebook, source:str, output:str):
        """Adds contents to the cells of Jupyter notebook"""
        code_cell = nbformat.v4.new_code_cell(source=source)
        notebook.cells.append(code_cell)
        result = nbformat.v4.new_output(output_type="display_data",
                                        data={"text/plain":output})
        code_cell.outputs.append(result)
        debug.trace(7, f"BatsppToJupyter.add_cell_contents{notebook}, {source}, {output}) => {code_cell}")

    def msg_success_convert(self, testfile_init:str, testfile_final:str):
        """
        Returns a message indicating successful conversion
        Example:
            testfile_init = "hello-world.batspp"
            testfile_final = "hello-world.ipynb"
            msg_success_convert(testfile_init, testfile_final) => "Converted hello-world.batspp to hello-world.ipynb successfully."
        """
        result = f"Converted {testfile_init} to {testfile_final} successfully."
        debug.trace(7, f"BatsppToJupyter.msg_success_convert({testfile_init}, {testfile_final}) => {result}")
        return result
    
    def return_output_path(self):
        """
        Returns appropriate Jupyter testfile path for output acc. to given argument options
        Example:
            self.OPT_BATSPP_FILE = "hello-world.ipynb"
            self.output = "hello-world-test1"
            - IF self.txt == False:
                return_output_path() => hello-world-test1.ipynb
            - ELSE:
                return_output_path() => hello-world-test1-ipynb.txt
        - Note: If self.output not given:
            - IF self.txt == False:
                return_output_path() => hello-world.ipynb
            - ELSE:
                return_output_path() => hello-world-ipynb.txt
        """
        basename_batspp_file = gh.basename(self.OPT_BATSPP_FILE, extension=f".{EXTENSION_BATSPP}")
        basename_ipynb_file = gh.basename(self.OPT_OUTPUT) if self.OPT_OUTPUT != "" else basename_batspp_file
        result = (basename_ipynb_file + f"-{EXTENSION_JUPYTER}.{EXTENSION_TESTFILES[2]}") if self.OPT_TXT else (basename_ipynb_file + f".{EXTENSION_JUPYTER}")
        debug.trace(7, f"BatsppToJupyter.return_output_path() => {result}; --batspp-file={self.OPT_BATSPP_FILE}, --output={self.OPT_OUTPUT}, --txt={self.OPT_TXT}")
        return result

    def is_source_line(self, line:str):
        """
        Returns True if the line is a Jupyter notebook source (or input)
        - Note: Detects "$ " for the case of Bash command-line
        """
        result = line.startswith("$ ") or line.startswith("#")
        debug.trace(7, f"BatsppToJupyter.is_source_line({line}) => {result}")
        return result
    
    def create_batspp_to_jupyter_dict(self, test_lines:list[str]) -> dict:
        """Assigns source and output contents for Jupyter Notebook and returns a dictionary"""
        arr_source_group = []
        arr_output_group = []
        b2j_dict = {}

        # Initialize with the first line
        is_source = self.is_source_line(test_lines[0])
        current_group = [test_lines[0]]

        for line in test_lines[1:]:
            line_is_source = self.is_source_line(line)
            line_filtered = self.remove_prompt_sign(line)

            if is_source == line_is_source:
                current_group.append(line_filtered)
            else:
                if is_source:
                    arr_source_group.append(current_group)
                else:
                    arr_output_group.append(current_group)

                current_group = [line_filtered]
                is_source = line_is_source

        # Add the last group to the appropriate list
        if is_source:
            arr_source_group.append(current_group)
        else:
            arr_output_group.append(current_group)

        b2j_dict[SOURCE] = arr_source_group
        b2j_dict[OUTPUT] = arr_output_group


        debug.trace(7, f"BatsppToJupyter.create_batspp_to_jupyter_dict({test_lines}) => {b2j_dict}")
        return b2j_dict

    def process_nb(self):
        """Assembles the functions and performs the processing"""
        batspp_path = self.OPT_BATSPP_FILE
        output_path = self.return_output_path()
        test_lines = gh.read_lines(batspp_path)
        nb = nbformat.v4.new_notebook()

        b2j_dict = self.create_batspp_to_jupyter_dict(test_lines)
        cell_count = self.return_cell_count(b2j_dict)

        if self.is_equal_length_dict(b2j_dict):
            for index in range(cell_count):
                self.add_cell_contents(notebook=nb, source=b2j_dict[SOURCE][index], output=b2j_dict[OUTPUT][index])
            nbformat.write(nb, output_path)

        print(self.msg_success_convert(batspp_path, output_path))


        ## OLD/BAD: This code was really "crap"
        # arr_output_index = self.get_seperating_index(text_lines, source=False)
        # arr_source_index = self.get_seperating_index(text_lines, source=True)
        # arr_output_group = self.group_cell_items(arr_output_index)
        # arr_source_group = self.group_cell_items(arr_source_index)

        # self.append_batspp_to_jupyter_dict(b2j_dict, arr_output_group, text_lines, source=False)
        # self.append_batspp_to_jupyter_dict(b2j_dict, arr_source_group, text_lines, source=True)

#   END OF BatsppToJupyter 
#   =================================================================

class RunScriptB2J(Main):
    """Adhoc script class (e.g., no I/O loop): just parses args"""
    output = ""
    batspp_file = ""
    source = ""
    txt = None
    verbose = None

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(TL.DETAILED, "RunScript.setup(): self={s}", s=self)
        self.batspp_file = self.get_parsed_argument(OPT_BATSPP_FILE, self.batspp_file)
        self.output = self.get_parsed_argument(OPT_OUTPUT, self.output)
        self.verbose = self.get_parsed_option(OPT_VERBOSE, not self.verbose)
        self.txt = self.get_parsed_option(OPT_TXT, self.txt)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def run_main_step(self):
        """Main processing step"""
        debug.trace_fmtd(TL.DETAILED, "RunScript.run_main_setup(): self={s}", s=self)
        batspp_to_jupyter = BatsppToJupyter(
            self.batspp_file,
            self.output,
            self.verbose,
            self.source,
            self.txt)

        batspp_content = system.read_file(self.batspp_file)
        debug.trace_expr(5, batspp_content)
        debug.assertion(batspp_content != "", f"Error: {self.batspp_file} not found or is empty")
        try:
            is_batspp_file = any(self.batspp_file.endswith(extension) for extension in EXTENSION_BATSPP)
        except:
            is_batspp_file = False
            extension = os.path.splitext(self.batspp_file)[-1][1:]
            system.print_exception_info(f"Invalid Extension: {extension} is not a BATSPP testfile")
        if is_batspp_file:
            batspp_to_jupyter.process_nb()
        if self.verbose:
            final_stdout = f"Resulting ipynb file saved on {batspp_to_jupyter.return_output_path()}"
            system.print_stderr("=" * len(final_stdout))
            system.print_stderr(final_stdout)

#   END OF RunScriptB2J
#   =================================================================

def main():
    """Entry point"""
    app = RunScriptB2J(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=False,
        manual_input=True,
        auto_help=False,
        multiple_files=False,
        positional_arguments=[
            (OPT_BATSPP_FILE, "Test batspp path")
            ],
        text_options=[
            (OPT_OUTPUT, "Target output .ipynb file path")
            ],
        boolean_options=[
            (OPT_VERBOSE, "Show verbose debug"),
            (OPT_TXT, "Returns output in text file")
            ],
        )
    app.run()

#   END OF main()
#   =================================================================

if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace_fmt(4, "Environment options: {eo}",
                    eo=system.formatted_environment_option_descriptions())
    main()
