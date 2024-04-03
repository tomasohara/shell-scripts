#!/bin/csh -f
setenv CRLDIR /home/tipster
setenv PATH $CRLDIR/crl_tipster/English/code/muc6_code:$PATH
setenv T_E_CODE $CRLDIR/crl_tipster/English/code/ejv_code/
cat >/usr/tmp/$$.inp
cmucl -core $CRLDIR/crl_tipster/English/code/ejv_code/post.core -init $T_E_CODE/post-init <<!
(progn 
  (setf *max-sentence-length* 2000)
  (defparameter *current-sentence-tags* (make-array *max-sentence-length*))
  (setf *sentence* (make-array *max-sentence-length*))
  (setf *bi-tag-alpha*
	(make-array \`(,*bi-tag-state-count* ,*max-sentence-length*)
		    :element-type 'float))

  (setf *bi-tag-trace-back*
	(make-array \`(,*tag-count* ,*max-sentence-length*)))

  (setf *bi-tag-beta*
	(make-array \`(,*bi-tag-state-count* ,*max-sentence-length*)
		    :element-type 'float))
  (tag-file "/usr/tmp/$$.inp" "/usr/tmp/$$.outp")
  (quit))
!

cat /usr/tmp/$$.outp
rm  /usr/tmp/$$.*
