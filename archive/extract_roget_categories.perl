# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# extract_roget_categories.perl: Extract the Roget categories from the
# public-domain 1911 version (prepared by MICRA)
#
# example input:
#
#        #3. Substantiality. -- N. substantiality, hypostasis; person, being,
#   thing, object, article, item; something, a being, an existence; creature,
#   body, substance, flesh and blood, stuff , substratum; matter &c. 316;
#   corporeity, element, essential nature, groundwork, materiality,
#   substantialness, vital part.
#        [Totality of existences], world &c. 318; plenum.
#        Adj. substantive, substantial; hypostatic; personal, bodily, tangible
#   &c. (material) 316; corporeal.
#        Adv. substantially &c. adj.; bodily, essentially.
#
# example output (single line per category: <category><TAB><category_words>):
#
#   substantiality	substantiality, hypostasis, person, being, thing, \
#                       object, article, item, something, a being, \
#                       an existence, ... substantially, bodily, essentially
#
# NOTE: MS-DOS style carraige returns (^M when viewed in Emacs) must be
# removed beforehand. Also, extraneous spaces must be removed from blank
# lines. And, "#984. Heterodoxy. [Sectarianism.]" => "#984. Heterodoxy. [Sectarianism]."
#
# TODO: Write a separate script for fixing up thes1911.asc
#       Also, filter out the phrases:
#             perl -n -e "print if (/^[^ ]+\t/);" roget_categories.index

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*base, "roget_categories");

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = [-base=roget_categories]";
    $example = "ex: $script_name thes1911.asc >! roget_categories.data\n";

    die "\nusage: $script_name [options] rogets_thesarus_text\n\n$options\n\n$example\n\n";
}

$categories = "";
%word_categories = ();

$/ = "";			# use paragraph input-mode
while (<>) {
    &dump_line();
    chop;

    # Remove comments (<-- comment -->)
    # ex: #187. [Nullibiety.1] <-- 1 Bishop Wilkins. --> Absence.-- N. absence
    s/<-- [^>]+ -->//g;

    # Check for a new category
    #     #405. Faintness. -- N. faintness &c. adj.; faint sound, whisper
    #     #406. [Sudden and violent sounds.] Snap. -- N. snap &c. v.;
    $open_bracket = "\\\[\\\{\\\(";
    $close_bracket = "\\\]\\\}\\\)";
    $bracketting = "[$open_bracket][^$close_bracket]+[$close_bracket]";
    if ((/^ *\#(\d+[a-e]?)\.? *($bracketting)? *([^-]+)\-\-/)
       || (/^ *\#(\d+[a-e]?)\.? *($bracketting)? *([^\.]+)\./)) {
	$category_words = $';
	$category_num = $1;
	$category_name = &trim_punctuation($3);
	$_ = $category_words;
	&debug_out(5, "cnum='$category_num' cname='$category_name'\n");
	&debug_out(6, "cwords='$category_words'\n");

	# Clean up the category name
	$category_name =~ s/\.//g;
	$category_name =~ s/$bracketting//g;
	$category_name =~ s/&c//g;
	$category_name = &iso_lower(&trim($category_name));
	$category_name =~ s/(,\s*)|(\s+)/_/g;
	if ($category_name =~ /^$/) {
	    &debug_out(3, "warning: no category name for $category_num\n");
	}
	$category_name = "${category_num}_${category_name}";

	# Remove miscellaneous codes and markers from the words
	s/--/ /g;
	s/\n/ /g;

	# Remove category cross references
	# NOTE: replaced with comma so that to join phrases
	s/&c,/&c./g;
	s/&c\. *((n\.)|(v\.)(adj\.)|(adv\.))/,/ig; # ex: "resolved &c. v.;"
	s/&c\. *\([^\)]+\)? *\d+/,/g;	# ex: "&c. (melodious) 413;"
	s/&c\. *\d+/,/g;		# ex: "&c. 495;"
	s/\{[^\}]+\}/,/g;	# ex: "Earliness. -- N. {ant. 135}"
	s/&c\./,/g;		# drop extraneous cross ref markers

	# Remove part-of-speech labels
	s/((n\.)|(v\.)(adj\.)|(adv\.))/,/ig;

	# Remove quotations, along with optional citation
	#      arranged &c. v.; ... methodical, orderly, regular, systematic.
	#      Phr.  "In vast cumbrous array"  [Churchill]
	while (/^[^\"]+\"[^\"]+\];/) {
	    &debug_out(5, "\$_ = $_\n");
	    &debug_out(4, "warning: bad quotation format: $&\n");
	    s/\"[^\"]+\];//;
	}
	s/(Phr. *)?\"[^\"]+\"( \[[^\]]+\])?/,/g;
	s/\"[^\"]+\"/,/g;
	s/\[[^\]]+\]/,/g;

	# Change semicolons to comma's
	s/;/,/g;

	# Print the category followed by its comma-separated list of words
	s/ +/ /g;
	$category_words = &iso_lower($_);
	$categories .= "${category_num}\t${category_name}\n";

	# Update inverted index (words -> catgeory)
	# Words or phrases are separated by comma
	&debug_out(6, "cwords2='$category_words'\n");
	local(@word_list);
	foreach $word (split(/[,.]/, $category_words)) {
	    $word = &trim($word);
	    next if ($word !~ /^[a-z]/);
	    if (!defined($word_categories{$word})) {
		$word_categories{$word} = "";
	    }
	    if (index($word_categories{$word}, $category_name) == -1) {
		$word_categories{$word} .= "$category_name ";
		push(@word_list, $word);
	    }
	}

	# Print the word list for the category
	printf "${category_name}\t%s\n", join(', ', @word_list);
    }
    else {
	&assert('$_ !~ /^ *\#/');
    }
}

&write_file("${base}.list", $categories);

open(WORD_INDEX, ">${base}.index") || die "unable to create ${base}.index\n";
foreach $word (sort(keys(%word_categories))) {
    printf WORD_INDEX "%s\t%s\n", $word, $word_categories{$word};
}
close(WORD_INDEX);

#------------------------------------------------------------------------------

sub fubar {
    local ($fubar) = @_;
    &debug_out(4, "fubar(@_)\n");

    return;
}

