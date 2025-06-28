# Contributing to shell-scripts

Thank you for your interest in contributing to this collection of shell scripts!

This repository contains a variety of scripts for Unix systems, written primarily in Perl, Bash, and C Shell, as well as some Python utilities. The project has evolved over many years and includes both production-use tools and experimental or research code. Contributions of all types—new scripts, bug fixes, ports, or documentation improvements—are welcome.

---

## Style and Guidelines

- **There is no strict, enforced code style in this repository.**
- The codebase is eclectic and prioritizes function and reusability over strict adherence to "pythonic" or modern code style.
- For new Python scripts (or other new code intended for broad or long-term use), please keep in mind general best practices for clarity, maintainability, and documentation.
- For "throwaway" scripts, rapid Perl-to-Python ports, or one-off utilities, **functional correctness and regression safety** take priority over code style.
- As a guideline, see the [mezcla companion project](https://github.com/tomasohara/mezcla) for code organization, naming, and maintainability. While strict mezcla style is not required, the spirit of those guidelines is encouraged for new contributions.

---

## Python Linting & Static Analysis

- Python scripts are **not required** to be auto-formatted (e.g., with Black) unless discussed for new modules.
- Linting is typically performed using `pylint`, with exclusions and symbolic warning codes managed via command-line options.  
  See the `python-lint` aliases in `tomohara-aliases.bash` for the workflow used in this repository.
- Contributors are encouraged to check for major `pylint` or syntax errors before submitting, but perfection is not required.
- Symbolic warning codes (e.g., `C0303` for "trailing-whitespace") may appear in comments or exclusion lists.

---

## Submitting Contributions

- Please provide clear and descriptive commit messages, and include a brief summary of your changes in the pull request.
- For quick ports, experimental code, or non-production scripts, note this in your commit or PR description.
- For widely-used or shared utilities, please try to add a usage note or comment at the top of the script.
- Add or update tests if possible, especially for scripts that are widely used or critical.

---

## Testing and Compatibility

- Where possible, test your scripts on a typical Unix environment (e.g., Linux, macOS).
- Regression tests or usage demos are welcome, but not required for small changes or one-off scripts.
- **Python 2 support is now phased out; new Python scripts should target Python 3.**

---

## Licensing

All contributions are covered under the repository’s [LICENSE.txt](archive/LICENSE.txt) (LGPLv3).

---

## Questions

If you have questions about conventions, code organization, or project history, please open an issue or refer to the [README.txt](README.txt) for more background.

---

Thanks for helping improve this collection!

*— Tom O'Hara*  
[tpo@cs.toronto.edu](mailto:tpo@cs.toronto.edu)