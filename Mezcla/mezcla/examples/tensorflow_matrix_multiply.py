#! /usr/bin/env python
#
# Simple tensorflow matrix multiplication based on following:
#    https://www.tensorflow.org/guide/gpu
#
# Sample usages:
# - Using defaults
#   NUM_ROWS=5000 NUM_COLS=5000 python tensorflow_matrix_multiply.py
#
# - Alternative (using environment variables for GPU usage):
#   export TF_FORCE_GPU_ALLOW_GROWTH=true
#   export NVIDIA_VISIBLE_DEVICES="0"
#   export CUDA_VISIBLE_DEVICES="0"
#   python tensorflow_matrix_multiply.py
#

"""Tensorflow matrix multiplication (for GPU usage diagnosis)"""

# Standard packages
import os
import random

# Installed packages
import tensorflow as tf

# Local pakcages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import system
from mezcla import tpo_common as tpo

# Environment options
NUM_ROWS = system.getenv_int("NUM_ROWS", 1000)
NUM_COLS = system.getenv_int("NUM_COLS", 1000)
DEVICE_ID = system.getenv_value("DEVICE_ID", None)
ALLOW_GROWTH = system.getenv_bool("ALLOW_GROWTH", True)

def random_vector(size):
    """Returns random list of SIZE floats"""
    return [random.random() for _i in range(size)]

def random_row(size): 
    """Returns row (list) of SIZE floats"""
    return random_vector(size)

def random_matrix(num_rows, num_cols):
    """Returns matrix of size NUM_ROWS x NUM_COLS filled with random float in [0, 1)"""
    return [random_row(num_cols) for _r in range(num_rows)]

def tensor_multiply(a, b):
    """Compute matrix multiplication via tensorflow"""
    c = tf.matmul(a, b)
    debug.trace(6, f"A: {a}\nB: {b}\nC: {c}")
    #
    session = tf.compat.v1.Session()
    result = session.run(c)
    debug.trace(6, f"tensor_multiply() => {result}")
    #
    return result


def main():
    """Multiply two matrices on the GPU"""

    # Show simple usage if --help given
    dummy_app = Main(description=__doc__, skip_input=False, manual_input=False)
    
    # Show final NVidia GPU usage
    if dummy_app.verbose:
        print("initial GPU usage:\n", gh.run("nvidia-smi"))

    # note: need to use version-specific stuff for basic functions
    # pylint: disable=no-member
    if (tf.__version__[0] >= '2'):
        tf.compat.v1.disable_eager_execution()
        tf.compat.v1.logging.set_verbosity(tf.compat.v1.logging.DEBUG)
    else:
        tf.logging.set_verbosity(tf.logging.DEBUG)
    tf.debugging.set_log_device_placement(True)
    device_id = DEVICE_ID
    debug.assertion((device_id is None) or tpo.is_numeric(device_id))
    debug.trace(4, f"using device {device_id}")
    if ALLOW_GROWTH:
        system.setenv("TF_FORCE_GPU_ALLOW_GROWTH", "true")
    if device_id:
        system.setenv("NVIDIA_VISIBLE_DEVICES", device_id)
    debug.trace(5, f"environment: {{\n{os.environ}\n}}")
    a = tf.constant(random_matrix(NUM_ROWS, NUM_COLS))
    b = tf.constant(random_matrix(NUM_ROWS, NUM_COLS))
    result = tensor_multiply(a, b)
    print(f"A x B: \n{result}")

    # Show final NVidia GPU usage
    if dummy_app.verbose:
        print("final GPU usage:\n", gh.run("nvidia-smi"))

#------------------------------------------------------------------------

if __name__ == '__main__':
    main()
