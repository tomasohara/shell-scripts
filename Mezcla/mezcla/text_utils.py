#! /usr/bin/env python
#
# Miscellaneous text utility functions, such as for extracting text from
# HTML and other documents.
#
# Notes:
# - Modules in other directoriess rely upon this (e.g., ~/visual-search),
#   so do global search before making significant changes.
# - This is in the spirit of quick-n-dirty (e.g., for R&D: they are packages
#   that are better suited for industrial strength code (e.g., for production).
#
# Usage examples:
#
#   from mezcla import debug
#   from mezcla import text_utils
#
#   import tensorflow
#   from mezcla.text_utils import version_to_number as version2num
#   debug.assertion(version2num(tensorflow.__version__) <= version2num("1.15"))
#
#   devlin_text = document_to_text("devlin-bert-pretraining-arxiv-1810-04805-dec19.pdf")
#   str(devlin_text).count("BERT")
#   => 117
#
# TODO:
# - Write up test suite, el tonto!.
# - Add pointer to specific packages better for production use.
# - Move HTML-specific functions into html_utils.py.
#

"""Miscellaneous text utility functions"""

# Library packages
import re
import six
import sys

# Installed packages
## HACK: temporarily make these conditional
## from bs4 import BeautifulSoup
## import textract

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re
from mezcla import system
from mezcla.system import to_int

# TEMP: Placeholders for dynamically loaded modules
BeautifulSoup = None
textract = None

def init_BeautifulSoup():
    """Make sure bs4.BeautifulSoup is loaded"""
    import bs4                           # pylint: disable=import-outside-toplevel, import-error
    global BeautifulSoup
    BeautifulSoup = bs4.BeautifulSoup


def extract_soup_text_with_breaks(soup):
    """Extract text from SOUP parse, accounting for implicit newlines"""
    # TODO: def extract_soup_text(soup: bs4.Tag) -> str:
    # Based on https://stackoverflow.com/questions/30337528/make-beautifulsoup-handle-line-breaks-as-a-browser-would
    debug.trace_fmtd(6, f"extract_soup_text({soup})")
    _inline_elements = {"a", "span", "em", "strong", "u", "i", "font", "mark", "label", "s",
                        "sub", "sup", "tt", "bdo", "button", "cite", "del", "b"}
    import bs4                           # pylint: disable=import-outside-toplevel, import-error

    # Define helper function for generating text
    def _get_text(tag):
        """Helper generator"""
        # TODO: def _get_text(tag: bs4.Tag) -> Generator:
        for child in tag.children:
            if isinstance(child, bs4.Tag):
                # if the tag is a block type tag then yield new lines before after
                is_block_element = (child.name not in _inline_elements)
                if is_block_element:
                    yield "\n"
                # note: 'yield from' used due to recursive invocation
                # TODO: see whether <br> produces extraneous newlines
                yield from (["\n"] if (child.name == "br") else  _get_text(child))
                if is_block_element:
                    yield "\n"
            elif isinstance(child, bs4.NavigableString):
                yield child.string
            else:
                debug.assertion(not ("".join(_get_text(child))).strip())

    # Extract all the text
    result = "".join(_get_text(soup))    
    debug.trace_fmtd(6, f"extract_soup_text() => {result}")
    return result


def html_to_text(document_data):
    """Returns text version of html DATA"""
    # EX: html_to_text("<html><body><!-- a cautionary tale -->\nMy <b>fat</b> dog has fleas</body></html>") => "My fat dog has fleas"
    # Note: stripping javascript and style sections based on following:
    #   https://stackoverflow.com/questions/22799990/beatifulsoup4-get-text-still-has-javascript
    # TODO: move into html_utils.py
    debug.trace_fmtd(7, "html_to_text(_):\n\tdata={d}", d=document_data)
    ## OLD: soup = BeautifulSoup(document_data)
    init_BeautifulSoup()
    soup = BeautifulSoup(document_data, "lxml")
    # Remove all script and style elements
    for script in soup(["script", "style"]):
        # *** TODO: soup = soup.extract(script)
        # -or- Note the in-place change (i.e., destructive).
        script.extract()
    # Get the text
    ## OLD: text = soup.get_text()
    text = soup.get_text(separator=" ")
    debug.trace_fmtd(6, "html_to_text() => {t}", t=gh.elide(text))
    return text


def init_textract():
    """Make sure textract is loaded"""
    import textract as ex                # pylint: disable=import-outside-toplevel, import-error
    global textract
    textract = ex


def document_to_text(doc_filename):
    """Returns text version of document FILENAME of unspecified type"""
    text = ""
    try:
        init_textract()
        ## OLD: text = system.from_utf8(textract.process(doc_filename))
        text = textract.process(doc_filename)
        if isinstance(text, bytes):
            text = text.decode("UTF-8", errors="ignore")
    except:
        debug.trace_fmtd(3, "Warning: problem converting document file {f}: {e}",
                         f=doc_filename, e=sys.exc_info())
    debug.trace_fmt(5, "document_to_text({fn}) => {r}",
                    fn=doc_filename, r=gh.elide(text))
    return text


def extract_html_images(document_data, url):
    """Returns list of all images in HTML DOC from URL (n.b., URL used to determine base URL)"""
    debug.trace_fmtd(8, "extract_html_images(_):\n\tdata={d}", d=document_data)
    # TODO: add example; return dimensions
    # TODO: have URL default to current directory
    # TODO: put in html_utils

    # Parse HTML, extract base URL if given and get website from URL.
    init_BeautifulSoup()
    soup = BeautifulSoup(document_data, 'html.parser')
    web_site_url = re.sub(r"(https?://[^\/]+)/?.*", r"\1", url)
    debug.trace_fmtd(6, "wsu1={wsu}", wsu=web_site_url)
    if not web_site_url.endswith("/"):
        web_site_url += "/"
        debug.trace_fmtd(6, "wsu2={wsu}", wsu=web_site_url)
    base_url_info = soup.find("base")
    base_url = base_url_info.get("href") if base_url_info else None
    debug.trace_fmtd(6, "bu1={bu}", bu=base_url)
    if not base_url:
        # Remove parts of the URLafter the final slash
        # TODO: comment and example
        base_url = re.sub(r"(^.*/[^\/]+/)[^\/]+$", r"\1", url)
        debug.trace_fmtd(6, "bu2={bu}", bu=base_url)
    if not base_url:
        base_url = web_site_url
        debug.trace_fmtd(6, "bu3={bu}", bu=base_url)
    if not base_url.endswith("/"):
        base_url += "/"
        debug.trace_fmtd(6, "bu4={bu}", bu=base_url)

    # Get images and resolve to full URL (TODO: see if utility for this)
    # TODO: include CSS background images
    # TODO: use DATA-SRC if SRC not valid URL (e.g., src="data:image/gif;base64,R0lGODl...")
    images = []
    all_images = soup.find_all('img')
    for image in all_images:
        debug.trace_fmtd(6, "image={inf}; style={sty}", inf=image, sty=image.attrs.get('style'))
        ## TEST: if (image.has_attr('attrs') and (image.attrs.get['style'] in ["display:none", "visibility:hidden"])):
        if (image.attrs.get('style') in ["display:none", "visibility:hidden"]):
            debug.trace_fmt(5, "Ignoring hidden image: {img}", img=image)
            continue
        image_src = image.get("src", "")
        if not image_src:
            debug.trace_fmt(5, "Ignoring image without src: {img}", img=image)
            continue
        if image_src.startswith("/"):
            image_src = web_site_url + image_src
        elif not image_src.startswith("http"):
            image_src = base_url + "/" + image_src
        ## TEMP: fixup for trailing newline (TODO: handle upstream)
        image_src = image_src.strip()
        if image_src not in images:
            images.append(image_src)
    debug.trace_fmtd(6, "extract_html_images() => {i}", i=images)
    return images


def version_to_number(version, max_padding=3):
    """Converts VERSION to number that can be used in comparisons
    Note: The Result will be of the form M.mmmrrrooo..., where M is the
    major number m is the minor, r is the revision and o is other.
    Each version component will be prepended with up MAX_PADDING [3] 0's
    Notes:
    - comparisons should be made against using functional constant, not number:
      EX: version_to_number("1.1.1") > version_to_number("1.1")
      EX: version_to_number("1.1.1") < 1.1
    - strings in the version are ignored
    - 0 is returned if version string is non-standard"""
    # EX: version_to_number("1.11.1") => 1.00110001
    # EX: version_to_number("1") => 1
    # EX: version_to_number("") => 0
    # TODO: support string (e.g., 1.11.2a).
    version_number = 0
    version_text = version
    new_version_text = ""
    max_component_length = (1 + max_padding)
    debug.trace_fmt(5, "version_to_number({v})", v=version)

    # HACK: Remove newlines
    # EX: "3.7.6 (default, Jan  8 2020, 19:59:22)<NL>[GCC 7.3.0]"
    if my_re.search(r"^([^\n]+)\n", version_text):
        debug.trace_fmt(5, "Removing pesky newline: '{vt}' => '{nvt}'", vt=version_text, nvt=my_re.group(1))
        version_text = my_re.group(1)

    # Remove all non-numeric components, after initial number-like value
    # ex: "3.7.6 (default, Jan  8 2020, 19:59:22" => "3.7.6"
    ## DEBUG: debug.trace_fmt(6, "stripped sys.version: {v}", v=re.sub(r"[^0-9\.]", "", sys.version))
    ## BAD: version_text = re.sub(r"[^0-9\.]", "", version_text)
    version_text = re.sub(r"^([0-9\.]+)[^0-9\.].*", r"\1", version_text, flags=re.DOTALL)
    if (version_text != version):
        debug.trace_fmt(3, "Warning: stripped non-numeric suffix from version: '{v}' => '{nv}'", 
                        v=version, nv=version_text)
    debug.assertion(not re.search(r"[^0-9\.]", version_text))

    # Convert component numbers iteratively and zero-pad if necessary
    # NOTE: Components greater than max-padding + 1 treated as all 9's.
    debug.trace_fmt(4, "version_text: '{vt}'", vt=version_text)
    first = True
    num_components = 0
    ## BAD: regex = r"^(\d+)(\.((\d*).*))?$"
    regex = r"^(\d+)\.?((\d*).*)?$"
    while (my_re.search(regex, version_text)):
        component = my_re.group(1)
        # TODO: fix my_re.group to handle None as ""
        version_text = my_re.group(2) if my_re.group(2) else ""
        num_components += 1
        debug.trace_fmt(4, "remaining version_text: {vt}", vt=version_text)

        component = system.to_string(system.to_int(component))
        if first:
            new_version_text = component + "."
            ## OLD: regex = r"^(\d+)\.?((\d*).*)$"
            first = False
        else:
            # If component exceeds max length, replace with max value (e.g., "12345" => "9999")
            if (len(component) > max_component_length):
                old_component = component
                component = "9" * max_component_length
                debug.trace_fmt(2, "Warning: replaced overly long component #{n} '{oc}' with '{nc}'",
                                n=num_components, oc=old_component, nc=component)
            # Otherwise, zero-fill the component text (e.g., "12" => "0012")
            else:
                component = "0" * (max_component_length - len(component)) + component
            new_version_text += component
        debug.trace_fmt(4, "Component {n}: '{c}'", n=num_components, c=component)
        debug.trace_fmt(4, "new_version_text: '{nvt}'", nvt=new_version_text)
    debug.assertion(not re.search(r"^[0-9\.]", version_text))

    version_number = system.to_float(new_version_text, version_number)
    ## TODO:
    ## if (my_re.search(p"[a-z]", version_text, re.IGNORECASE)) {
    ##     version_text = my_re.... 
    ## }
    debug.trace_fmt(4, "version_to_number({v}) => {n}", v=version, n=version_number)
    return version_number


def extract_string_list(text):
    """Extract list of string values in TEXT string separated by spacing or a comma.
    Note: quotes can be used if there are embedded spaces"""
    ## OLD: Note: the string values currently cannot be quoted (i.e., no embedded spaces)."""
    # EX: extract_string_list("1, 2,3 4") => ['1', '2', '3', '4']
    # EX: extract_string_list(" ") => []
    # EX: extract_string_list(",,") => []
    # EX: extract_string_list("'my dog'  likes  'my  hot  dog'") => ['my dog', 'likes', 'my  hot  dog']

    # Convert commas and whitespace to be blanks
    normalized_text = text.replace(",", " ").strip()
    normalized_text = re.sub(r"\s", " ", normalized_text)
    debug.trace_fmtd(6, "normalized_text1: {nt}", nt=normalized_text)

    # Change spaces within embedded quotes to be new-page (i.e., ^L)
    max_tries = 1 + text.count(" ")
    num_tries = 0
    quoted_space_regex = r"(['\"])([^ '\"]+) ([^'\"]+)\1"
    while (num_tries < max_tries):
        num_tries += 1
        new_normalized_text = re.sub(quoted_space_regex, r"\1\2\f\3\1", normalized_text)
        if (new_normalized_text == normalized_text):
            break
        normalized_text = new_normalized_text
        debug.trace_fmtd(7, "sub{i}: {nt}", i=num_tries, nt=normalized_text)
    debug.assertion(num_tries <= max_tries)
    debug.trace_fmtd(6, "num_tries={nt}; max_tries={mt}", nt=num_tries, mt=max_tries)
    debug.trace_fmtd(6, "normalized_text2: {nt}", nt=normalized_text)

    # Change other spaces to be tab delimited then restore spaces.
    normalized_text = re.sub(" +", "\t", normalized_text)
    normalized_text = re.sub("\f", " ", normalized_text)
    debug.trace_fmtd(6, "normalized_text3: {nt}", nt=normalized_text)
    
    # Split based on tabs and remove outer quotes
    ## OLD: value_list = re.split(" +", normalized_text)
    value_list = re.split("\t", normalized_text)
    if (value_list == [""]):
        value_list = []
    for (i, value) in enumerate(value_list):
        if re.search("^" + quoted_space_regex + "$", value):
           value_list[i] = value[1:-1]
    debug.assertion("" not in value_list)
    debug.trace_fmtd(5, "extract_string_list({t}) => {vl}", t=text, vl=value_list)
    return value_list


def extract_int_list(text, default_value=0):
    """Extract list of integral values from comma and/or whitespace delimited TEXT using DEFAULT_VALUE for non-integers (even if floating point)"""
    return [to_int(v, default_value) for v in extract_string_list(text)]


def getenv_ints(var, default_values_spec):
    """Get integer list using values specified for environment VAR (or DEFAULT_VALUES_SPEC)"""
    # EX: getenv_ints("DUMMY VARIABLE", str(list(range(5)))) => [0, 1, 2, 3, 4]
    return extract_int_list(system.getenv_text(var, default_values_spec))


def is_symbolic(token):
    """Indicates whether (string) token is symbolic (e.g., non-numeric like "ABC").
    Note: for convenience, tokens can be numeric types (e.g., 17), with False returned."""
    # EX: is_symbolic("PI") => True
    # EX: is_symbolic("3.14159") => False
    # EX: is_symbolic("123") => False
    # EX: is_symbolic(123) => False
    # EX: is_symbolic(0.1) => False
    # TODO: add support for complex numbers
    in_token = token
    result = True
    try:
        if isinstance(token, six.string_types):
            token = token.strip()
        # Note: if an exception is not triggered, the token is numeric
        if (float(token) or int(token)):
            debug.trace_fmt(6, "is_symbolic: '{t}' is numeric", t=token)
        result = False
    except (TypeError, ValueError):
        pass
    debug.trace_fmt(7, "is_symbolic({t}) => {r})", t=in_token, r=result)
    return result


def make_fixed_length(text, length=16):
    """Return TEXT with padding up to LENGTH chars; similar to str.ljust except for trucation"""
    # ex: make_fixed_length("fubar", 3) => "fub"
    # ex: make_fixed_length("fub", 5) => "fub  "
    result = text.ljust(length)[:length]
    debug.trace_fmt(7, "make_fixed_length({t}, [len={l}]) => {r}",
                    t=text, l=length, r=result)
    return result

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    system.print_stderr("Warning: not intended for command-line use")
    debug.assertion("html" not in html_to_text("<html><body></body></html>"))
