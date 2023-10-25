#! /usr/bin/env python

# DATE: 2023-09-26 (22:38 +05:45 GMT)
# INDEV: automate_ipynb_indev.py
# Automates Jupyter Notebook testing using Selenium Webdriver
# Estimated Time (default, per testfile): (SELENIUM_SLEEP_RERUN + 20) + [0 to 1] seconds

# TODO: (A LOT!)
# (CHECKED) 1. Convert to a class-based approach
# 2. (EXPERIMENTAL - ENV VAR) Run the command run-jupyter-notebook before starting the tests
# (50% CHECKED) 3. Track time for each testfile and finally overall testfiles (time.time)
# 4. IMP: Detect if run-jupyter-notebook is executed (if not, execute) 
# 5. Fix the location of TESTFILE_URL
# 6. Add script termination for Invalid Credentials (XPATH ADDED)

# Author: Aviyan Acharya (avyn.xyz@gmail.com)

"""
Automates Jupyter Notebook testing using Selenium Webdriver
"""

# Standard modules
import time
import random

# Installed modules
from selenium import webdriver
from selenium.webdriver.common.by import By

# Local modules
from mezcla import debug
from mezcla.main import Main
from mezcla import system
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
IPYNB_HELLO_WORLD_BASIC = "hello-world-basic.ipynb"
COMMAND_RUN_JUPYTER = "run-jupyter-notebook"
debug.assertion(TESTFILE_URL.endswith("/"))

## Constant II (Elements for Selenium Webdriver)
SELENIUM_SLEEP_RERUN = 40
SELENIUM_IMPLICIT_WAIT = 10

# HTML IDs for each component
ID_PASSWORD_INPUT = "password_input"
ID_LOGIN_SUBMIT = "login_submit"
ID_KERNELLINK = "kernellink"
ID_RESTART_RUN_ALL = "restart_run_all"
ID_FILELINK = "filelink"
ID_SAVE_CHECKPOINT = "save_checkpoint"
ID_CLOSE_AND_HALT = "close_and_halt"

# XPATH for some HTML elements
## OLD: XPATH_RESTART_RUN_ALL_WARNING_RED = "/html/body/div[8]/div/div/div[3]/button[2]"
## OLD: XPATH_INVALID_CREDENTIALS = "/html/body/div[2]/div/div[2]/div"
XPATH_PASSWORD_INPUT = f"//input[@id='{ID_PASSWORD_INPUT}']"
XPATH_LOGIN_SUBMIT = f"//button[@id='{ID_LOGIN_SUBMIT}']"
XPATH_RESTART_RUN_ALL_WARNING_RED = "//div/button[text()='Restart and Run All Cells']"
XPATH_INVALID_CREDENTIALS = "//div[@class='message error' and text()='Invalid credentials']"

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
                        description=f"Target output .{JUPYTER_EXTENSION} file path (Default: .)")
RANDOMIZE_TESTS = system.getenv_bool("RANDOMIZE_TESTS", False,
                        description="Randomized the testfile order during execution (Default: False)")
DISABLE_SINGLE_INPUT = system.getenv_bool("DISABLE_SINGLE_INPUT", False,
                        description="Disables single testfile automation and allows all testfiles (if --include not used) (Default: False)")
FORCE_RUN_JUPYTER = system.getenv_bool("FORCE_RUN_JUPYTER", True,
                        description="Runs the command 'run-jupyter-notebook' when script executed (Default: True)")
END_PAUSE = system.getenv_float("END_PAUSE", 0,
                                "Number of seconds to pause after running")
IMPLICIT_WAIT = system.getenv_float("IMPLICIT_WAIT", SELENIUM_IMPLICIT_WAIT,
                                "Number of seconds to pause Webdriver implicitly")

class AutomateIPYNB(Main):
    """Consists of functions for the automation of testfiles (.ipynb)"""
    opt_include_file = ""
    opt_first_n_testfile = 0
    opt_verbose = None
    driver = None

    def get_entered_text(self, label: str, default: str = "") -> str:
        """
        Return entered LABEL var/arg text by command-line or environment variable,
        also can be specified a DEFAULT value
        """
        result = (self.get_parsed_argument(label=label.lower()) or
                system.getenv_text(var=label.upper()))
        result = result if result else default
        debug.trace(7, f'automate_ipynb.get_entered_text(label={label}) => {result}')
        return result

    def setup(self):
        """Check results of command line processing"""
        # TODO: rework to make environment optional
        self.opt_include_file = self.get_entered_text(INCLUDE_TESTFILE, self.opt_include_file)
        self.opt_first_n_testfile = int(self.get_entered_text(FIRST_N_TESTFILE, self.opt_first_n_testfile))
        self.opt_verbose = self.get_parsed_option(VERBOSE, self.opt_verbose)
        self.driver = webdriver.Firefox() if USE_FIREFOX else webdriver.Chrome()
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def wrapup(self):
        """Process end of input"""
        if self.driver:
            self.driver(quit)
            self.driver = None
        
    def return_ipynb_url_array(self):
        """Returns an array of URLs of IPYNB testfiles"""
        ipynb_files_all = [file for file in system.read_directory("./") if file.endswith(JUPYTER_EXTENSION)]
        ipynb_files_filtered = [file for file in ipynb_files_all if not NOBATSPP in file]
        ipynb_url = []

        # Create a copy of the original list
        ipynb_files = ipynb_files_all.copy()

        # Apply filtering conditions
        # A) SELECT_BATSPP selects each and every file
        if not SELECT_NOBATSPP:
            ipynb_files = ipynb_files_filtered.copy()

        # B) RANDOMIZE_TESTS randomizes the order of tests
        if RANDOMIZE_TESTS:
            random.shuffle(ipynb_files)

        # C) Handle the opt_first_n_testfile and opt_include_file options
        if self.opt_first_n_testfile:
            ipynb_files = ipynb_files[:self.opt_first_n_testfile]
        elif self.opt_include_file:
            # If an include file is specified, only include that file
            ipynb_files = [self.opt_include_file]

        # If neither opt_first_n_testfile nor opt_include_file is specified,
        # the list ipynb_files will remain as is (all test files).

        # Iterate through all files present in the array
        for file in ipynb_files:
            file_url = TESTFILE_URL + file
            print (file_url)
            ipynb_url.append(file_url)
        return ipynb_url

    def find_element(self, how, elem_id):
        """Finds ELEM_ID in DOM using HOW (e.g., By.ID)"""
        # ex: token_input_box = self.find_element(By.ID, ID_PASSWORD_INPUT)
        debug.trace(5, f"find_element({how}, {elem_id}); self={self}")
        elem = None
        try:
            elem = self.driver.find_element(how, elem_id)
        except:
            system.print_exception_info(f"find_element {elem_id}")
        debug.trace(6, f"find_element() => {elem}")
        return elem

    def click_element(self, how, elem_id, delay=2):
        """Finds ELEM_ID in DOM using HOW (e.g., By.ID), and it clicks if found"""
        # ex: token_input_box = self.find_element(By.ID, ID_PASSWORD_INPUT)
        debug.trace(5, f"find_element({how}, {elem_id}); self={self}")
        result = None
        try:
            elem = self.driver.find_element(how, elem_id)
            result = elem.click()
            time.sleep(delay)
            ## TODO2 (for automatic debug tracing): system.pause(delay)
        except:
            system.print_exception_info(f"click_element {elem_id}")
        debug.trace(6, f"click_element() => {result}")
        return result
    
    def automate_testfile(self, url_arr:str):
        """Automates the testfile using URLs from argument"""
        debug.trace(5, f"automate_testfile({url_arr!r})")
        test_count = 1
        print("\nDuration for each testfiles (in seconds):")
        for url in url_arr:
            if not url.startswith("http"):
                url = TESTFILE_URL + url
            start_time = time.time()

            ## OLD: driver = webdriver.Firefox() if USE_FIREFOX else webdriver.Chrome()
            driver = self.driver
            debug.trace_expr(5, url)
            driver.get(url)
            driver.implicitly_wait(IMPLICIT_WAIT)
            debug.trace_expr(5, JUPYTER_PASSWORD)
            
            token_input_box = self.find_element(By.XPATH, XPATH_PASSWORD_INPUT)
            token_input_submit = self.find_element(By.XPATH, XPATH_LOGIN_SUBMIT)

            if (JUPYTER_PASSWORD.strip() and token_input_box and token_input_submit):
                # OLD: token_input_box = self.find_element(By.ID, ID_PASSWORD_INPUT)
                if token_input_box is not None:
                # OLD: token_input_submit = self.find_element(By.ID, ID_LOGIN_SUBMIT)
                    token_input_box.send_keys(JUPYTER_PASSWORD)
                if token_input_box is not None:
                    token_input_submit.click()
                # time.sleep(5)
                driver.implicitly_wait(5)

            # TODO: In the case of Invalid Credentials
            try:
                self.click_element(By.ID, ID_KERNELLINK, 1)
                ok = self.click_element(By.ID, ID_RESTART_RUN_ALL, 3)
                if not ok:
                    ok = self.click_element(By.XPATH, XPATH_RESTART_RUN_ALL_WARNING_RED, AUTOMATION_DURATION_RERUN)
                ## OLD:
                # if not ok:
                #     ## TODO1: get the following to work
                #     ok = self.click_element(By.XPATH, "//div/button[contains(text(), 'Run All Cells')]", AUTOMATION_DURATION_RERUN)
                self.click_element(By.ID, ID_FILELINK)
                self.click_element(By.ID, ID_SAVE_CHECKPOINT)
                self.click_element(By.ID, ID_FILELINK)
                self.click_element(By.ID, ID_CLOSE_AND_HALT)
                ## TODO: put quit in new wrap_up method
                ## OLD: driver.quit()
            except:
                system.print_exception_info(f"navigating url {url}")
            
            finally:
                ## OLD: driver.quit()
                end_time = time.time()
                
                print(f"#{test_count}. {url.split('/')[-1]}: {round(end_time - start_time, 2)}")
                test_count += 1
                if END_PAUSE:
                    time.sleep(END_PAUSE)
                
            # driver.quit()
            self.wrap_up()

    def run_main_step(self):
        """Process main script"""
        start_time_main = time.time()
        ## OLD: self.automate_testfile(self.return_ipynb_url_array())
        test_files = [self.filename] if (self.filename != "-") else self.return_ipynb_url_array()
        self.automate_testfile(test_files)
        print(f"\nTotal Time (including pauses): {round(time.time() - start_time_main, 2)} sec\n")

def main():
    """Entry point"""
    app = AutomateIPYNB(
        description = __doc__.format(script=gh.basename(__file__)),
        skip_input = False,
        manual_input = True,
        auto_help = False,
        boolean_options=[
            (VERBOSE, "Verbose Mode"),
        ],
        text_options=[
            (INCLUDE_TESTFILE, "Includes a single testfile for automation"),
        ],
        int_options=[
            (FIRST_N_TESTFILE, "Includes first N testfiles for automation"),
        ],
        float_options=None
        )
    app.run()
    
#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    main()