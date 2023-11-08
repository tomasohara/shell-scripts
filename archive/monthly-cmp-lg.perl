# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/bin/sh -- # -*- perl -*-
eval 'exec perl -Ssw $0 ${1+"$@"}'
  if 0;

#!/bin/sh perl -Ssw
eval 'exec perl -Ssw $0 ${1+"$@"}'
  if 0;

# #!/bin/sh -- # -*- perl -*-
# eval 'exec perl -Ssw $0 ${1+"$@"}'
#   if 0;

#!/usr/local/bin/perl -sw
#
# monthly-cmp-lg.perl: script to retrieve cmp-lg listings. This is based
# on a script contained in the cmp-lg file "monthly" in the macros directory.
#
#------------------------------------------------------------------------------
#
# from The Computation and Language E-Print Archive
# CMP-LG@XXX.LANL.GOV
#
# Here is a perl program, which I call "monthly-cmp-lg", that requests
# the cmp-lg server to send title/author information for all paper's
# submitted during the previous month.  (No abstract information is
# sent, unless you use the alternate $subject definition that is
# commented out below.)
#
# Save this in the file "monthly-cmp-lg".  (The first two characters in
# the file must be the "#!" at the beginning.)  You can then request
# that this command be executed on the first day of each month by adding
# the following line to your crontab file:
# 
#    30 0 1 * * /home/flicker/shieber/shieber/bin/monthly-cmp-lg
#
#    30 0 1 * * /home/ch1/tomohara/bin/monthly-cmp-lg.sh
#
# monthly-cmp-lg.sh must be used in stupid environments where perl
# is not in a standard location. It just invokes the perl script
# after ensuring perl is active (e.g., via .cshrc).
#

$dir = ($ENV{"HOME"} || ".") . "/bin";
require "$dir/common.perl";

&init_var(*mail, "/usr/ucb/mail");

#################################################
# Perl script to retrieve last month's listings #
#################################################

# The server email address
$address = "cmp-lg\@xxx.lanl.gov";

# Get the time
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
        localtime;
&debug_out(5, "time=($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)\n");

# Move back to last month
if ($mon == 0) {
    $mon = 12;
    $year = $year - 1;
}

## # Generate the subject line to get listings for last month
## $subject = sprintf("listing %02d%02d", $year, $mon);

# Generate the subject line to get listings for last month. 
# TODO: figure out way to include the abstracts, as well as title/author.
# This used to be via 'listing MMYY.abs'
## $subject = sprintf("listing %02d%02d.abs", $year, $mon);
$subject = sprintf("list %02d%02d", $year, $mon);

# Request listings
&issue_command("$mail -s \"$subject\" $address < /dev/null");
