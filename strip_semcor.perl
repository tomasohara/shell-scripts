# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
# strip_semcor.perl: converts from Semcor SGML format into
# plain ascii text
#
# Sample input:
#
# <s snum=28>
# <wf cmd=ignore pos=PRP$>His</wf>
# <wf cmd=done pos=NN lemma=petition wnsn=1 lexsn=1:10:00::>petition</wf>
# <wf cmd=done pos=VB lemma=charge wnsn=6 lexsn=2:32:00::>charged</wf>
# <wf cmd=done pos=JJ lemma=mental wnsn=2 lexsn=3:01:00::>mental</wf>
# <wf cmd=done pos=NN lemma=cruelty wnsn=2 lexsn=1:12:00::>cruelty</wf>
# <punc>.</punc>
# </s>
#
# Sample output:
# 
#  His petition charged mental cruelty .
#  
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

# process each line of the input stream
while (<>) {
    s/<[^>]+>//g;
    s/([a-z0-9\'\`\",;])\n/$1 /i;
    s/^ *\n//;
    s/^\.$/.\n/;
    print;		# remainder of line (includes newline)
}
