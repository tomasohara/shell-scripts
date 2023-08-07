#! /usr/bin/env python
#
# Test(s) for glue_helpers.py
#
# Notes:
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_glue_helpers.py
#
# TODO:
# - Add support for write_lines & read_lines.
# - Add support for other commonly used functions.
#

"""Tests for glue_helpers module"""

# Standard packages
from os import path
from io import StringIO
import sys

# Installed packages
import pytest

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import tpo_common as tpo # Deprecated, only used for mock
## OLD: from mezcla.unittest_wrapper import TestWrapper
from mezcla import system

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.glue_helpers as THE_MODULE # pylint: disable=reimported

class TestGlueHelpers:
    """Class for testcase definition"""

    def test_get_temp_file(self):
        """Ensure get_temp_file works as expected"""
        debug.trace(4, "test_get_temp_file()")
        assert isinstance(THE_MODULE.get_temp_file(), str)

    def test_remove_extension(self):
        """Ensure remove_extension works as expected"""
        debug.trace(4, "test_remove_extension()")
        assert THE_MODULE.remove_extension("/tmp/solr-4888.log", ".log") == "/tmp/solr-4888"
        assert THE_MODULE.remove_extension("/tmp/fubar.py", ".py") == "/tmp/fubar"
        assert THE_MODULE.remove_extension("/tmp/fubar.py", "py") == "/tmp/fubar."

    def test_dir_path(self):
        """Ensure dir_path works as expected"""
        debug.trace(4, "test_dir_path()")
        assert THE_MODULE.dir_path("/tmp/solr-4888.log") == "/tmp"

    def test_file_exists(self):
        """Ensure file_exists works as expected"""
        debug.trace(4, "test_file_exists()")
        # Existent file
        test_filename = gh.get_temp_file()
        gh.write_file(test_filename, 'some content')
        assert THE_MODULE.file_exists(test_filename)
        # Not existent file
        assert not THE_MODULE.file_exists('bad_filename')

    def test_non_empty_file(self):
        """Ensure non_empty_file works as expected"""
        debug.trace(4, "test_non_empty_file()")

        # Test valid file
        file_with_content = gh.get_temp_file()
        gh.write_file(file_with_content, 'content')
        assert THE_MODULE.non_empty_file(file_with_content)

        # Test non existent file
        assert not THE_MODULE.non_empty_file('bad_file_name')

        # Test empty file
        empty_file = gh.get_temp_file()
        with open(empty_file, 'wb') as _:
            pass # gh.write_file cant be used because appends a newline
        assert not THE_MODULE.non_empty_file(empty_file)

    def test_form_path(self):
        """Ensure form_path works as expected"""
        debug.trace(4, "test_form_path()")
        assert THE_MODULE.form_path("/home/", "User/Desktop", "file.txt") == "/home/User/Desktop/file.txt"

    @pytest.mark.xfail
    def test_create_directory(self):
        """Ensure create_directory works as expected"""
        debug.trace(4, "test_create_directory()")
        assert False

    @pytest.mark.xfail
    def test_full_mkdir(self):
        """Ensure full_mkdir works as expected"""
        debug.trace(4, "test_full_mkdir()")
        assert False

    @pytest.mark.xfail
    def test_real_path(self):
        """Ensure real_path works as expected"""
        debug.trace(4, "test_real_path()")
        assert THE_MODULE.real_path("/etc/mtab").startswith("/proc")

    def test_indent(self):
        """Ensure indent works as expected"""
        debug.trace(4, "test_indent()")
        test_text = 'this is an example text to be indented'
        tab_indented_text = '\tthis is an example text to be indented'
        assert THE_MODULE.indent(test_text, '\t') == tab_indented_text

    def test_indent_lines(self):
        """Ensure indent_lines works as expected"""
        debug.trace(4, "test_indent_lines()")
        test_text = (
            'this is\n'
            'an example text\n'
            'to be indented\n'
        )
        tab_indented_text = (
            '\tthis is\n'
            '\tan example text\n'
            '\tto be indented\n'
        )
        assert THE_MODULE.indent_lines(test_text, '\t') == tab_indented_text

    def test_elide(self):
        """Ensure elide works as expected"""
        debug.trace(4, "test_elide()")
        assert THE_MODULE.elide("=" * 80, max_len=8) == "========..."
        assert THE_MODULE.elide(None, 10) is ""

    def test_elide_values(self):
        """Ensure elide_values works as expected"""
        debug.trace(4, "test_elide_values()")
        assert THE_MODULE.elide_values(["1", "22", "333"], max_len=2) == ["1", "22", "33..."]

    @pytest.mark.xfail
    def test_disable_subcommand_tracing(self):
        """Ensure disable_subcommand_tracing works as expected"""
        debug.trace(4, "test_disable_subcommand_tracing()")
        assert False

    @pytest.mark.xfail
    def test_run(self):
        """Ensure run works as expected"""
        debug.trace(4, "test_run()")
        assert "root" in THE_MODULE.run("ls /")

    def test_issue(self, monkeypatch, capsys):
        """Ensure issue works as expected"""
        debug.trace(4, "test_issue()")

        # Simple command test
        temp_file = gh.get_temp_file()
        THE_MODULE.issue(f'echo "this is a simple test" > {temp_file}')
        assert 'this is a simple test' in gh.read_file(temp_file)

        # Setup log file
        log_file = gh.get_temp_file()
        system.write_file(log_file, 'random content')
        def debugging_mock():
            return True
        monkeypatch.setattr(tpo, 'debugging', debugging_mock)
        monkeypatch.setenv('TEMP_LOG_FILE', log_file, prepend=False)

        # Run test with log file
        THE_MODULE.issue('bash bad_filename.bash')

        # Check result of test with log file
        if debug.debugging():
            captured = capsys.readouterr()
            assert 'stderr' in captured.err
            assert 'bad_filename.bash' in captured.err
        ## TODO: for some reason the log_file is not being overriden
        ## assert 'random content' not in gh.read_file(log_file)
        ## assert 'bad_filename.bash' in gh.read_file(log_file)

    def test_get_hex_dump(self):
        """Ensure get_hex_dump works as expected"""
        debug.trace(4, "test_get_hex_dump()")
        ## TODO: mock hexview.perl output
        ## assert THE_MODULE.get_hex_dump("Tomás") == "00000000  54 6F 6D C3 A1 73       -                          Tom..s"

    def test_extract_matches(self):
        """Tests for extract_matches(pattern, lines)"""
        assert THE_MODULE.extract_matches(r"Mr. (\S+)", ["Mr. Smith", "Mr. Jones", "Mr.X"]) == ["Smith", "Jones"]
        assert THE_MODULE.extract_matches(r"\t\S+", ["abc\tdef", "123\t456"]) != ["def", "456"]

    def test_extract_match(self):
        """Ensure extract_match works as expected"""
        debug.trace(4, "test_extract_match()")
        assert THE_MODULE.extract_match(r"Mr. (\S+)", ["Mr. Smith", "Mr. Jones", "Mr.X"]) == "Smith"

    def test_basename(self):
        """Tests for basename(path, extension)"""
        assert THE_MODULE.basename("fubar.py", ".py") == "fubar"
        assert not THE_MODULE.basename("fubar.py", "") == "fubar"
        assert THE_MODULE.basename("/tmp/solr-4888.log", ".log") == "solr-4888"

    def test_resolve_path(self):
        """Tests for resolve_path(filename)"""
        script = "glue_helpers.py"
        test_script = "test_glue_helpers.py"
        # The main script should resolve to parent directory but this one to test dir
        assert not THE_MODULE.resolve_path(script) == path.join(path.dirname(__file__), test_script)
        assert THE_MODULE.resolve_path(test_script) == path.join(path.dirname(__file__), test_script)

    def test_extract_match_from_text(self):
        """Ensure extract_match_from_text works as expected"""
        debug.trace(4, "test_extract_match_from_text()")
        assert THE_MODULE.extract_match_from_text(r"Mr. (\S+)", "Mr. Smith\nMr. Jones\nMr.X") == "Smith"

    def test_extract_matches_from_text(self):
        """Ensure extract_matches_from_text works as expected"""
        debug.trace(4, "test_extract_matches_from_text()")
        assert THE_MODULE.extract_matches_from_text(".", "abc") == ["a", "b", "c"]
        assert THE_MODULE.extract_matches_from_text(".", "abc", multiple=False) == ["a"]

    def test_count_it(self):
        """Ensure count_it works as expected"""
        debug.trace(4, "test_count_it()")
        assert dict(THE_MODULE.count_it("[a-z]", "Panama")) == {"a": 3, "n": 1, "m": 1}
        assert THE_MODULE.count_it(r"\w+", "My d@wg's fleas have fleas")["fleas"] == 2

    def test_read_lines(self, monkeypatch, capsys):
        """Ensure read_lines works as expected"""
        debug.trace(4, "test_read_lines()")

        # Test valid file
        temp_file = gh.get_temp_file()
        gh.write_file(temp_file, 'file\nwith\nmultiple\nlines\n')
        assert THE_MODULE.read_lines(temp_file) == ['file', 'with', 'multiple', 'lines']

        # Test no filename (read from stdin)
        monkeypatch.setattr('sys.stdin', StringIO('my input\nsome line'))
        assert THE_MODULE.read_lines() == ['my input', 'some line']
        ## TODO: solve "ValueError: I/O operation on closed file."
        ## THE_MODULE.read_lines()
        ## captured = capsys.readouterr()
        ## assert 'stdin' in captured.err

        # Test invalid filename
        assert THE_MODULE.read_lines(filename='bad_filename.txt') == []
        if debug.debugging():
            captured = capsys.readouterr()
            assert 'Warning:' in captured.err

    def test_write_lines(self):
        """Ensure write_lines works as expected"""
        debug.trace(4, "test_write_lines()")

        content = (
            'this is\n'
            'a multiline\n'
            'text used\n'
        )
        content_in_lines = [
            'this is',
            'a multiline',
            'text used',
        ]

        # Test normal usage
        filename = gh.get_temp_file()
        THE_MODULE.write_lines(filename, content_in_lines)
        assert THE_MODULE.read_file(filename) == content

        # Test append
        THE_MODULE.write_lines(filename, ['for testing'], append=True)
        assert THE_MODULE.read_file(filename) == content + 'for testing\n'

    def test_read_file(self):
        """Ensure read_file works as expected"""
        debug.trace(4, "test_read_file()")
        temp_file = gh.get_temp_file()
        gh.write_file(temp_file, 'file\nwith\nmultiple\nlines\n')
        assert THE_MODULE.read_file(temp_file) == 'file\nwith\nmultiple\nlines\n'

    def test_write_file(self):
        """Ensure write_file works as expected"""
        debug.trace(4, "test_write_file()")

        # Test normal usage
        filename = gh.get_temp_file()
        THE_MODULE.write_file(filename, "some test")
        assert THE_MODULE.read_file(filename) == "some test\n"

        # Test append argument
        THE_MODULE.write_file(filename, "with appended text", append=True)
        assert THE_MODULE.read_file(filename) == "some test\nwith appended text\n"

    def test_copy_file(self):
        """Ensure copy_file works as expected"""
        debug.trace(4, "test_copy_file()")
        first_temp_file = gh.get_temp_file()
        second_temp_file = f"{first_temp_file}_target_copy"
        gh.write_file(first_temp_file, 'some random content')
        THE_MODULE.copy_file(first_temp_file, second_temp_file)
        assert gh.read_file(second_temp_file) == 'some random content\n'

    def test_rename_file(self):
        """Ensure rename_file works as expected"""
        debug.trace(4, "test_rename_file()")
        test_filename = gh.get_temp_file()
        new_test_filename = gh.get_temp_file() + '_this_append_avoids_bad_file_exists'
        gh.write_file(test_filename, 'some content')

        # Check existense of files before rename
        assert gh.file_exists(test_filename)
        assert not gh.file_exists(new_test_filename)

        THE_MODULE.rename_file(test_filename, new_test_filename)

        # Check integrity of renamed file
        assert gh.file_exists(new_test_filename)
        assert not gh.file_exists(test_filename)
        assert gh.read_file(new_test_filename) == 'some content\n'

    def test_delete_file(self, capsys):
        """Ensure delete_file works as expected"""
        debug.trace(4, "test_delete_file()")

        # Test valid file to delete
        test_filename = gh.get_temp_file()
        gh.write_file(test_filename, 'some content')
        assert gh.file_exists(test_filename)
        THE_MODULE.delete_file(test_filename)
        assert not gh.file_exists(test_filename)

        # Test invalid file
        THE_MODULE.delete_file('bad_filename.txt')
        if debug.debugging():
            captured = capsys.readouterr()
            assert 'assertion failed' in captured.err.lower()

    def test_file_size(self):
        """Ensure file_size works as expected"""
        debug.trace(4, "test_file_size()")
        temp_file = gh.get_temp_file()
        gh.write_file(temp_file, 'content')
        assert THE_MODULE.file_size(temp_file) == 8
        assert THE_MODULE.file_size('non-existent-file.txt') == -1

    @pytest.mark.xfail
    def test_get_matching_files(self):
        """Ensure get_matching_files works as expected"""
        debug.trace(4, "test_get_matching_files()")
        assert False

    @pytest.mark.xfail
    def test_get_files_matching_specs(self):
        """Ensure get_files_matching_specs works as expected"""
        debug.trace(4, "test_get_files_matching_specs()")
        assert False

    @pytest.mark.xfail
    def test_get_directory_listing(self):
        """Ensure get_directory_listing works as expected"""
        debug.trace(4, "test_get_directory_listing()")
        filenames = [gh.get_temp_file() for _ in range(5)]
        for file in filenames:
            gh.write_file(file, 'random content')
        debug.assertion("/tmp" == system.getenv("TMP"))
        filenames = [file.replace('/tmp/', '') for file in filenames]
        assert set(filenames).issubset(THE_MODULE.get_directory_listing('/tmp/'))

    def test_getenv_filename(self, monkeypatch, capfd):
        """Ensure getenv_filename works as expected"""
        debug.trace(4, "test_getenv_filename()")

        # Test valid filename with valid content
        test_filename = gh.get_temp_file()
        gh.write_file(test_filename, 'random content')
        monkeypatch.setenv('TEST_ENV_FILENAME', test_filename, prepend=False)
        assert THE_MODULE.getenv_filename('TEST_ENV_FILENAME') == test_filename

        # Test valid filename with empty content
        test_filename = gh.get_temp_file()
        with open(test_filename, 'wb') as _:
            pass # gh.write_file cant be used because appends a newline
        debug.set_level(7)
        monkeypatch.setenv('TEST_ENV_FILENAME', test_filename, prepend=False)
        # This avoids flaky tpo.stderr due to other tests
        ## TODO: fix tpo.restore_stderr() to work with pytest 
        tpo.stderr = sys.stderr
        THE_MODULE.getenv_filename('TEST_ENV_FILENAME')
        captured = capfd.readouterr() # Note: capfd must be used instead of capsys to capture stderr
        assert 'Error' in captured.err
        assert test_filename in captured.err

        # Test non enviroment var
        assert THE_MODULE.getenv_filename('BAD_ENV_VAR', default='altfile') == 'altfile'


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
