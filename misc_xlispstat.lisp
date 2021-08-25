;; misc_xlispstat.lisp: Miscellaneous supporting routines for using xlispstat
;; for basic statistical analyses. 
;;
;; This includes support for the t-test statistic based on the description
;; in
;;    Cohen, P. R.  (1995), Empirical Methods for Artificial Intelligence, 
;;    Cambridge, MA: MIT Press.
;;
;; In addition, support for the Mann-Whitney nonparametric test is
;; based on the description in
;;
;;    William Mendenhall and Richard L. Scheaffer (1973), {\em Mathematical
;;    Statistics with Applications}, North Scituate, Massachusetts: Duxbury
;;    Press.
;;
;; Tom O'Hara
;; Summer/Fall 1998
;;

;(format t "~%SHELL=~a~%" (system "printenv SHELL"))
;(format t "~%HELL=~a~%" (system "printenv HELL"))
;(format t "~%XLISP_DEBUG=~a~%" (system "printenv XLISP_DEBUG"))

;; set XLISP-DEBUG to t if XLISP_DEBUG is set (i.e., error code is 0)
(setq xlisp-debug (equal (system "printenv XLISP_DEBUG") 0)) 

;; calc-summary-statistics(data): calculate mean, stdev, etc for the data
;;
;; TODO: add mode and percentiles
;;

(defun calc-summary-statistics (data &optional brief)
  (format t "~%")
  ;; (format t "data = ~a~%" data)
  (if XLISP-DEBUG (print-array "data = " data))
  (format t "n = ~a; sum = ~,3f; min = ~,3f; max = ~,3f~%" 
	  (length data) (sum data) (min data) (max data))
  (format t "mean = ~,3f; stdev = ~,3f~%" 
	  (mean data) (standard-deviation data))
  (unless brief
    (show-confidence-interval data))
  (format t "~%")
  )
                 
(defun show-summary-statistics (data1 data2)
  (calc-summary-statistics data1)
  (format t "~%")
  (calc-summary-statistics data2)
  (format t "~%")
  )

;; show-confidence-interval(data): displays 95% confidence interval
;; for the data
;;
;; Since sigma is unknown, the normal distribution is not used to obtain the 
;; confidence interval (CI). That is, if sigma were known, the CI would be 
;;	(x-bar - 1.96 sigma,   x-bar + 1.96 sigma)
;; where 1.96 is the value of a normal variable such that 97.5% of the values
;; lie to the left. To account for the unknown sigma, the estimate 
;;      x-bar-sigma-hat = (stdev / sqrt(N))
;; is used and the t distribution is used to derive the scaling factor for
;; the interval:
;; 	(x-bar - t_{a/2,n-1} * s-hat,   x-bar + t_{a/2,n-1} * s-hat)
;;
;; See [Cohen 95, p. 134] for more details.
;;

(defun show-confidence-interval (data)
  (let* ((N (length data))
	 (df (- N 1))
	 (mean (mean data))
	 (stdev (standard-deviation data))
	 (s-hat (/ stdev (sqrt N)))
	 (t-value (t-quant 0.975 df))
	 (epsilon (* t-value s-hat)))
    (format t "epsilon is ~,3f~%" epsilon)
    (format t "CI = (~,3f, ~,3f)~%" (- mean epsilon) (+ mean epsilon) )
    ))


;; print-array: output a numeric array formatted with 3 decimal places
;;
(defun print-array (label data)
  (format t "~a" label)
  (mapcar (lambda (num) (format t "~,3f " num)) data)
  (format t "~%")
  )


;; do-t-test (data1 data2): perform t-test over the two sets of data points
;;
;; This is a one-sided test from H_0: u2 = u1; H_a: u2 > u1
;; TODO: have option for other types of tests (eg, 2-sided)
;;
;; sample input:
;;    Table 12.2 of [Mendenhall & Scheaffer 73], p. 445
;;
;; sample output:
;;
;;    
;;    data1 = 327.600 327.700 327.600 327.800 327.400 327.600 327.800 327.700 327.300
;;    data2 = 327.600 327.700 327.700 327.900 327.400 327.700 327.800 327.800 327.400
;;    N1=9 mean1=327.611 stdev1=0.169 SS1=0.229
;;    N2=9 mean2=327.667 stdev2=0.173 SS2=0.240
;;    s-hat=0.171 s-hat-aux=0.081 df=16
;;    t=0.688428
;;    p=0.250522
;;    
;;    for one-sided test at .05, reject H0 if t > 1.746
;;    for two-sided test at .05, reject H0 if |t| > 2.120
;;    for one-sided test at .01, reject H0 if t > 2.583
;;    for two-sided test at .01, reject H0 if |t| > 2.921
;;    
;; NOTES: See "Two-Sample t Test", pp. 127-129, [Cohen 95].
;;

(defun do-t-test (data1 data2)
  (let* ((N1 (length data1))
	 (mean1 (mean data1))
	 (stdev1 (standard-deviation data1))
	 (SS1 (* (- N1 1) (* stdev1 stdev1)))

	 (N2 (length data2))
	 (mean2 (mean data2))
	 (stdev2 (standard-deviation data2))
	 (SS2 (* (- N2 1) (* stdev2 stdev2)))

	 (s-hat (sqrt (/ (+ SS1 SS2) (+ N1 N2 -2))))
	 (s-hat-aux (* s-hat (sqrt (+ (/ 1 N1) (/ 1 N2)))))
	 (df (+ N1 N2 -2))
	 (t-value (/ (- mean2 mean1) s-hat-aux))
	 (p (- 1.0 (t-cdf t-value df)))
	 (t1 (t-quant .95 df))
	 (t2 (t-quant .975 df))
	 ;; TODO: use better variable names for t1 ... t4
	 (t3 (t-quant .99 df))
	 (t4 (t-quant .995 df)))
    (format t "~%")
    (if XLISP-DEBUG (print-array "data1 = " data1))
    (if XLISP-DEBUG (print-array "data2 = " data2))
    (format t "N1=~a mean1=~,3f stdev1=~,3f SS1=~,3f~%" N1 mean1 stdev1 SS1)
    (format t "N2=~a mean2=~,3f stdev2=~,3f SS2=~,3f~%" N2 mean2 stdev2 SS2)
    (format t "s-hat=~,3f s-hat-aux=~,3f df=~a~%" s-hat s-hat-aux df)
    (format t "t=~,6f~%" t-value)
    (format t "p=~,6f~%" p)
    (format t "~%")
    (format t "for one-sided test at .05, reject H0 if t > ~,3f~%" t1)
    (format t "for two-sided test at .05, reject H0 if |t| > ~,3f~%" t2)
    (format t "for one-sided test at .01, reject H0 if t > ~,3f~%" t3)
    (format t "for two-sided test at .01, reject H0 if |t| > ~,3f~%" t4)
    (format t "~%")
    ))


;; do-paired-t-test (data1 data2 [adjust-variance folds]): perform t-test over
;; the two sets of (paired) data points to see whether the difference is
;; significant above zero. The variance used in the statistic is optional
;; adjusted as discussed in (Bouckaert 2003) to reduce the likelihood
;; of Type I error (ie, rejecting null hypothesis when true.
;;
;; This is a one-sided test from H_0: u_diff = 0; H_a: u_diff > 0
;; TODO: have option for other types of tests (eg, 2-sided)
;;
;;     D = (X1 - X2)
;;     t = mean(D) / (sqrt(stdev(D)) / sqrt(N))
;;
;; sample input:
;;    Table 12.2 of [Mendenhall & Scheaffer 73], p. 445
;;    
;; sample output:
;;
;;    
;;    diff_data = 0.000 0.000 0.100 0.100 0.000 0.100 0.000 0.100 0.100
;;    N=9 mean=0.056 stdev=0.053 s-hat=0.018 df=8
;;    t=3.162278
;;    p=0.006675
;;    
;;    for one-sided test at .05, reject H0 if t > 1.860
;;    for two-sided test at .05, reject H0 if |t| > 2.306
;;    for one-sided test at .01, reject H0 if t > 2.896
;;    for two-sided test at .01, reject H0 if |t| > 3.355
;;    
;; NOTES:
;; - See "The Paired Sample t Test", pp. 129-130, [Cohen 95].
;; - Also, see Bouckaert, Choosing between two learning algorithms based on
;;   calibrated tests, Proceedings of the Twentieth International Conference
;;   on Machine Learning (ICML-2003), Washington DC, 2003.
;; TODO:
;; - create separate routine for the adjusted variant??
;;

(defun do-paired-t-test (data1 data2 &optional adjust-variance folds)
  (let* ((diff_data (- data2 data1))
	 (N (length diff_data))
	 (mean (mean diff_data))
	 (mean-aux (if adjust-variance (* mean N) mean))
	 (stdev (standard-deviation diff_data))
         (num-folds (if folds folds N))
	 (testing (/ 1 num-folds))
	 (training (- 1 testing))
	 (stdev-adjustment (sqrt (+ (/ 1 N) (/ testing training))))
	 ;; (stdev-adjustment (sqrt (+ (/ 1 N) (/ training testing))))
	 (stdev-aux (if adjust-variance (* stdev stdev-adjustment) stdev))
	 (s-hat (/ stdev-aux (sqrt N)))
	 (df (- N 1))
	 (t-value (if (> s-hat 0) (/ mean-aux s-hat) 0))
	 (p (- 1.0 (t-cdf t-value df)))
	 (t1 (t-quant .95 df))
	 (t2 (t-quant .975 df))
	 ;; TODO: use better variable names for t1 ... t4
	 (t3 (t-quant .99 df))
	 (t4 (t-quant .995 df)))
    (format t "~%")
    (when XLISP-DEBUG
      (print-array "diff_data = " diff_data)
      (format t "stdev-adjustment=~,3f training=~,3f testing=~,3f~%" 
	stdev-adjustment training testing))
    (format t "N=~a mean=~,3f stdev=~,3f s-hat=~,3f df=~a~%" 
            N mean stdev s-hat df)
    (when adjust-variance
      (format t "adjusted-mean=~,3f adjusted-stdev=~,3f~%" mean-aux stdev-aux))

    (format t "t=~,6f~%" t-value)
    (format t "p=~,6f~%" p)
    (format t "~%")
    (format t "for one-sided test at .05, reject H0 if t > ~,3f~%" t1)
    (format t "for two-sided test at .05, reject H0 if |t| > ~,3f~%" t2)
    (format t "for one-sided test at .01, reject H0 if t > ~,3f~%" t3)
    (format t "for two-sided test at .01, reject H0 if |t| > ~,3f~%" t4)
    (format t "~%")
    ))


;; calculate-anova-p(): calculates the p-value for the ANOVA results
;;

(defun calculate-anova-p (anova)
  (let* ((F-value (/ (send anova :GROUP-MEAN-SQUARE)
		    (send anova :ERROR-MEAN-SQUARE)))
	  (numerator-df (send anova :GROUP-DF))
	  (denominator-df (send anova :ERROR-DF))
	  (p-value (- 1.0 (f-cdf F-value numerator-df denominator-df)))
	  (F-critical (f-quant 0.95 numerator-df denominator-df)))
    (format t "f = ~,3f~%" F-value)
    (format t "p = ~,3f~%" p-value)
    (format t "~%")
    (format t "reject at .05 if f >= ~,3f~%" F-critical)
    t))

;; do-anova: run ANOVA analysis on the accuracy and precision results
;; TODO: support more than 2 samples
;;

(defun do-anova (data1 data2) 
  (format t "~%~%ANOVA analysis~%")
  (show-summary-statistics data1 data2)
  (let* ((anova-results (oneway-model (list data1 data2))))
    (calculate-anova-p anova-results))
  )

(defun do-anova2 (data_list) 
  (format t "~%~%ANOVA analysis~%")
  (mapcar (lambda (data) (calc-summary-statistics data)) data_list)
  (let* ((anova-results (oneway-model data_list)))
    (calculate-anova-p anova-results))
  )


;; tag-data (data-list tag)
;; 
;; Append the tag to each item in the data list.
;;
(defun tag-data (data tag)
  (mapcar (lambda (item) (format nil "~a ~a" item tag) data)))

;; member-ge(item data-list)
;;
;; Finds the position of the item in the sorted list or that of the first
;; item greater than it if not found.
;;
(defun member-ge (item data)
  (cond ((null data) nil)
	((>= (first data) item) data)
	(t (member-ge item (rest data)))
	))

(defun member-gt (item data)
  (cond ((null data) nil)
	((> (first data) item) data)
	(t (member-gt item (rest data)))
	))

;; rank(data-list, item)
;;
;; Returns the rank of the item in the list or -1 if not found.
;; Ties are handled by averaging the ranks.
;;
;; TODO: use a more straight-forward method for handling ties
;;
(defun rank (data item)
  (let* ((len (length data))
	 (rest (member-ge item data)))
    (- len (length rest))
    ))

(defun new-rank (data item)
  (let* ((len (length data))
	 (rest-ge (member-ge item data))
	 (len-ge (length rest-ge))
	 (rest-gt (member-gt item data))
	 (len-gt (length rest-gt))
	 (len-rest (/ (+ len-ge len-gt) 2)))
    (- len len-rest)
    ))

;; 5 6 7
;; 5 7

;; do-mann-whitney-test: perform the Mann-Whitney nonparametric test
;; over the two sets of data
;; TODO: for independence?
;; 
;; Let u_i is the number of A items that precede the i'th B item
;;     U = sum of u_i 
;;     E(U) = (n1 x n2)/2
;;     V(U) = (n1 x n2)(n1 + n2 + 1)/12
;;
;; Z = (U - E(U))/sqrt(V(U))
;;
;; [Mendenhall & Scheaffer 73]
;;
;; TODO: Handle ties in the data properly by assigning the average of
;; the ranks, instead of the first rank.
;;

(defun do-mann-whitney-test (data1 data2)
  (let* ((n1 (length data1))
	 (n2 (length data2))
	 (data1_sorted (sort-data data1))
	 ;; (u_i (mapcar (lambda (x) (rank data1_sorted x)) data2))
	 (u_i (mapcar (lambda (x) (new-rank data1_sorted x)) data2))
	 (U (sum u_i))
	 (E_U (/ (* n1 n2) 2))
	 (V_U (/ (* (* n1 n2) (+ n1 n2 1)) 12))
	 (z (abs (/ (- U E_U) (sqrt V_U))))
	 (p (- 1.0 (normal-cdf z)))
	 )
    (format t "~%")
    (if XLISP-DEBUG (show-summary-statistics data1 data2))
    (format t "u_i = ~a~%" u_i)
    (format t "U = ~a; E(U) = ~a; V(U) = ~a~%" U E_U V_U)
    (format t "z = ~a~%" z)
    (format t "p = ~a~%" p)
    ))

(defun do-mann-whitney-test2 (data1 data2)
  (let* ((n1 (length data1))
	 (n2 (length data2))
	 (data1_sorted (sort-data (append data1 data2)))
	 ;; (u_i (mapcar (lambda (x) (rank data1_sorted x)) data2))
	 (u_i (mapcar (lambda (x) (new-rank data1_sorted x)) data2))
	 (U (sum u_i))
	 (temp1_new_U (+ (* n1 n2) (* n2 (+ n2 1) 0.5) (- U)))
	 (temp2_new_U (- (* n1 n2) temp1_new_U))
	 (new_U (if (<= temp1_new_U (* n1 n2 0.5)) temp1_new_U temp2_new_U))
	 (E_U (/ (* n1 n2) 2))
	 (V_U (/ (* (* n1 n2) (+ n1 n2 1)) 12))
	 (z (abs (/ (- U E_U) (sqrt V_U))))
	 (p (- 1.0 (normal-cdf z)))
	 )
    (format t "~%")
    (if XLISP-DEBUG (show-summary-statistics data1 data2))
    (format t "u_i = ~a~%" u_i)
    (format t "U = ~a; E(U) = ~a; V(U) = ~a~%" U E_U V_U)
    (format t "new_U = ~a; U1 = ~a; U2 = ~a~%" new_U temp1_new_U temp2_new_U)
    (format t "z = ~a~%" z)
    (format t "p = ~a~%" p)
    ))
