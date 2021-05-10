# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# run-make.perl: Run GNU make and then do reformatting of the line number references
# so that they are recognized by Visual C++ (in output window)
#
# example (in Visual C++ custom build commands field):
#    perl .\run-make.perl -f makefile clean prep
#
# NOTES:
# - When running from within Visual C++, The PATH environment variable needs
# to contain the directory with run-make.perl (and common.perl).
# 

system("make @ARGV 2>&1 | perl -pe  's/\\//\\\\/g;' -pe 's/:(\\d+):/\\(\\1\\) :/g;'");
