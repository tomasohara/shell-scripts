#! /local/common/bin/tcsh

set subdir = solaris
set file = mt-parse
if ("$1" == "-u") then
    set subdir = .
    set file = parse
    shift
endif
if ("$1" == "-f") then
    set file = $2
    shift
    shift
endif

set echo=1
ftp_get -dir=course_work/parser/$subdir $file

