#! /bin/csh -f
#
# show_term_vector.sh: displays a sparse-vector representation for the
# document's term vector

if ("$2" == "") then
    echo "usage: show_term_vector.sh base_name doc_num [key_file]"
    exit
endif

if (-e full_matrix.lisp.gz) gunzip full_matrix.lisp.gz
if (! (-e full_matrix.lisp)) then
    echo "full_matrix.lisp not found; run matrix2lisp.sh first!"
    exit
endif

set base = $1
set doc_num = $2
set key_file = $3
if ("$3" == "") set key_file = $base.keys
@ line_num = $doc_num + 1

## set echo = 1
tail +$line_num full_matrix.lisp | head -1 > temp_features.list
set feature_num = 1
foreach feature_value (`cat temp_features.list`)
    if ("${feature_value}" !~ [\(\)0]) then
	set feature_name = `grep -w ${feature_num} $key_file | cut -f1`
	echo "${feature_name}: ${feature_value}"
    endif
    @ feature_num++
end

