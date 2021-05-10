# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl

#$text = "";

# process each line of the input stream
while (<>) {
    chop;
    if (/<wf .*>(.*)<\/wf>/) {
	$word = $1;

	$word =~ s/<[^>]+>//g;
	print "$word ";
    }

    if (/<\/s>/) {
	print "\n";
    }
}

