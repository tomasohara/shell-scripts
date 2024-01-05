#! /bin/csh -f
#
# do_tex.sh: front-end script for running TeX optionally w/ BibTex.
# This has evolved into a kitchen-sink typoe script for tex processing.
# It also includes support for producing indexes, viewing the output
# via ghostview, and converting the result into html via latex2html.
#
# Usual data files produced:
#    file.dvi	tex output file (i.e., DeVice Independent output)
#    file.ps	postscript output file
#    file.log	log file produced by tex
#
# Other data files produced:
#    file.list	output from the latex command??? (a subset of file.log)
#    file.aux	tex intermediate file with cross-reference info, etc.
#    file.bbl	preprocessed bibliography file (output of bibtex)
#    file.blg   log file from bibtex
#    file.idx   index produced by \makeindex statement
#    file.latex2html  log from latex2html
#
# TODO:
# - Add support for diagnosing errors due to missing style files:
#   (eg, mysterious "LaTeX Error: File `r.ent' not found." error message [endnotes.sty]).
# - Rename to do_latex.sh since TeX proper not supported.
#

# Uncomment following for command tracing (for use in script debugging)
## set echo=1


# Set defaults for the script options
#
set run_dvips = 1
set view = 0
set tex_command = "latex"
set ignore_errors = 0
set make_clean = 0
set just_clean = 0
set real_clean = 0
set landscape = 0
set do_biblio = 0
set do_index = 0
set a4 = 0
set do_html = 0
set context = 0
set latex2html = `printenv LATEX2HTML`
if ("$latex2html" == "") set latex2html = latex2html
set latex2html_options = `printenv LATEX2HTML_OPTIONS`
set pdf = 0
set ascii = 0
set spell = 0
set show_warnings = 1
set verbose_mode = 0
set check_vbox = 0
set check_hbox = 0

# Show usage statement if no arguments given
#
if ("$1" == "") then
    set script = `basename $0`
    echo ""
    echo "Usage: do_tex.sh [options] source_file"
    echo ""
    echo "options = [--no-ps] [--no-view] [--slides]  [--biblio] [--index]"
    echo "          [--pdf | --pdflatex] [--html] [--view] [--plain] [--landscape] [--a4]"
    echo "          [--clean] [--verbose] [--no-warnings] [--ignore] [--ascii] [--spell]"
    echo "          [--[no-]check-vbox] [--[no-]check-hbox] [--just-clean] [--real-clean]"
    echo ""
    echo "environment variables:"
    echo "    LATEX2HTML_OPTIONS: options for latex2html"
    echo "    TEXINPUTS: directories for LaTeX style files"
    echo ""
    echo "examples:"
    echo ""
    echo "$script --index hector_entries.tex"
    echo ""
    echo "$script --clean --biblio --check-vbox `basename $PWD`.tex 2>&1 | less"
    echo ""
    # Latex2html options
    # -link N: Stop revealing child nodes at each node at this depth
    # -split N: Stop splitting sections into separate files at this depth
    # -address [S]: Sign each page with this address
    # -info [S]: text used for 'About this document ...' section; disabled if empty
    ## echo "Note: subsection pages till level L4; subcontents links until L2; no address & info pages."
    echo "Note: no inline images; no address & info pages."
    echo "export LATEX2HTML_OPTIONS='-local_icons -address -info'"
    echo "$script --html `dirname $PWD`"
    echo ""
    exit
endif

# Determine the file for the TeX source & any optional settings
#
while ("$1" =~ --*) 
    if ("$1" == "--no-ps") then
        set run_dvips = 0
        set view = 0
    else if ("$1" == "--no-view") then
        set view = 0
    else if ("$1" == "--pdflatex") then
        set tex_command = "pdflatex"
    else if ("$1" == "--view") then
        set view = 1
    else if ("$1" == "--slides") then
        set tex_command = "slitex"
    else if ("$1" == "--plain") then
        set tex_command = "tex"
    else if ("$1" == "--ignore") then
        set ignore_errors = 1
    else if ("$1" == "--force") then
        set ignore_errors = 1
    else if ("$1" == "--landscape") then
        set landscape = 1
    else if ("$1" == "--a4") then
        set a4 = 1
    else if ("$1" == "--clean") then
        set make_clean = 1
    else if ("$1" == "--just-clean") then
        set make_clean = 1
        set just_clean = 1
    else if ("$1" == "--just-clean") then
        set make_clean = 1
        set just_clean = 1
    else if ("$1" == "--real-clean") then
        set make_clean = 1
        set real_clean = 1
    else if ("$1" == "--biblio") then
        set do_biblio = 1
    else if ("$1" == "--index") then
        set do_index = 1
    else if ("$1" == "--html") then
        set do_html = 1
    else if ("$1" == "--pdf") then
        set pdf = 1
    else if ("$1" == "--ascii") then
        set ascii = 1
    else if ("$1" == "--spell") then
        set spell = 1
        set ascii = 1
    else if ("$1" == "--no-warnings") then
        set show_warnings = 0
    else if ("$1" == "--trace") then
	set echo = 1
    else if ("$1" == "--verbose") then
        set verbose_mode = 1
        set context = 3
        set check_hbox = 1
        set check_vbox = 1
    else if ("$1" == "--check-hbox") then
        set check_hbox = 1
    else if ("$1" == "--check-vbox") then
        set check_vbox = 1
    else if ("$1" == "--no-check-hbox") then
        set check_hbox = 0
    else if ("$1" == "--no-check-vbox") then
        set check_vbox = 0
    else
        echo "ERROR: unknown option $1"
    endif
    shift
end

# Determine the file name for the latex source
# TODO: simplify check for assumed .tex/.latex extension
set text_source = $1
set latex_exts="tex latex .tex .latex"
if (! -e "$text_source") then
    foreach ext ($latex_exts)
	if (-e "$text_source$ext") then
	    set text_source = "${1}$ext"
	    break
	endif
    end
endif
if (! -e "$text_source") then
    echo "ERROR: Unable to find $text_source or file w/ following extensions: $latex_exts"
    exit 1
endif

# Determine the name without directory and extensions
## set file_base = `basename $text_source .tex`
set file_base = `echo "$text_source" | perl -pe 's/\.[^\.]+$//;'`
if ($?TMP == 0) set TMP = /tmp
set temp_file_base = $TMP/`basename $file_base`

# Run the TeX source through LaTeX
# TODO: try to be compatible w/ tcsh
# example: echo r | latex role-inventory.tex > /tmp/role-inventory.list
#
if ($make_clean) then
    # Determine whether any of the latex temporary files need to be deleted
    # TODO: handle spaces and other shell special characters in the filename
    # TODO: add .cb??
    set deletion = "$file_base.aux $file_base.ent $file_base.error $file_base.fff $file_base.lof $file_base.log $file_base.lot $file_base.toc $file_base.ttt $file_base.warning $file_base.bbl $file_base.blg $file_base.qry  $file_base.latex2html $temp_file_base.error $temp_file_base.warning $temp_file_base.list"
    if ($real_clean) then
	set deletion = "$deletion $file_base.ps $file_base.dvi $file_base.pdf"
    endif
    set do_deletion = 0
    foreach file ($deletion)
	if (-e "$file") set do_deletion = 1
    end

    # Proceed with deletion if at least one temporary file
    # NOTE: This way the user is alarmed if the cleanup is down in wrong directory, etc.
    if ($do_deletion) then
	if ($verbose_mode || $just_clean) echo "issuing: rm -f -v $deletion"
	rm -f $deletion
    else
	echo "No latex temporary files to delete for $text_source"
    endif
    if ($just_clean) then
	echo "Just cleaned up tex files"
	exit
    endif
endif
if ($verbose_mode) echo "issuing: $tex_command $text_source"
echo r | $tex_command $text_source > $temp_file_base.list

# Check for errors in the latex processing. These are indicated
# by ! in the latex file
#
# example:
# ! Undefined control sequence.
# l.233 \inc
#           {upper-cyc-role-inventory}
#
# Note that latex/tex doesn't flag a missing include as an error,
# instead just displaying a warning. However, since the same warning
# occurs for .aux files (cross-reference listing, etc.) and .bbl files
# (preprocessed bibliography), the 'no file'  warning is only treated 
# as an error if the extension is .tex or .latex.
#
# example:
# No file da-upper-cyc-role-inventory.tex.
#
# Note: other errors just mention the filename and linenumber
# ex: "./womrad-chord-sequence-meaning.tex:566: Extra }, or forgotten $."
# TODO: show above only in show-warning mode
#
set ok = 1
egrep -i '(^\!)|(LaTeX Error)' $file_base.log > $temp_file_base.error
if ($show_warnings) then
    # TODO: collote with above (e.g., by repeating above pattern); check for a revision elsewhere that handles this
    ## OLD: egrep -i '(\.l?a?tex:[0-9]+:)' $file_base.log >> $temp_file_base.error
    egrep -i '(\.\w+:[0-9]+:)' $file_base.log >> $temp_file_base.error
endif

# Display the errors that have occurred. This also shows which files are being included
# to help with the error diagnosis.
# TODO:
# - check for absolute filenames in inclusion spec
#
if (-Z $temp_file_base.error) then
    set grep_options="-A1 "
    if ($verbose_mode) set grep_options="$grep_options -B$context -A$context"
    ## OLD: egrep $grep_options '((^\!)|(^l.[0-9]+)|(^\(.*.(la)?tex( \[[0-9]+.*)?$)|(LaTeX Error))' $file_base.log
    ## OLD: egrep $grep_options '((^\!)|(^l.[0-9]+)|(^\(.*.(la)?tex( \[[0-9]+.*)?$)|(LaTeX Error)|(\.l?a?tex:[0-9]+:))' $file_base.log
    egrep $grep_options '((^\!)|(^l.[0-9]+)|(^\(.*\.\w+( \[[0-9]+.*)?$)|(LaTeX Error)|(\.\w+:[0-9]+:))' $file_base.log
    set ok = 0

    # Quit if there are any errors
    if ($ignore_errors == 0) then
	echo "Error in latex processing; check log ($file_base.log)"
	echo ""
	exit 1
    endif
endif

# Optionally produce the index in file.idx
# example: makeindex role-inventory.idx
#
if ($do_index == 1) then
    if ($verbose_mode) echo "issuing: makeindex ${file_base}.idx"
    makeindex ${file_base}.idx
    if ($verbose_mode) echo "re-issuing: $tex_command $text_source"
    echo r | $tex_command $text_source > $temp_file_base.list
endif

# Optionally process the .bib file specified in the \bibliography statement,
# producing file.bbl
# note: latex is run again so that new references can be incorporate
# Actually, it is run twice for good measure.
#
# example: bibtex role-inventory
#
if ($do_biblio) then
    if ($verbose_mode) echo "issuing:  bibtex $file_base"
    bibtex $file_base
    if ($verbose_mode) echo "re-issuing: $tex_command $text_source"
    echo r | $tex_command $text_source > $temp_file_base.list
    if ($verbose_mode) echo "re-re-issuing: $tex_command $text_source"
    echo r | $tex_command $text_source > $temp_file_base.list
    if ($make_clean) then
	if ($verbose_mode) echo "re-re-re-issuing: $tex_command $text_source"
	echo r | $tex_command $text_source > $temp_file_base.list
    endif
endif

# Show warnings
# NOTE:
# - This is done after bibtex and then re-issue of latex to
# avoid spurious warnings due to not-yet-defined references.
# - If warnings are found, then additional information is also show
#   (eg, locations in the source file mention in the log). This
#   leads to a little redundancy in the support code below.
# TODO:
# - Integrate this with the error-checking code above???
# - Check for absolute filenames in inclusion spec.
#
# First, determine if there were any warnings
egrep '(LaTeX.*Warning)|(WARNING)' $file_base.log > $temp_file_base.warning
if ($do_biblio) grep "^Warning" $file_base.blg >> $temp_file_base.warning
if ($check_vbox) grep "Overfull \\vbox"  $file_base.log >> $temp_file_base.warning
if ($check_hbox) grep "Overfull \\hbox"  $file_base.log >> $temp_file_base.warning
# 
# If so, then show the warnings along with file context information
if ($show_warnings && (-Z $temp_file_base.warning)) then
    ## OLD: egrep '(LaTeX.*Warning)|(WARNING)|(^\(.*.(la)?tex( \[[0-9]+.*)?$)' $temp_file_base.list
    egrep '(LaTeX.*Warning)|(WARNING)|(^\(.*\.\w+( \[[0-9]+.*)?$)' $temp_file_base.list
    # TODO: integrate the regex patterns below into the main egrep pattern
    # (in order to eliminate redundant file name output)
    ## OLD: if ($check_vbox) egrep '(Overfull \\vbox)|(^\(.*.(la)?tex( \[[0-9]+.*)?$)' $temp_file_base.list
    ## OLD: if ($check_hbox) egrep '(Overfull \\hbox)|(^\(.*.(la)?tex( \[[0-9]+.*)?$)' $temp_file_base.list
    if ($check_vbox) egrep '(Overfull \\vbox)|(^\(.*\.\w+( \[[0-9]+.*)?$)' $temp_file_base.list
    if ($check_hbox) egrep '(Overfull \\hbox)|(^\(.*\.\w+( \[[0-9]+.*)?$)' $temp_file_base.list
    if ($do_biblio) grep "^Warning" $file_base.blg
endif

## # Show warnings
## # note: this is done after bibtex and then re-issue of latex to
## # avoid spurious warnings due to not-yet-defined references
## if ($show_warnings) then
##     egrep "(LaTeX Warning|WARNING)" $temp_file_base.list
##     if ($do_biblio) grep "^Warning" $file_base.blg
## endif

# Convert into postscript (and PDF) if all went well
# TODO: convert directly into PDF
#
if (($ok || ($ignore_errors == 1)) && ($run_dvips == 1))  then
    set viewer=gv
    set output_ext=ps

    set options = "-t letter"
    if ($a4) set options = "-t a4"
    if ($landscape) set options = "$options -t landscape"

    # Convert to postscript
    # example: dvips -t letter -o role-inventory.ps role-inventory.dvi
    #
    if ($verbose_mode) echo "issuing: dvips $options -o ${file_base}.ps ${file_base}.dvi"
    dvips $options -o ${file_base}.ps ${file_base}.dvi >> $temp_file_base.list
    ## set ok = ???

    # Convert the postscript into ASCII
    # NOTE: this works best when typewriter font family used
    # See preposition-classification.tex for conditional support for this
    if ($ascii) then
	if ($verbose_mode) echo "issuing: ps2ascii ${file_base}.ps > ${file_base}.ascii"
	ps2ascii ${file_base}.ps > ${file_base}.ascii
    endif

    # Spell check the ascii version
    if ($spell) then
	if ($verbose_mode) echo "issuing: spell.perl -spell_file=${file_base}.spell ${file_base}.ascii"
	## OLD: perl -Ssw spell.perl -spell_file=${file_base}.spell ${file_base}.ascii | sort -u
	ps2ascii ${file_base}.ps > ${file_base}.ascii
	perl -Ssw spell.perl ${file_base}.ascii
    endif

    # Convert the postscript file into PDF (Portable Document Format)
    # example: ps2pdf role-inventory.ps role-inventory.pdf
    #
    if ($pdf) then
	if ($verbose_mode) echo "issuing: ps2pdf ${file_base}.ps ${file_base}.pdf"
	ps2pdf ${file_base}.ps ${file_base}.pdf
	set viewer=acroread
	set output_ext=pdf
    endif

    # View it with ghostview (or acroread) if conversion successful
    # example: acroread role-inventory.pdf &
    #
    if (($ok || ($ignore_errors == 1)) && ($view == 1)) then
        if ($verbose_mode) echo "issuing: $viewer ${file_base}.${output_ext} &"
	$viewer ${file_base}.${output_ext} &
    endif
endif

# Optionally, convert the file into HTML
# Notes:
# - this needs the output files produced by latex
# - options to latex2html can be specified via LATEX2HTML_OPTIONS env. var
#
# example:
#    latex2html role-inventory > role-inventory.latex2html
#
if ($do_html == 1) then
    if ($verbose_mode) echo "issuing: $latex2html $latex2html_options $file_base"

    # The following is needed to avoid problems related to shell expansion of the latex options
    echo "#\!/bin/sh" >  /tmp/run_latex2html_$$.sh
    echo "$latex2html $latex2html_options $file_base" >> /tmp/run_latex2html_$$.sh
    chmod +x /tmp/run_latex2html_$$.sh
    /tmp/run_latex2html_$$.sh >& $file_base.latex2html
    ## rm /tmp/run_latex2html_$$.sh
endif
