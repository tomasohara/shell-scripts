# Contributing to shell-scripts

Thank you for considering a contribution to this collection of shell scripts!

This repository contains miscellaneous scripts for Unix, written primarily in Perl, Bash, and C Shell, and serves both as a toolkit for practical work and as a historical collection of utilities developed over many years. Contributions—whether new scripts, bugfixes, or enhancements—are welcome.

## Style and Guidelines

- **There is no strict or enforced code style in this repository.**
- The codebase is eclectic and prioritizes function and reusability over "pythonic" or modern code style.
- For new Python scripts (or other new code intended for broad or long-term use), please keep in mind general best practices for clarity, maintainability, and documentation.
- For "throwaway" scripts, rapid Perl-to-Python ports, or one-off utilities, **functional correctness and regression safety** are the top priorities, not code style.
- See the [mezcla companion project](https://github.com/tomasohara/mezcla) for inspiration on code organization, naming, and maintainability. While strict mezcla style is not required, the spirit of those guidelines is encouraged for new contributions.

## Submitting Contributions

- Add a short, descriptive commit message and, if applicable, a brief summary of what your change does.
- If your change is a quick port, ad-hoc fix, or non-production script, please mention that in your commit or pull request.
- For widely-used scripts or shared utilities, please try to add a short comment or usage note at the top of the file.

## Testing and Compatibility

- Where possible, test your scripts on a typical Unix environment (e.g., Linux, macOS).
- Regression tests or usage demos are welcome, but not required for small changes or one-off scripts.
- Python 2 support is now phased out; new Python scripts should target Python 3.

## Licensing

All contributions are covered under the repository’s [LICENSE.txt](LICENSE.txt) (LGPLv3).

## Questions

If you have questions about conventions, code organization, or project history, please open an issue or refer to the [README.txt](README.txt) for more background.

---

Thanks for helping improve this collection!

*- Tom O'Hara*
[tpo@cs.toronto.edu](mailto:tpo@cs.toronto.edu)