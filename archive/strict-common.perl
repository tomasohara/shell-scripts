# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
# strict-common.perl: version of common.perl that specifies 'use strict'
#
# NOTE: This is mainly for testing that common.perl itself is strict in
# it's declarations.
#
use strict;

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
}


# Initialization: return 1 to indicate success in the package loading.

1;
