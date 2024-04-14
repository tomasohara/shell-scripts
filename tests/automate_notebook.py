#! /usr/bin/env python

# DATE: 2023-09-26 (22:38 +05:45 GMT)
# INDEV: automate_notebook.py
# Automates Jupyter Notebook testing using Selenium Webdriver
# Estimated Time (default, per testfile): (SELENIUM_SLEEP_RERUN + 20) + [0 to 1] seconds

# TODO: (A LOT!)
# 1. Convert to a class-based approach [CHECKED]
# 2. Run the command run-jupyter-notebook before starting the tests []
# 3. Track time for each testfile and finally overall testfiles (time.time) [CHECKED]
# 4. IMP: Detect if run-jupyter-notebook is executed (if not, execute) [IMPLEMENTED; NOT FUNCTIONING]
# 5. Fix the location of TESTFILE_URL
# 6. Add script termination for Invalid Credentials (XPATH ADDED)

# 2024-03-05: Refining the script 
# 7. Run hello-world ipynb test for the default run 
# 8. Sorting must be alphabetical (Completed)
# 9. Add environment variable for Jupyter Token
# 10. Add custom Jupyter commands (or nbclassic)
# 11. Option for enabling or disabling password (Complete)

# PREQUISITIES (TEMPORARY):
# 0. The script is developed around the use of Jupyter 6 (or nbclassic)
# 1. Before executing the script, run "jupyter-nbclassic" from the root directory of shell-script
# 2. It is advised to setup a password for the notebook, and provide the password through JUPYTER_PASSWORD environment variable

# Usage Example (run from shell-scripts/tests/):
# ricekiller@pop-os:~/shell-scripts/tests$ JUPYTER_PASSWORD="password" python3 automate_ipynb --include hello-world-basic.ipynb

"""
Automates Jupyter Notebook testing using Selenium Webdriver
"""

# Standard modules
import time
import random
import subprocess

# Installed modules
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException

# Local modules
from mezcla import debug
from mezcla.main import Main
from mezcla import system
from mezcla import glue_helpers as gh

## Debug Tracing
debug.trace(5, f"global __doc__: {__doc__}")
debug.assertion(__doc__)

## Constants 0 (Command-line Labels)
OPT_INCLUDE_TESTFILE = "include"
OPT_FIRST_N_TESTFILE = "first"
OPT_VERBOSE = "verbose"

## Constants I (Initials for script)
TL = debug.TL
TESTFILE_URL = "http://127.0.0.1:8888/tree/tests/"
JUPYTER_TOKEN = ""
JUPYTER_EXTENSION = ".ipynb"
NOBATSPP = "NOBATSPP"
IPYNB_HELLO_WORLD_BASIC = "hello-world-basic.ipynb"
COMMAND_RUN_JUPYTER = "jupyter nbclassic --no-browser"
COMMAND_IS_JUPYTER_RUNNING = "jupyter nbclassic list"
CURRENT_PATH = gh.real_path(".")
debug.assertion(TESTFILE_URL.endswith("/"))

## Constant II (Elements for Selenium Webdriver)
# Waiting Time before re-running a test
SELENIUM_SLEEP_RERUN = 10
# Implicit Wait = Amount of time before throwing a 'NoSuchElementException'
SELENIUM_IMPLICIT_WAIT = 10
SELENIUM_SLEEP = 20

# HTML IDs for each component
ID_PASSWORD_INPUT = "password_input"
ID_LOGIN_SUBMIT = "login_submit"
ID_KERNELLINK = "kernellink"
ID_RESTART_RUN_ALL = "restart_run_all"
ID_FILELINK = "filelink"
ID_SAVE_CHECKPOINT = "save_checkpoint"
ID_CLOSE_AND_HALT = "close_and_halt"
ID_MENU_CHANGE_KERNEL = "menu-change-kernel"
ID_KERNEL_SUBMENU_BASH = "kernel-submenu-bash"
ID_CHECKPOINT_STATUS = "autosave_status"

# XPATH for some HTML elements
## OLD: XPATH_RESTART_RUN_ALL_WARNING_RED = "/html/body/div[8]/div/div/div[3]/button[2]"
## OLD: XPATH_INVALID_CREDENTIALS = "/html/body/div[2]/div/div[2]/div"
XPATH_PASSWORD_INPUT = f"//*[@id='{ID_PASSWORD_INPUT}']"
XPATH_LOGIN_SUBMIT = f"//*[@id='{ID_LOGIN_SUBMIT}']"
## OLD: XPATH_RESTART_RUN_ALL_WARNING_RED = "//div/button[text()='Restart and Run All Cells']"
XPATH_RESTART_RUN_ALL_WARNING_RED = "//*[text()='Restart and Run All Cells']"
XPATH_INVALID_CREDENTIALS = "//*[@class='message error']"
XPATH_MENU_CHANGE_KERNEL = f"//li[@id='{ID_MENU_CHANGE_KERNEL}']/a"
XPATH_KERNEL_SUBMENU_BASH = f"//li[@id='{ID_KERNEL_SUBMENU_BASH}']/a"
XPATH_CHECKPOINT_STATUS = f"//span[@id='{ID_CHECKPOINT_STATUS}']"

## Environment options
SELECT_NOBATSPP = system.getenv_bool("SELECT_NOBATSPP", False,
                        description="Includes testfiles with NOBATSPP during automation (Default: False)")
JUPYTER_PASSWORD = system.getenv_text("JUPYTER_PASSWORD", JUPYTER_TOKEN,
                        description="Token or Password for Jupyter Notebook (DEFAULT: '')")
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
FORCE_RUN_JUPYTER = system.getenv_bool("FORCE_RUN_JUPYTER", False,
                        description="Runs the command 'run-jupyter-notebook' when script executed (Default: True)")
END_PAUSE = system.getenv_float("END_PAUSE", 0,
                                "Number of seconds to pause after running")
IMPLICIT_WAIT = system.getenv_float("IMPLICIT_WAIT", SELENIUM_IMPLICIT_WAIT,
                                "Number of seconds to pause Webdriver implicitly")
FORCE_SET_BASH_KERNEL = system.getenv_bool("FORCE_SET_BASH_KERNEL", False,
                            description="Force sets Bash kernel when reruning each testfile (Default: False)")

## TODO: Force run Jupyter from the root "shell-scripts" directory
if FORCE_RUN_JUPYTER:
    ## Check if Jupyter Notebook is running in the background
    is_jupyter_running = gh.run(COMMAND_IS_JUPYTER_RUNNING)
    jupyter_instances = is_jupyter_running.split("\n")[1:]
    if len(jupyter_instances) > 0:
        print("Jupyter is running")
    else:
        print("Jupyter is NOT running")
        run_jupyter_path = gh.dirname(CURRENT_PATH)
        try:
            subprocess.run(COMMAND_RUN_JUPYTER, cwd=run_jupyter_path, shell=True)
        except Exception as e:
            print (f"Error: {e}")
        ## CHECKPOINT ## 

class AutomateNotebook:
    """Consists of functions for the automation of testfiles (.ipynb)"""

    def __init__(
        self,
        OPT_INCLUDE_TESTFILE,
        OPT_FIRST_N_TESTFILE,
        OPT_VERBOSE   
    ):
        """Initializer for class: AutomateNotebook"""
        self.OPT_INCLUDE_TESTFILE = OPT_INCLUDE_TESTFILE
        self.OPT_FIRST_N_TESTFILE = OPT_FIRST_N_TESTFILE
        self.OPT_VERBOSE = OPT_VERBOSE
        self.driver = webdriver.Firefox() if USE_FIREFOX else webdriver.Chrome()

    ## OLD: WebDriver object is not callable    
    # def wrapup(self):
    #     """Process end of input"""
    #     if self.driver:
    #         self.driver(quit)
    #         self.driver = None
            
    def return_ipynb_url_array(self):
        """Returns a list of URLs of IPYNB test files based on filtering conditions."""
        debug.trace(5, f"return_ipynb_url_array(); self={self}")
        
        # Get all IPYNB files in the current directory
        ipynb_files_all = [file for file in system.read_directory("./") if file.endswith(JUPYTER_EXTENSION)]
        ipynb_files_all.sort()
        
        # Apply filtering conditions based on environment variables
        ipynb_files_filtered = ipynb_files_all.copy()

        # Apply filtering conditions
        if not SELECT_NOBATSPP:
            ipynb_files_filtered = [file for file in ipynb_files_filtered if NOBATSPP not in file]

        # Randomize the order of files if specified
        if RANDOMIZE_TESTS:
            random.shuffle(ipynb_files_filtered)

        # Handle the opt_first_n_testfile and opt_include_file options
        if self.OPT_FIRST_N_TESTFILE:
            ipynb_files_filtered = ipynb_files_filtered[:self.OPT_FIRST_N_TESTFILE]
        elif self.OPT_INCLUDE_TESTFILE:
            ipynb_files_filtered = [self.OPT_INCLUDE_TESTFILE]

        # Generate URLs for the filtered files
        ipynb_urls = [TESTFILE_URL + file for file in ipynb_files_filtered]

        # Print the URLs for debugging
        print(f"IPYNB files selected for automation (RANDOMIZE_TESTS: {RANDOMIZE_TESTS})\n")
        for url in ipynb_urls:
            print(url)

        return ipynb_urls

    def find_element(self, how, elem_id):
        """Finds ELEM_ID in DOM using HOW (e.g., By.ID)"""
        # ex: token_password_box = self.find_element(By.ID, ID_PASSWORD_INPUT)
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
        # ex: token_password_box = self.find_element(By.ID, ID_PASSWORD_INPUT)
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
        print("\nDuration for each testfiles (in seconds):\n")
        ## NEW: Added an external try (nested try-catch)
        try:
            for url in url_arr:
                if not url.startswith("http"):
                    url = TESTFILE_URL + url
                
                start_time = time.time()
                # driver = webdriver.Firefox() if USE_FIREFOX else webdriver.Chrome()
                driver = self.driver
                debug.trace_expr(5, url)
                driver.get(url)
                # driver.implicitly_wait(IMPLICIT_WAIT)
                debug.trace_expr(5, JUPYTER_PASSWORD)
                
                token_password_box = self.find_element(By.XPATH, XPATH_PASSWORD_INPUT)
                token_password_submit = self.find_element(By.XPATH, XPATH_LOGIN_SUBMIT)
                
                if (JUPYTER_PASSWORD.strip() and token_password_box and token_password_submit):
                    # OLD: token_password_box = self.find_element(By.ID, ID_PASSWORD_INPUT)
                    if token_password_box is not None and JUPYTER_PASSWORD != "":
                    # OLD: token_input_submit = self.find_element(By.ID, ID_LOGIN_SUBMIT)
                        token_password_box.send_keys(JUPYTER_PASSWORD)
                    if token_password_box is not None and JUPYTER_PASSWORD != "":
                        token_password_submit.click()
                    
                    ## Invalid Credentials is shown if the credentials are not matching
                    try:
                        token_invalid_credentials = self.find_element(By.XPATH, XPATH_INVALID_CREDENTIALS)
                        if token_invalid_credentials is not None:
                            raise NoSuchElementException("Invalid credentials detected")
                    except NoSuchElementException:
                        system.print_exception_info("Invalid Credentials used for notebook")
                        print("Invalid Credentials. Retry with another password.")
                        break
                    except Exception as e:
                        debug.trace_expr(6)

                driver.implicitly_wait(5)
                
                try:
                    if FORCE_SET_BASH_KERNEL:
                        time.sleep(1)
                        self.click_element(By.ID, ID_KERNELLINK)
                        self.click_element(By.XPATH, XPATH_MENU_CHANGE_KERNEL)
                        self.click_element(By.XPATH, XPATH_KERNEL_SUBMENU_BASH, 2)
                
                    self.click_element(By.ID, ID_KERNELLINK, 1)
                    ok = self.click_element(By.ID, ID_RESTART_RUN_ALL, 0.25)
                    if not ok:
                        ok = self.click_element(By.XPATH, XPATH_RESTART_RUN_ALL_WARNING_RED, 0.25)
                    ## OLD:
                    # if not ok:
                    #     ## TODO1: get the following to work
                    #     ok = self.click_element(By.XPATH, "//div/button[contains(text(), 'Run All Cells')]", AUTOMATION_DURATION_RERUN)
                    # driver.implicitly_wait(IMPLICIT_WAIT) 
                    time.sleep(SELENIUM_SLEEP)

                    self.click_element(By.ID, ID_FILELINK, 0.25)
                    self.click_element(By.ID, ID_SAVE_CHECKPOINT, 0.25)
                    self.click_element(By.ID, ID_FILELINK, 0.25)
                    self.click_element(By.ID, ID_CLOSE_AND_HALT, 0.25)
                    ## TODO: put quit in new wrap_up method
                    ## OLD: driver.quit()
                except:
                    system.print_exception_info(f"navigating url {url}")
                
                finally:
                    ## OLD: driver.quit()
                    end_time = time.time()
                    
                    print(f"\n#{test_count}. {url.split('/')[-1]}: {round(end_time - start_time, 2)}\n")
                    test_count += 1
                    if END_PAUSE:
                        time.sleep(END_PAUSE)
        finally:
            if driver:
                driver.quit()

    def do_it(self):

        filename = self.OPT_INCLUDE_TESTFILE
        ## OLD: test_files = [filename] if (filename != "-") else self.return_ipynb_url_array()
        if filename in [None, ""]:
            test_files = self.return_ipynb_url_array()
        else:
            test_files = [filename]
        self.automate_testfile(test_files)

## END OF AutomateNotebook

class RunScriptAutomateNotebook(Main):
    """Adhoc script class (e.g., no I/O loops): just for arg-parsing"""
    opt_include_testfile = ""
    opt_first_n_testfile = 0
    opt_verbose = ""
    driver = None

    def setup(self):
        """Check results of command line processing"""
        # TODO: rework to make environment optional
        self.opt_include_testfile = self.get_parsed_argument(OPT_INCLUDE_TESTFILE, self.opt_include_testfile)
        self.opt_first_n_testfile = int(self.get_parsed_argument(OPT_FIRST_N_TESTFILE, self.opt_first_n_testfile))
        self.opt_verbose = self.get_parsed_option(OPT_VERBOSE, self.opt_verbose)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def run_main_step(self):
        """Process main script"""
        start_time_main = time.time()
        ## OLD: self.automate_testfile(self.return_ipynb_url_array())
        # test_files = [self.filename] if (self.filename != "-") else self.return_ipynb_url_array()
        # self.automate_testfile(test_files)
        automate_ipynb = AutomateNotebook(
            self.opt_include_testfile,
            self.opt_first_n_testfile,
            self.opt_verbose
        )
        # if FORCE_RUN_JUPYTER:
        #     time.sleep(1)
        #     # OLD: gh.run(COMMAND_RUN_JUPYTER)
        #     os.system(COMMAND_RUN_JUPYTER)
        automate_ipynb.do_it()
        print(f"\nTotal Time (including pauses): {round(time.time() - start_time_main, 2)} sec\n")

def main():
    """Entry point"""
    app = RunScriptAutomateNotebook(
        description = __doc__.format(script=gh.basename(__file__)),
        skip_input = False,
        manual_input = True,
        auto_help = False,
        boolean_options=[
            (OPT_VERBOSE, "Verbose Mode"),
        ],
        text_options=[
            (OPT_INCLUDE_TESTFILE, "Includes a single testfile for automation"),
        ],
        int_options=[
            (OPT_FIRST_N_TESTFILE, "Includes first N testfiles for automation"),
        ],
        float_options=None
        )
    
    app.run()
    
#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    main()