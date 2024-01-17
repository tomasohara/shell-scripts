# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# client.perl: sends text to the server
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (defined($ARGV[0]) && ($ARGV[0] eq "help")) {
    $options = "options = [-server_addr=N.N.N.N]";
    $example = "ex: $script_name text\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}



$sockaddr_pat = 'S n C4 x8';
$pf_inet = 2;

&init_var(*port, 1500);
&init_var(*server_addr, "127.0.0.1");

@server = split(/\./, $server_addr);
$this = pack($sockaddr_pat, $pf_inet, $port, 
	     $server[0], $server[1], $server[2], $server[3]);

select(NS); $| = 1; select(STDOUT);

if (socket(S,2,1,6) == 0) { die $!; }
&debug_out(3, "socket ok\n");

if (bind(S, $this) == 0) { die $!; }
&debug_out(3, "bind ok (addr=${server_addr}; port=$port)\n");

if (listen(S,5) == 0) { die $!; }
&debug_out(3, "listen ok\n"); 

for (;;) {
    &debug_out(3, "Listening again\n");
    if (($addr = accept(NS,S)) eq "") { die $!; }
    &debug_out(3, "accept ok\n");

    @ary = unpack($sockaddr_pat, $addr);
    ## $, = ' ';
    &debug_out(4, "ary=@ary\n"); 

    while (<NS>) {
	print;
	print NS;
    }
}
