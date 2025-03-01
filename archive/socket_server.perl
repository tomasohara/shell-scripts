# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -Tsw
#
# socket server script from Perl man pages (sockets section)
#
# NOTES:
#
# -T forces ``taint'' checks to be turned on so you can test them. 
#    Ordinarily these checks are done only when running setuid or setgid.
#

require 5.002;

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

use strict;
BEGIN { $ENV{PATH} = '/usr/ucb:/bin' }
use Socket;
use Carp;

sub logmsg { print "$0 $$: @_ at ", scalar localtime, "\n" }

my $port = shift || 2345;
my $proto = getprotobyname('tcp');
socket(Server, PF_INET, SOCK_STREAM, $proto)        || die "socket: $!";
setsockopt(Server, SOL_SOCKET, SO_REUSEADDR,
	   pack("l", 1))   || die "setsockopt: $!";
bind(Server, sockaddr_in($port, INADDR_ANY))        || die "bind: $!";
listen(Server,SOMAXCONN)                            || die "listen: $!";

logmsg "server started on port $port";

my $paddr;

$SIG{CHLD} = \&REAPER;

for ( ; $paddr = accept(CLIENT,Server); close CLIENT) {
    my($port,$iaddr) = sockaddr_in($paddr);
    ## &debug_out(4, "port=$port; iaddr=%s\n", unpack("x4", $iaddr));
    my $name = gethostbyaddr($iaddr,AF_INET) || "???";

    logmsg "connection from $name [", inet_ntoa($iaddr), "] at port $port";

    select(CLIENT); $| = 1; select(STDOUT);
    print CLIENT "Hello there, $name, it's now ",  scalar localtime, "\n";
    while (<CLIENT>) {
	print;
	print CLIENT "ok\n";
    }
}

