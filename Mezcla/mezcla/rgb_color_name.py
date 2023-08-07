#! /usr/bin/env python
#
# Displays names of web colors for RGB codes, using a distance match in
# case no exact matches exists.
#
# Notes:
# - Based on https://computergraphics.stackexchange.com/questions/1542/convert-rgb-hex-or-any-other-color-format-to-standard-color-programmatically.
# - Color rgb:(0, 255, 0) is reported as lime instead of green. See
#     https://webcolors.readthedocs.io
# - For utility to extract colors from images, see
#   https://pypi.org/project/extcolors
#
#--------------------------------------------------------------------------------
# Sample input (based on extcolors):
#
#   Extracted colors:
#   (128, 128, 128):  72.98% (1888)
#   (39, 39, 39)   :  24.35% (630)
#   (255, 255, 255):   2.67% (69)
#   
#   Pixels in output: 2587 of 11648
#
# Sample output:
#
#   Extracted colors:
#   <(128, 128, 128), gray>:  72.98% (1888)
#   <(39, 39, 39), darkslategray>   :  24.35% (630)
#   <(255, 255, 255), white>:   2.67% (69)
#   
#   Pixels in output: 2587 of 11648
#
#................................................................................
# TODO:
# - Add example usage with extcolors:
#   extcolors self.filename | self.program -
# - Add option to invoke extcolors automatically.
#

"""Convert RGB tuples into color names

Sample usage:
   extcolors tests/resources/orange-gradient.png | {script} -
"""

# Standard packages
import re

# Installed packages
import webcolors
from scipy.spatial import KDTree

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import system
from mezcla.my_regex import my_re

# Constants for switches omitting leading dashes (e.g., DEBUG_MODE = "debug-mode")

## TODO: REPLACEMENT = "regex-replacement"
RGB_REGEX = "rgb-regex"
HEX = "hex"
SKIP_DIRECT = "skip-direct"
SHOW_HEX = "show-hex"

class Script(Main):
    """Input processing class: convert RGB tuples to <RGB, label> pairs"""
    rgb_regex = r"\((0?x?[0-9A-F]+), (0?x?[0-9A-F]+), (0?x?[0-9A-F]+)\)"
    ## TODO: replacement = r"<COLOR, \1>"
    space_color_db = None
    color_names = []
    hex = False
    skip_direct = False
    show_hex = False
    check_direct_match = None

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(5, "Script.setup(): self={s}", s=self)
        # Extract argument values
        ## TODO: self.REPLACEMENT = self.get_parsed_option(REPLACEMENT, self.REPLACEMENT)
        self.rgb_regex = self.get_parsed_option(RGB_REGEX, self.rgb_regex)
        spec_regex = r"\([^\(\)]+\).*" * 3
        debug.assertion(re.search(spec_regex, self.rgb_regex, re.IGNORECASE))
        self.hex = self.get_parsed_option(HEX, self.hex)
        self.skip_direct = self.get_parsed_option(SKIP_DIRECT, self.skip_direct)
        self.show_hex = self.get_parsed_option(SHOW_HEX, self.show_hex)
        self.check_direct_match = not self.skip_direct

        # Populate color names into spatial name database
        hexnames = webcolors.CSS3_HEX_TO_NAMES
        self.color_names = []
        color_positions = []
        #
        for hex_code, name in hexnames.items():
            debug.trace(6, f"color: {name}={hex_code}")
            self.color_names.append(name)
            color_positions.append(webcolors.hex_to_rgb(hex_code))
            #
        self.space_color_db = KDTree(color_positions)
        debug.trace_object(5, self, label="Script instance")

    def process_line(self, line):
        """Processes current line from input"""
        debug.trace_fmtd(6, "Script.process_line({l})", l=line)

        # Do sanity check for inadvertant image input
        # TODO: abort processing unless --force option given
        if (self.line_num <= 1):
            debug.assertion(not re.search(r"^\s*(IMDR|JFIF|PNG)\s*$", line),
                            "Input should not be an image (e.g., use extcolors output)")
        
        # Extract RGB references and add color name label
        # ex: "(128, 128, 128):  72.98% (1888)" => "<Grey, (128, 128, 128)>:  72.98% (1888)
        ## OLD: MAX_TRIES = max(1, line.count("("))
        MAX_TRIES = (1 + len(re.findall(self.rgb_regex, line)))
        debug.trace(5, f"len: {len(line)}; MAX_TRIES={MAX_TRIES}")
        num_tries = 0
        text = line
        processed_text = ""
        while (my_re.search(self.rgb_regex, text) and (num_tries < MAX_TRIES)):
            num_tries += 1
            # Extract RGB components
            rgb = my_re.group(0)
            red = my_re.group(1)
            green = my_re.group(2)
            blue = my_re.group(3)

            # Determine whether RGB in hexadecimal or decimal
            rgb_base = 10
            if (self.hex or re.search("(0x)|[A-F]|(^#)", rgb, re.IGNORECASE)):
                rgb_base = 16
            query_color = [system.safe_int(c, base=rgb_base) for c in [red, green, blue]]

            try:
                # Try for exact match
                color_name = None
                if self.check_direct_match:
                    try:
                        color_name = webcolors.rgb_to_name(query_color)
                    except:
                        debug.trace(5, f"Direct lookup failed: {system.get_exception()}")
                    
                # Query nearest point
                if not color_name:
                    dist, index = self.space_color_db.query(query_color)
                    debug.trace_fmtd(5, f"{rgb} => {index}; dist={dist}")
                    color_name = self.color_names[index]
            except:
                system.print_stderr(f"Exception in color decoding: {system.get_exception()}")
                continue

            rgb_spec = rgb
            hex_spec = ""
            if self.show_hex:
                # https://stackoverflow.com/questions/2269827/how-to-convert-an-int-to-a-hex-string
                hex_spec = " 0x" + "".join(f"{c:0>2X}" for c in query_color)
            color_spec = f"<{rgb_spec}, {color_name}{hex_spec}>"
            processed_text += text[0: my_re.start()] + color_spec
            text = text[my_re.end():]
            debug.trace_fmtd(4, "match: {m}; new text: {new}",
                             m=my_re.group(0), new=text)
        debug.assertion(num_tries <= MAX_TRIES)

        # Print revised line
        print(processed_text + text)

def main():
    """Entry point"""
    app = Script(
        description=__doc__.format(script=gh.basename(__file__)),
        usage_notes="Note: Input is not an image (e.g., use extcolors)",
        # Note: skip_input controls the line-by-line processing, which is inefficient but simple to
        # understand; in contrast, manual_input controls iterator-based input (the opposite of both).
        boolean_options=[(HEX, "RGB triple specified in hex (not decimal)"),
                         (SHOW_HEX, "Show hex-style specification XXXXXX"),
                         (SKIP_DIRECT, "Don't include direct match (for nearest neighbor test")],
        # Note: FILENAME is default argument unless skip_input
        text_options=[
            ## TODO: (REPLACEMENT, "Regex-like replacement using \\1 for RGB tuple and COLOR for color name"),
            (RGB_REGEX, "Regex for finding RGB color specifications with \\1, \\2, and \\3 for reg, green, and blue")
        ],
        # Note: Following added for indentation: float options are not common
        float_options=None)
    app.run()
    
        
#-------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context(level=debug.QUITE_DETAILED)
    main()
