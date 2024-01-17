;; /home/tom/NL/NL_support.lisp
;; supporting code for perl module NL_support.perl
;;
;; usage:
;; (load "/home/tom/NL/NL_support.lisp")
;;
;; Copyright (c) 2000 - 2001 Cycorp, Inc.  All rights reserved.
;;

(in-package "CYC")

(define-private nl-support-stub ()
  "Dummy function used by perl code to ensure loaded"
  (ret nil))

; ;; Temporary load of customization to lexicon-accessors.lisp
; (progn 
;   (load "/home/tom/cvs/head/cycorp/cyc/cyc-lisp/cycl/lexicon-cache.lisp")
;   (load "/home/tom/cvs/head/cycorp/cyc/cyc-lisp/cycl/lexicon-utilities.lisp")
;   (load "/home/tom/cvs/head/cycorp/cyc/cyc-lisp/cycl/lexicon-accessors.lisp"))

;; is-function-word(word-form)
;;
;; Returns T iff any word unit with a mapping the word form has a part-of-speech
;; in a close category (determiner, preposition, pronoun, etc.).
;;
(define is-function-word (word-form)
    (clet ((is-function-word nil))
        (csome (word-unit (words-of-string word-form) is-function-word)
	   (pwhen (fi-ask-int `(#$thereExists ?POS 
				    (#$and (#$posForms ,word-unit ?POS) 
				           (#$genls ?POS #$ClosedClassWord)))
			      #$EnglishMt)
	     (csetq is-function-word T)
	     ))
	(ret is-function-word)
	))

;; is-valid-word(word-form)
;;
;; Returns T iff there exists a word unit mapped to the word form.
;;
(define is-valid-word (word-form)
   (ret (cnot (null (words-of-string word-form)))))

;; part-of-speech(word-form)
;;
;; Determine the parts-of-speech for the word-form, based on whether on explicit
;; syntactic mapping exists with it or whether the word maps into an individual.
;;
(define parts-of-speech (word-form)
  (clet ((POS-list (pos-of-string word-form)))
    (csome (denot (denots-of-string word-form) POS-list)
      (pwhen (isa-in-any-mt? denot #$Individual)
	(csetq POS-list '(#$ProperNoun))))
    (ret POS-list)
    ))

(define-public string-to-formula (formula-text)
  "@return formula ; lisp representation of the formula given by FORMULA-TEXT
   @todo Make sure the entire string is read"
  (ret (read-from-string-ignoring-errors (cyclify-string formula-text))))

(define-public derive-wordform (word-unit speech-part &optional (lexical-mt #$EnglishMt))
  "@return string ; the main wordform associatied with WORD-UNIT and SPEECH-PART
   @note get-strings-of-type (word-unit pos &optional (include :all) exceptions (mt *lexicon-lookup-mt*)
   @todo ensure that the last wordform returned uses preferred mapping for the speech part"
  (ret (last-one (get-strings-of-type word-unit speech-part :all nil lexical-mt))))

(define-public derive-nonplural-wordform (word-unit speech-part &optional (lexical-mt #$EnglishMt))
  "@return string ; the nonplural wordform associatied with WORD-UNIT and SPEECH-PART
   @note get-strings-of-type (word-unit pos &optional (include :all) exceptions (mt *lexicon-lookup-mt*)
   @todo ensure that the first wordform returned uses non-plural mapping for the speech part"
  (ret (first (get-strings-of-type word-unit speech-part :all nil lexical-mt))))

;;------------------------------------------------------------------------
;; Other utility functions
;; TODO: move to approporiate utilites module (e.g., misc-utilities.lisp)

(define-public try-assert-int (formula mt &optional (strength :default) direction)
  "Like @xref fi-assert-int, but only does the operation when the assertion doesn't exist.
   @return boolean; status code.
   @owner tom"
  (punless (formula-assertions formula mt)
    (ret (fi-assert-int formula mt strength direction)))
  (ret t))

(define-public try-unassert-int (formula mt)
  "Like @xref fi-unassert-gi, but only does the operation when the assertion exists.
   @return boolean; status code.
   @owner tom"
  (pwhen (formula-assertions formula mt)
    (ret (fi-unassert-int formula mt)))
  (ret t))

;;------------------------------------------------------------------------
;; Temporary work-arounds for problems with existing code

(define-private default-api-output-protocol (out-stream api-result &optional error?)
  "Output the result of the API evaluation to the TCP stream
   @note To work around problem with embedded newline characters these are converted to
carriage returns
   @return integer ; api result code (e.g., @xref *api-success-code* )"
  (clet ((result-code (fif error? *api-error-code* *api-success-code*))
	 (new-api-result (convert-newlines api-result)))
    (format out-stream "~D ~S" result-code new-api-result))
  ;; ensure that the result is immediately sent
  (network-terpri out-stream)
  (force-output out-stream)
  (ret api-result))

(define-private convert-newlines (api-result)
  "Convert newline characters (#\newline) to carriage returns (#\return)
  @param api-result ; sexpression - result of evaluating an API call
  @return sexpression ; the input with #\newline changed to #\return
  @note This is just intended for use with @xref default-api-output-protocol"
  (clet (new-api-result)
    (pcond
     ((stringp api-result) 
      (csetq new-api-result (substitute #\return #\newline api-result)))
     ((cand (consp api-result) (consp (cdr api-result)))
      (csetq new-api-result (mapcar #'convert-newlines api-result)))
     (t 
      (csetq new-api-result api-result)))
    (ret new-api-result)))
