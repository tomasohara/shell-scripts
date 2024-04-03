# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# reoundup2iso.perl: convert from the Round Up's encoding into iso 9660
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

while (<>) {
    &dump_line;
    s/�/�/g;			# "R�o Grande"
    s/�/--/g;			# "Texas (AP) � Agentes"
    s/�/�/g;			# "operaci�n"
    s/�/�/g;			# "M�xico"
    s/�/�/g;			# "a�adiendo"
    s/�/�/g;			# "est�"
    s/[��]/\"/g;		# "�Este es otro ejemplo ... zonas rurales�"
    # s///g;			# ""
    print;
}
