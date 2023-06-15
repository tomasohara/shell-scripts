var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"set -euo pipefail","class":"lineCov","hits":"1","order":"1","possible_hits":"0",},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"if command -v greadlink >/dev/null; then","class":"lineCov","hits":"1","order":"2","possible_hits":"0",},
{"lineNum":"    6","line":"  bats_readlinkf() {"},
{"lineNum":"    7","line":"    greadlink -f \"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"  }"},
{"lineNum":"    9","line":"else"},
{"lineNum":"   10","line":"  bats_readlinkf() {"},
{"lineNum":"   11","line":"    readlink -f \"$1\"","class":"lineCov","hits":"1","order":"4","possible_hits":"0",},
{"lineNum":"   12","line":"  }"},
{"lineNum":"   13","line":"fi"},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"fallback_to_readlinkf_posix() {"},
{"lineNum":"   16","line":"  bats_readlinkf() {"},
{"lineNum":"   17","line":"    [ \"${1:-}\" ] || return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"    max_symlinks=40","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"    CDPATH=\'\' # to avoid changing to an unexpected directory","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":""},
{"lineNum":"   21","line":"    target=$1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   22","line":"    [ -e \"${target%/}\" ] || target=${1%\"${1##*[!/]}\"} # trim trailing slashes","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   23","line":"    [ -d \"${target:-/}\" ] && target=\"$target/\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   24","line":""},
{"lineNum":"   25","line":"    cd -P . 2>/dev/null || return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   26","line":"    while [ \"$max_symlinks\" -ge 0 ] && max_symlinks=$((max_symlinks - 1)); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   27","line":"      if [ ! \"$target\" = \"${target%/*}\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   28","line":"        case $target in","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   29","line":"        /*) cd -P \"${target%/*}/\" 2>/dev/null || break ;;","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   30","line":"        *) cd -P \"./${target%/*}\" 2>/dev/null || break ;;","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   31","line":"        esac"},
{"lineNum":"   32","line":"        target=${target##*/}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   33","line":"      fi"},
{"lineNum":"   34","line":""},
{"lineNum":"   35","line":"      if [ ! -L \"$target\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   36","line":"        target=\"${PWD%/}${target:+/}${target}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   37","line":"        printf \'%s\\n\' \"${target:-/}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   38","line":"        return 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   39","line":"      fi"},
{"lineNum":"   40","line":""},
{"lineNum":"   41","line":"      # `ls -dl` format: \"%s %u %s %s %u %s %s -> %s\\n\","},
{"lineNum":"   42","line":"      #   <file mode>, <number of links>, <owner name>, <group name>,"},
{"lineNum":"   43","line":"      #   <size>, <date and time>, <pathname of link>, <contents of link>"},
{"lineNum":"   44","line":"      # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/ls.html"},
{"lineNum":"   45","line":"      link=$(ls -dl -- \"$target\" 2>/dev/null) || break","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   46","line":"      target=${link#*\" $target -> \"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   47","line":"    done"},
{"lineNum":"   48","line":"    return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   49","line":"  }"},
{"lineNum":"   50","line":"}"},
{"lineNum":"   51","line":""},
{"lineNum":"   52","line":"if ! BATS_PATH=$(bats_readlinkf \"${BASH_SOURCE[0]}\" 2>/dev/null); then","class":"lineCov","hits":"2","order":"3","possible_hits":"0",},
{"lineNum":"   53","line":"  fallback_to_readlinkf_posix","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   54","line":"  BATS_PATH=$(bats_readlinkf \"${BASH_SOURCE[0]}\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   55","line":"fi"},
{"lineNum":"   56","line":""},
{"lineNum":"   57","line":"export BATS_ROOT=${BATS_PATH%/*/*}","class":"lineCov","hits":"2","order":"5","possible_hits":"0",},
{"lineNum":"   58","line":"export -f bats_readlinkf","class":"lineCov","hits":"1","order":"6","possible_hits":"0",},
{"lineNum":"   59","line":"exec env BATS_ROOT=\"$BATS_ROOT\" \"$BATS_ROOT/libexec/bats-core/bats\" \"$@\"","class":"lineCov","hits":"1","order":"7","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2023-06-15 21:54:54", "instrumented" : 30, "covered" : 7,};
var merged_data = [];
