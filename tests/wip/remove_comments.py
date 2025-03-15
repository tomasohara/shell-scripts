#!/usr/bin/env python3

import sys

def remove_comments(input_file, output_file):
    """
    Removes all comments from the input file, except for the shebang line.
    Also removes lines that start with the word "trace".
    """
    try:
        with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
            # Read the first line to check for a shebang
            first_line = infile.readline()
            if first_line.startswith('#!'):
                outfile.write(first_line)  # Preserve the shebang line
            
            # Process the rest of the file
            for line in infile:
                # Skip lines that start with "trace"
                if line.strip().startswith('trace'):
                    continue
                
                # Remove comments (everything after '#') and strip trailing whitespace
                cleaned_line = line.split('#', 1)[0].rstrip()
                if cleaned_line:  # Only write non-empty lines
                    outfile.write(cleaned_line + '\n')
        
        print(f"Comments removed. Output saved to '{output_file}'.")
    
    except FileNotFoundError:
        print(f"Error: Input file '{input_file}' not found.")
        sys.exit(1)

if __name__ == "__main__":
    # Check if the input file is provided
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <input_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = f"{input_file}.nocomments"  # Output file name
    
    # Call the function to remove comments
    remove_comments(input_file, output_file)

    ## Issues prone functions from x.bash
    # grep-to-less
    # check-errors
    # line-wc
    # cmd-trace
    # reset-prompt-root
    # dir