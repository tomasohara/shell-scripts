# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# get_cmplg.perl: Retrieve abstract and postscript file for an article 
# available at the Computation and Language (Cmp-Lg) E-print archive,
#
# This uses lynx to retrieve the documents via the web.
#
# NOTE: The configuration file needs to disable the postscript type
# in order to force downloading to disk.
# TODO: figure out how to do this via a command line argument to lynx
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (!defined($ARGV[0])) {
    $options = "options = [-source] [-old]";
    $example = "ex: $script_name -prefix=argamon_ 9806011\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

&init_var(*source, &FALSE);
&init_var(*LYNX, "lynx");
&init_var(*lynx_config, "${script_dir}/lynx_batch.cfg");
&reference_var($script_dir);
&init_var(*prefix, "");
&init_var(*old, &FALSE);

local($key);
foreach $key (@ARGV) {
    &retrieve_article($key);
}
&exit();

#------------------------------------------------------------------------------

# retrieve_article(key)
#
# Retrieves the article with the given 7 digit key (YYMMNNN).
#
sub retrieve_article {
    local($key) = @_;
    local($base) = "$prefix$key";
    local($lynx_command) = "$LYNX -cfg=${lynx_config}";

    # Determine the prefix from the first author's last name in the abstract
    # examples: "Author: [2]Aravind K. Joshi, [3]B. Srinivas"
    #           "Author: Michael Mc Hale, Air Force Research Laboratory"
    if ($prefix eq "") {
	local($abstract) = &run_command("$lynx_command -dump http://xxx.lanl.gov/abs/cmp-lg/$key");
	if ($abstract =~ /Authors?: (\[\d+\])?([^,\(]+)/i) {
	    $author = &trim(&to_lower($2));
	    $author =~ s/((mc)|(o)) /$1/g; 	# include last name prefixes
	    $author =~ s/.* //;			# drop all but the last token
	    $base = "${author}_${key}";
	}
    }
    &debug_out(4, "base=$base\n");
    local($section) = ($old ? "cmp-lg" : "cs.CL");
    &cmd("$lynx_command -dump http://xxx.lanl.gov/abs/$section/$key > $base.abs", &TL_USUAL);
    &cmd("$lynx_command -dump http://xxx.lanl.gov/ps/$section/$key > $base.ps", &TL_USUAL);
    if ($source) {
	&cmd("$lynx_command -dump http://xxx.lanl.gov/e-print/$section/$key > $base.tar.gz", &TL_USUAL);
    }

    return;
}
