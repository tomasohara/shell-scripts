# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# new_bib2text.perl: convert bibtex bibliography into free-text format
# 
# This version creates a dummy tex article with a bibliography, latexes it, 
# and then produces an ascii version from the dvi file (eg, via dvi2tty).
# This way the items can be formatted according to the user's desired format.
#
# TODO:
# - Find a better way to produce the ascii version.
# - Add following fixup example to usage notes:
#   perl -i.BAK -0777 -pe 's/\n\n\d+\x0C\n\n/ /g; s/\x0C//g; s/([^.\s])\n\n(\S)/\1 \2/ig;' thesis-biblio.ascii
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$verbose $TEMP/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$style $bib_style $bib_style $temp_base $addkey $extra $fixed/;

# Check command-line arguments
if (!defined($ARGV[0])) {
    my($options) = "options = [-style=name] [-bib_style=name] [-extra=latex-command(s)] [-fixed]";
    my($example) = "example:\n\n$script_name -d=4 -style=aclsub -bib_style=acl russell_norvig_AT_text.bib\n\n";

    $example .= 'bib2text.perl -addkey -fixed -style=aclsub -extra="\singlespace" -bib_style=acl tomohara.bib >| tomohara-biblio.ascii' . "\n";
    $example .= "perl -i.BAK -0777 -pe 's/\\n\\n\\d+\\x0C\\n\\n/ /g; s/\\x0C//g; s/([^.\\s])\\n\\n(\\S)/\\1 \\2/ig;' tomohara-biblio.ascii\n";

    print STDERR "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
    &exit();
}
my($file) = $ARGV[0];
my($bib_file) = &basename($file, ".bib");

&init_var(*style, "");		# latex style file to use
&init_var(*bib_style, "plain"); # bibliography style to use
&init_var(*temp_base, 		# basename for temporary latex files
	  "temp-bib2text-${bib_file}"); # NOTE: must be in same directory (eg, for .sty files)
&init_var(*addkey, &FALSE);	# show bibtex key in output
&init_var(*extra, "");		# additional latex commands (placed after \begin{document})
&init_var(*fixed, &FALSE);	# use typewriter-type font (avoids word concatenation)

#........................................................................
# Create LaTeX file with references to each item in the biblio
#

# Create latex header, with optional package inclusion for alternative
# style files
## my($temp_dir) = ((&DEBUG_LEVEL <= &TL_USUAL) ? $TEMP : ".");
## my($temp_base) = "$temp_dir/temp-${bib_file}-biblio";
my($tex_file) = "";
my($temp_tex) = "${temp_base}.tex";
my($temp_dvi) = "${temp_base}.dvi";
my($temp_bib) = "${temp_base}.bib";
my($temp_ps) = "${temp_base}.ps";
my($temp_text) = "${temp_base}.ascii";
$tex_file .= "\\documentclass{article}\n";
if ($style ne "") {
    $tex_file .= "\\usepackage{$style}\n";
}

# TODO: Redefine \bibitem command to show key in output and to force a newline
## $tex_file .= "\\let\\oldbibitem = \\bibitem\n";
## $tex_file .= "\\renewcommand\\bibitem[2][]{\#1: \\oldbibitem[\#1]{\#2}\\vspace{1pc}}\n";

# Use typewriter font to facilitate conversion to ascii (eg, avoids word concatenation)
if ($fixed) {
    $tex_file .= "\\ttfamily\n\\renewcommand{\\familydefault}{\\ttdefault}\n";
}

# Create the body of the latex document, consisting of \cite's
# for each entry in the .bib file
$tex_file .= "\\begin{document}\n";
$tex_file .= "\n";
$tex_file .= "$extra\n" if ($extra ne "");
$tex_file .= &make_tex_refs();

# Add the trailer for the latex document, specifyig the bibliography
# style as well as the .bib file specified on the command line.
#
$tex_file .= "\\bibliographystyle{$bib_style}\n";
&copy_file($file, $temp_bib);
$tex_file .= "\\bibliography{$bib_file}\n";
$tex_file .= "\\end{document}\n";
&write_file($temp_tex, $tex_file);

# Run latex and bibtex over the source file
# TODO:
# - fix problem with running do_tex in different directories
# - fix problem with errors not being displayed
## my($current_dir) = &pwd();
## chdir $temp_dir;
my($options) = "--clean --biblio --ascii";
$options .= " --verbose" if ($verbose);
&cmd("do_tex.sh $options $temp_base 1>&2");
## chdir $current_dir;

# Fix-up the bibliography entries to include the key
#
# NOTE: 'key' label added to facilitate making each entry appear
# on separate line in ascii listing (to overcome quirk of ps2ascii).
#
# EXAMPLE:
# \bibitem[\protect\citename{Akkerman}1989]{Akkerman-89}
# E.~Akkerman.
# \newblock 1989.
# \newblock An independent analysis of the {LDOCE} grammar coding system.
# ...
# =>
# \bibitem[\protect\citename{Akkerman}1989]{Akkerman-89}
# BIBKEY Akkerman-89:
# E.~Akkerman.
# \newblock 1989.
# \newblock In Boguraev and Briscoe \cite{Boguraev-Briscoe-89}, pages 65--84.
#
# TODO:
# - Do this via redefinition of \bibitem command.
#
if ($addkey) {
    print STDERR "Adding bibtex keys to bibliography\n";
    &cmd("perl -i.BAK -00 -pe 's/(\\\\bibitem\\[[^\\]]+\\]{(\\S+)}\\n)/\\\\vspace*{1pc}\\n\\1key\\\\\\{\\2\\\\\\}:\\n/' $temp_base.bbl 1>&2");
    $options =~ s/\-\-clean|\-\-biblio//g;
    &cmd("do_tex.sh $options $temp_base 1>&2");
}

#........................................................................
# Print the result sans the citations used to force bibliography entry
# inclusion. Also, make sure each citation appears on a separate line.
#
# TODO:
# - Format each citation to remove extra spaces and make justified
# (as with Emac's fill-paragraph command.
# - Fix  cross-reference formatting problem (e.g., 'In Smith (Smith, 1981)').
#
my($text_version) = &read_file($temp_text);
## $text_version =~ s/[^[\000]+\n\s*References\s*\n//i;
$text_version =~ s/[^[\000]+\n\s*References\s+//i;
$text_version =~ s/key{(\S+)}/\n\n$1/g;
printf "%s\n", $text_version;


# Remove the temporary files produced by latex, etc.
if (! &DEBUGGING) {
    &cmd("do_tex.sh --just-clean $temp_base 1>&2");
    unlink glob("${temp_base}*");
}

&exit();

#------------------------------------------------------------------------

# make_tex_refs(): create dummy reference for each item in the biblio
# (contained in STDIN)
#
sub make_tex_refs {
    my($refs) = "";

    $/ = "";			# paragraph input mode
    while (<>) {
	&dump_line();
	chop;
	my($type, $key, $entries);

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

	# Skip entries without author fields (presumably comments)
	if ($_ !~ /(author|editor)\s*=/i) {
	    &warning("ignoring entry without author: key='$key'\n");
	    next;
	}
	
	# Print a citation using the key
	# NOTE: citation indicator doesn't show in text
	$refs .= sprintf "\\nocite{%s}\n", $key;
    }

    return ($refs);
}


