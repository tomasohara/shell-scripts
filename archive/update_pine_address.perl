# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# update_pine_address.perl: updates Pine's address book with entries from
# .mailrc
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*HOME, "~");
&init_var(*MAIL_DIR, "$HOME/Mail");

chdir $MAIL_DIR;

&issue_command("brk2pine.sh < $HOME/.mailrc > .temp_pine_update");

# Read the pine address book and make all entries have single lines
$pine_addresses = &read_file("$HOME/.pine_addressbook");
&write_file(".old_pine_addressbook", $pine_addresses);
$pine_addresses =~ s/\n //g;
&write_file(".temp_pine_addressbook", $pine_addresses);

# Combine the entries from .mail, retaing the unique cases
&issue_command("sort .temp_pine_update .temp_pine_addressbook | uniq > .new_pine_addressbook");

# Print the updated version
## &copy_file(".new_pine_addressbook", "$HOME/.pine_addressbook");
$new_pine_addresses = &read_file(".new_pine_addressbook");
print $new_pine_addresses;
