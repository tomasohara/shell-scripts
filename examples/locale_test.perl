# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# locale_test.perl: illustrate use of locale
# via https://www.cs.ait.ac.th/~on/O/oreilly/perl/cookbook/ch06_13.htm
#
# Sample ouput:
# English names: Andreas K Nig
# German names:  Andreas Kænig

# TODO: Address the to-do notes below (search for 'todo')
#

use open ":std", ":encoding(UTF-8)";

use locale;
use POSIX 'locale_h';

$name = "andreas k\xF6nig";
## BAD: @locale{qw(German English)} = qw(de_DE.ISO_8859-1 us-ascii);
@locale{qw(German English)} = qw(de_DE.utf8 en_US.utf8);

setlocale(LC_CTYPE, $locale{English})
  or die "Invalid locale $locale{English}";
@english_names = ();
while ($name =~ /\b(\w+)\b/g) {
        push(@english_names, ucfirst($1));
}
setlocale(LC_CTYPE, $locale{German})
  or die "Invalid locale $locale{German}";
@german_names = ();
while ($name =~ /\b(\w+)\b/g) {
        push(@german_names, ucfirst($1));
}

print "English names: @english_names\n";
print "German names:  @german_names\n";
