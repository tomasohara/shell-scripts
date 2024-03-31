# Some csh aliases that have been useful
#
alias check_reports "egrep -A1 '(BEST MODEL)|(testing)' \!* | egrep -v '(idx)|(BEST)|(\-\-)'"
alias check_class_dist 'perl_ count_it.perl "^(\S+)\t" \!* | perl_ calc_entropy.perl -'
alias remove_tex_comments "perl -i.bak -p -e 's/([^\\])%.*/\1/; s/^%.*\n//;' \!*"
