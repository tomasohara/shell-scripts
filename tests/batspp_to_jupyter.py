#!/usr/bin/env python3

## DATE: 2023-07-28 (08:44 +05:45 GMT)
## INDEV: batspp_to_jupyter.py

## Converts batspp based testfiles to Jupyter Notebook 
## Uses nbformat for txt2ipynb conversion (https://pypi.org/project/nbformat/)
## TLDR: Reverses the work of jupyter_to_batspp.py
## TODO: (A LOT!)
## 1. Generalize the script
## 2. Convert to a class based approach
## 3. Set the default kernel to bash_kernel
##
## Author: Aviyan Acharya

# Standard Libraries
import os
import json

# Installed Libraries 
import nbformat

# Local Libraries
from mezcla import debug
from mezcla.main import Main
from mezcla import system
from mezcla.my_regex import my_re
from mezcla import glue_helpers as gh

# Command-line labels
OUTPUT       = 'output'
VERBOSE      = 'verbose'
SOURCE       = 'source'

# Other constants
JUPYTER_EXTENSION = 'ipynb'
BATSPP_EXTENSION  = 'batspp'
TESTFILE_EXTENSION = ['test', 'txt', 'batspp']
JUPYTER_STORE = "test_to_jupyter"
NOTEBOOK_KERNEL = "bash_kernel"

## Conditions: Storage exists
jupyter_store_exists = gh.file_exists(JUPYTER_STORE)

# PREREQUISITES: Read the plain text file
TEXT_FILE_PATH = "dir-aliases-test-revised-v2.sh"

# 0. Duplicate text_lines array when required
def duplicate_text_lines():
    return text_lines.copy()

def return_test_basename(test_name:str, add_ipynb_extenstion=False):
    basename = os.path.splitext(test_name)[0]
    return basename if not add_ipynb_extenstion else (basename+".ipynb")

def extract_test_content(test_name:str):
    return gh.read_lines(test_name)

text_lines = extract_test_content(TEXT_FILE_PATH)
CONVERTED_JUPYTER_PATH = return_test_basename(TEXT_FILE_PATH, True)

# 1. Seperating index of test cells: seperates output index (default)
def get_separating_index(array, source=False):
    separating_index = []
    for index, line in enumerate(array):
        if source:
            if line and line[0] in ["$", "#"]:
                separating_index.append(index)
        else:
            if not line or line[0] not in ["$", "#"]:
                separating_index.append(index)
    return separating_index

# 2. Grouping of seperated index: consecutive index = single group
def group_cell_items(input_list):
    result = []
    current_group = [input_list[0]]

    for i in range(1, len(input_list)):
        if input_list[i] - input_list[i - 1] == 1:
            current_group.append(input_list[i])
        else:
            result.append(current_group)
            current_group = [input_list[i]]

    result.append(current_group)
    return result

# 3. Remove '$' from the starting of each cell source
def remove_prompt_sign(line:str, source=True):
    return line[2:] if (line.startswith("$") and source) else line

# 4. Store the grouped items in dictionary
def append_test_to_jupyter_dict(dict, group_arr, source=True):
    dict_key = "source" if source else "output"
    for index_arr in group_arr:
        index_content = []
        for i in index_arr:
            content = remove_prompt_sign(text_lines_TEMP2[i], source) + "\n"
            index_content.append(content)
        dict[dict_key].append(index_content)

# 5. Check if dictionary has equal lengths
def check_equal_length(dict):
    lengths = [len(value) for value in dict.values()]
    return all(length == lengths[0] for length in lengths)

# 6. Return number of cells in dictionary
def return_cell_count(dict:dict):
    return len(dict["source"]) if check_equal_length(dict) else -1    

# 7. Add cell contents to the jupyter file (simple_text or stdout?)
def add_cell_contents(notebook, cell_source, cell_output):
    code_cell = nbformat.v4.new_code_cell(source=cell_source)
    notebook.cells.append(code_cell)
    cell_result = nbformat.v4.new_output(output_type="display_data", data={"text/plain":cell_output})
    code_cell.outputs.append(cell_result)

# MAIN
test_to_jupyter_dict = {
    "source":[],
    "output":[]
}

nb = nbformat.v4.new_notebook()
text_lines_TEMP1 = duplicate_text_lines()
text_lines_TEMP2 = duplicate_text_lines()
output_index_arr = get_separating_index(text_lines_TEMP1, source=False)
source_index_arr = get_separating_index(text_lines_TEMP1, source=True)
output_group_arr = group_cell_items(output_index_arr)
source_group_arr = group_cell_items(source_index_arr)

append_test_to_jupyter_dict(test_to_jupyter_dict, output_group_arr, source=False)
append_test_to_jupyter_dict(test_to_jupyter_dict, source_group_arr, source=True)
cell_count = return_cell_count(dict=test_to_jupyter_dict)

if check_equal_length(test_to_jupyter_dict):
    for index in range(cell_count):
        add_cell_contents(
            notebook=nb,
            cell_source=test_to_jupyter_dict["source"][index],
            cell_output=test_to_jupyter_dict["output"][index]
        )
    nbformat.write(nb, CONVERTED_JUPYTER_PATH)   
