my @tests = (
  'skipif.([^,]+)',
  'skipif.$([^,]+)',
  'skipif.^([^,]+)',
  'skipif.[^,$]+',
  'skipif.[^,^]+',
  'foo$',
  '^foo',
  'foo\$bar',
  'foo\^bar',
);
foreach my $pattern (@tests) {
  my $clean = $pattern;
  $clean =~ s/\\.//g;
  $clean =~ s/\[.*?\]//g;
  my $has_internal_anchor = ($clean =~ /[\^\$]/) ? 1 : 0;
  print "Pattern: $pattern | Clean: $clean | Has Internal: $has_internal_anchor\n";
}
