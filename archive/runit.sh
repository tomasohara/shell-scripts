#!/bin/csh -f
# rem @echo off

r0:
set DEBUG_LEVEL=4
perl -Ss align_all_words.perl -redirect=1 -k=100 -min_freq=3 -max_freq=10 eng_revelations.text sp_revelations.text > runit0.log
goto exit


r1:
set DEBUG_LEVEL=5
perl -Ssw align_words.perl -redirect=1 -subset1="angel" temp_english.kvec.50 temp_spanish.kvec.50 > runit1.log
goto exit


r2_:
current:
set DEBUG_LEVEL=3
nice +19 perl -Ssw align_words.perl -min_freq=10 temp_english.kvec.var temp_spanish.kvec.var >& runit2_.log
goto exit


r3:
set DEBUG_LEVEL=5
perl -Ssw align_words.perl -redirect=1 temp_english.kvec.50 temp_spanish.kvec.50 any y
goto exit

r4:
set DEBUG_LEVEL=6
perl -Ssw align_all_words.perl -redirect=1 -use_fixed_slots=0 rev_eng.text rev_sp.text > runit4.log
goto exit


r5:
set DEBUG_LEVEL=3
perl -Ssw align_all_words.perl -redirect=1 -use_fixed_slots=0 eng_revelations.text sp_revelations.text > runit5.log
goto exit


r6:
set DEBUG_LEVEL=5
perl -Ssw align_words.perl -redirect=1 -subset1="$2" temp_english.kvec.50 temp_spanish.kvec.50 > runit6.log
goto exit


r7:
set DEBUG_LEVEL=5
perl -Ssw align_words.perl -redirect=1 -subset1="$2" temp_english.kvec.var temp_spanish.kvec.var > runit7.log
goto exit

r9:
perl -Ssw qd_eval.perl -d=5 -spanish=0 -eng_dict=eng_f.dict -sp_dict=sp_f.dict temp_output_1 > &! runit9.log
goto exit

r10:
perl -Ssw qd_eval.perl -d=5 -spanish=1 -eng_dict=eng_c.dict -sp_dict=sp_c.dict temp_output_2 > &! runit10.log
goto exit

exit:
