;; anova.lisp: xlispstat source for running ANOVA analysis over two
;; sets of data
;; TODO: support two-factor aanlyses, etc.
;;

(load "misc_xlispstat.lisp")


;; calculate-anova-p(): calculates the p-value for the ANOVA results
;;

(defun calculate-anova-p (anova)
  (let* ((F-value (/ (send anova :GROUP-MEAN-SQUARE)
		    (send anova :ERROR-MEAN-SQUARE)))
	  (numerator-df (send anova :GROUP-DF))
	  (denominator-df (send anova :ERROR-DF))
	  (p-value (- 1.0 (f-cdf F-value numerator-df denominator-df)))
	  (F-critical (f-quant 0.95 numerator-df denominator-df)))
    (format t "f-value:~13,6f~%" F-value)
    (format t "p-value:~13,6f~%" p-value)
    (format t "~%")
    (format t "reject at .05 if f >= :~13,6f~%" F-critical)
    t))


;; do-anova: run ANOVA analysis on the accuracy and precision results
;; TODO: support more than 2 samples
;;

(defun do-anova (data1 data2) 
  (format t "~%~%ANOVA analysis~%")
  (calc-summary-statistics data1)
  (calc-summary-statistics data2)
  (let* ((anova-results (oneway-model (list data1 data2))))
    (calculate-anova-p anova-results))
  )
