#! /usr/bin/env python
#
# Uses the Hugging Face API for machine translation (MT)
#
# Based on:
# - https://stackoverflow.com/questions/71568142/how-can-i-extract-and-store-the-text-generated-from-an-automatic-speech-recognit
# - Hugging Face's NLP with Transformers text
#

"""Machine translation via Hugging Face"""

# Standard modules
# TODO: import re

# Intalled module
## OLD: import gradio as gr
## TODO: import transformers
## OLD: from transformers import pipeline

# Local modules
from mezcla import debug
from mezcla.main import Main
from mezcla import system
from mezcla import glue_helpers as gh

# Constants
TL = debug.TL

## TODO:
## # Environment options
## # Notes:
## # - These are just intended for internal options, not for end users.
## # - They also allow for enabling options in one place rather than four
## #   when using main.Main (e.g., [Main member] initialization, run-time
## #   value, and argument spec., along with string constant definition).
## #
## ENABLE_FUBAR = system.getenv_bool("ENABLE_FUBAR", False,
##                                   description="Enable fouled up beyond all recognition processing")

FROM = system.getenv_text("FROM", "es")
TO = system.getenv_text("TO", "en")
SOURCE_LANG = system.getenv_text("SOURCE_LANG", FROM,
                                 "Source language")
TARGET_LANG = system.getenv_text("TARGET_LANG", TO,
                                 "Target language")
MT_TASK = f"translation_{SOURCE_LANG}_to_{TARGET_LANG}"
DEFAULT_MODEL = f"Helsinki-NLP/opus-mt-{SOURCE_LANG}-{TARGET_LANG}"
MT_MODEL = system.getenv_text("MT_MODEL", DEFAULT_MODEL,
                              "Hugging Face model for MT")
TEXT_ARG = "text"

#-------------------------------------------------------------------------------

TEXT_FILE = system.getenv_text("TEXT_FILE", "-",
                               "Text file to translate")
USE_INTERFACE = system.getenv_bool("USE_INTERFACE", False,
                                   "Use web-based interface via gradio")

# Optionally load UI support
gr = None
if USE_INTERFACE:
    import gradio as gr                 # pylint: disable=import-error


def main():
    """Entry point"""
    debug.trace(TL.USUAL, f"main(): script={system.real_path(__file__)}")

    # Show simple usage if --help given
    ## OLD: dummy_app = Main(description=__doc__, skip_input=False, manual_input=False)
    dummy_app = Main(description=__doc__, skip_input=False, manual_input=True,
                     text_options=[(TEXT_ARG, "Text to translate")])
    debug.trace_object(5, dummy_app)
    debug.assertion(dummy_app.parsed_args)
    text = dummy_app.get_parsed_option(TEXT_ARG)

    # Get input file
    text_file = TEXT_FILE
    if (text is not None):
        pass
    elif (text_file == "-"):
        text_file = dummy_app.temp_file
        text = dummy_app.read_entire_input()
    else:
        text = system.read_file(text_file)

    ## TEMP:
    ## pylint: disable=import-outside-toplevel
    from transformers import pipeline
    model = pipeline(task=MT_TASK, model=MT_MODEL)

    if USE_INTERFACE:
        pipeline_if = gr.Interface.from_pipeline(
            model,
            title="Machine translation (MT)",
            ## OLD:
            ## description="Using pipeline with default",
            ## examples=[text_file])
            )
        pipeline_if.launch()
    else:
        TRANSLATION_TEXT = "translation_text"
        try:
            translation = model(text)
            debug.assertion(isinstance(translation, list)
                            and (TRANSLATION_TEXT in translation[0]))
            print(translation[0].get(TRANSLATION_TEXT) or "")
        except:
            system.print_exception_info("translation")
    debug.code(4, lambda: debug.trace(1, gh.run("nvidia-smi")))

    return

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    main()
