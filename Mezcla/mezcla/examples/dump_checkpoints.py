#! /usr/bin/env python
#
# Copyright 2017 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#
# via https://github.com/Paperspace/training_styletransfer

"""A script to dump tensorflow checkpoint variables to deeplearnjs.
This script takes a checkpoint file and writes all of the variables in the
checkpoint to a directory.
"""

# TEMP: pylint: disable=unspecified-encoding

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

## OLD: import argparse
import json
import os
import re
import string
## OLD: import tensorflow as tf
## TODO?:
import tensorflow.compat.v1 as tf

# Local modules
# TODO: def mezcla_import(name): ... components = eval(name).split(); ... import nameN-1.nameN as nameN
from mezcla import debug
from mezcla.main import Main
from mezcla import system

# Command-line arguments
JSON_OUTPUT = "json"
CHECKPOINT_FILE = "checkpoint"
OUTPUT_DIR = "output-dir"


## TODO:
## # Environment options
## # Note: These are just intended for internal options, not for end users.
## # It also allows for enabling options in one place rather than four
## # (e.g., [Main member] initialization, run-time value, and argument spec., along
## # with string constant definition).
## #
## FUBAR = system.getenv_bool("FUBAR", False,
##                            description="Fouled Up Beyond All Recognition processing")


FILENAME_CHARS = string.ascii_letters + string.digits + '_'

#-------------------------------------------------------------------------------

def _var_name_to_filename(var_name):
    """Return filename to use fo VAR_NAME"""
    chars = []
    for c in var_name:
        if c in FILENAME_CHARS:
            chars.append(c)
        elif c == '/':
            chars.append('_')
        else:
            debug.trace(7, f"Excluding char '{c}' from filename")
    return ''.join(chars)

def remove_optimizer_variables(output):
    """Remvoes tensorflow variables used for optimization"""
    ## OLD: vars_dir = os.path.expanduser(output)
    manifest_file = os.path.join(output, 'manifest.json')
    with open(manifest_file) as f:
        manifest = json.load(f)
        new_manifest = {key: manifest[key] for key in manifest 
                        if 'Adam' not in key and 'beta' not in key}
    with open(manifest_file, 'w') as f:
        json.dump(new_manifest, f, indent=2, sort_keys=True)

    for name in os.listdir(output):
        if 'Adam' in name or 'beta' in name:
            os.remove(os.path.join(output, name))


def dump_checkpoints(checkpoint_dir, output, use_json=False):
    """Dump all tensorflow variabes in CHECKPOINT_DIR [file???] to OUTPUT dir.
    Note: Optionally USEs_JSON format for arrays"""
    chk_fpath = os.path.expanduser(checkpoint_dir)
    reader = tf.train.NewCheckpointReader(chk_fpath)
    var_to_shape_map = reader.get_variable_to_shape_map()
    output_dir = os.path.expanduser(output)
    tf.gfile.MakeDirs(output_dir)
    manifest = {}
    ## TODO: remove_vars_compiled_re = re.compile('')

    var_filenames_strs = []
    for name in var_to_shape_map:
        ## OLD:
        ## if ('' and
        ##     re.match(remove_vars_compiled_re, name)) or name == 'global_step':
        if name == 'global_step':
            debug.trace(5, f"Ignoring tf var {name}")
            continue
        var_filename = _var_name_to_filename(name)
        manifest[name] = {'filename': var_filename, 'shape': var_to_shape_map[name]}

        tensor = reader.get_tensor(name)
        if use_json:
            with open(os.path.join(output_dir, var_filename + ".json"), 'w') as f:
                f.write(json.dumps(tensor.tolist()))
        else:
            with open(os.path.join(output_dir, var_filename), 'wb') as f:
                f.write(tensor.tobytes())

    var_filenames_strs.append("\"" + var_filename + "\"")

    manifest_fpath = os.path.join(output_dir, 'manifest.json')
    print('Writing manifest to ' + manifest_fpath)
    with open(manifest_fpath, 'w') as f:
        f.write(json.dumps(manifest, indent=2, sort_keys=True))

    remove_optimizer_variables(output_dir)

#...............................................................................

class Script(Main):
    """Adhoc script class (e.g., no I/O loop, just run calls)"""
    json_output = False
    checkpoint_file = None
    output_dir = None

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(5, "Script.setup(): self={s}", s=self)
        self.json_output = self.get_parsed_option(JSON_OUTPUT, self.json_output)
        self.checkpoint_file = self.get_parsed_argument(CHECKPOINT_FILE)
        self.output_dir = self.get_parsed_argument(OUTPUT_DIR)
        debug.trace_object(5, self, label="Script instance")

    def run_main_step(self):
        """Main processing step"""
        debug.trace_fmtd(5, "Script.run_main_step(): self={s}", s=self)
        dump_checkpoints(self.checkpoint_file, self.output_dir,
                         use_json=self.json_output)

#-------------------------------------------------------------------------------


if __name__ == '__main__':
    debug.trace_current_context(level=debug.QUITE_DETAILED)
    debug.trace_fmt(4, "Environment options: {eo}",
                    eo=system.formatted_environment_option_descriptions())
    app = Script(
        description=__doc__,
        skip_input=True,
        manual_input=True,
        boolean_options=[(JSON_OUTPUT, "Use JSON format for arrays, not binary")],
        # Note: FILENAME is default argument unless skip_input
        positional_arguments=[CHECKPOINT_FILE, OUTPUT_DIR], 
        # Note: Following added for indentation: float options are not common
        float_options=None)
    app.run()
    debug.assertion(not any(re.search(r"^TODO_", m, re.IGNORECASE)
                            for m in dir(app)))
                   
