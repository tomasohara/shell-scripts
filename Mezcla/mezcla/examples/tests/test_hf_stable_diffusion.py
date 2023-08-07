#! /usr/bin/env python
#
# Test(s) for Hugging Face (HF) Stable Diffulion (SD) module: ../hf_stable_diffusion.py
#
# Notes:
# - Fill out TODO's below. Use numbered tests to order (e.g., test_1_usage).
# - TODO: If any of the setup/cleanup methods defined, make sure to invoke base
#   (see examples below for setUp and tearDown).
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_hf_stable_diffusion.py
#
# TODO3: check image attributes (e.g., backgfround color) and work in image classification (e.g., box)
#

"""Tests for hf_stable_diffusion module"""

# Standard packages
import base64

# Installed packages
import pytest
try:
    import diffusers
except:
    diffusers = None
try:
    import extcolors
except:
    extcolors = None

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug
from mezcla import system
from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re

# Note: Two references are used for the module to be tested:
#    THE_MODULE:                  global module object
#    TestTemplate.script_module:  path to file
import mezcla.examples.hf_stable_diffusion as THE_MODULE
#
# Note: sanity test for customization (TODO: remove if desired)
if not my_re.search(__file__, r"\btemplate.py$"):
    debug.assertion("mezcla.template" not in str(THE_MODULE))

class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)
    # -or- non-mezcla: script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)
    #
    use_temp_base_dir = True            # treat TEMP_BASE as directory
    # note: temp_file defined by parent (along with script_module, temp_base, and test_num)

    @pytest.mark.skipif(not diffusers, reason="SD diffusers package missing")
    def test_simple_generation(self):
        """Makes sure simple image generation works as expected"""
        debug.trace(4, f"TestIt.test_data_file(); self={self}")
        # ex: See sd-app-image-1.png
        output = self.run_script(
            options="--batch --prompt 'orange ball' --negative 'green blue red yellow purple pink brown'",
            env_options=f"BASENAME='{self.temp_base}' LOW_MEMORY=1", uses_stdin=True)
        debug.trace_expr(5, output)
        assert (my_re.search(r"See (\S+.png) for output image\(s\).", output.strip()))
        image_file = my_re.group(1)
        # ex: sd-app-image-3.png: PNG image data, 512 x 512, 8-bit/color RGB, non-interlaced
        file_info = gh.run(f"file {image_file}")
        debug.trace_expr(5, file_info)
        assert (my_re.search("PNG image data, 512 x 512, 8-bit/color RGB", file_info))
        # TODO2: orange in rgb-color profile for image
        return

#...............................................................................

class TestIt2:
    """Another class for testcase definition
    Note: Needed to avoid error with pytest due to inheritance with unittest.TestCase via TestWrapper"""
    
    @pytest.mark.skipif(not diffusers, reason="SD diffusers package missing")
    def test_pipeline(self):
        """Make sure valid SD pipeline created"""
        debug.trace(4, f"TestIt2.test_something_else(); self={self}")
        sd = THE_MODULE.StableDiffusion(use_hf_api=True)
        pipe = sd.init_pipeline()
        actual = my_re.split(r"\W+", str(pipe))
        expect = "CLIPImageProcessor CLIPTextModel StableDiffusionSafetyChecker text_encoder".split()
        debug.trace_expr(5, actual, expect, delim="\n")
        assert (len(system.intersection(actual, expect)) > 2)
        return

    
    @pytest.mark.xfail                   # TODO: remove xfail
    @pytest.mark.skipif(not extcolors, reason="extcolors package missing")
    def test_something_else(self):
        """Make sure prompted color is used"""
        debug.trace(4, f"TestIt2.test_something_else(); self={self}")
        sd = THE_MODULE.StableDiffusion(use_hf_api=True, low_memory=True)
        images = sd.infer(prompt="a ripe orange", scale=30)
        # note: encodes image base-64 str data into bytes and then decodes into image bytes
        image_data = (base64.decodebytes(images[0].encode()))
        image_path = gh.create_temp_file(image_data, binary=True)
        # note: use of rgb_color_name.py allows for fudge factor
        # $ extcolors sd-app-image-1.png | rgb_color_name.py - | grep orange
        # <(255, 92, 0), orangered>   :  47.07% (123388)
        # <(255, 153, 0), orange>  :   6.13% (16074)
        output = gh.run(f"extcolors '{image_path}' | rgb_color_name.py - 2> /dev/null")
        debug.trace_expr(4, output)
        assert ("orange" in output)
        assert (len(images) == 1)
        return

#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
