# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# new_bib2text.perl: convert bibtex bibliography into free-text format
# 
# This version creates a dummy tex article with a bibliography, latexs it, 
# and then produces an ascii version from the dvi file (eg, via dvi2tty).
# This way the items can be formatted according to the user's desired format.
#
# TODO: find a better way to produce the ascii version
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

# Check command-line arguments
if (!defined($ARGV[0])) {
    $options = "options = n/a";
    $example = "example:\n\n$script_name -d=4 -style=aclsub -bib_style=acl russell_norvig_AT_text.bib\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}
local($bib_file) = &basename($ARGV[0], ".bib");

&init_var(*style, "");
&init_var(*bib_style, "plain");


# Create TeX file with references to each item in the biblio
local($tex_file) = "";
local($temp_tex) = "temp_tex.tex";
local($temp_dvi) = "temp_tex.dvi";
local($temp_text) = "temp_tex.text";
$tex_file .= "\\documentstyle[$style]{article}\n";
$tex_file .= "\\begin{document}\n";
$tex_file .= "\n";
$tex_file .= &make_tex_refs();
$tex_file .= "\\bibliographystyle{$bib_style}\n";
$tex_file .= "\\bibliography{$bib_file}\n";
$tex_file .= "\\end{document}\n";
&write_file($temp_tex, $tex_file);

# TeX & BibTex the source file
&run_command("do_tex.sh --biblio $temp_tex");

# Convert to ascii
&run_command("dvi2tty -w 132 $temp_dvi > $temp_text");

# Print the result sans the citations
# TODO: format each citation to remove extra spaces and make justified
#       (as with Emac's fill-paragraph command.
local($text_version) = &read_file($temp_text);
$text_version =~ s/[^[\000]+\n\s*References\s*\n//i;
printf "%s\n", $text_version;

&exit();

#------------------------------------------------------------------------

# make_tex_refs(): create dummy reference for each item in the biblio
# (contained in STDIN)
#
sub make_tex_refs {
    local($refs) = "";

    $/ = "";			# paragraph input mode
    while (<>) {
	&dump_line();
	chop;
	local($type, $key, $entries);

	# Skip non-entry lines
	if (/^\@string\{/i) {
	    next;
	}
	
	# Extract key from bibtex entry
	if (/^@(\S+){(\S*)\s*,([^\000]+)}/) {
	    $type = $1; $key = $2; $entries = $3;
	}
	else {
	    &debug_out(3, "WARNING: Unrecognized bibtex entry: $_\n");
	    next;
	}
	&debug_out(7, "t=$type k=$key entries={%s}\n", $entries);

	# Print a citation using the key
	$refs .= sprintf "\\cite{%s}\n", $key;
    }

    return ($refs);
}


