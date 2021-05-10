# convera-setup.bash: Setup TPO's bash environment for Convera work
#
# TODO:
# - Move Convera-specific settings from bin/do_setup.bash and cygwin-setup.bash
#   into here. 
# - Create similar scripts for ILIT, NMSU, and other specific settings.
#
# NOTE:
# - Variables in function definitions should be declared local to avoid subtle problems
#   fue to retained values.
#

export PATH="$PATH:/c/convera/rware/bin"

function do-pdf-extraction () { file=$1;   basename=`basename $file .pdf`; dir=`dirname $file`; base="$dir/$basename";   /usr/bin/time /c/cartera-de-tomas/convera/rw_pdf.exe -b 'C:\Convera\rware' -debug 6 -plain -encoding UTF-8 -file $file  -o  $base.adobe.txt >| $base.adobe.log 2>&1; ls -lt $file $base.adobe.txt $base.adobe.log; }

# Language and encoding detection related
#
function utf8-to-utf16 () { java -jar `winpath ~/bin/convera/encodingConverter.jar` -bom UTF-8 $1 UTF-16LE $1.utf16; }
function utf16-to-utf8 () { java -jar `winpath ~/bin/convera/encodingConverter.jar` -bom UTF-16LE $1 UTF-8 $1.utf8; }
function detect-encoding () { java -cp `winpath ~/bin/convera/encodingDetector.jar` com.convera.EncodingDetector "$@"; }
function detect-encoding-verbose () { java -cp `winpath ~/bin/convera/encodingDetector.jar` com.convera.EncodingDetector --verbose "$@"; }
#
# Aliases for running RWare standalone tokenizers over input text file, including a separate debug run.
# Usage: IDtok FILE [SUFFIX] [ARGS], where ID is one of { ar, cs, ja, ko }.
# Example: jatok JA-japan-wiki.txt with-compounds --retain-compounds
#
function xxtok() { 
    local lang="$1"; local file="$2"; shift; shift; 
    local suffix=""; case $1  in   -*) suffix="";;   ?*) suffix=".$1"; shift;; esac;
    local basename=`basename "$file" .txt`; local dir=`dirname "$file"`; local base="$dir/$basename";
    ## local xxtok="${lang}tok"; local bin_dir="$HOME/bin/convera"; local tok_exe="${bin_dir}/${xxtok}.exe"; local params=`winpath $bin_dir/shared.params`;
    local xxtok="${lang}tok"; local bin_dir="/my-data/bin-copy/convera"; local tok_exe="${bin_dir}/${xxtok}.exe"; local params=`winpath $bin_dir/shared.params`;
    local output_base="$base.$xxtok$suffix";
    # HACK: Use the local version of the xxtok executable.
    if [ -x "debug\\${xxtok}.exe" ]; then tok_exe="debug\\${xxtok}.exe"; fi
    ## TODO:  show-unicode-code-info $file >| $basename.code-info;
    $tok_exe --utf8 --params "$params" "$@" < "$file" >| "$output_base.list" 2>&1;
    $tok_exe --utf8 --debug 6 --params "$params"  "$@" < "$file" >| "$output_base.debug.log" 2>&1;
    ls -lt "$output_base.list" "$output_base.debug.log" "$file";
}
function artok() { xxtok ar "$@"; }
function cstok() { xxtok cs "$@"; }
alias zhtok=cstok
function jatok() { xxtok ja "$@"; }
function kotok() { xxtok ko "$@"; }

# Tokenization related
#
# NOTE: show-unicode-code-info defined in bin/do_setup.bash:
#    function show-unicode-code-info() { perl -CIOE   -e 'use Encode "encode_utf8"; print "char\tord\toffset\tencoding\n";'    -ne 'chomp;  printf "%s: %d\n", $_, length($_); foreach $c (split(//, $_)) { $encoding = encode_utf8($c); printf "%s\t%04X\t%d\t%s\n", $c, ord($c), $offset, unpack("H*", $encoding); $offset += length($encoding); }   $offset += length($/); print "\n"; ' < $1; }
#
#
function show-unicode-code-info-simple () { perl -CIOE   -e 'use Encode "encode_utf8"; print "char\tord\toffset\n";'    -ne 'chomp;  printf "%s: %d\n", $_, length($_); foreach $c (split(//, $_)) { printf "%s\t%04X\t%d\n", $c, ord($c), $offset; $offset += length(encode_utf8($c)); }   $offset += length($/); print "\n"; ' < $1; }
#
function show-character-offsets () { perl -e 'print "offset\tline\tlength\tbytes\n";';    perl   -e 'use Encode "decode_utf8"; binmode(STDOUT, ":utf8");'    -ne 'chomp $_;  $line = $_;  $uni = decode_utf8($line);  printf "%d\t%s\t%d\t%d\n", $offset, $uni, length($uni), length($line);  $offset += (1 + length($line));' < $1; }
#
function do-tagging () { xxtok="${1}tok"; file=$2;   basename=`basename $file .txt`; dir=`dirname $file`; base="$dir/$basename";         /usr/bin/time debug/$xxtok.exe --utf8 --debug 6 --params shared.params < $file >| $base.debug.log 2>&1;  debug/$xxtok.exe --utf8 --params shared.params < $file >| $base.list 2>&1;  }

# RWare settings
export RW_BASE="/c/convera/rware/"
export RW_APPS="/c/convera/apps/"
export INSTALL_DIR='c:\convera\rware'
export RW_BIN="$RW_BASE/bin"
export RW_LIB="$RW_BASE/lib"
export RW_LANGS="$RW_BASE/resource/cartridges/languages"
admind="RetrievalWare AdminExecd"
jboss_app="RetrievalWare App Server"
#
alias start-admind-old="sc start '$admind'"
alias stop-admind-old="sc stop '$admind'"
alias start-admind="$RW_BASE/admin/manage_admind.bat start"
alias stop-admind="$RW_BASE/admin/manage_admind.bat stop"
alias query-admind="sc query '$admind'"
alias restart-admind='stop-admind; start-admind'
#
alias start-jboss-app="sc start '$jboss_app'"
alias stop-jboss-app="sc stop '$jboss_app'"
alias query-jboss-app="sc query '$jboss_app'"
#
function kill-rware-forcibly() { stop-admind; foreach.perl 'taskkill /f /im $f.exe' execd cqdh cqindex cqns cqquery cqsched cqserv cqxref; }

# RWare Compilation
alias prep-regular-build='echo rlogin aldeberon script/build_each.csh -debug -nt >| _nt-debug-build_each.log'
alias do-regular-build='ntutils/buildnt.bat >| _buildnt.log 2>&1; check-errors  _buildnt.log 80make.nt.txt'
