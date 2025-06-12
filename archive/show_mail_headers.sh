#! /bin/csh -f

## egrep -h "^((From )|(Date:)|(Subject:))" $* > temp_show.list
egrep -h "^((From )|(Subject:))" $* > temp_show.list
perl -pn -e "s/From/\nFrom/g;" temp_show.list
