#! /bin/csh -f

set make_it=0
if ("$1" == --it) then
    set make_it=1
    shift
endif

if ($make_it == 1) then
    echo "it("
    grep -v '^%' $1 | grep -v '^ *$' | sed -e "s/\]\./])./";
else
    grep -v '^%' $1 | grep -v '^ *$'
endif

