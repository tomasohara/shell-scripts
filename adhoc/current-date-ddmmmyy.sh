#! /usr/bin/env bash
#
# Outputs current date in format DDmmmYY
#
date '+%d%b%y' | perl -pe 's/.*/\L$&/;'
