# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# dso2sgml.perl: convert from DSO's annotation to an SGML-style annotation
# This is mainly intended to convert grep listings of the same word across
# different files, but it also supports conversion of a single file.
#
# example:
#
#	development.n:ch09.db #002 In view of the increasing shortage of
#	... for the >> development 0 << of practicable low-cost ...
#
#	ground.n:ch09.db #002 In view of the increasing shortage of 
#	>> ground 1 << water in many parts of the Nation ...
#       ...
#
#    =>
#	In view of the increasing shortage of ... for the 
#	<wf sense=1>ground</wf> water in many parts of the Nation ...
#	<wf sense=0>development</wf>of practicable low-cost ...
#
# NOTE: the grep listing needs to indicate the filename, which indicates
#       the part-of-speech
#
# TODO: put the consolidate support into a separate script?
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*use_pound_sign, &FALSE);
&init_var(*consolidate, &TRUE);
&init_var(*POS, "n");
&init_var(*keep_DB_id, &FALSE);

@master_word_list = ();
$master_id = "";

while (<>) {
    &dump_line();
    ## s/>> *([^ ]+) *(\d+) *<</<wf sense=$2>$1<\/wf>/g;
    
    # drop grep file position and DSO corpus position indicator
    local($id);
    if ($consolidate) {
	s/(^((\S+\.)(\S+):(\S+\.db)) (\#\d+))//;
	# 1 23      4     5          6
	$id = $1;
	$POS = $4;
    }
    else {
	# Drop the ID if not consolidating the data
	s/^\S+\.db \#\d+// unless ($keep_DB_id);
    }

    # Change from sense -1 to sense 0
    s/>> ([^<>]+) -1 <</>> $1 0 <</g;

    # Change from ">> word N <<" to "<POS>:<word>#<sense>"
    ## s/>> *([^ ]+) *(\d+) *<</$1\#$2/g; # old "word#N" format
    ## s/>> *([^ ]+) *(\d+) *<</<wf POS=$POS sense=$2>$1</wf>/g;
    s/>> *([^ ]+) *(\d+) *<</$POS:$1\#$2/g;

    ## # drop punctuation (TODO: drop other miscellaneous stuff)
    ## s/[,.?:!@\"\'\$\(\)]//g;

    if ($consolidate) {
	# Convert into a list for comparison against master list
	@word_list = split(/\s+/, $_);

	# Initialize the master word list for sentence if first entry
	if ($#master_word_list < 0) {
	    @master_word_list = @word_list;
	    $master_id = $id;
	}

	# Reconcile word sense indicators of the master word list
	if ($#word_list != $#master_word_list) {
	    &debug_out(2, "*** $id sentence different from $master_id: ignored\n");
	    &debug_out(3, "diff($id, $master_id): %s\n",
		       &difference(*word_list, *master_word_list));
	    &debug_out(3, "diff($master_id, $id): %s\n",
		       &difference(*master_word_list, *word_list));
	    next;
	}
	for ($i = 0; $i <= $#master_word_list; $i++) {
	    if ($word_list[$i] =~ /\#/) {
		$master_word_list[$i] = $word_list[$i];
	    }
	}
    }

    # Otherwise just print the entry
    else {
	s/(\S+):([^ ]+)\#(\d+)/<wf POS=$1 sense=$3>$2<\/wf>/g
	    unless ($use_pound_sign);
	print "$_";
    }
}

# Print the master word list
if ($consolidate) {
    $master_word_list = join(' ', @master_word_list);
    $master_word_list =~ s/(\S+):([^ ]+)\#(\d+)/<wf POS=$1 sense=$3>$2<\/wf>/g
	unless ($use_pound_sign);
    print "$master_word_list\n";
}
