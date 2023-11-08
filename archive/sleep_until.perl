# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# sleep_until.perl: sleep until the time specified
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (!defined($ARGV[0])) {
    $options = "options = n/a";
    $example = "ex: $script_name 8:00pm\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

local($now_hour, $now_min) = &get_hour_min();
##local($end_hour, $end_min) = split(/:/, $ARGV[0]);
local($end_time) = $ARGV[0];
local($end_hour) = $now_hour;
local($end_min) = $now_min;

# Parse the time specification
if ($end_time =~ /(\d+):?(\d+)?(am|pm)?/i) {
    $end_hour = $1; 
    $end_min = defined($2) ? $2 : 0;
    $am_pm = defined($3) ? $3 : "";

    if (($am_pm =~ /am/i) && ($end_hour == 12)) {
	$end_hour -= 12;
    }
    if (($am_pm =~ /pm/i) && ($end_hour < 12)) {
	$end_hour += 12;
    }
}
else {
    &error_out("unable to parse time specification '$end_time'\n");
    exit;
}

# Determine how many seconds to wait

# $hour_diff = ($end_hour - $now_hour);
# $hour_diff += 24 if ($hour_diff <0);

# $min_diff = ($end_min - $now_min);
# if ($min_diff < 0) {
#     $min_diff += 60;
#     $hour_diff -= 1;
# }

# $seconds = ($hour_diff * 3600) + ($min_diff * 60);
# &debug_out(5, "min_diff=$min_diff hour_diff=$hour_diff seconds=$seconds\n");

$sec_now = (($now_hour * 3600) + ($now_min * 60));
$sec_end = (($end_hour * 3600) + ($end_min * 60));
$seconds = ($sec_end - $sec_now);
if ($seconds < 0) {
    $seconds += (24 * 3600);
}
&debug_out(5, "sec_now=$sec_now sec_end=$sec_end seconds=$seconds\n");

# Wait for the time to elapse
&cmd("sleep $seconds", 3);

#------------------------------------------------------------------------------

# get_HM(): returns current time in (hour, min) format with 24-hour times
#
sub get_hour_min {
    &debug_out(6, "get_hour_min()\n");

    # Get the local time structure
    local($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) 
        = localtime(time);
    &debug_out(6, "($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)\n");

    return (($hour, $min));
}
