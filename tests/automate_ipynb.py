#!/usr/bin/env python3

## DATE: 2023-09-26 (22:38 +05:45 GMT)
## INDEV: automate_ipynb.py

## Automates Jupyter Notebook testing using Selenium Webdriver
## Estimated Time (per testfile): 
## TODO: (A LOT!)
## 1. Convert to a class-based approach
## 2. (EXPERIMENTAL - ENV VAR) Run the command run-jupyter-notebook before starting the tests
## BUGS: 
## 1. TESTFILE_URL might change for every run
## Author: Aviyan Acharya

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys

from mezcla import glue_helpers as gh
from mezcla import system as msy
import time

TESTFILE_URL = "http://127.0.0.1:8888/tree/tests/"
JUPYTER_TOKEN = "111222"
FILE_EXTENSION = ".ipynb"
NOBATSPP = "NOBATSPP"

def return_ipynb_array(all:bool = False):
    ipynb_files_all = [file for file in msy.read_directory("./") if file.endswith(FILE_EXTENSION)]
    ipynb_files_filtered = [file for file in ipynb_files_all if not NOBATSPP in file]
    ipynb_URL = []
    ipynb_files = ipynb_files_all.copy() if bool else ipynb_files_filtered.copy()
    
    for file in ipynb_files:
        file_URL = TESTFILE_URL + file
        print (file_URL)
        ipynb_URL.append(file_URL)

    return ipynb_URL

def automate_testfile(url:str):
    driver = webdriver.Firefox()
    driver.get(url)
    time.sleep(1)
    token_input_box = driver.find_element(By.ID, "password_input")
    token_input_submit = driver.find_element(By.ID, "login_submit")
    token_input_box.send_keys(JUPYTER_TOKEN)
    token_input_submit.click()

    driver.find_element(By.ID, "kernellink").click()
    time.sleep(3)
    driver.find_element(By.ID, "restart_run_all").click()
    time.sleep(3)
    driver.find_element(By.XPATH, "/html/body/div[8]/div/div/div[3]/button[2]").click()
    time.sleep(30)
    driver.find_element(By.ID, "filelink").click()
    time.sleep(2)
    driver.find_element(By.ID, "save_checkpoint").click()
    time.sleep(2)
    driver.find_element(By.ID, "filelink").click()
    time.sleep(2)
    driver.find_element(By.ID, "close_and_halt").click()
    time.sleep(2)
    driver.quit()

## Experimental: Run run-jupyter-notebook command as soon as script starts
# gh.run("run-jupyter-notebook")

ipynb_arr = return_ipynb_array(False)
for _ in ipynb_arr:
    automate_testfile(_)