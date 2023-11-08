# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# convert-xwn-sense-tags.perl: Converts the XML-style sense annoations for
# Extended WordNet into a simpler text with #-<sense> tags
#
# Sample input:
#
# <gloss synsetID=00002378 pos="NOUN" >
# <wf pos="DT" >a</wf>
# <wf pos="NN" lemma="thing" quality="gold" wnsn="3" wnsn="3" >thing</wf>
# <wf pos="IN" >of</wf>
# <wf pos="DT" >any</wf>
# <wf pos="NN" lemma="kind" quality="silver" wnsn="1" >kind</wf>
# </gloss>
#
# Sample output:
#
# N00002378: a n:thing#3 of any n:kind#1
#



# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'wordnet.perl';

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name noun.wsd\n\n";
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
## &init_var(*fu, &FALSE);		# TODO: add command-line options

my($synset_ID) = "";
while (<>) {
    &dump_line();
    chomp;

    
    # check for a new definition
    if (/^<gloss synsetID=(\S+) pos="(\S+)"/i) {
	my($offset, $POS) = ($1, $2);
	$synset_ID = &wn_letter_for_POS($POS) . $offset;

	print "$synset_ID: ";
    }

    # Output a sense-tagged word from the definition
    # ex: <wf pos="NN" lemma="thing" quality="gold" wnsn="3" wnsn="3" >thing</wf>
    elsif (/<wf pos="(\S+)" .* wnsn="(\d+)".*>(\S+)<\/wf>/i) {
	my($POS, $sense, $word) = ($1, $2, $3);
	
	printf "%s:%s#%d ", &wn_letter_for_POS($POS), $word, $sense;
    }

    # Output an untagged word from the definition
    # ex: <wf pos="DT" >any</wf>
    elsif (/<wf .*>(\S+)<\/wf>/i) {
	my($word) = $1;
	
	printf "$word ";
    }
    

    # Output punctuation as is
    # ex: <punct>;</punc>
    elsif (/<punc>(\S+)<\/punc>/i) {
	print " $1 ";
    }
    

    # Check for end of a gloss
    elsif (/^<\/gloss>/i) {
	print "\n";
	$synset_ID = "";
    }

    # Check for miscellanous XML tags
    elsif (/^<xwn.*>|<\/xwn>|(<wf pos=\"\" ><\/wf>)/i) {
	# do nothing
    }

    # Warn about unrecognized entries
    else {
	&warning("Unrecognized line: $_\n");
    }
}
&assert($synset_ID eq "");

&exit();
