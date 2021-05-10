#! /bin/csh -f

set echo = 1

set i = 0
while ($i < 10)
    source test_csh_sub.sh
#    goto sub
# ret:

    @ i++
end

