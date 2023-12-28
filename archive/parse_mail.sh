#! /bin/csh -f

pushd ~/Mail
## perl -Ss parse_mail.perl -temp=$HOME/temp/Mail -anonymous_notify
perl -Ss parse_mail.perl -temp=$HOME/temp/Mail
popd
