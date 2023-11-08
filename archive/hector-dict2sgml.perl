# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# dict2latex.perl: convert HECTOR dictionary entry into latex format
#
# based on intolatex.pl from SENSEEVAL distribution 
#
# TODO: 
#    Put spacing after trailing notes so that they don't appear to belong
#    to the following sense or entry (see impress 1a).
#
# NOTE:
#    The sectioning is primarily intended for use with latex2html.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (!defined($ARGV[0])) {
    $options = "options = [-index] [-sections] [-a4] [-footnote_examples]";
    $example = "examples:\n\n";
    $example .= "$script_name lemon.dic >! lemon.tex\n\n";
    $example .= "$script_name -sections -index -o=entries.tex TRAINING/*.dic >&! entries.log\nlatex2html -address \"\" -bottom_navigation -local_icons entries.tex >&! latex2html.log\n";

    die "\nusage: $script_name [options] dict_file ...\n\n$options\n\n$example\n\n";
}

&init_var(*index, &FALSE);
&init_var(*a4, &FALSE);
&init_var(*sections, &FALSE);
&init_var(*footnote_examples, &FALSE);

# Determine the document style
$style = "11pt";
$style .= ",a4" if ($a4);
$style .= ",makeidx" if ($index);

# Print the document header
print "\\documentstyle[$style]{article}\n";
print "\\makeindex\n" if ($index);
print "\\begin{document}\n";
print "\\parindent=0mm\n";

$inexa = 0;			# indicates whether in an example
$exflag = 0;			# example flag (<ex> w/o </ex>)
$lemma = "";			# lemma for current entry

# Print section for the dictionary file
if ($sections) {
    local($file) = $ARGV[0];
    local($base) = &basename(&remove_dir($file), ".dic");
    print "\n\\section\{$base\}\n";
}

while(<>) {
    &dump_line();

    s/([\_\$])/\\$1/g;		# put escapes around special characters

    $full=$_;
    s/\&ellip\./\\ldots /g;
    s/\&quid\./\\pounds /g;
    s/\&dash/---/g;
    s/\&/\\&/g;
    $uid="";

    # Check for new dictionary entry
    if (/<entry/){
	$ordlevel=0;
	&end_examples();
# 	if ($inexa) {
# 	    $inexa=0;
# 	    print "\\end{enumerate}\n";
# 	}
#	$exflag = 0;
	if (s/^<entry (done=TRUE)?//){
	    $done = defined($1);
	    if (s/( uid=(\d+))?>([a-zA-Z -]+)$//){
		$uid=$2;
		$hwd=$3;
		if ($sections) {
		    $lemma = $hwd; 	# save lemma for subsection headers
		    print "\n\\subsection\{$hwd\}\n";
		}
		else {
		    print "\n\n \\fbox\{\\Large \\bf $hwd\}";
		}
		print "\n\\index\{$hwd\}\n" if ($index);
		if ($uid) {print " {\\small ($uid)}"}
		if (! $done) {
		    print " {\\bf NOTE: ENTRY NOT DONE} ";
		}
	    } else {
		print STDERR "OTHER-ENTRY $_";
	    }
	} else 	{
	    print STDERR "ZZ-OTHER-ENTRY $_";
	}

    }	

    # Check for new lexicalization
    elsif (/<(lex|phr) +ord=(\d+)>(.*)$/){
	&end_examples();
# 	if ($inexa) {
# 	    $inexa=0;
# 	    print "\\end{enumerate}\n";
# 	}
# 	else {
# 	    ## print "\\\\\n";	# TODO: use \vspace ???
# 	    print "\\vspace\{1pc\}\n";
# 	}
	print "\\vspace\{1pc\}\n";
	$ordlevel++;
	if ($sections) {
	    $ord = $2;
	    $word = &trim($3);
	    $word = $lemma if ($word eq "");
		
	    print "\n\\subsubsection\{$word $ord\}\n";
	}
	else {
	    print "\\fbox\{\\Large \\bf $2 $3 \}";
	}
    }

    # Check for new sense
    elsif (/<sen/){
	$uid="";$ord="";$mne="";
	print "% Im in sense here: $_";
	&end_examples();
# 	if ($inexa) {
# 	    $inexa=0;
# 	    print "\\end{enumerate}\n";
# 	}
	if (s/uid=(\d+) +//) {$uid=$1};
	if (s/ord=([^ >]+) *//) {$ord=$1};
	if (s/tag=([^ >]+) *//) {$mne=$1};
	if (/^<sen *> *(<\/sen>)?$/) {
	    print "\n\n\\noindent {\\large \\bf $ord} {\\small ($mne $uid)}";
	} else {
	    
	    print STDERR "OTHER-SENSE $full\n $_";
	} 
    }

    # Put grammar code in boldface
    elsif (/<gr/){
	if (/<gr>([^<]+)<\/gr>/){
	    print "{\\bf [$1]}";
	} else {	
	    print STDERR "OTHER-GR $full";
	}
    }

    # Ignore embedded cross-reference
    elsif (/<see>/) {
	next;
    } 

    # Check for miscellaneous fields to be included 
    elsif (/<(dfrm|field|kind|full|idi|xtyp|note|reg)/){
	$tag=$1;
	&end_examples();
# 	if ($inexa){ 
# 	    print "\n\\end{enumerate}";
# 	    $inexa=0;
# 	}
	if (/<$tag>([^<]+)<\/$tag>/){
	    if ($tag eq "idi"){
		print "{\\bf $1 \}\\\\\n";
	    } else {
		print "{\\small (${tag}=$1) \}";
	    }
	} else {	
	    print STDERR "OTHER-$tag $full";
	}
    } 

    # Print the definition
    elsif (/<def/){
	if  (/<def>([^<]+)<\/def>/){
	    print " $1 ";
	} else {	
	    print STDERR "OTHER-DEF $full";
	}
    } 

    # Make clues have footnote-sized fonts
    elsif (/<clues/){
	if  (/<clues[^>]*>([^<]*)<\/clues>/){
	    if ($1) {print "\{\\footnotesize \\normalfont [[$1]] \}"};
	} else {	
	    print STDERR "OTHER-CLUES $full";
	}
	if (/<\/ex>/) {print "\}\n";
		   }
    } 

    # Put examples in a list environment
    elsif (/<ex>/){
	&start_examples();
	if  (/<ex>([^<]+)(<\/ex>)?/){
	    local($text) = $1;
	    local($end_tag) = defined($2) ? $2 : "";
	    &print_example($text, $end_tag);
# 	    if ($2 eq "</ex>"){
# 		print "\n \\item {\\it $1\} ";
# 	    } else  {
# 		print "\n \\item {\\it $1 " ;
# 		$exflag=1;
# 	    }
	} else {	
	    print STDERR "OTHER-EX $full";
	}
    } 

    # If an example is active, then print the line
    elsif ($exflag){
	&finish_example($_);
# 	if (/^(.*)<\/ex>/){
# 	    print " $1 \} ";
# 	    $exflag=0;
# 	} else  {
# 	    print  ;
# 	}
    } 

    # Check for variant forms
    elsif (/<vf>(.*)<\/vf>/) {	# <vf> variant form
	print " \{\\em variant form:} $1 ";
    } 

    # Check for fields to ignore
    elsif (/<lex/) {			# <lex> lexical form
	# ignore the line
    } 

    # Print warning if unrecognized line
    elsif (/\S/) { 
	print STDERR "WARNING: unrecognized line: $_";
    }

    # Determine next file name, and print new section if different
    if ($sections && eof && ($#ARGV >= 0)) {
	local($file) = $ARGV[0];
	local($base) = &basename(&remove_dir($file), ".dic");

	# Terminate any open examples
	&end_examples();
# 	if ($inexa) {
# 	    $inexa=0;
# 	    print "\\end{enumerate}\n";
# 	}
# 	$exflag = 0;

	# Print the new section header
	print "\n\\section\{$base\}\n";
    }
}

# Terminate example list environment if active
&end_examples();
# if ($inexa) 	    {
#     print "\n\\end{enumerate}"
#     };

# Print document trailer
print "\n\\printindex\n" if ($index);
print "\n\\end{document}\n";

#------------------------------------------------------------------------------

sub start_examples {
    if (!$inexa) { 
	if ($footnote_examples == &FALSE) {
	    print "\n\n\\begin{enumerate}\n";
	    print "\\itemsep=-2mm\n" if (!$sections);
	}
	$inexa=1;
    }
    $exflag = 0;
}

sub end_examples {
    if ($inexa) {
	$inexa=0;
	if ($footnote_examples == &FALSE) {
	    print "\\end{enumerate}\n";
	}
    }
    $exflag = 0;

    return;
}

sub print_example {
    local($text, $end_tag) = @_;
    local($formatting, $end_formatting);

    # Format the example either as a footnote or as an enumeration item
    if ($footnote_examples) {
	$formatting = "\\footnote\{$text";
	$end_formatting = "} ";
    }
    else {
	$formatting = "\n \\item \{\\it $text";
	$end_formatting = "}\n";
    }

    # Print the formatting, along with optional environment terminator if
    # all the text was given.
    print "$formatting ";
    if ($end_tag eq "</ex>") {
	print "${end_formatting}";
    }
    else {
	$exflag = 1;
    }

    return;
}


sub finish_example {
    if (/^(.*)<\/ex>/){
	print " $1 \} ";
	$exflag=0;
    } else  {
	print  ;
    }
}
