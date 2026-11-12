This directory contains data from the Bash2Py repository at the University of
Waterloo. This uses a custom Bash interpreter to do the translation.
Due to problems with the latest source (circa Jan 2017), an older version
of the code was used (circa Jul 2014): 
    https://www.swag.uwaterloo.ca/bash2py/downloads/2.3/bash2py-2.3.zip

................................................................................
Known issues:
- Bash still in Python:
  - `secretNumber.py` (n.b., include garbage likely due to stack dump):\
	secretNumber=$ ((`date +%N` / 1000) % 100) +1" ))	_[0x8B\xFF\x7F]a```
  - `ext_cmd_with_output.py`: ditto
  - `open_source.zip.py`: no corresponding Bash file
- TODO: flesh out issues

