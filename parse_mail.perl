# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s

# parse_mail.pl: adapted from ne_tag's parse_mail

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'rfc822.pl';

$user = $ENV{"USER"};
$home = $ENV{"HOME"};

## debug_out(5, "ARGV[0]=%s ARGV[1]=%s\n", @ARGV[0], @ARGV[1]);

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (defined($h))) {
    $options = "options = [-m=mail_file] [-dir=mail_dir] [-t=test_mode] [-f=mail_folder] [-batch] [-anonymous_notify]";
    $example = "example:\n\n$script_name -batch\n\n";
    $example .= "$script_name -d=5 -t -m=919782780\n\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}
## debug_out(5, "char_occurences(abcabca, a) = %d\n", char_occurences("abcabca", "a"));
## die;

# Determine mail options
# TODO: reconcile w/ .procmailrc
#
$system_mail_file = (&SOLARIS ? "/var/mail/$user" : "/var/spool/mail/$user");
$mail_file = ($m ne "") ? $m : $system_mail_file;
$separate_mail_file = ($mail_file ne $system_mail_file);
$sleep_period = get_env("SLEEP_PERIOD", 60);
$temp_dir = ($temp ne "") ? $temp : "$home/temp";
$mail_dir = ($dir ne "") ? $dir : "$home/Mail";
$temp_mail_file = ($tf ne "") ? $tf : "${temp_dir}/mail";
$test_mode = ($t ne "") ? $t : &FALSE;
$mail_folder = ($f ne "") ? $f : "inbox";
$max_lines = ($ml ne "") ? $ml : 1000000;
&init_var(*batch, $separate_mail_file);
&init_var(*anonymous_notify, &FALSE);

$procmail_options = "VERBOSE=on";
if ($test_mode == 1) {
    $mail_dir = "$home/Mail/Test";
    $temp_dir = ($temp ne "") ? $temp : "$home/temp";
    $temp_mail_file = "${temp_dir}/Mail/Test/mail";
    $max_lines = 100;
    ## $procmail_options .= " MAILDIR=$mail_dir ";
    $procmail_options .= "  $home/.test_procmailrc";
    ## run_command("echo \"\" > $mail_file") if (! (-e "$mail_file"));
}

if (! -e $temp_dir) {
    run_command("mkdir $temp_dir");
}

$last_real_mail = access_time("$mail_dir/$mail_folder");
$last_sender_list = get_sender_list("$mail_dir/$mail_folder");

debug_out(5, "mail_file=$mail_file\n");
debug_out(5, "sleep_period=$sleep_period\n");
debug_out(5, "temp_dir=$temp_dir\n");
debug_out(5, "mail_dir=$mail_dir\n");
debug_out(5, "temp_mail_file=$temp_mail_file\n");
debug_out(5, "test_mode=$test_mode\n");
debug_out(5, "mail_folder=$mail_folder\n");

for (;;) {
    if (-s $mail_file) {
        run_command("cp $mail_file $temp_mail_file");
	if ($? != 0) {
	    &error_out("Unable to copy mail file (%s) status=%9\n",
		       $mail_file, $?);
	    &exit();
	}
        process_mail_file("$temp_mail_file");
	if (!$batch
	    && (access_time("$mail_dir/$mail_folder") > $last_real_mail)) {
	    $last_real_mail = access_time("$mail_dir/$mail_folder");
            $new_sender_list = get_sender_list("$mail_dir/$mail_folder");
            $senders = substr($new_sender_list, length($last_sender_list));
	    $senders =~ s/^[, ]+//;
	    if ($senders ne "") {
		if ($anonymous_notify) {
		    $senders = "someone";
		}
		issue_command("notify.sh New mail from $senders &");
	    }

            $last_sender_list = $new_sender_list;
	}
	if (! $separate_mail_file) {
	    run_command("rm $mail_file");
	}
    }
    if ($batch || $test_mode) {
	last;
    }

    system("sleep $sleep_period");
}

#------------------------------------------------------------------------------

sub access_time {
    local ($filename) = @_;
    local ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
           $atime,$mtime,$ctime,$blksize,$blocks)
                        = stat($filename);
    return ($mtime);
}


# get the list of senders from the specified mailfile
# TODO: filter out senders from embedded messages
#
sub get_sender_list {
    local ($filename) = @_;
    local ($senders);

##    $senders = run_command("grep '^From: ' $filename | sed -e 's/From: //' -e 's/ <.*//' | sort | uniq");
    $senders = run_command("grep '^From: ' $filename | sed -e 's/From: //' -e 's/ <.*//'");
    $senders =~ s/\n\n//g;
    $senders =~ s/\n/, /g;
    $senders =~ s/["'<>]//g;
    #senders =~ s/ *,* *//;           # remove leading spaces and extra comma

    ## Escape special shell characters
    $senders =~ s/([\(\)\&\*\?\$])/\\$1/g;
    $senders =~ s/\[/\\\</g;
    $senders =~ s/\]/\\\>/g;
    ## $senders =~ s/&/\\&/g;

    return ($senders);
}

sub handle_message {

    @header = parse_header();
    $temp_file = create_temp(@header);
    run_command("procmail $procmail_options < $temp_file 1> procmail.log 2>&1");
    ## unlink($temp_file);
}


#
# This function stores a message in a temporary file.
# It returns the name of the temporary file or null.
#
# NOTE: header argument ignored; uses globals mail_header & mail_body
#
sub create_temp {
    local(@header) = @_;
    local($login, $time, $temp_file);
    local($date, $time, $proc_info);

    # Create a temporary file name using the time
    #
    do {
	$time = time;
	$temp_file = "${temp_dir}/$time";
    } until (! -e "$temp_file");

    # Now create temporary header and body files, logging the process.
    #
    open(MSG, ">$temp_file");
    print(MSG "$mail_header\n");
    print(MSG "\n\n");
    print(MSG "$mail_body\n");
    close(MSG);
    chmod 0666, "$temp_file";
    return ($temp_file);
}


# This function extracts the from address, subject and mailing date
# from a mail message header, held in the global variable $mail_header.
#
sub parse_header {
    local($addr, $subj, $date, $to);

    #
    # Fix up the continuation lines
    #
    $mail_header =~ s/\n\s+/ /g;

    # Get rid of stupid "csgrads message", etc. that the CS mailer adds
    $mail_header =~ s/cs(grads|all|crl) message ://;

    if ($mail_header =~ /^From: (.*)/) {
	$addr = rfc822_first_route_addr($1);
	$addr =~ s/[<>]//g;
	$addr = "\L$addr";
    }
    
    if ($mail_header =~ /^Subject: (.*)/) {
	$subj = $1;
	while (index($subj, " ", (length($subj)-1)) != ($[ - 1)) {
	    chop($subj);
	}
    }

    if ($mail_header =~ /^Date: (.*)/) {
	$date = $1;
    }

    if ($mail_header =~ /^To: (.*)/) {
	$to = $1;
    }
    debug_out(3, "$addr: $subj ($date; %s)>\n", substr($to, 0, 80));

    return ($addr, $subj, $date, $to);
}


# This function parses a mail file into separate messages
# and then invokes procmail on each message.
#
# GLOBALS: mail_header & mail_body
#
sub process_mail_file {
    local($mail_file) = @_;
    local($next_header, $line_num, $new_num_lines);
    local($temp_file, $num_lines, $truncated, $lines_added, $num_chars, $chars_added);
    local($date, $time, $status, $type, $body);

    if (open(MAIL, "$mail_file")) {

	$num_lines = 0;
	$num_chars = 0;
	$lines_added = 0;
	$chars_added = 0;
	$truncated = $FALSE;
	undef $mail_body;

	## Get the mail header and determine the length
	## TODO: eliminate the redundant parsing in the loop
	$/ = "";		# Set paragraph input mode
	$* = 1;			# Set multi-line matching mode
	$mail_header = <MAIL>;
	debug_out(6, "H: {\n$mail_header}\n");
	$/ = "\n";		# restore line input mode

	if ($mail_header =~ /^X-Lines: ([0-9]*)/) {
	    $num_lines = $1;
	}
	if ($mail_header =~ /^Content-Length: ([0-9]*)/) {
	    $num_chars = $1;
	}
	debug_out(5, "num_lines=$num_lines num_chars=$num_chars\n");

	while (<MAIL>) {
	    debug_out(6, "L%d ($num_lines, $num_chars): {\n$_}\n", $line_num++);
	    
	    ## See if there is a new mail header:
	    ##     line starts with From
	    ##     the counts shouldn't be positive (to skip over forwarded mail)
	    if (/^From/ && ($num_lines <= 0) && ($num_chars <= 0)) {
		## Get the mail header and determine the length
		$next_header = $_;

		# Read the rest of the header (in paragraph mode)
		$/ = "";	# set paragraph input mode
		$next_header .= <MAIL>;
		debug_out(6, "H: {\n$next_header}\n");
		$/ = "\n";	# restore line input mode

		$num_lines = 0;
		$num_chars = 0;
		if ($next_header =~ /^X-Lines: ([0-9]*)/) {
		    $num_lines = $1;
		}
		if ($next_header =~ /^Content-Length: ([0-9]*)/) {
		    $num_chars = $1;
		}

		handle_message();
		$mail_header = $next_header;

		undef $mail_body;
		$lines_added = 0;
		$chars_added = 0;
		$truncated = $FALSE;
		debug_out(5, "num_lines=$num_lines num_chars=$num_chars\n");
	    }

	    ## Otherwise still in the body, so append it to the text
	    else {
		## $new_num_lines = char_occurences($_, "\n");
		$new_num_lines = 1;
		if ($lines_added <= $max_lines) {
		    $mail_body .= $_;
		    $lines_added += $new_num_lines;
		}
		elsif ($truncated == $FALSE) {
		    $mail_body .= "*** Message truncated due to size ***\n";
		    $truncated = $TRUE;
		}
		else {
		    # ignore the line
		}
		$num_lines -= $new_num_lines;
		$num_chars -= 1 + length($_);
	    }
	}
	$/ = "\n";

	# Don't forget to handle last message
	#
        handle_message();
    }
    else {
	$status = "Panic";
	$type = "Open-Error";
	$desc = "Open on $mail_file failed!";
	print stderr "$status: $type ($desc)\n";
	exit 1;
    }

}


## char_occurences: count occurrences in the text of the given text
## TODO: optimize
##

sub char_occurences {
    local ($text, $char) = @_;
    local ($i, $len, $count);
    ## debug_out(5, "char_occurences($text, $char)\n");

    $count = 0;
    $len = length($text);
    for ($i = 0; $i < $len; $i++) {
	## debug_out(5, "substr($text, $i, 1) = %d\n", substr($text, $i, 1));
	if (substr($text, $i, 1) eq $char) {
	    $count++;
	}
    }

    return ($count);
}
