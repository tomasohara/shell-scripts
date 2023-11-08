#! /bin/csh -f

if ("$1" == "") then
    echo "usage: `basename $0` text_file"
    echo ""
    echo "Runs LSI (latent semantic indexing) on the text file, which is treated"
    echo "as a group of documents that are each separated by a blank line."
    echo ""
    exit
endif

set echo = 1
setenv PATH ${PATH}:/home/language_tools/IR/lsi/bin
set script_dir = `dirname $0`
set file = $1
shift
if ((! -e file) && (-e $file.text)) set file = "$file.text"
set base = `basename $file .text`


# Remove previous output files
if (-e keys.pag) rm keys.pag keys.dir RUN_SUMMARY out full_matrix.list full_matrix.list.gz

# Preprocess the file AND invoke SVD (singular value decomposition)
# pindex options used:
#	-hb			keeps hb (harwell boeing) matrix around
#	-P			use 'svd' as svd binary*
#	-M<line_len>		maximum document-length for mkey
#
## pindex -hb -P $1
nice +19 $script_dir/pindex.sh -M 1000000 -hb -P $* $file

# Display the result of the indexing
scat > $base.scat

# Display the key index
getkeydb -a > $base.temp_keys
sort -n +1 $base.temp_keys | cut -f1,2 > $base.keys
