# Adhoc scripts

This directory contains script that are not quite general pupose.
Nonetheless, they seem useful for inclusion in the shell script
collection.

Some of these are suitable for automatiion such as via cron jobs.
This can be done as follow (optionally run via sudo):

```
crontab -e

    # check for inactive server every hour (on the hour) and shutdown if so
    # min hour mday mon wday  command
      0   *    *    *   *     $HOME/bin/adhoc/consolidate-notes.bash
```

where the cron table format follows:
```
    # - crontab format and example [based on CRONTAB(5), web searching, etc.]:
    #     min  hour  day-of-month  month  day-of-week   command

```
