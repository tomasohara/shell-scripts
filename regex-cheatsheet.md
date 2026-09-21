## Regular expression cheatsheet

TODO2: finish adding simple but representative examples

| Pattern       | Comment             | Example    | Text | Match |
|---------------|---------------------|------------|------|-------|
|(?:regex)      | non-capturing group |            |      |       |
|(?<!regex)     | negative lookbehind |            |      |       |
|(?!regex)      | negative lookahead  |            |      |       |
|(?=regex)      | positive lookahead  |            |      |       |
|(?<=regex)     | positive lookbehind (e.g., pre-context) | (?<=\$)\d+ | $100 |  100  |
|*?  and  +?    | non-greedy match	  |            |      |       |
