#! /usr/bin/env python
#
# Tests for Audio.py
#
# Notes:
# - *** All the tests are skipped if the audio packages not installed.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_audio.py
# - some tests will take a while.
#
## TODO: solve test execution long times.


"""Tests for Audio module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
# note: The audio library packages are not installed by default, so tests skipped if not found.
import pytest
try:
    import librosa
except:
    librosa = None

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh
from mezcla import debug

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
if librosa:
    import mezcla.audio as THE_MODULE
else:
    debug.trace(3, "Unable to import librosa, so tests will be disabled")
    THE_MODULE = None

# Constants
AUDIOFILE = 'samples/test_audiofile.wav'

class TestAudio(TestWrapper):
    """Class for testcase definition"""
    script_module     = TestWrapper.derive_tested_module_name(__file__)
    use_temp_base_dir = True
    maxDiff           = None

    ## TODO2: rework skip's as xfail
    
    @pytest.mark.skip(reason="this will take a while and this require a valid audio path in AUDIOFILE")
    def test_sphinx_engine(self):
        """Test CMUSphinx speech recognition engine class"""
        debug.trace(debug.DETAILED, f"TestAudio.test_sphinx_engine({self})")

        sample = THE_MODULE.Audio(AUDIOFILE)
        result_speech = sample.speech_to_text(engine='sphinx')
        assert isinstance(result_speech, str)
        assert result_speech

    @pytest.mark.skipif(not librosa, reason="librosa missing")
    def test_audio_path(self):
        """Test for audio.path"""
        debug.trace(debug.DETAILED, f"TestAudio.test_audio_path({self})")

        path = 'some/path'

        sample = THE_MODULE.Audio(path)
        assert sample.get_path() == path

        sample = THE_MODULE.Audio()
        assert not sample.get_path()
        sample.set_path(path)
        assert sample.get_path(), path

    @pytest.mark.skip(reason='TODO: tests command-line using batspp style')
    def test_source_single_audio(self):
        """End to end test sourcing a single audio file"""
        debug.trace(debug.DETAILED, f"TestAudio.test_source_single_audio({self})")

        audio = self.temp_file + '.wav'
        gh.write_file(audio, 'some content')

        command  = f'python {self.script_module} --verbose {audio}'
        expected = f'Audio: {audio}'
        assert gh.run(command) == expected

    @pytest.mark.skip(reason='TODO: tests command-line using batspp style')
    def test_source_list(self):
        """End to end test sourcing a list of audio files"""
        debug.trace(debug.DETAILED, f"TestAudio.test_source_list({self})")

        list_file = self.temp_file + '.list'

        audio_list = ('audio1.wav\n'
                      'audio2.wav\n'
                      'audio23.wav\n'
                      'audioN.wav')

        gh.write_file(list_file, audio_list)

        command  = f'python {self.script_module} --verbose {list_file}'
        expected = ('Audio: audio1.wav\n'
                    'Audio: audio2.wav\n'
                    'Audio: audio23.wav\n'
                    'Audio: audioN.wav')
        assert gh.run(command) == expected

    @pytest.mark.skip(reason='TODO: tests command-line using batspp style')
    def test_source_folder(self):
        """End to end test sourcing a folder and discover audiofiles"""
        debug.trace(debug.DETAILED, f"TestAudio.test_source_folder({self})")

        ## TODO: resolve librosa find files recursively not woking.
        ## filenames = ['/audio1.wav', '/somedir/audio2.wav', '/audio23.wav']

        filenames = ['/audio1.wav', '/audio23.wav']
        for filename in filenames:
            gh.write_file(self.temp_base + filename, 'content')

        actual = gh.run(f'python {self.script_module} --verbose {self.temp_base}')

        for filename in filenames:
            assert filename in actual

    @pytest.mark.skip(reason="this will take a while and this require a valid audio path in AUDIOFILE")
    def test_extract_speech(self):
        """End to end test extracting speech using CMUSphinx engine"""
        debug.trace(debug.DETAILED, f"TestAudio.test_extract_speech({self})")

        actual = gh.run(f'python {self.script_module} --verbose --speech sphinx {AUDIOFILE}')
        assert actual
        assert '- speech recognized' in actual
        assert isinstance(actual, str)


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
