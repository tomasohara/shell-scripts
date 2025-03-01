# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# remote_lpr.perl: submit network interpretation request to the Hugin server 
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (!defined($ARGV[0])) {
    $options = "options = [-printer=name] [-use_lpr] [-testing]";
    $example = "ex: $script_name whatever\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

# TODO: use the users server with their own passwd
&init_var(*GRAPHLING_PASSWD, 'G!r@a#p$h%L^i&n*g(');
## &init_var(*lexquad, &FALSE);
&init_var(*printer, "lexdraft");
&init_var(*use_lpr, &FALSE);
&init_var(*TEMP, "/tmp");
&init_var(*testing, &FALSE);

# See if any of the known printers were specified by -printer or -Pprinter
@printers = ("sp4", "sp5", "lp",
	     "lexquad", "lexnormal", "lexdraft", "lexfine", 
	     "lex2quad", "lex2normal", "lex2draft", "lex2fine");
foreach $p (@printers) {
    if (eval "defined(\$$p) || defined(\$P$p)") {
	$printer = $p;
	last;
    }
}

local($file);
foreach $file (@ARGV) {
    local($base) = &remove_dir($file);
    local($temp_log) = "temp_$$.log";

    # Determine whether the file is postscript
    local($ps) = ($file =~ /.ps$/);
    # local($ps_header) = &run_command("head -1 $file");
    # local($ps) = ($ps_header =~ /%! *PS/);
    
    # Create script for printing the file
    $script = "";
    $script .= "AUTHENTICATE graphling $GRAPHLING_PASSWD\n";
    $script .= "SEND_FILE $file\n";
    $pre = ($testing ? "echo" : "");
    if ($ps || $use_lpr) {
	$script .= "RUN_COMMAND $pre lpr -P$printer $base >${temp_log} 2>&1\n";
	$script .= "RUN_COMMAND $pre lpq -P$printer $base >>${temp_log} 2>&1\n";
    }
    else {
	$script .= "RUN_COMMAND $pre print.sh -P$printer $base >${temp_log} 2>&1\n";
    }
    $script .= "RECEIVE_FILE ${temp_log}\n";

    # Run the client interface, with the results placed in TEMP dir
    open(CLIENT, "|perl -Ssw generic_client.perl -data_dir=$TEMP -");
    print CLIENT $script;
    close(CLIENT);
    local($log) = &read_file("$TEMP/$temp_log");
    debug_out(3, "$log\n");
}
