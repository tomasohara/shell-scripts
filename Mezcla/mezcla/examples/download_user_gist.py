#! /usr/bin/env python
#
# Based on following:
#   https://www.geeksforgeeks.org/downloading-gists-from-github-made-simple
#
# TODO:
#  - Get the script to work!
#

"""
Download user-specific gists from Github

    Commands:
    show:               To show all the available gists with their assigned gistno.
    download all:       To download all the available gists.
    download gistno(s): To download gist(s) assigned to gistno(s).
    detailed gistno:    To print content of gist assigned to gistno.
    exit:               To exit the script.

"""

# Standard modules
import os

# Intalled module
import requests

# Local modules
from mezcla import debug
from mezcla.main import Main
from mezcla import glue_helpers as gh
from mezcla import system


def create_directory(dirname):
    """Creates a new directory if a directory with dirname does not exist"""
    debug.trace(4, f"create_directory({dirname})")

    try:
        os.stat(dirname)
    except:
        os.mkdir(dirname)


def show(obj):
    """Displays the items in the obj"""
    debug.trace(4, f"show({obj})")

    for i in range(len(obj)):
        print(str(i)+': '+str(obj[i]))


def auth():
    """Asks for the user details"""
    debug.trace(4, "auth()")

    ask_auth = input("Do you want to download gists from your account"
                     "? Type 'yes' or 'no': ")
    debug.trace(6, ask_auth)
    user = None
    request = None
    if (ask_auth=="yes"):
        user = input("Enter your username: ")
        password = input("Enter your password: ")
        debug.trace_expr(3, user, password)
        request = requests.get('https://gists.github.com/users/' + user,
                               auth=(user, password))
    elif (ask_auth=="no"):
        user = input("Enter username: ")
        debug.trace_expr(3, user)
        ## OLD
        ## request = requests.get('https://api.github.com/users/'
        ##                        +user+'/gists')
        request = requests.get('https://gists.github.com/' + user)
        debug.trace_object(5, request)
    else:
        system.print_error("Error: unexpected condition in auth: {ask_auth}")
    debug.trace(5, f"auth() => {[ask_auth, user, request]}")
    return [ask_auth, user, request]


def load(request):
    """Loads the files and the gist urls"""
    debug.trace(4, f"load({request})")

    output = request.text.split(",")
    debug.trace_expr(6, output)
    gist_urls = []
    files = []
    for item in output:
        debug.trace_expr(6, item)
        if "raw_url" in item:
            gist_urls.append(str(item[11:-1]))
        if "filename" in item:
            files.append(str(item.split(":")[1][2:-1]))
    debug.trace(5, f"load() => {[gist_urls, files]}")
    
    return [gist_urls, files]


def write_gist(filename, text):
    """Writes text(gist) to filename"""
    debug.trace(4, f"write_gist({filename}, {gh.elide(text)})")

    fp = open(filename, mode='w', encoding='utf-8')
    fp.write(text)
    fp.close()


def download(permission, user, request, fileno):
    """Loads and writes all the gists to <em>dirname</em>"""
    debug.trace(4, f"download({permission}, {user}, {request}, {fileno})")

    ## OLD: if(permission == "yes" or permission == "no"):
    if permission in ["yes", "no"]:
        gist_urls, files = load(request)
        debug.trace_expr(6, gist_urls, files)
        ## OLD: dirname = user+"'s_gists/"
        dirname = user + "_gists/"
        create_directory(dirname)
        if(fileno[1] == "all"):
            for i in range(len(gist_urls)):
                gist = requests.get(gist_urls[i])
                write_gist(dirname+files[i], gist.text)
        else:
            for i in range(1,len(fileno)):
                gist = requests.get(gist_urls[int(fileno[i])])
                write_gist(dirname+files[int(fileno[i])], gist.text)


def detailed(urls, pos):
    """Prints out the contents of a file"""
    debug.trace(4, f"detailed({urls}, {pos})")

    gist = requests.get(urls[int(pos)])
    print(gist.text)


def main():
    """Authenticates and downloads gists according to user's choice"""
    debug.trace(4, "main()")
    
    # Show simple usage if --help given
    dummy_app = Main(description=__doc__, skip_input=False, manual_input=False)

    ask_auth, user, request = auth()
    urls, files = load(request)
    try:
        while(1):
            command = input("Enter your command: ").strip()
            debug.trace_expr(3, command)
            if ("download" in command):
                download(ask_auth, user, request, command.split(" "))
            elif ("detailed" in command):
                detailed(urls, command.split(" ")[1])
            elif (command == "show"):
                show(files)
            elif (command == "exit"):
                return
            elif (command == ""):
                pass
            else:
                system.print_error(f"Unknown command '{command}'\nUsage follows:{__doc__}")
    except:
        pass

if(__name__ == '__main__'):
    main()
