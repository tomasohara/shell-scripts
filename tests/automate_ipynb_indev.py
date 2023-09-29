#! /usr/bin/env python

## DATE: 2023-09-26 (22:38 +05:45 GMT)
## INDEV: automate_ipynb_indev.py
## Automates Jupyter Notebook testing using Selenium Webdriver
## Estimated Time (per testfile): 
## TODO: (A LOT!)
## 1. Convert to a class-based approach
## 2. (EXPERIMENTAL - ENV VAR) Run the command run-jupyter-notebook before starting the tests
## 3. Track time for each testfile and finally overall testfiles (time.time)
## 4. IMP: Detect if run-jupyter-notebook is executed (if not, execute) 
## 5. Fix the location of TESTFILE_URL

## Author: Aviyan Acharya

"""
Automates Jupyter Notebook testing using Selenium Webdriver
"""

# Standard modules
import time

# Installed modules
from selenium import webdriver
from selenium.webdriver.common.by import By

# Local modules
from mezcla import debug
from mezcla.main import Main
from mezcla import system
from mezcla.my_regex import my_re
from mezcla import glue_helpers as gh

## Debug Tracing
debug.trace(5, f"global __doc__: {__doc__}")
debug.assertion(__doc__)

## Constants 0 (Command-line Labels)
INCLUDE_TESTFILE = "include"
FIRST_N_TESTFILE = "first"
VERBOSE = "verbose"

## Constants I (Initials for script)
TL = debug.TL
TESTFILE_URL = "http://127.0.0.1:8888/tree/"
JUPYTER_TOKEN = "111222"
JUPYTER_EXTENSION = ".ipynb"
NOBATSPP = "NOBATSPP"

## Constant II (Elements for Selenium Webdriver)
SELENIUM_SLEEP_RERUN = 30
# HTML IDs for each component
ID_PASSWORD_INPUT = "password_input"
ID_LOGIN_SUBMIT = "login_submit"
ID_KERNELLINK = "kernellink"
ID_RESTART_RUN_ALL = "restart_run_all"
ID_FILELINK = "filelink"
ID_SAVE_CHECKPOINT = "save_checkpoint"
ID_CLOSE_AND_HALT = "close_and_halt"
# XPATH for some HTML elements
XPATH_RESTART_RUN_ALL_WARNING_RED = "/html/body/div[8]/div/div/div[3]/button[2]"

## Environment options
SELECT_NOBATSPP = system.getenv_bool("SELECT_NOBATSPP", False,
                        description="Includes testfiles with NOBATSPP during automation (Default: False)")
JUPYTER_PASSWORD = system.getenv_text("JUPYTER_PASSWORD", JUPYTER_TOKEN,
                        description="Token or Password for Jupyter Notebook (DEFAULT: '111222')")
USE_FIREFOX = system.getenv_bool("USE_FIREFOX", True,
                        description="Uses GeckoDriver when True, else uses ChromeDriver (Default: True)")
AUTOMATION_DURATION_RERUN = system.getenv_int("AUTOMATION_DURATION_RERUN", SELENIUM_SLEEP_RERUN,
                        description="Sets duration (in seconds) for automating re-run for each testfile (Default: 30)")
OUTPUT_PATH = system.getenv_text("OUTPUT_PATH", ".",
                        description=f"Target output .{JUPYTER_EXTENSION} file path")

class AutomateIPYNB(Main):
    """Consists of functions for the automation of testfiles (.ipynb)"""
    
    include_file = ""
    first_n_testfile = 0
    verbose = None

    def setup(self):
        """Check results of command line processing"""        
        self.include_file = self.get_parsed_argument(INCLUDE_TESTFILE, self.include_file)
        self.first_n_testfile = self.get_parsed_argument(FIRST_N_TESTFILE, self.first_n_testfile)
        self.verbose = self.get_parsed_argument(VERBOSE, self.verbose)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def return_ipynb_URL_array(self):
        """Returns an array of URLs of IPYNB testfiles"""
        ipynb_files_all = [file for file in system.read_directory("./") if file.endswith(JUPYTER_EXTENSION)]
        ipynb_files_filtered = [file for file in ipynb_files_all if not NOBATSPP in file]
        ipynb_URL = []
        ipynb_files = ipynb_files_all.copy() if SELECT_NOBATSPP else ipynb_files_filtered.copy()
        
        for file in ipynb_files:
            file_URL = TESTFILE_URL + file
            print (file_URL)
            ipynb_URL.append(file_URL)
        
        return ipynb_URL
    
    def automate_testfile(self, url_arr:str):
        """Automates the testfile using URLs from argument"""
        for url in url_arr:
            driver = webdriver.Firefox() if USE_FIREFOX else webdriver.Chrome()
            driver.get(url)
            time.sleep(1)
            token_input_box = driver.find_element(By.ID, ID_PASSWORD_INPUT)
            token_input_submit = driver.find_element(By.ID, ID_LOGIN_SUBMIT)
            token_input_box.send_keys(JUPYTER_TOKEN)
            token_input_submit.click()

            driver.find_element(By.ID, ID_KERNELLINK).click()
            time.sleep(3)
            driver.find_element(By.ID, ID_RESTART_RUN_ALL).click()
            time.sleep(3)
            driver.find_element(By.XPATH, XPATH_RESTART_RUN_ALL_WARNING_RED).click()
            time.sleep(AUTOMATION_DURATION_RERUN)
            driver.find_element(By.ID, ID_FILELINK).click()
            time.sleep(2)
            driver.find_element(By.ID, ID_SAVE_CHECKPOINT).click()
            time.sleep(2)
            driver.find_element(By.ID, ID_FILELINK).click()
            time.sleep(2)
            driver.find_element(By.ID, ID_CLOSE_AND_HALT).click()
            time.sleep(2)
            driver.quit()

    def run_main_step(self):
        """Process main script"""
        self.automate_testfile(self.return_ipynb_URL_array())

def main():
    """Entry point"""
    app = AutomateIPYNB(
        description = __doc__.format(script=gh.basename(__file__)),
        skip_input = True,
        manual_input = True,
        auto_help = False,
        boolean_options=[
            (VERBOSE, f"Verbose Mode"),
        ],
        text_options=[
            (INCLUDE_TESTFILE, f"Includes a single testfile for automation"),
        ],
        int_options=[
            (FIRST_N_TESTFILE, f"Includes first N testfiles for automation"),
        ],
        float_options=None
        )
    app.run()
    
#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    main()
