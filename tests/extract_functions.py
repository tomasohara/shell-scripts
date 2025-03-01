import re
import json

def is_comment(line):
    """Detects if a line is a comment."""
    line = line.strip()
    return line.startswith("#")

def extract_functions_aliases(script_path, output_json):
    """Extracts function definitions and aliases from a Bash script, ignoring commented-out lines, and saves to JSON."""
    with open(script_path, "r") as f:
        script_content = f.readlines()

    function_ranges = {}
    aliases = []
    function_name = None
    start_line = None

    # Define the regex for detecting function declarations (ignores comments)
    # FUNC_REGEX = re.compile(r"^(?!\s*#)(?:function\s+)?([a-zA-Z_][a-zA-Z0-9_]*)\s*\(\)\s*\{")
    FUNC_REGEX = re.compile(r"function\s+([\w-]+)\s*(\(\))?\s*\{")

    # Iterate through each line in the script
    for i, line in enumerate(script_content, 1):
        line = line.strip()  # Remove leading/trailing spaces

        # Skip commented-out lines
        if is_comment(line):
            continue

        # Match function definitions using regex
        func_match = FUNC_REGEX.match(line)
        if func_match:
            if function_name:
                function_ranges[function_name]["end"] = i - 1  # Previous function ends here
            function_name = func_match.group(1)
            start_line = i
            function_ranges[function_name] = {"start": start_line, "end": None}

        # Match alias declarations
        alias_match = re.match(r"^alias\s+([a-zA-Z0-9_]+)=", line)
        if alias_match:
            aliases.append(alias_match.group(1))

    # Set end for the last function
    if function_name:
        function_ranges[function_name]["end"] = len(script_content)

    # Prepare data for JSON
    data = {
        "functions": function_ranges,
        "aliases": aliases
    }

    # Save to JSON file
    with open(output_json, "w") as f:
        json.dump(data, f, indent=4)

    print(f"✅ Extracted functions and aliases saved to: {output_json}")

# Example usage
bash_script = "../tomo.bash"
output_json = "extracted_functions.json"
extract_functions_aliases(bash_script, output_json)
