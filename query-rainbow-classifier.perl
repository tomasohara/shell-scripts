# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# query-rainbow-classifier.perl: queries the classifier built via rainbow
# (see new-adhoc-rainbow-test.sh), using it's socket server to support batch 
# mode.
#
# Automates following interaction:
#
#  [Rainbow query server]
#  
#  $ rainbow -b -d cal500-lyrics-tfidf-all-rainbow --query-server 9999
#  Placed remaining 294 documents in the train set:
#  Setting weights over words:
#  Normalizing weights:
#  Waiting for connection...
#  Got connection.
#  
#  [Rainbow client]
#  
#  $ telnet localhost 9999
#  Trying 127.0.0.1...
#  Connected to localhost.
#  Escape character is '^]'.
#  how now brown cow
#  
#  .
#  Bizarre-Weird 0.1573861241
#  Arousing-Awakening 0.009179899469
#  .
#  bow wow blue car
#  .
#  Angry-Agressive 0.06090302393
#  Arousing-Awakening 0.03712609783
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    ## TODO: use vars qw/$verbose/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
## use vars qw/$fu $bar/;

# Show a usage statement if no arguments given.
# NOTE: By convention '-' is used when no arguments are required.
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Example(s):\n\n$script_name example\n\n";  # TODO: example
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n\n";	     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
## &init_var(*fu, &FALSE);		# TODO: add command-line options

# TODO: start server and get pid

# TODO: send files separated by <CR><NL>.<CR><NL>

# TODO: summarize results

# The end
&exit();


#------------------------------------------------------------------------------

# TODO: subroutine101(some_arg): What subroutine101 does
#
sub subroutine101 {
    ## my($arg) = @_;
    &debug_print(&TL_VERBOSE, "subroutine101(@_)\n");

    return;
}
