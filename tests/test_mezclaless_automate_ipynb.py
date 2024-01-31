import os
import subprocess
import automate_ipynb
import pytest
from unittest.mock import Mock, patch
from selenium import webdriver

def test_url_generation():
    app = automate_ipynb_indev.AutomateIPYNB()
    urls = app.return_ipynb_url_array()
    assert len(urls) > 0
    assert urls[0] == "http://127.0.0.1:8888/tree/hello-world-basic.ipynb"

def test_automation():
    app = automate_ipynb_indev.AutomateIPYNB()
    with patch("selenium.webdriver.Firefox") as mock_firefox:
        mock_driver = Mock(spec=webdriver.Firefox)
        mock_firefox.return_value = mock_driver
        app.automate_testfile(["http://127.0.0.1:8888/tree/hello-world-basic.ipynb"])
        mock_driver.get.assert_called_once_with("http://127.0.0.1:8888/tree/hello-world-basic.ipynb")

def test_command_line_options():
    output = subprocess.check_output(["python", "automate_ipynb_indev.py", "--include", "test.ipynb"])
    assert b"Duration for each testfiles (in seconds):" in output

def test_environment_variables():
    os.environ["SELECT_NOBATSPP"] = "True"
    os.environ["JUPYTER_PASSWORD"] = "123456"
    os.environ["USE_FIREFOX"] = "False"

    app = automate_ipynb_indev.AutomateIPYNB()

    assert app.SELECT_NOBATSPP == True
    assert app.JUPYTER_PASSWORD == "123456"
    assert app.USE_FIREFOX == False

def test_script_execution():
    return_code = subprocess.call(["python", "automate_ipynb_indev.py"])
    assert return_code == 0

def test_verbose_mode():
    app = automate_ipynb_indev.AutomateIPYNB()
    app.opt_verbose = True

    with pytest.raises(SystemExit) as exc_info:
        with patch("sys.stdout") as mock_stdout:
            app.run_main_step()
    
    captured = mock_stdout.write.call_args_list
    assert any("Duration for each testfiles (in seconds):" in call[0][0] for call in captured)

# Run all the tests in this file
if __name__ == '__main__':
    pytest.main()
