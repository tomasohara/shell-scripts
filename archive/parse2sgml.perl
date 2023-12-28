# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# parse2sgml.perl: Convert from Penn Treebank parse to sgml tagged data
# for a particular set of tags
#
# NOTE: Inclusion filter can be used to only tag instances of particular words.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*tag_set, "");		# Treebank tags (constituents) to check
&init_var(*wsd_senses, &FALSE);		# Add word_sense attribute for tag
&init_var(*numeric_senses, &FALSE); 	# Use numeric sense distinctions
&init_var(*inclusion_filter, "");	# Space-delimited list of words to tag

$inclusion_filter = &to_lower(" $inclusion_filter ");
local(@tag_set) = split(/\s+/, $tag_set);


# Process each line of the input stream: a node of the parse tree
while (<>) {
    &dump_line;
    chop;

    # Skip Penn Treebank comments and other extraenous text
    if (/^\*x\*/ || /END_OF_TEXT_UNIT/) {
	next;
    }

    # Print a newline if this starts a new sentence
    if (/\( \(S/ || /\(TOP \(S /) {
	print "\n";
    }

    # Convert the syntactic tag of interest into an SGML tag
    local($i);
    for ($i = 0; $i <= $#tag_set; $i++) {
	local($tag) = $tag_set[$i];
	if ($wsd_senses) {
	    local($sense) = ($numeric_senses ? ($i + 1) : $tag);
	    if (/\($tag ([^()]+)/) {
		$word = $1;
		$lower_word = &to_lower($word);
		
		# Tag the word unless it is not in the filter
		if (($inclusion_filter eq "") ||
		    (index($inclusion_filter, " $lower_word ") != -1)) {
		   s/\($tag ([^()]+)/<wf sense=$sense>$word<\/wf>/;
		}
	    }
	}
	else {
	    s/\($tag ([^()]+)/<$tag>$1<\/$tag>/;
	}
	
    }

    # Delete all the parse-specific markup
    s/\([A-Z0-9-]+ //g;		# drop syntactic tag (eg, (NP-PRD
    s/[()]//g;			# drop all parentheses
    s/\*\S*//g;			# drop trace elements, etc. (eg, '*T*-4')
    s/\-[A-Z]+\-//g;		# drop other misc. elements (eg, '-RRB-')
    s/\s+/ /g;			# collapse whitespace

    # Output the phrase
    print;			# remainder of line w/o newline
}

# Print newline for end of last sentence
print "\n";
