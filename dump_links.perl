# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl -sw
#
# dump_links.perl: dump the html files linked to in the current file
#
# TODO:
# - Add support for handling frames.
# - Handle links split across lines.
# - Create directory structure as with wget.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$script_name/;
}

use strict;
use vars qw/$LYNX $base $prefix $file_prefix $all $bare $retries $pause $width $testing $link $depth $inclusion $exclusion $start $end $source $sublink_regex $create_subdirs/;

if (!defined($ARGV[0])) {
    my($options) =  "options = [-base=base_URL] [-LYNX=lynx_command] [-file_prefix=name] [-bare] [-source] [-testing]\n";
    $options .= "          [-all] [-depth=N][-sublink_regex=pattern] [-create_subdirs]";
    my($example) = "examples:\n\n$script_name acm_careerops.html\n\n";
    $example .= "$script_name -base=http://dancetv.com/tutorial/swing/ swing_index.html\n\n";
    ## $example .= "$script_name -all -bare sgi_ml_index.html\n\n";
    $example .= "$0 -d=4 -link http://www.icsi.berkeley.edu/~framenet\n\n";
    ## $example .= "$script_name -d=4 -all -bare -link http://piscopia.nmsu.edu/dept/ThesisFiles/ThesisFiles.html > dump_links.log 2>&1\n\n";
    $example .= "$script_name -d=4 -all -bare -link -depth=5 http://citec.panam.edu > dump_links.log 2>&1\n\n";
    my($notes) .= "Notes:\n\n";
    $notes .= "Misc. Options:\n";
    $notes .= "-all	dump all linked files (not just HTML ones)\n";
    $notes .= "-bare	don't determine file prefix from base\n";
    $notes .= "-base	base URL to use (in case of relative links)\n";
    $notes .= "-depth	depth of embedded links to dump recursively\n";
    $notes .= "-link	HTML link given on the command line\n";
    $notes .= "-source	use HTML source (i.e., don't convert into ascii)\n";

    print "\nusage: $script_name [options] files\n\n$options\n\n$example\n\n$notes\n";
    &exit();
}

# Check command-line arguments
# Note: init_var_exp used to support recursive invocation
&init_var_exp(*LYNX, "lynx");	# lynx command to use
&init_var_exp(*base, "");	# base URL to use (in case of relative links)
&init_var_exp(*prefix, "-");	# alias for -file_prefix
&init_var_exp(*file_prefix, $prefix); # file prefix to use in the local directory
&init_var_exp(*all, &FALSE);	# dump all embedded links, not just those for html files
&init_var_exp(*bare, &FALSE);	# don't determine file prefix from base
&init_var_exp(*retries, 3);	# number of attempts to make (in case server busy)
&init_var_exp(*pause, 5);	# wait 5 seconds between retries
&init_var_exp(*width, 512);	# line width
&init_var_exp(*testing, &FALSE);# just show the links that would be dumped
&init_var_exp(*link, &FALSE);	# HTML link given on the command line
&init_var_exp(*depth, 0);	# depth of embedded links to dump recursively
&init_var_exp(*inclusion, "");	# regex pattern for links to include
&init_var_exp(*exclusion, "");	# regex pattern for links to exclude
&init_var_exp(*start, "");	# text signaling start of links
&init_var_exp(*end, "");	# text signaling end of text
&init_var_exp(*source, &FALSE);	# use HTML source (ie, don't convert into ascii)
my($dump_option) = ($source ? "-source" : "-dump");
&init_var_exp(*sublink_regex, "");	# pattern for links to follow recursively
&init_var_exp(*create_subdirs, &FALSE); # create sudirectory for each recursive traversal

## my($LYNX, $base, $file_prefix) = ($LYNX, $base, $file_prefix);
##
# NOTE: uncomment the following to help track down undeclared variables.
# Be prepared for a plethora of warnings. One that is important is
#    'Global symbol "xyz" requires explicit package name'
# when NOT preceded by 'Global symbol "xyz" requires explicit package name'
#
# use strict 'vars';

my(%link_processed);		# indicates if URL link already processed

# If a link is specified, download it and then recursively operate on the file
# TODO: have an opton for specifying the filename for the source (or to delete it)
if ($link) {
    my($url) = $ARGV[0];
    my($temp_file) = "temp_dump_links_$$.html";
    &run_command("lynx -source '$url' > $temp_file");
    if ($base eq "") {
	$base = &url_dirname($url);
    }
    &run_command("perl -sw $0 -link=0 -base='$base' $temp_file");
    &exit();
}

if (($base eq "") && (defined($ARGV[0]))) {
    $base = &basename(&remove_dir($ARGV[0]), ".html");
    $base .= "_";
}
if ($base ne "") {
    $base .= "\/" unless ($base =~ /\/$/);
}
if ($file_prefix eq "-") {
    $file_prefix = $bare ? "" : &remove_dir($base);
}

## &debug_out(5, "NOTE: stupid Perl bug in reporting undefined values\n");
&debug_out(5, "base='%s'\nfile_prefix='%s'\n", $base, $file_prefix);
my($include) = ($start eq "");
while (<>) {
    &dump_line();
    chop;
    my($original_line) = $_;

    # See if the start text anchor is in the line
    # TODO: strip HTML markup to account for HTML entities, etc.
    if ((!$include) && ($start eq "") && ($original_line =~ /$start/i)) {
	&debug_out(&TL_DETAILED, "starting to include at line $.\n");
	$include = &TRUE;
    }

    # Check for the base location
    # ex: <BASE HREF="http://www.acm.org/cacm/careeropps/">
    if (($original_line =~ /<BASE HREF="(\S+)">/i) && ($base eq "")) {
	$base = &url_dirname($1);
	$base .= "\/" unless ($base =~ /\/$/);

	&debug_out(&TL_DETAILED, "Using base '%s'\n", $base);
	next;
    }

    # Dump each link on the line
    my($line) = $original_line;
    while (($line =~ /<A[^<>]+HREF=[\"\']([^\"\']+)[\"\']/i)
	   || ($line =~ /<A[^<>]+HREF=([^ <>]+)/i)
	   || ($line =~ /<img.* src=[\"\']([^\"\']+)[\"\']/i)) {
	my($http_ref) = $1; 
        $line = $' || "";	# ' (for Emacs)
	&debug_print(&TL_VERBOSE, "http_ref='$http_ref'\n");

	# See if link should be filtered or skipped automatically
	if (($inclusion ne "") && ($http_ref !~ /$inclusion/i)) {
	    &debug_print(&TL_DETAILED, "non-inclusion link: '$http_ref'\n");
	    next;
	}
	if (($exclusion ne "") && ($http_ref =~ /$exclusion/i)) {
	    &debug_print(&TL_DETAILED, "exclusion link: '$http_ref'\n");
	    next;
	}
	if ($http_ref =~ /^mailto:/i) {
	    &debug_print(&TL_DETAILED, "skipping mailto link: '$http_ref'\n");
	    next;
	}

	# Standardize the reference
	if ($http_ref !~ /http:/i) {
	    $http_ref =~ s/^\///;
	    $http_ref = "$base${http_ref}";

	    # Resolve relative path references
	    # ex: http://www.thesonglyrics.com/menus/../privacy.html
	    # => http://www.thesonglyrics.com/privacy.html
	    $http_ref =~ s@/[^/]+/\.\.@/@g;
	}
	&debug_print(&TL_DETAILED, "ref='$http_ref'\n");

	# Remove the subpage section indicator
	$http_ref =~ s/\#.*$//;

	# Make sure it hasn't already been downloaded
	if (defined($link_processed{$http_ref})) {
	    &debug_print(&TL_DETAILED, "already processed: '$http_ref'\n");
	    next;
	}
	$link_processed{$http_ref} = &TRUE;

	# Proceed if .html type link or if everything desired
	if ($all || ($http_ref =~ /\.htm/i)) {
	    print "dumping link $http_ref\n";
	    ## my($file) = &remove_dir($http_ref);
	    my($file) = $http_ref;
	    $file =~ s/$base//;		# remove base html prefix
	    $file =~ s/\//_/g;		# flatten out dir structure (\ => _)
	    if (! $source) {
		$file =~ s/\.html?/.list/i;	# HTML files are converted to text
	    }
	    my($OK) = &FALSE;
	    if (! $testing) {
		for (my $i = 0; ($i < $retries) && (! $OK); $i++) {
		    &run_command("$LYNX $dump_option -nolist -width=$width '${http_ref}' > '${file_prefix}$file'");
		    if (-z "${file_prefix}$file") {
			sleep($pause);
		    }
		    else {
			$OK = &TRUE;
		    }
		}
	    }
	}

	# Optionally, dump all content on embedded pages
	if (($depth > 0) && ($all || ($http_ref =~ /\.htm/i))) {
	    # Filter links that don't match filter
	    if (($sublink_regex eq "") && ($http_ref !~ /$sublink_regex/i)) {
		&debug_print(&TL_DETAILED, "Filtering out sub-link: $http_ref\n");
		next;
	    }
	    elsif ($testing) {
		# no-op
	    }
	    else {
		my($subdepth) = ($depth - 1);

		# Optionally create separate directory for child
		my($current_directoery);
		if ($create_subdirs) {
		    # Make note of the current directory for later restore
		    $current_directoery = &pwd();

		    my($subdir) = $http_ref;
		    $subdir =~ s/$base//;	# remove base html prefix
		    $subdir =~ s/\//_/g;	# flatten out dir structure (\ => _)
		    $subdir =~ s/\.html?//i;	# strip extension
		    &issue_command("mkdir -p $subdir");
		    chdir $subdir;
		}

		# Recursively process the link
		# Note: command arguments specified via init_var_exp above so that don't need to respecify each here
		# TODO: use stack for recursion so that %processed hash valid
		&debug_print(&TL_DETAILED, "Recursively processing link '$http_ref'\n");
		&run_command("perl -sw $0 -depth=$subdepth -start='' -end='' -link '$http_ref'");

		# Restore previous working directory
		if ($create_subdirs) {
		    chdir $current_directoery;
		}
	    }
	}
    }

    # See if the end text anchor is in the line
    if ($include && ($end ne "") && ($original_line =~ /$end/i)) {
	&debug_print(&TL_DETAILED, "no longer including at line $.\n");
	last;
    }
}
