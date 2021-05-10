# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl

# Tabulate the tags in the data files (eg, big_tag.f)
#

# Process each line of the input stream
while (<>) {
    $text = $_;
    while ($text ne "") {
    	if ($text =~ /<([^<>]+)>/) {
       	 	$tag = $1;
        	$count{$tag} = $count{$tag} + 1;
		$text = $';
	}
	else {
		$text = "";
	}
    }
}

foreach $tag (keys(%count)) {
    if ($count{$tag} != 0) {
        print '[', $tag, "]\t", $count{$tag}, "\n";
    }
}

print "\n";
