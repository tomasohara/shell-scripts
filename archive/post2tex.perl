# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# post2tex.perl: convert POS tagger output (Brill) into tex format
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

# Print the TeX header
#
print <<END_HEADER;
\\documentstyle[11pt]{article}
\\pagestyle{empty}
\\textwidth 6.5 in
\\oddsidemargin 0.0in
\\textheight 8.25 in
\\begin{document}
%% \\Large
%% \\sc
%% \\large
\\small

END_HEADER


# Convert each line to a paragraph. Make each of the Penn tags (in Brill
# format) into subscripts.

    
while (<>) {
    &dump_line();
    chop;
    $text = $_;

    # strip punctuation tags
    $text =~ s/\/[:().,]//g;
    
    # escape character sequences that would confuse tex
    $text =~ s/([\#_\$])/\\$1/g;	# puts \ before #, _, ...

    # change POS tags into subscripts
    $new_text = "";
    while ($text =~ /\/([A-Z]+\\?\$?)/) {
	$tag = $1;
	$new_text .= $`;
	$text = $';

	## s/\/([A-Z]+)/\$_{\\sc \1}\$/g;	# ex: dog/NN => dog$_{NN}$
	$tag =~ tr/A-Z/a-z/;
	$new_text .= "\$_{\\sc $tag}\$";
    }
    $new_text .= $text;

    # print line w/ extra newline (ie, a separate paragraph)
    # print "\\noindent\n${new_text}\n\\vspace{1 pc}\n\n";
    print "\\noindent\n${new_text}\n\n";
}


# Print the TeX trailer
# 
print <<END_TRAILER;

\\end{document}
END_TRAILER
