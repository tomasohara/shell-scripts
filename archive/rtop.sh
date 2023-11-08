#!/bin/csh -f
set hosts=(aeolia aigyptos aiaia aiolon crl dodona ephyre hellespont ilios ismaros ithaka kimmerion kypros lemnos lole marathon mykene ogygia orchomenos phoenicia pylos scheria sparta thebes thrinakia troia zakynthos)

rm top.lst
foreach host ($hosts)
   rsh $host top >> top.lst
end

	      

