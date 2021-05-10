# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# wc.perl: simple wordcount script
#

require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = [-para]";
    $example = "ex: $script_name whatever\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

&init_var(*para, &FALSE);	# paragraph input mode
&init_var(*w, &FALSE);		# show word count
&init_var(*l, &FALSE);		# show line count
&init_var(*c, &FALSE);		# show character count
my($show_all) = ((! $w) && (! $l) && (! $c));
my($show_words) = ($show_all || $w);
my($show_lines) = ($show_all || $l);
my($show_characters) = ($show_all || $c);

# Optionally set paragraph input mode
if ($para) {
    $/ = "";
}

my($lines) = 0;
my($words) = 0;
my($characters) = 0;

# Tabulate the character, word, and line counts
#
while (<>) {
    &dump_line();

    $lines++;
    $characters += length($_);
    $words += (scalar &tokenize($_));
}

# Print the counts
print "$lines " if $show_lines;
print "$words " if $show_words;
print "$characters " if $show_characters;
print "\n";

&exit();


#------------------------------------------------------------------------------

sub fubar {
    local ($fubar) = @_;
    &debug_out(4, "fubar(@_)\n");

    return;
}

