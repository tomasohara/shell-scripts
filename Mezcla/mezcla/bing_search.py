#! /usr/bin/env python
#
# Issues query via Bing Search API

# Notes:
# - The results can be cached to a local file to avoid using up search quota when
#   debugging with the same query. Multiple cached results are stored under temp dir.
# - Requires a Bing Search API key, which can be obtained via Windows Azure Marketplace:
#      https://datamarket.azure.com/account/keys
# - Currently only 1000 queries per month are allowed without fee. (Previously it was 5k!)
# - Based on http://www.guguncube.com/2771/python-using-the-bing-search-api.
# - Updgraded for Azure Cognitive Services:
#      https://docs.microsoft.com/en-us/azure/cognitive-services/bing-web-search/quickstarts/python
# - For the latest API as of Spring 2020, see
#      https://docs.microsoft.com/en-us/rest/api/cognitiveservices-bingsearch/bing-web-api-v7-reference
#
# TODO:
# - *** Have option to just show hit count. ***
# - Have option to just show results for misspelling (not Bing's replacement).
# - Have option to specify user agent.
# - Have option to download document for each result.
# - Make note of new Azure URL:
#   https://azure.microsoft.com/...
#

"""Issues queries via Bing Search API (using MS Azure Cognitive Services)"""

# Standard packages
## TEST: import base64
import json
import sys
from six.moves.urllib_parse import quote as quote_url       # pylint: disable=import-error
from six.moves.urllib.request import Request, build_opener  # pylint: disable=import-error
import tempfile

# Local packages
from mezcla import tpo_common as tpo
# TODO: import xml.dom.minidom
from mezcla import debug
from mezcla import system


BING_KEY = (tpo.getenv_value("BING_KEY", None,
                             "API key (via Microsoft Azure)") or "")
BING_BASE_URL = tpo.getenv_text("BING_BASE_URL",
                                "https://api.cognitive.microsoft.com/bing/v7.0/")
SEARCH = "search"
NEWS = "news/search"
IMAGES = "images"
VALID_SEARCH_TYPES = {SEARCH, IMAGES, "videos", NEWS}
DEFAULT_SEARCH_TYPE = SEARCH
SEARCH_TYPE = system.getenv_text("SEARCH_TYPE", SEARCH)

DEFAULT_TEMP_FILE = tempfile.NamedTemporaryFile().name
TEMP_FILE = system.getenv_text("TEMP_FILE", DEFAULT_TEMP_FILE)
DEFAULT_TEMP_DIR = tempfile.gettempdir()
TEMP_DIR = system.getenv_text("TEMP", DEFAULT_TEMP_DIR)

USE_CACHE = system.getenv_bool("USE_CACHE", False)

#...............................................................................

def bing_search(query, key=None, use_json=False, search_type=None, topn=None, non_phrasal=False):
    """Issue QUERY bing using API KEY returning result, optionally using JSON format or with alternative SEARCH_TYPE (e.g., image) or limited to TOPN results. The query is quoted unless NON_PHRASAL.
    Note: SEARCH_TYPE in {search, images, videos, news, SpellCheck}."""
    ## TODO: see if old search types RelatedSearch and Composite still supported
    tpo.debug_print("bing_search(%s, %s, %s, %s, %s)" % (query, key, use_json, search_type, topn), 4)
    if search_type is None:
        search_type = SEARCH_TYPE
    debug.assertion(search_type in VALID_SEARCH_TYPES)
    if key is None:
        key = BING_KEY
    full_query = query if non_phrasal else ("'" + query + "'")
    query_spec = quote_url(full_query)

    # Create credential for authentication
    # TODO: make user_agent an option, along with ip_address
    user_agent = "Nonesuch/1.0 (python)"
    ## TEST:
    ## try:
    ##     colon_key_bytes = (":" + key).encode("utf-8")
    ##     encoded_colon_key = base64.b64encode(colon_key_bytes)
    ## except(TypeError, ValueError):
    ##     system.print_stderr("Exception in bing_search: {exc}", exc=sys.exc_info())
    ##     encoded_colon_key = ":???"
    ## auth = "Basic %s" % encoded_colon_key

    # Format search URL with optional format and top-n specification
    debug.assertion(use_json)
    format_spec = ""
    topn_spec = ("&count=%d" % topn) if topn else ""
    tpo.debug_print("format_spec=%s topn_spec=%s" % (format_spec, topn_spec), 5)
    sources_spec = ""
    # HACK: if multiple types specified, comvert into Composite search
    if " " in search_type:
        sources = quote_url("'" + "+".join(search_type.split(" ")) + "'")
        sources = sources.replace("SpellingSuggestion", "spell").lower()
        sources_spec = "&Sources=" + sources
        search_type = "Composite"
    url_params = search_type + "?q=" + query_spec + sources_spec + topn_spec + format_spec
    url = BING_BASE_URL + "/" + url_params

    # Check cache if available
    response_data = None
    cache_file = system.form_path(TEMP_DIR, "_bs-" + url_params)
    if USE_CACHE and system.non_empty_file(cache_file):
        debug.trace_fmt(4, "Using cached results: {cf}", cf=cache_file)
        response_data = system.read_file(cache_file)
    
    # Download data from URL (unless cached).
    # Note: Also caches result
    if not response_data:
        tpo.debug_print("Accessing URL %s" % url, 3)
        request = Request(url)
        ## OLD: request.add_header("Authorization", auth)
        request.add_header("Ocp-Apim-Subscription-Key", key)
        request.add_header("User-Agent", user_agent)
        tpo.debug_print("Headers: %s" % request.header_items(), 5)
        request_opener = build_opener()
        response = request_opener.open(request) 
        response_data = response.read()
        if USE_CACHE:
            system.write_file(cache_file, response_data)

    # Format result
    tpo.debug_print("Response: %s" % response_data, 5)
    if use_json:
        json_result = json.loads(response_data)
        if debug.verbose_debugging():
            ## TODO: system.write_file(TEMP_FILE, str(json_result))
            ## TEST: hash_text = "\n".join([(str(k) + ": " + str(h)) for (k, h) in json_result.items()])
            ## system.write_file(TEMP_FILE, str(json_result))
            system.write_file(TEMP_FILE, system.to_string(response_data))
        ## TODO: result_list = json_result["webPages"]["value"]
        result_list = json_result
    else:
        result_list = response_data
        ## TODO: xml_result = xml.dom.minidom.parseString(response_data)
        ## TODO: result_list = xml_result.toprettyxml()
    return result_list

#...............................................................................

def main():
    """Entry point for script"""
    search_type = SEARCH
    use_json = True
    
    # Check command-line arguments (TODO: convert to main.py)
    i = 1
    show_usage = (i >= len(sys.argv))
    while (i < len(sys.argv) and (sys.argv[i][0] == "-")):
        if (sys.argv[i] == "--json"):
            use_json = True
        elif (sys.argv[i] == "--xml"):
            use_json = False
        elif (sys.argv[i] == "--image"):
            search_type = IMAGES
        elif (sys.argv[i] == "--type"):
            i += 1
            search_type = sys.argv[i]
        else:
            show_usage = True
        i += 1
    if (show_usage):
        print("Usage: %s [--json | --xml] [--image] [--type label] query_word ..." % sys.argv[0])
        print("Notes:")
        print("- Set BING_KEY to key from https://datamarket.azure.com/account/keys")
        print("- Types: Web, Image, Video, News, SpellingSuggestion, RelatedSearch")
        print("- For API details, see https://datamarket.azure.com/dataset/bing/search.")
        print("- The resuslt is XML file with <entry> tags for blurb info")
        sys.exit()
    debug.assertion(BING_KEY)

    # Issue query and print result
    query = " ".join(sys.argv[i:])
    print(bing_search(query, use_json=use_json, search_type=search_type))
    return


if __name__ == "__main__":
    main()
