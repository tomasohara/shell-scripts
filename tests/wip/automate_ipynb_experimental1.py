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
XPATH_INVALID_CREDENTIALS = "/html/body/div[2]/div/div[2]/div"

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

class AutomateIPYNB(Main):
    """Consists of functions for the automation of testfiles (.ipynb)"""
    opt_include_file = ""
    opt_first_n_testfile = 0
    opt_verbose = None
    driver = webdriver.Firefox()
    
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
        self.opt_include_file = self.get_entered_text(INCLUDE_TESTFILE, self.opt_include_file)
        self.opt_first_n_testfile = int(self.get_entered_text(FIRST_N_TESTFILE, self.opt_first_n_testfile))
        self.opt_verbose = self.get_parsed_option(VERBOSE, self.opt_verbose)
        self.driver = self.driver if USE_FIREFOX else webdriver.Chrome()
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def wrap_up_driver(self):
        self.driver.quit()

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
        
        # C) DISABLE_SINGLE_INPUT when false only selects one file for test (hello-world-basic.ipynb)
        if not DISABLE_SINGLE_INPUT:
            if self.opt_first_n_testfile:
                ipynb_files = ipynb_files[:self.opt_first_n_testfile]
            elif not RANDOMIZE_TESTS:
                ipynb_files = [IPYNB_HELLO_WORLD_BASIC]
            else:
                ipynb_files = [random.choice(ipynb_files)]

        if self.opt_include_file:
            # If an include file is specified, only include that file
            ipynb_files = [self.opt_include_file]

        # If neither opt_first_n_testfile nor opt_include_file is specified,
        # the list ipynb_files will remain as is (all test files).

        # Sort array alphabetically
        ipynb_files.sort()

        # Iterate through all files present in the array
        for file in ipynb_files:
            file_url = TESTFILE_URL + file
            print (file_url)
            ipynb_url.append(file_url)
        return ipynb_url
    
    def automate_testfile(self, url_arr:str):
        """Automates the testfile using URLs from argument"""
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
            time.sleep(1)
            if JUPYTER_PASSWORD:
                token_input_box = driver.find_element(By.ID, ID_PASSWORD_INPUT)
                token_input_submit = driver.find_element(By.ID, ID_LOGIN_SUBMIT)
                token_input_box.send_keys(JUPYTER_PASSWORD)
                token_input_submit.click()

            # TODO: In the case of Invalid Credentials
            try:
                time.sleep(1)
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
                ## TODO: put quit in new wrap_up method
                ## OLD: driver.quit()
                self.wrap_up_driver()
            except:
                system.print_exception_info(f"navigating url {url}")
                self.wrap_up_driver()
            finally:
                self.wrap_up_driver()
                end_time = time.time()
                
                print(f"#{test_count}. {url.split('/')[-1]}: {round(end_time - start_time, 2)}")
                test_count += 1
                if END_PAUSE:
                    time.sleep(END_PAUSE)

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
