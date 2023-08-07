## Test TODO notes

An optional priority is indicated by [Pn]

- [P1] Use @pytest.mark.xfail to add new tests rather than an empty tets with a TODO note.
- [P2] Make sure path wrappers used instead of using / (e.g., "a/b" => gh.format_path("a", "b").
- [P2] Use mkdir wrapper (e.g., system.create_directory or glue_helpers.full_mkdir).
- [P3] Remove unused boiterplate from template.py (e.g., setup methods).
- [P4] Keep the tests in sync with package upgrades.
