#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# Micellaneous HTML utility functions, in particular with support for resolving HTML
# rendered via JavaScript (via selenium). This was motivated by the desire to extract
# images from pubchem.ncbi.nlm.nih.gov web pages for drugs (e.g., Ibuprofen, as
# illustrated below).
#
#-------------------------------------------------------------------------------
# Example usage:
#
# TODO: see what html_file should be set to
# $ PATH="$PATH:/usr/local/programs/selenium" DEBUG_LEVEL=6 MOZ_HEADLESS=1 $PYTHON html_utils.py "$html_file" > _html-utils-pubchem-ibuprofen.log7 2>&
# $ cd $TMPDIR
# $ wc *ibuprofen*
#     13   65337  954268 post-https%3A%2F%2Fpubchem.ncbi.nlm.nih.gov%2Fcompound%2FIbuprofen
#   3973   24689  178909 post-https%3A%2F%2Fpubchem.ncbi.nlm.nih.gov%2Fcompound%2FIbuprofen.txt
#     60    1152   48221 pre-https%3A%2F%2Fpubchem.ncbi.nlm.nih.gov%2Fcompound%2FIbuprofen
#
# $ count_it.perl "<img" pre-https%3A%2F%2Fpubchem.ncbi.nlm.nih.gov%2Fcompound%2FIbuprofen
# $ count_it.perl "<img" post-https%3A%2F%2Fpubchem.ncbi.nlm.nih.gov%2Fcompound%2FIbuprofen
# <img  7
#
# $ diff pre-https%3A%2F%2Fpubchem.ncbi.nlm.nih.gov%2Fcompound%2FIbuprofen post-https%3A%2F%2Fpubchem.ncbi.nlm.nih.gov%2Fcompound%2FIbuprofen
# ...
# <   <body>
# <     <div id="js-rendered-content"></div>
# ---
# > 
# >     <div id="js-rendered-content"><div class="relative flex-container-vertical"><header class="bckg-white b-bottom"><div class="bckg
# 54c7
# <     <script type="text/javascript" async src="/pcfe/summary/summary-v3.min.js"></script><!--<![endif]-->
# ---
# >     <script type="text/javascript" async="" src="/pcfe/summary/summary-v3.min.js"></script><!--<![endif]-->
# 58,60c11,13
# <     <script type="text/javascript" async src="https://www.ncbi.nlm.nih.gov/core/pinger/pinger.js"></script>
# <   </body>
#
#................................................................................
# Note:
#  - via https://dirask.com/posts/JavaScript-difference-between-innerHTML-and-outerHTML-MDg8mp:
#    The difference between innerHTML and outerHTML html:
#      innerHTML = HTML inside of the selected element
#      outerHTML = HTML inside of the selected element + HTML of the selected element
#-------------------------------------------------------------------------------
# TODO:
# - Standardize naming convention for URL parameter accessors (e.g., get_url_param vs. get_url_parameter).
# - Create class for selenium support (e.g., get_browser ... wait_until_ready).
# - * Use kawrgs to handle functions with common arguments (e.g., download_web_document, retrieve_web_document, and wrappers around them).
# 

"""HTML utility functions"""

# Standard packages
import re
import sys
import time
import urllib
from urllib.error import HTTPError, URLError

# Installed packages
# Note: selenium import now optional; BeautifulSoup also optional
## OLD: from selenium import webdriver
import requests

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re
from mezcla import system
from mezcla.system import write_temp_file

# Constants
DEFAULT_STATUS_CODE = "000"
MAX_DOWNLOAD_TIME = system.getenv_integer("MAX_DOWNLOAD_TIME", 60,
                                          "Time in seconds for rendered-HTML download as with get_inner_html")
## OLD: MID_DOWNLOAD_SLEEP_SECONDS = system.getenv_integer("MID_DOWNLOAD_SLEEP_SECONDS", 60)
MID_DOWNLOAD_SLEEP_SECONDS = system.getenv_integer("MID_DOWNLOAD_SLEEP_SECONDS", 15,
                                                   "Mid-stream delay if document not ready")
POST_DOWNLOAD_SLEEP_SECONDS = system.getenv_integer("POST_DOWNLOAD_SLEEP_SECONDS", 1,
                                                    "Courtesy delay after URL access--prior to download")
SKIP_BROWSER_CACHE = system.getenv_boolean("SKIP_BROWSER_CACHE", False,
                                           "Don't use cached webdriver browsers")
USE_BROWSER_CACHE = (not SKIP_BROWSER_CACHE)
DOWNLOAD_VIA_URLLIB = system.getenv_bool("DOWNLOAD_VIA_URLLIB", False,
                                         "Use old-style download via urllib instead of requests")
DOWNLOAD_VIA_REQUESTS = (not DOWNLOAD_VIA_URLLIB)
DOWNLOAD_TIMEOUT = system.getenv_float("DOWNLOAD_TIMEOUT", 5,
                                       "Timeout in seconds for request-based as with download_web_document")
HEADLESS_WEBDRIVER = system.getenv_bool("HEADLESS_WEBDRIVER", True,
                                        "Whether Selenium webdriver is hidden")
STABLE_DOWNLOAD_CHECK = system.getenv_bool("STABLE_DOWNLOAD_CHECK", False,
                                           "Wait until download size stablizes--for dynamic content")
HEADERS = "headers"
FILENAME = "filename"

# Globals
# note: for convenience in Mako template code
user_parameters = {}
issued_param_dict_warning = False

# Placeholders for dynamically loaded modules
BeautifulSoup = None

#-------------------------------------------------------------------------------
# HTML utility functions

browser_cache = {}
##
def get_browser(url):
    """Get existing browser for URL or create new one
    Notes: 
    - This is for use in web automation (e.g., via selenium).
    - A large log file might be produced (e.g., geckodriver.log).
    """
    browser = None
    global browser_cache
    debug.assertion(USE_BROWSER_CACHE, "Note: Browser automation without cache not well tested!")

    # Check for cached version of browser. If none, create one and access page.
    browser = browser_cache.get(url) if USE_BROWSER_CACHE else None
    if not browser:
        # HACK: unclean import (i.e., buried in function)
        from selenium import webdriver       # pylint: disable=import-error, import-outside-toplevel

        # Make the browser hidden by default (i.e., headless)
        # See https://stackoverflow.com/questions/46753393/how-to-make-firefox-headless-programmatically-in-selenium-with-python.
        # pylint: disable=import-outside-toplevel
        from selenium.webdriver.firefox.options import Options
        webdriver_options = Options()
        webdriver_options.headless = HEADLESS_WEBDRIVER
        browser = webdriver.Firefox(options=webdriver_options)
        debug.trace_object(5, browser)

        # Get the page, setting optional cache entry and sleeping afterwards
        if USE_BROWSER_CACHE:
            browser_cache[url] = browser
        browser.get(url)

        # Optionally pause after accessing the URL (to avoid overloading the same server).
        # Note: This assumes that the URL's are accessed sequentially. ("Post-download" is
        # a bit of a misnomer as this occurs before the download from browser, as in get_inner_html.)
        if POST_DOWNLOAD_SLEEP_SECONDS:
            time.sleep(POST_DOWNLOAD_SLEEP_SECONDS)
            
    # Make sure the bare minimum is included (i.e., "<body></body>"
    debug.assertion(len(browser.execute_script("return document.body.outerHTML")) > 13)
    debug.trace_fmt(5, "get_browser({u}) => {b}", u=url, b=browser)
    return browser


def get_inner_html(url):
    """Return the fully-rendered version of the URL HTML source (e.g., after JavaScript DOM manipulation)
    Note:
    - requires selenium webdriver (browser specific)
    - previously implemented via document.body.innerHTML (hence name)"""
    # Based on https://stanford.edu/~mgorkove/cgi-bin/rpython_tutorials/Scraping_a_Webpage_Rendered_by_Javascript_Using_Python.php
    # Also see https://stackoverflow.com/questions/8049520/web-scraping-javascript-page-with-python.
    # Note: The retrieved HTML might not match the version rendered in a browser due to a variety of reasons such as timing of dynamic updates and server controls to minimize web crawling.
    debug.trace_fmt(5, "get_inner_html({u})", u=url)
    try:
        # Navigate to the page (or get browser instance with existing page)
        browser = get_browser(url)
        # Wait for Javascript to finish processing
        wait_until_ready(url)
        # Extract fully-rendered HTML
        ## OLD: inner_html = browser.execute_script("return document.body.innerHTML")
        inner_html = browser.page_source
    except:
        inner_html = ""
        system.print_exception_info("get_inner_html")
    debug.trace_fmt(7, "get_inner_html({u}) => {h}", u=url, h=inner_html)
    return inner_html


def get_inner_text(url):
    """Get text of URL (i.e., without HTML tags) after JavaScript processing (via selenium)"""
    debug.trace_fmt(5, "get_inner_text({u})", u=url)
    # See https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/innerText
    try:
        # Navigate to the page (or get browser instance with existing page)
        browser = get_browser(url)
        # Wait for Javascript to finish processing
        wait_until_ready(url)
        # Extract fully-rendered text
        inner_text = browser.execute_script("return document.body.innerText")
    except:
        system.print_exception_info("get_inner_text")
    debug.trace_fmt(7, "get_inner_text({u}) => {it}", u=url, it=inner_text)
    return inner_text


def document_ready(url):
    """Determine whether document for URL has completed loading (via selenium)"""
    # See https://developer.mozilla.org/en-US/docs/Web/API/Document/readyState
    browser = get_browser(url)
    ready_state = browser.execute_script("return document.readyState")
    is_ready = (ready_state == "complete")
    debug.trace_fmt(6, "document_ready({u}) => {r}; state={s}",
                    u=url, r=is_ready, s=ready_state)
    return is_ready


def wait_until_ready(url, stable_download_check=STABLE_DOWNLOAD_CHECK):
    """Wait for document_ready (q.v.) and pause to allow loading to finish (via selenium)
    Note: If STABLE_DOWNLOAD_CHECK, the wait incoporates check for download size differences"""
    # TODO: make sure the sleep is proper way to pause
    debug.trace_fmt(5, "in wait_until_ready({u})", u=url)
    start_time = time.time()
    end_time = start_time + MAX_DOWNLOAD_TIME
    browser = get_browser(url)
    last_size = -1
    size = 0
    done = False

    # Wait until document ready and optionally that the size is the same after a delay
    while ((time.time() < end_time) and (not done)):
        done = document_ready(url)
        if (done and stable_download_check):
            size = len(browser.page_source)
            done = (size == last_size)
            debug.trace_fmt(5, "Stable size check: last={l} size={s} done={d}",
                            l=last_size, s=size, d=done)
            last_size = size
        if not done:
            debug.trace_fmt(6, "Mid-stream download sleep ({s} secs)", s=MID_DOWNLOAD_SLEEP_SECONDS)
            time.sleep(MID_DOWNLOAD_SLEEP_SECONDS)

    # Issue warning if unexpected condition
    if (not document_ready(url)):
        debug.trace_fmt(5, "Warning: time out ({s} secs) in accessing URL '{u}')'",
                        s=system.round_num(end_time - start_time, 1), u=url)
    elif (stable_download_check and (size > last_size)):
        debug.trace_fmt(5, "Warning: size not stable after {s} secs when accessing URL '{u}')'",
                        s=system.round_num(end_time - start_time, 1), u=url)
    debug.trace_fmt(5, "out wait_until_ready(); elapsed={t}s",
                    t=(time.time() - start_time))
    return
    

def escape_html_value(value):
    """Escape VALUE for HTML embedding"""
    return system.escape_html_text(value)


def unescape_html_value(value):
    """Undo escaped VALUE for HTML embedding"""
    return system.unescape_html_text(value)


def escape_hash_value(hash_table, key):
    """Wrapper around escape_html_value for HASH_TABLE[KEY] (or "" if missing).
    Note: newlines are converted into <br>'s."""
    escaped_item_value = escape_html_value(hash_table.get(key, ""))
    escaped_value = escaped_item_value.replace("\n", "<br>")
    debug.trace_fmtd(7, "escape_hash_value({h}, {k}) => '{r}'", h=hash_table, k=key, r=escaped_value)
    return escaped_value


def get_param_dict(param_dict=None):
    """Returns parameter dict using PARAM_DICT if non-Null else USER_PARAMETERS
       Note: """
    result = (param_dict if (param_dict is not None) else user_parameters)
    debug.trace(7, f"get_param_dict([pd={param_dict}]) => {result}")
    return result


def set_param_dict(param_dict):
    """Sets global user_parameters to value of PARAM_DICT"""
    # EX: set_param_dict({"param1": "a+b+c", "param2": "a%2Bb%2Bc"}); len(user_parameters) => 2
    debug.trace(7, f"set_param_dict({param_dict})")
    global issued_param_dict_warning
    global user_parameters

    # Make update, issuing warning if first time
    if not issued_param_dict_warning:
        issued_param_dict_warning = True
        debug.trace(5, "Warning: set_param_dict is not thread-safe")
    user_parameters = param_dict


def get_url_param(name, default_value=None, param_dict=None, escaped=False):
    """Get value for NAME from PARAM_DICT (e.g., USER_PARAMETERS), using DEFAULT_VALUE (normally "").
    Note: It can be ESCAPED for use in HTML."""
    if default_value is None:
        default_value = ""
    param_dict = (get_param_dict(param_dict) or {})
    value = param_dict.get(name, default_value)
    value = system.to_unicode(value)
    if escaped:
        value = escape_html_value(value)
    debug.trace_fmt(5, "get_url_param({n}, [{d}]) => {v})",
                    n=name, d=default_value, v=value)
    return value
#
get_url_parameter = get_url_param


def get_url_text(name, param_dict=None):
    """Get TEXT value for URL encoded parameter, using current PARAM_DICT"""
    # EX: get_url_text("param1") => "a b c"
    encoded_vaue = get_url_parameter(name, param_dict)
    value = unescape_html_value(system.unquote_url_text(encoded_vaue))
    debug.trace_fmt(6, "get_url_text({n}, [d={d}]) => {v})",
                    n=name, d=param_dict, v=value)
    return value
#
# EX: get_url_text("param2") => "a b c"
   

def get_url_param_checkbox_spec(name, default_value="", param_dict=None):
    """Get value of boolean parameters formatted for checkbox (i.e., 'checked' iff True or on) from PARAM_DICT
    Note: the value is only specified/submitted if checked"""
    # EX: get_url_param_checkbox_spec("param", param_dict={"param": "on"}) => "checked"
    # EX: get_url_param_checkbox_spec("param", param_dict={"param": "off"}) => ""
    # NOTE: 1 also treated as True
    # TODO: implement in terms of get_url_param
    param_dict = (get_param_dict(param_dict) or {})
    param_value = param_dict.get(name, default_value)
    param_value = system.to_unicode(param_value)
    ## OLD: value = "checked" if (param_value in [True, "on"]) else ""
    value = "checked" if (param_value in ["1", "on", True]) else ""
    debug.trace_fmtd(4, "get_url_param_checkbox_spec({n}, [{d}]) => {v})",
                     n=name, d=default_value, v=value)
    return value
#
get_url_parameter_checkbox_spec = get_url_param_checkbox_spec


def get_url_parameter_value(param, default_value=None, param_dict=None):
    """Get (last) value for PARAM in PARAM_DICT (or DEFAULT_VALUE)"""
    param_dict = (get_param_dict(param_dict) or {})
    result = param_dict.get(param, default_value)
    if isinstance(result, list):
        result = result[-1]
    debug.trace_fmtd(5, "get_url_parameter_value({p}, {dft}, _) => {r}",
                     p=param, dft=default_value, r=result)
    return result


def get_url_parameter_bool(param, default_value=False, param_dict=None):
    """Get boolean value for PARAM from PARAM_DICT, with "on" treated as True. @note the hash defaults to user_parameters, and the default value is False
    Note: Only treates {"1", "on", "True", True} as True.
    Warning: defaults with non-None values might return unintuitive results unless
    coerced to boolean beforehand.
    """
    # EX: get_url_parameter_bool("abc", False, { "abc": "on" }) => True
    # TODO: implement in terms of get_url_param and also system.to_bool
    ## OLD: result = (param_dict.get(param, default_value) in ["on", True])
    debug.assertion((default_value is None) or isinstance(default_value, bool))
    result = (get_url_parameter_value(param, default_value, param_dict)
              ## OLD: in ["1", "on", True])
              in ["1", "on", "True", True])
    ## HACK: result = ((system.to_unicode(param_dict.get(param, default_value))) in ["on", True])
    debug.trace_fmtd(4, "get_url_parameter_bool({p}, {dft}, _) => {r}",
                     p=param, dft=default_value, r=result)
    return result
#
get_url_param_bool = get_url_parameter_bool
#
# EX: get_url_param_bool("abc", False, { "abc": "True" }) => True


def get_url_parameter_int(param, default_value=0, param_dict=None):
    """Get integer value for PARAM from PARAM_DICT.
    Note: the hash defaults to user_parameters, and the default value is 0"""
    result = system.to_int(get_url_parameter_value(param, default_value, param_dict))
    debug.trace_fmtd(4, "get_url_parameter_int({p}, {dft}, _) => {r}",
                     p=param, dft=default_value, r=result)
    return result
#
get_url_param_int = get_url_parameter_int


def fix_url_parameters(url_parameters):
    """Uses the last values for any user parameter with multiple values
    and ensures dashes are used instead of underscores in the keys"""
    # EX: fix_url_parameters({'w_v':[7, 8], 'h_v':10}) => {'w-v':8, 'h-v':10}
    new_url_parameters = {p.replace("_", "-"):v for  (p, v) in url_parameters.items()}
    new_url_parameters = {p:(v[-1] if isinstance(v, list) else v) for (p, v) in new_url_parameters.items()}
    debug.trace_fmt(6, "fix_url_parameters({up}) => {new}",
                    up=url_parameters, new=new_url_parameters)
    return new_url_parameters


def expand_misc_param(misc_dict, param_name, param_dict=None):
    """Expands MISC_DICT to include separate keys for those in PARAM_DICT under PARAM_NAME
    Notes:
    - The parameter specification is comma separated. 
    - PARAM_DICT defaults to the global user_parameters (or MISC_DICT if unset): see set_param_dict.
    - This was added to support having multiple user parameters specified in an HTML field.
    """
    # EX: expand_misc_param({'x': 1, 'y': 2, 'z': 'a=3, b=4'}, 'z') => {'x': 1, 'y':, 2, 'z': 'a=3 b=4', 'a': '3', 'b': '4'}
    debug.trace(6, f"expand_misc_param({misc_dict}, {param_name}, {param_dict})")
    ## TODO: debug.trace_expr(6, misc_dict, param_name, param_dict=None, prefix="expand_misc_param: ")
    if param_dict is None:
        param_dict = (user_parameters or misc_dict)
    new_misc_dict = misc_dict
    misc_params = get_url_param(param_name, "", param_dict=param_dict)
    if (misc_params and ("=" in misc_params)):
        new_misc_dict = new_misc_dict.copy()
        for param_spec in re.split(", *", misc_params):
            try:
                param_key, param_value = param_spec.split("=")
                new_misc_dict[param_key] = param_value
            except:
                system.print_exception_info("expand_misc_param")
    debug.trace(5, f"expand_misc_param() => {new_misc_dict}")
    return new_misc_dict


def _read_file(filename, as_binary):
    """Wrapper around read_entire_file or read_binary_file if AS_BINARY"""
    debug.trace(8, f"_read_file({filename}, {as_binary})")
    read_fn = system.read_binary_file if as_binary else system.read_entire_file
    return read_fn(filename)


def _write_file(filename, data, as_binary):
    """Wrapper around write_file or write_binary_file if AS_BINARY"""
    debug.trace(8, f"_write_file({filename}, _, {as_binary})")
    write_fn = system.write_binary_file if as_binary else system.write_file
    return write_fn(filename, data)


def old_download_web_document(url, filename=None, download_dir=None, meta_hash=None, use_cached=False, as_binary=False, ignore=False):
    """Download document contents at URL, returning as unicode text (unless AS_BINARY)
    Notes: An optional FILENAME can be given for the download, an optional DOWNLOAD_DIR[ectory] can be specified (defaults to '.'), and an optional META_HASH can be specified for recording filename and headers. Existing files will be considered if USE_CACHED. If IGNORE, no exceptions reports are printed."""
    # EX: ("Search" in old_download_web_document("https://www.google.com"))
    # EX: ((url := "https://simple.wikipedia.org/wiki/Dollar"), (old_download_web_document(url) == download_web_document(url)))[-1]
    debug.trace_fmtd(4, "old_download_web_document({u}, d={d}, f={f}, h={mh}, cached={uc}, binary={ab})",
                     u=url, d=download_dir, f=filename, mh=meta_hash,
                     uc=use_cached, ab=as_binary)

    # Download the document and optional headers (metadata).
    # Note: urlretrieve chokes on URLS like www.cssny.org without the protocol.
    # TODO: report as bug if not fixed in Python 3
    if url.endswith("/"):
        url = url[:-1]
    if filename is None:
        filename = system.quote_url_text(gh.basename(url))
        debug.trace_fmtd(5, "\tquoted filename: {f}", f=filename)
    if "//" not in url:
        url = "http://" + url
    if download_dir is None:
        download_dir = "downloads"
    local_filename = gh.form_path(download_dir, filename)
    headers = ""
    status_code = DEFAULT_STATUS_CODE
    ok = False
    if DOWNLOAD_TIMEOUT:
        # HACK: set global socket timeout
        import socket                   # pylint: disable=import-error, import-outside-toplevel
        socket.setdefaulttimeout(DOWNLOAD_TIMEOUT)
    if use_cached and system.non_empty_file(local_filename):
        debug.trace_fmtd(5, "Using cached file for URL: {f}", f=local_filename)
    else:
        try:
            ## TEMP: issue separate call to get status code (TODO: figure out how to do after urlretrieve call)
            with urllib.request.urlopen(url) as fp:
                status_code = fp.getcode()
            local_filename, headers = urllib.request.urlretrieve(url, local_filename)      # pylint: disable=no-member
            debug.trace_fmtd(5, "=> local file: {f}; headers={{{h}}}",
                             f=local_filename, h=headers)
            ok = True
        except(HTTPError) as exc:
            status_code = exc.code
        except:
            ## TODO: except(IOError, UnicodeError, URLError, socket.timeout):
            debug.reference_var(URLError)
            if not ignore:
                system.print_exception_info("old_download_web_document")
    if not ok:
        local_filename = None
    if meta_hash is not None:
        meta_hash[FILENAME] = local_filename
        meta_hash[HEADERS] = headers
    debug.trace(5, f"status_code={status_code}")

    # Read all of the data and return as text
    data = _read_file(local_filename, as_binary) if local_filename else None
    debug.trace_fmtd(7, "old_download_web_document() => {d}", d=data)
    return data


def download_web_document(url, filename=None, download_dir=None, meta_hash=None, use_cached=False, as_binary=False, ignore=False):
    """Download document contents at URL, returning as unicode text (unless AS_BINARY).
    Notes: An optional FILENAME can be given for the download, an optional DOWNLOAD_DIR[ectory] can be specified (defaults to '.'), and an optional META_HASH can be specified for recording filename and headers. Existing files will be considered if USE_CACHED. If IGNORE, no exceptions reports are printed."""
    # EX: "currency" in download_web_document("https://simple.wikipedia.org/wiki/Dollar")
    # EX: download_web_document("www. bogus. url.html") => None
    ## TODO: def download_web_document(url, /, filename=None, download_dir=None, meta_hash=None, use_cached=False):
    debug.trace_fmtd(4, "download_web_document({u}, d={d}, f={f}, h={mh}, cached={uc}, binary={ab})",
                     u=url, d=download_dir, f=filename, mh=meta_hash,
                     uc=use_cached, ab=as_binary)

    if not DOWNLOAD_VIA_REQUESTS:
        return old_download_web_document(url, filename, download_dir, meta_hash, use_cached, as_binary, ignore=ignore)
    
    # Download the document and optional headers (metadata).
    # Note: urlretrieve chokes on URLS like www.cssny.org without the protocol.
    # TODO: report as bug if not fixed in Python 3
    if url.endswith("/"):
        url = url[:-1]
    if filename is None:
        ## TODO: support local filenames with subdirectories
        filename = system.quote_url_text(gh.basename(url))
        debug.trace_fmtd(5, "\tquoted filename: {f}", f=filename)
    if "//" not in url:
        url = "http://" + url
    if download_dir is None:
        download_dir = "downloads"
    if not gh.is_directory(download_dir):
        gh.full_mkdir(download_dir)
    local_filename = gh.form_path(download_dir, filename)
    if meta_hash is not None:
        meta_hash[FILENAME] = local_filename
    headers = "n/a"
    doc_data = ""
    if use_cached and system.non_empty_file(local_filename):
        debug.trace_fmtd(5, "Using cached file for URL: {f}", f=local_filename)
        doc_data = _read_file(local_filename, as_binary)
    else:
        doc_data = retrieve_web_document(url, meta_hash=meta_hash, as_binary=as_binary, ignore=ignore)
        if doc_data:
            _write_file(local_filename, doc_data, as_binary)
        if meta_hash:
            headers = meta_hash.get(HEADERS, "")
    debug.trace_fmtd(5, "=> local file: {f}; headers={{{h}}}",
                     f=local_filename, h=headers)

    ## OLD: debug.trace_fmtd(6, "download_web_document() => {d}", d=gh.elide(doc_data))
    ## TODO: show hex dump of initial data
    debug.trace_fmtd(6, "download_web_document() => _; len(_)={l}",
                     l=(len(doc_data) if doc_data else -1))
    return doc_data


def test_download_html_document(url, encoding=None, lookahead=256, **kwargs):
    """Wrapper around download_web_document for HTML or text (i.e., non-binary), using ENCODING.
    Note: If ENCODING unspecified, checks result LOOKAHEAD bytes for meta encoding spec and uses UTF-8 as a fallback."""
    # EX: "Google" in test_download_html_document("www.google.com")
    # EX: "Tomás" not in test_download_html_document("http://www.tomasohara.trade", encoding="big5"¨)
    result = (download_web_document(url, as_binary=True, **kwargs) or b"")
    if (len(result) and (not encoding)):
        encoding = "UTF-8"
        if my_re.search(r"<meta.*charset=[\"\']?([^\"\' <>]+)[\"\']?", str(result[:lookahead])):
            encoding = my_re.group(1)
            debug.trace(5, f"Using {encoding} for encoding based on meta charset")
    try:
        result = result.decode(encoding=encoding, errors='ignore')
    except:
        result = str(result)
        system.print_exception_info("download_html_document decode")
    debug.trace_fmtd(7, "test_download_html_document({u}, [enc={e}, lkahd={la}]) => {r}; len(_)={l}",
                     u=url, e=encoding, la=lookahead, r=gh.elide(result), l=len(result))
    return (result)


def download_html_document(url, **kwargs):
    """Wrapper around download_web_document for HTML or text (i.e., non-binary)"""
    result = (download_web_document(url, as_binary=False, **kwargs) or "")
    debug.trace_fmtd(7, "download_html_document({u}) => {r}; len(_)={l}",
                     u=url, r=gh.elide(result), l=len(result))
    return (result)


def download_binary_file(url, **kwargs):
    """Wrapper around download_web_document for binary files (e.g., images)"""
    result = (download_web_document(url, as_binary=True, **kwargs) or "")
    debug.trace_fmtd(7, "download_binary_file({u}) => _; len(_)={l}",
                     u=url, l=len(result))
    return (result)
    

def retrieve_web_document(url, meta_hash=None, as_binary=False, ignore=False):
    """Get document contents at URL, using unicode text (unless AS_BINARY)
    Note:
    - Simpler version of old_download_web_document, using an optional META_HASH for recording headers
    - Works around Error 403's presumably due to urllib's user agent
    - If IGNORE, no exceptions reports are printed."""
    # EX: re.search("Scrappy.*Cito", retrieve_web_document("www.tomasohara.trade"))
    # Note: See https://stackoverflow.com/questions/34957748/http-error-403-forbidden-with-urlretrieve.
    debug.trace_fmtd(5, "retrieve_web_document({u})", u=url)
    result = None
    status_code = DEFAULT_STATUS_CODE
    if "//" not in url:
        url = "http://" + url
    try:
        r = requests.get(url, timeout=DOWNLOAD_TIMEOUT)
        status_code = r.status_code
        result = r.content
        debug.assertion(isinstance(result, bytes))
        if not as_binary:
            result = result.decode(errors='ignore')
        if meta_hash is not None:
            meta_hash[HEADERS] = r.headers
    ## TODO: except(AttributeError, ConnectionError):
    except:
        if not ignore:
            system.print_exception_info("retrieve_web_document")
    debug.trace(5, f"status_code={status_code}")
    debug.trace_fmtd(7, "retrieve_web_document() => {r}", r=result)
    return result


def init_BeautifulSoup():
    """Make sure bs4.BeautifulSoup is loaded"""
    import bs4                           # pylint: disable=import-error, import-outside-toplevel
    global BeautifulSoup
    BeautifulSoup = bs4.BeautifulSoup
    return


def extract_html_link(html, url=None, base_url=None):
    """Returns list of all aref links in HTML. The optional URL and BASE_URL parameters can be specified to ensure the link is fully resolved."""
    debug.trace_fmtd(7, "extract_html_links(_):\n\thtml={h}", h=html)

    # Parse HTML, extract base URL if given and get website from URL.
    init_BeautifulSoup()
    soup = BeautifulSoup(html, 'html.parser')
    web_site_url = ""
    if url:
        web_site_url = re.sub(r"(https?://[^\/]+)/?.*", r"\1", url)
        debug.trace_fmtd(6, "wsu1={wsu}", wsu=web_site_url)
        if not web_site_url.endswith("/"):
            web_site_url += "/"
            debug.trace_fmtd(6, "wsu2={wsu}", wsu=web_site_url)
    # Determine base URL
    if base_url is None:
        base_url_info = soup.find("base")
        
        base_url = base_url_info.get("href") if base_url_info else None
        debug.trace_fmtd(6, "bu1={bu}", bu=base_url)
        if url and not base_url:
            # Remove parts of the URLafter the final slash
            base_url = re.sub(r"(^.*/[^\/]+/)[^\/]+$", r"\1", url)
            debug.trace_fmtd(6, "bu2={bu}", bu=base_url)
        if web_site_url and not base_url:
            base_url = web_site_url
            debug.trace_fmtd(6, "bu3={bu}", bu=base_url)
        if base_url and not base_url.endswith("/"):
            base_url += "/"
            debug.trace_fmtd(6, "bu4={bu}", bu=base_url)

    # Get links and resolve to full URL (TODO: see if utility for this)
    links = []
    all_links = soup.find_all('a')
    for link in all_links:
        debug.trace_fmtd(6, "link={inf}; style={sty}", inf=link, sty=link.attrs.get('style'))
        link_src = link.get("href", "")
        if not link_src:
            debug.trace_fmt(5, "Ignoring link without href: {img}", img=link)
            continue
        if link_src.startswith("/"):
            link_src = web_site_url + link_src
        elif base_url and not link_src.startswith("http"):
            link_src = base_url + "/" + link_src
        links.append(link_src)
    debug.trace_fmtd(6, "extract_html_links() => {i}", i=links)
    return links


def format_checkbox(param_name, label=None, default_value=False, disabled=False):
    """Returns HTML specification for input checkbox
    Warning: includes separate hidden field for explicit off state"""
    ## Note: Checkbox valuee are only submitted if checked, so a hidden field is used to provide explicit off.
    ## This requires use of html_utils.fix_url_parameters to give preference to final value specified (see results.mako).
    ## See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/checkbox for hidden field tip.
    ## Also see https://stackoverflow.com/questions/155291/can-html-checkboxes-be-set-to-readonly
    ## EX: format_checkbox("disable-touch") => '<label>Disable touch? <input id="disable-touch" type="checkbox" name="disable-touch" ></label>&nbsp;"'
    ## EX: format_checkbox("disable-touch", disabled=True) => '<label>Disable touch? <input id="disable-touch" type="checkbox" name="disable-touch" disabled></label>&nbsp;"'
    checkbox_spec = get_url_param_checkbox_spec(param_name, default_value)
    disabled_spec = ("disabled" if disabled else "")
    status_spec = f"{checkbox_spec} {disabled_spec}".strip()
    if (label is None):
        label = (param_name.replace("-", " ").capitalize() + "?")
    result = ""
    ## TODO: use hidden only if (default_value in ["1", "on", True])???
    result = f"<input type='hidden' name='{param_name}' value='off'>"
    result += f"<label>{label} <input type='checkbox' id='{param_name}-id' name='{param_name}' {status_spec}></label>&nbsp;"
    debug.trace(6, f"format_checkbox({param_name}, [def={default_value}]) => {result}")
    return result

def format_url_param(name):
    """Return URL parameter NAME formatted for an HTML form (e.g., escaped)"""
    # EX: html_utils.set_param_dict({"q": '"hot dog"'}); format_url_param("q") => '&quot;hot dog&quot;'
    value_spec = (get_url_param(name) or "")
    if value_spec:
        value_spec = system.escape_html_text(value_spec)
    debug.trace(5, f"format_url_param({name}) => {value_spec!r}")
    return value_spec

#-------------------------------------------------------------------------------

def main(args):
    """Supporting code for command-line processing"""
    debug.trace_fmtd(6, "main({a})", a=args)
    user = system.getenv_text("USER")
    system.print_stderr("Warning, {u}: this is not intended for direct invocation".format(u=user))

    # HACK: Do simple test of inner-HTML support
    # TODO: Do simpler test of download_web_document
    if (len(args) > 1):
        # Get web page text
        debug.trace_fmt(4, "browser_cache: {bc}", bc=browser_cache)
        url = args[1]
        debug.trace_expr(6, retrieve_web_document(url))
        html_data = download_web_document(url)
        filename = system.quote_url_text(url)
        if debug.debugging():
            write_temp_file("pre-" + filename, html_data)

        # Show inner/outer HTML
        # Note: The browser is hidden unless MOZ_HEADLESS false
        # TODO: Support Chrome
        ## OLD: wait_until_ready(url)
        ## BAD: rendered_html = render(html_data)
        system.setenv("MOZ_HEADLESS",
                      str(int(system.getenv_bool("MOZ_HEADLESS", True))))
        rendered_html = get_inner_html(url)
        if debug.debugging():
            write_temp_file("post-" + filename, rendered_html)
        print("Rendered html:")
        print(system.to_utf8(rendered_html))
        if debug.debugging():
            rendered_text = get_inner_text(url)
            debug.trace_fmt(5, "type(rendered_text): {t}", t=rendered_text)
            write_temp_file("post-" + filename + ".txt", rendered_text)
        debug.trace_fmt(4, "browser_cache: {bc}", bc=browser_cache)
    else:
        print("Specify a URL as argument 1 for a simple test of inner access")
    return

if __name__ == '__main__':
    main(sys.argv)
