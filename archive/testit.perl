# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# testit.perl: adhoc script for testing various perl features
#

#local $SIG{__WARN__} = sub { die $_[0] };
# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    require 'extra.perl';
    require 'wordnet.perl';
}

use Data::Dumper;

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$all $test_all $uid $username $test_words $POS $add_syns 
    $all_hypernyms $add_depth $test_words $use_one $lexquad $var1 $var2/;

&init_var(*all, &FALSE);
&init_var(*test_all, $all);
    
printf STDERR "starting: %s\n", (scalar localtime);

# Test of time support

printf "current timestamp: %s\n", &current_timestamp();
printf "current year: %s\n", &current_year();

print "split 'A\tB\tC': ", split("\t", "A\tB\tC"), "\n";

# Test of assertion support
&assert(1);		# should never fail
&assert(2+2==5);	# should always fail (unless 1984)

# Determining values of evaluations
print "value of (2+2==4):", stringify(2+2==4), "\n";
print "value of (2+2==5):", stringify(2+2==5), "\n";
print "value of (undef):", stringify(undef), "\n";

# Test of regex pattern variables
# TODO: use EX-style testing (see test-perl-examples.perl)
&debug_print(&TL_DETAILED, "Testing regex variables ...\n");
my($YEAR) = "\\d\\d\\d\\d[a-z]?";
my($citation) = "O'Hara, Tom (2004), {\em Empirical Acquistion ...}";
if ($citation !~ /$YEAR/) {
    &error("Regex variable pattern failed\n");
}

# Make sure the hash buckets are distributed evenly.
# This example hashes as keys rnadom numers from 0 to 999999
# TODO: use string keys as well
my($num_buckets) = 10;
my(@bucket_count) = (0) x $num_buckets; 
my($num_samples) = 1000;
for (my $i = 0; $i < $num_samples; $i++) { 
    my($bucket) = &hash_key(int(rand() * 100000), $num_buckets); 
    $bucket_count[$bucket]++;
} 
my($stdev_listing) = &run_command_over("perl -Ssw sum_file.perl -stats",
				       join("\n", @bucket_count));
my($stdev) = ($stdev_listing =~ /stdev = (\S+)/); 
my($mean) = ($num_samples / $num_buckets);
my($coefficient_of_variation) = ($stdev / $mean);
&debug_out(&TL_DETAILED, "hash bucket count stdev: %.3f; mean=%g coefficient_of_variation=%.3f\n", $stdev, $mean, $coefficient_of_variation);
# TODO: figure out a principled test for this
&assert($coefficient_of_variation < 0.2);

# Current test(s)
#

# Dumping various perl structures
#
print "test of Data::Dumper\n";
$Data::Dumper::Indent = 0;
print Dumper($all);
print Dumper(\$all);
print Dumper([[1, 2, 3], ['a', 'b', 'c']]);
print "\n";
print Data::Dumper->Dump([$all], ['$all']);
print Data::Dumper->Dump([\$all], ['\$all']);
print Data::Dumper->Dump([[[1, 2, 3], ['a', 'b', 'c']]], ['n/a']);
print "\n";
print "ENV:", stringify(\%ENV), "\n";
&trace_assoc_array(\%ENV, &TL_VERBOSE, "ENV");


# Make sure that different formats for the same time are recognized as equivalent
#
my($date_spec);
my($good_time_value) = &derive_time_stamp("Sun Mar 01 00:30:00 MST 1998");
my(@test_date_specs) = ("Sun 1 Mar 98 12:30am", "Sun Mar 01 00:30:00 MST 1998", "Sun, 1 Mar 1998 00:30:00 -0700 (MST)");
#
print "timestamps for Sun 1 Mar 98 12:30am in various formats:\n";
foreach $date_spec (@test_date_specs) {
    my($time_value) = &derive_time_stamp($date_spec);
    printf "\t'%s' => %08d\n", $date_spec, $time_value;
    &assert('($time_value == $good_time_value)');
}
print "\n";

# topN tests
print "." x 80, "\n";
my(@max_label, @max_value);
my($n) = 4;
&init_topN($n);
&clear_topN(\@max_label, \@max_value);
&revise_topN(\@max_label, \@max_value, "a", 3);
&revise_topN(\@max_label, \@max_value, "b", 2);
&revise_topN(\@max_label, \@max_value, "c", 9);
&revise_topN(\@max_label, \@max_value, "da", 4);
&revise_topN(\@max_label, \@max_value, "db", 4);
&revise_topN(\@max_label, \@max_value, "e", 9);
&show_topN(\@max_label, \@max_value);
&assert($max_value[0] > $max_value[$n - 1]);
&clear_topN(\@max_label, \@max_value);
&assert((scalar @max_value) == 0);
print "." x 80, "\n";

# use of gcc w/ bash vs. csh (via cmd.sh)
#
my($result1) = &run_command("gcc -v");
my($result2) = &run_command("cmd.sh gcc -v");
&debug_out(4, "result1=%s\nresult2=%s\n", $result1, $result2);

my(@wn_test_list) = ("scrap:verb", "scrap:noun", "wave:verb", "fat:adj", "quickly:adv", "unassertatively:adv");
&trace_array(\@wn_test_list);
foreach my $word_with_POS (@wn_test_list) {
    my($word, $POS) = split(/:/, $word_with_POS);
    printf "%s\n", &wn_get_polysemy($word, $POS);
}

# # test for obscure Perl undefined-values bug when using run_command
# while (<>) {
#     &run_command("echo $_");
# }

&test_wn();

## &run_command("rlog -R fubar >&2 fubar.log");
my $rcs_info = &run_command("cmd.sh rlog -R fubar");
&debug_out(4, "rcs_info=$rcs_info\n");
if ($rcs_info =~ /No such file/i) {
    &debug_out(2, "fubar not under RCS\n");
}
&test_ping();

# Problem w/ $delim in assertion
my($delim) = &DELIM;
&assert('defined($delim)');
&assert('(($delim eq "\\") || ($delim eq "/"))');
&debug_out(2, "path delim is '$delim'\n");
&debug_out(2, "(\$delim eq \"/\")=%d \n", ($delim eq "/"));

my $x = "";
if ($x !~ /Oxford/) {
    &debug_out(2, "ok\n");
}

# password info
&init_var(*uid, 333);
printf "getpwuid($uid) => (%s)\n", join(' : ', getpwuid($uid));
&init_var(*username, &get_env("USER", "joe"));
printf "getpwnam($username) => (%s)\n", join(' : ', getpwnam($username));

&test_more if ($test_all);
&old_tests if ($test_all);

printf STDERR "end: %s\n", (scalar localtime);

&exit();

#------------------------------------------------------------------------------


# test_wn(): Test the WordNet interface
#
sub test_wn {
    &wn_init();
    &init_var(*POS, "noun");
    &init_var(*add_syns, &FALSE);
    &init_var(*all_hypernyms, &FALSE);
    &init_var(*add_depth, &FALSE);

    # Do the tests
    &init_var(*test_words, "money market hate love");
    my($word);
    foreach $word (&tokenize($test_words)) {
	my($hypernyms) = &wn_get_ancestors($word, $POS, $add_syns, 
					      $all_hypernyms, !$add_depth);
	printf "\nwn_get_ancestors(%s, %s, %s, %s, %s) = {\n%s\n}\n",
	     $word, $POS, $add_syns, $all_hypernyms, $add_depth, $hypernyms;
    }

    return;
}


# Old tests
#

sub old_tests {
    my (@list1, @list2, @diff, @nums);

    # Variable initialization
    &init_var(*var1, 99);	# $var1 => 101 if perl -s it.perl -var1=101
    &init_var(*var2, 77);	# $var2 => 77
    &debug_out(3, "var1=$var1 var2=$var2\n");

    # Detection of bad usage of difference function
    @list1 = ("a", "b", "c", "d", "e");
    @list2 = ("b", "d");
    @diff = &difference(\@list1, \@list2);
    print "diff((@list1), (@list2)) = (@diff)\n";
    @diff = &difference(@list1, @list2);
    print "diff((@list1), (@list2)) = (@diff)\n";

    # References to subroutines
    #
    &init_var(*use_one, &TRUE);
    *thesub = ($use_one ? *one : *two);
    &thesub();

    # WordNet morphology
    #
    foreach my $word ("Scrap", "DOG", "caT", "AÑO") {
	&debug_out(3, "lower($word) = %s\n", &lower($word));
    }
    foreach my $word_cat ("parties noun", "dog noun", "seeked verb") {
	my($wn_word, $wn_cat) = split(/ /, $word_cat);
	&debug_out(3, "root of '%s' = '%s'\n", $wn_word, &wn_get_root($wn_word, $wn_cat));
    }
    print "\n";

    # Stupid $# doesn't seem to work (even in perl 4)
    # TODO: figure out where OFMT comes from
    use vars qw/$OFMT/;
    print "OFMT (ie.m \$\#) tests:\n\n";
    printf "\$OFMT = %s\n", $OFMT;
    @nums = (2.17154, 3.3333333, 2.1);
    printf "@nums\n";
    $OFMT = "%.3f";
    printf "\$OFMT = %s\n", $OFMT;
    printf "@nums\n";
    #
    # note: The following is put in an eval environment to
    # avoid 'Use of $# is deprecated' when old_test's not used
    my $commands = <<END_COMMANDS;
        printf "\\\$\# = %s; \\\$OFMT = %s\n", \$#, \$OFMT;
        \@nums = (2.17154, 3.3333333, 2.1);
        printf "\@nums\n";
        \$# = "%.3f";
        printf "\\\$\# = %s; \\\$OFMT = %s\n", \$#, \$OFMT;
        \$OFMT = "%.3f";
        printf "\\\$\# = %s; \\\$OFMT = %s\n", \$#, \$OFMT;
        printf "\@nums\n";
END_COMMANDS
    eval "$commands";

    # Do other miscellaneous tests
    &test_whatever();
}


sub one {
    print "one\n";
    return;
}


sub two {
    my(@two) = ("uno", "dos");
    print "@two\n";
    return;
}


sub lower {
    my ($word) = @_;

    $word =~ tr/A-Z/a-z/;
    ## return (lc $word);

    return ($word);
}


sub test_loops {
    # For loop indices
    # NOTE: for(;;) loops don't have implicit scope as with foreach loop
    #
    my $i = 999;
    for ($i = 0; $i < 15; $i++) {	# no scoping
	&debug_out(5, "i = $i\n");
    }
    &debug_out(3, "i = $i\n");
    { my $i;
      for ($i = 0; $i < 10; $i++) {	# dynamic scoping
          &debug_out(5, "i = $i\n");
      }
    }
    &debug_out(3, "i = $i\n");
    { my $i;			# lexical scoping
      for ($i = 0; $i < 5; $i++) {
          &debug_out(5, "i = $i\n");
      }
    }
    &debug_out(3, "i = $i\n");
}

sub test_whatever {
    &debug_out(2, "%s\n", &asctime());
    &debug_out(2, "lexquad=%s\n", !defined($lexquad) ? "<UND>" : $lexquad);
    &init_var(*lexquad, &FALSE);
    &debug_out(2, "lexquad=%s\n", !defined($lexquad) ? "<UND>" : $lexquad);

    &debug_out(2, "(a, b, c) = %s\n", join(' ', ("a", "b", "c")));

    my(@nums) = (0) x 5;
    &debug_out(3, "nums=(@nums)\n");

    my $fred = "Fred Flintstone";
    my($word1, $word2);
    if ( ($word1, $word2) = ($fred =~ /(\w+)\W+(\w+)/)) {
	&debug_out(2, "($word1, $word2)\n");
    }

    my $who = `who`;
    &debug_out(2, "who={\n$who}\n");

    # Test of ls command
    printf "%s\n", &run_command("ls -al | grep -v ' \\.'");
}

# sub old_asctime {
#     return (scalar mytime);
# }

sub test_ping {
    &debug_out(3, "running ping fubar|\n");
    open(PING, "ping fubar|") ||
	debug_out(2, "WARNING: couldn't run 'ping fubar'\n");
    while (<PING>) {
	&dump_line("ping output: $_", 2);
    }
    close (PING);

    &run_command("ping fubar > temp_$$.output 2> temp_$$.error");
    printf "ping2 output: %s\n", &read_file("temp_$$.output");
    printf "ping2 error: %s\n", &read_file("temp_$$.error");


    &debug_out(3, "running ping.sh fubar|\n");
    open(PING, "ping.sh fubar|") ||
	debug_out(2, "WARNING: couldn't run 'ping.sh fubar'\n");
    while (<PING>) {
	&dump_line("ping3 output: $_", 2);
    }
    close (PING);
}

sub test_more {
    my($nosuch_file) = "/tmp/_nosuch_file_.text";
    unlink $nosuch_file;
    my($nosuch_file_size) = (-s $nosuch_file);
    printf "The size of ${nosuch_file} is %s\n", defined($nosuch_file_size) ? $nosuch_file_size : "UNDEFINED";
    my($empty_file) = "/tmp/_empty_file_.text";
    &issue_command("touch ${empty_file}");
    printf "The size of ${empty_file} is %s\n", (-s $empty_file);
    
    my(@quoted) = ('', '"', 'abc "', 'abc " xyz', '""', 'abc ""', '"" abc',
    	       '\"', 'abc \"', 'abc \" xyz', '\"\"', 'abc \"\"', '\"\" abc');
    foreach  my $string (@quoted) {
        printf "has_open_quote('%s') = %d\n", $string, &has_open_quote($string);
    }
    printf "\n";
    
    use constant DEVILS_SIGN => "666";
    
    printf "The sign of the devil is %s\n", DEVILS_SIGN;
    ## exit;
    
    open(MY_FILE, "/home/tom/.bashrc.local") ||
        die "Unable to open /home/tom/.bashrc.local";
    printf "bash line 1: %s\n", &read_line("MY_FILE");
    close(MY_FILE);
    
    {
    my($i, $j);
    my(@names) = ("a", "b", "c");
    my(@cross_names);
    for ($i = 0; $i <= $#names; $i++) {
        $cross_names[$i] = [];
        for ($j = 0; $j <= $#names; $j++) {
    	&set_2d_array(\@cross_names, $i, $j, ($names[$i] . $names[$j]));
    	printf "%s ", $cross_names[$i][$j];
        }
        print "\n";
    }
    #  &trace_array(\@cross_names);
    #  for ($i = 0; $i <= $#cross_names; $i++) {
    #      printf "[%s]: ", $cross_names[$i];
    #      my(@array) = @$cross_names[$i];
    #      &trace_array(\@array);
    #      printf "%s\n", join("\t", @$cross_names[$i]);
    #  }
    print "\n";
    }
    
    my($dir);
    foreach $dir (@INC) {
        &run_command("grep offline $dir/CGI/*");
    }
    
    my($lynx_command) = "lynx -dump -nolist http://www.reallyfubar.com";
    printf "output from '%s':\n%s\n", $lynx_command, &run_command("${lynx_command}");
    $lynx_command .= " 2>&1";
    printf "output from '%s':\n%s\n", $lynx_command, &run_command("${lynx_command}");
}

# set_2d_array(array_ref, row, col, valud)
#
# ex: set_2d_array(\@siblings, 2, 3, "fred");
#
sub set_2d_array {
    my($array_ref, $row, $col, $value) = @_;
    my(@array) = @$array_ref;
    &debug_out(&TL_ALL, "set_2d_entry(@_)\n");
    
    $array[$row][$col] = $value;
    &trace_array(\@array);

    return;
}

# read_line(handle_name): read next line from file handle specified in string
# This evaluates a read with the handle name:
#      &read_line("MY_FILE") => eval "<MY_FILE>;"
# where <MY_FILE>; returns the next line from the file
#
sub read_line {
    my($handle_name) = @_;
    &debug_out(5, "evaluating: <$handle_name>\n");
    my($line) = eval "<$handle_name>;";
    return ($line);
}


# has_open_quote(string): determines whether the string has an open quote
# (excluding escape quotes)
#
sub has_open_quote {
    my($string) = @_;
    my($count) = 0;
    my($escaped) = 0;
    &debug_out(5, "has_open_quote(@_)\n");

    for (my $i = 0; $i < length($string); $i++) {
	my($char) = substr($string, $i, 1);
	&debug_out(6, "char='%s' escaped='%d'", $char, $escaped);
	if (($char eq '"')  && (! $escaped)) {
	    $count++;
	}
	elsif ($char eq "\\") {
	    $escaped = 1;
	}
	else {
	    $escaped = 0;
	}
	&debug_out(6, "count='%d'\n", $count);
    }

    return (&is_odd($count));
}


# id_odd(number): indicates whether the number is odd or not
#
sub is_odd {

    my $num = shift;

    use integer;
    my $int_div = $num / 2;
    no integer;
    my $float_div = $num / 2;

    $int_div != $float_div;

}
