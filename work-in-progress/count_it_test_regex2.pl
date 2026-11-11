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
  my $temp = $pattern;
  $temp =~ s/\\.//g;
  $temp =~ s/\[.*?\]//g;
  my $has_internal_anchor = 0;
  if ($temp =~ /(?<!^)\^|\$(?!$)/) { $has_internal_anchor = 1; }
  print "Pattern: $pattern | Internal: $has_internal_anchor\n";
}
