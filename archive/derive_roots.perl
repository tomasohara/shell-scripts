# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# derive_word_list.perl: derive the roots for the tagged words in the data 
# file (produced by consolidate_all.perl)
# 
# TODO: have option for verbs
#       add morphological function (derive_root) to wordnet.perl
# 

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'wordnet.perl';
require 'graphling.perl';

## &init_var(*POS, "noun");
&init_var(*old_format, &FALSE);		# check for old <word>#<sense> format

## # Set environment option for wn customization
## $ENV{WN_JUSTMORPH} = "1";

# Read the text and scan for annotated words
#
while (<>) {
    &dump_line();

    if ($old_format) {
	&old_check_roots($_) 
	}
    else {
	&check_roots($_) 
    }
}

# Print the list of words that are roots.
# NOTE: These are the keys of the associative array, which is used as
# a simple way to avoid duplicates
#
printf "%s\n", join("\n", sort(keys(%roots)));


#------------------------------------------------------------------------------


# old_derive_root(word)
#
# Get the word's root form via WordNet.
#
# ex: wn beagles
#	No information available for noun beagles
#
#	Information available for noun beagle
#           -hypen          Hypernyms
#	...
#
# NOTE: Preference is given to the basic form over derivatives.
#       For instance, WordNet has entries for both steps and step,
#       so the latter would be preferred.
#
sub old_derive_root {
    local($word) = @_;
    local($root) = $word;

    # Get the listing of the applicable entries for the word
    $word = &iso_lower($word);
    local($morph) = &run_command("wn $word");

    # Find the last entry of the given part-of-speech that applies
    # to the word. Note that the plurals are given first in WordNet.
    while ($morph =~ /Information available for $default_POS (.*)\n/) {
	$root = $1;
	$morph = $';
	&debug_out(5, "Possible root for $word: $root\n");
    }

    return ($root);
}



# Check each word to see whether the sense was specified.
# This version uses the old word#sense format.
#
# All roots are added as keys to global associative array %roots.
#

sub old_check_roots {
    local ($text) = @_;

    foreach $token (split) {

        # If the sense is given, use WordNet to derive the root
        #
        if ($token =~ /^(.*)\#\S+$/) {
            $root = &wn_get_root($1, $default_POS);

            # Indicate that the root form is one of the roots encountered
            # NOTE: The associative array is used to ignore duplicates
            $roots{$root} = &TRUE;
        }
    }

    return;
}


# Check each word to see whether the sense was specified.
# This version uses the <wf pos=n>word</wf> format
#
# All roots are added as keys to global associative array %roots.
# NOTE: The associative array is used to ignore duplicates
#

sub check_roots {
    local ($text) = @_;

    # For each sense-tagged word, use WordNet to derive the root
    #
    local($attr, $word, $word_POS, $root);
    while ($text =~ /<wf( [^<>]*)>([^<>]+)<\/wf>/) {
	$text = $';
	$attr = $1;
	$word = $2;
	$word_POS = $default_POS;
	&debug_out(6, "tagging=%s attr=%s word=%s\n", $&, $attr, $word);

	# See if the word's part-of-speech was given
	if ($attr =~ /POS=([^<> ]+)/) {
	    $word_POS = &convert_POS($1);
	}

	# Derive the root. First see if explicitly given. Otherwise, stem word.
	$root = ($word_POS ne "") ? "${word_POS}:" : "";
	if ($attr =~ /root=([^<> ]+)/) {
	    $root .= $1;
	}
	else {
	    $root .= &wn_get_root($word, $word_POS);
	}

	# Indicate that the root form is one of the roots encountered
	$roots{$root} = &TRUE;
    }

    return;
}


# convert_POS: convert part-of-speech abbreviation to full form
#
sub old_convert_POS {
    local ($in_POS) = @_;

    # Part-of-speech associations
    # TODO: do this initialization elsewhere
    %POS_abbrevs = ("n", "noun",
		    "v", "verb",
		    "adj", "adjective",
		    "adv", "adverb") if (!defined(%POS_abbrevs));

    return (&get_entry(*POS_abbrevs, $in_POS, ""));
}
