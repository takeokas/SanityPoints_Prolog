;;;; -*-   coding: utf-8 -*-
;;;
;;;	Sanchi Prolog with CUT Ver 3.000
;;;	2012/APR/30
;;;	2012/APR/24
;;;	2012/APR/22, 23
;;;	by Shozo TAKEOKA, take@takeoka.org
;;;
;;; http://www.takeoka.org/~take/ailabo/prolog/sanchi-prolog/sanchipro-man.html
;;;
;;;	2011/MAY/05
;;;	1987/Jul/14
;;;	1987/Jan/16
;;;	1986/Dec/25
;;;
;;; (load "sanchi-pro.lsp")
;;; (sanchi-pro)
;
; Lisp Functions
;(pro-trace t)
;(pro-trace nil)
;(set-sanchi 90)
;
;;;;;; sanchi-prolog top-level is (sanchi-pro)
;;; (sanchi-pro)
;;
;;; sanchi-prolog test
;; prolog syntax
;  90:plus(*x,*y,*z) :- *z = *x + *y.
;  60:plus(*x,*y,*z) :- *z1 = *x + *y, *z = *z1 + 1.
;  30:plus(*x,*y,*z) :- *z = mul(*x ,  *y) .
;  (set-sanchi 90)
;  (set-sanchi 65)
;  (set-sanchi 25)
;  ((plus 2 5 *x))
;;
;; prolog syntax
;  90:foo("(」・ω・)」うー").
;  60:foo("(／・ω・)／にゃー！").
;  30:foo("xxx").
;  (set-sanchi 90)
;  (set-sanchi 65)
;  (set-sanchi 25)
;   ((foo *x))
;

;;  prolog append-test
;;; ((append *x *y (a s d))(prin1 *x)(f))
;;; ((append (a s d) (q w e) *x))
;;; ((xap on))
;;; ((xap off))
;;; ((zz (1 2 3 4)(2 1 5 4)))
;;; hanoi test
;; ((hanoi 3 a b via))
;;

(defvar *sanchi-yaraneba* )
(defvar *sanchi* 90)

(defvar *sanchi-choiced-clause* nil)
(defvar *sanchi-last-diff* 10000)
(defvar *sanchi-facts*)

(defvar *sanchi-choiced-sanchi* nil)


(defvar *facts*)

(defvar *built_in*)

(defvar *pro-debug-print*)

(setq *pro-debug-print* nil)

(defmacro pro-format (&rest lll)
  (list
   'when '*pro-debug-print*
   (cons 'format  lll)))


(defmacro 1st(x)
  `(aref (symbol-name ,x) 0) )

(defmacro var? (x)
  `(and (symbolp ,x)
	(string= "*" (1st ,x))))


(defun dovar (pair)	;returns (Flg . pair)  ;pair=(value . env)
 (let (var-val new-pair (x (car pair)) (env (cdr pair)))
;(format t "doVar x=~s , env=~s~%" x env)
   (cond
    ((not (var? x)) (error "~s is not VAR" x))
    ((null (setq var-val (assoc x (cdr env))))
     (cons NIL pair))
    ((not(var? (car (setq new-pair (cdr var-val)))))
     (cons T new-pair))
    (t
     (dovar new-pair)))))


(defmacro bind (px py)
;(format t " x ~s <-y ~s~%" (car ,px) ,py)
 `(cond
  ((and(eql(car ,px)(car ,py))(eql (cdr ,px)(cdr ,py)))
   T)
  (t
;(format t "bind: x ~s <-y ~s~%" (car ,px) ,py)
   (rplacd (cdr ,px)
	(cons (cons (car ,px) ,py) (cdr (cdr ,px)))))))

(defun unify (pairx pairy)
 (let (pax pay result-x result-y)
;(format t "unify x=~s , envx=~s~%" (car pairx)(cdr pairx))
;(format t "      y=~s , envy=~s~%" (car pairy)(cdr pairy))
   (cond
    ((var? (car pairx))
     (setq result-x (dovar pairx))
     (setq pax (cdr result-x)))
    (t
     (setq pax pairx)))

   (cond
    ((var? (car pairy))
     (setq result-y (dovar pairy))
     (setq pay (cdr result-y)))
    (t
     (setq pay pairy)))

   (cond
    ((and (var? (car pairx))
	  (not (car result-x)))
	;unbound & bind var
;(format t "biVar: x=~s , envx=~s~%" (car pairx)(cdr pairx))
     (bind pax pay)
     T)

    ((and (var? (car pairy))
	  (not (car result-y)))
	;unbound & bind var
;(format t "biVar: y =~s , envy=~s~%" (car pairy)(cdr pairy))
     (bind pay pax)
     T)

    ((atom (car pax)) ; bound & compair value
     (eql(car pax)(car pay)))

    ((atom (car pay)) ; bound & compair 
     (eql(car pax)(car pay)))

    (t
     (let ( (x (car pax))(envx (cdr pax)) (y (car pay))(envy (cdr pay)))
       (and
	(unify (cons (car x) envx) (cons (car y) envy))
	(unify (cons (cdr x) envx) (cons (cdr y) envy))))))))


;;;   Driver of UNIFY for testing

(defmacro unib (x y)
  `(let (
	 (ex (cons ':ENVX nil)) ;get 2 new cons dynamically
	 (ey (cons ':ENVY nil)))
     (list (unify (cons ,x ex) (cons ,y ey) ) ex ey)))


;;;    top level of UNIFY for testing

(defmacro unia()
  '(do ((x) (y)(result)) (nil T)
       (setq x (read))
       (cond ((eql x 'end)
	      (return T)))
       (setq y (read))
       (cond ((eql y 'end)
	      (return T)))
       (setq result (unib x y))
       (format t "unify=~s~%" (car result))
       (format t "ex=~s~%" (cadr result))
       (format t "ey=~s~%" (caddr result))))

;;
(defun tangle-var (lst env)
  (let (x)
;(if(null lst) (return-from tangle-var NIL ))
     (cond
      ((not(atom lst))
       (cons (tangle-var (car lst) env)
	     (tangle-var (cdr lst) env)))
      (t ;lst is symbol
       (cond
	((not(var? lst))
	 lst) ;not Var must be Atom
	(t ; dereference variable
	 (setq x (dovar (cons lst env)))
	 (cond
	  ((not (car x))
	   (cadr x))
	  (t
	   (tangle-var (cadr x)(cddr x))))))))))

;;;
;;;



;;;
;;;	Prolog
;;;

(defmacro pro-or (cur-fact goal1 goal env que not_flg)
 `(let ((undo NIL)envy new-clause rrr  sando
	(sanchi-last-diff 1000)
	(sanchi-choiced-clause nil)
	(sanchi-choiced-env nil)
	(success nil))
    (loop
     (push  (cdr ,env) undo)
     (setq envy (cons ':ENVY nil )) ;get new cons dynamically
     (when(null ,cur-fact) ; no more clause, fail head matching
       (cond
	(success 
	     (rplacd ,env sanchi-choiced-env) ;ajust env
	     (return T))
	(t
	 (return :no-match))))

;(format t " cur-fact=~s~%" ,cur-fact)
     (setq new-clause (pop ,cur-fact))
;(format t " - new-clause=~s~%" new-clause)
;(format t " - new-head=~s~%" (cdr(car new-clause)))
;prolog     (when (unify(cons ,goal1 ,env)(cons (car new-clause) envy)) ; matching head
     (when (unify(cons ,goal1 ,env)(cons (cdr(car new-clause)) envy)) ; matching head
				; body becomes new-goal
       (setq rrr (pro-and (cdr new-clause) envy (cons(cons(cdr ,goal),env),que) ,not_flg))
;(format t " rrr=~s " rrr)
       (cond
	((eql rrr :not-t)
	 (return NIL))
	((eql rrr :cut-fail)
	 (return NIL))
	((eql rrr t)
	 ; clause successed 	 (return T)
	 (setq sando (car(car new-clause)))
	 (if (eql sando T) (return T)) ; normal cluase
	 (setq success t)
	 (format t " - new-head=~s sanchi=~s ~%" 
		 (cdr(car new-clause))
		 sando)
	 (when (< (abs(- *sanchi* sando)) sanchi-last-diff)
	   (setq sanchi-last-diff (abs(- *sanchi* sando)))
	   (setq sanchi-choiced-clause; new-clause )
		 (tangle-var new-clause envy))
	   (setq *sanchi-choiced-sanchi* sando)
	   (setq sanchi-choiced-env (cdr ,env))
	   (format t " - choiced-clause=~s ~%" 
		   sanchi-choiced-clause)
	   ))
	 
	(t  ;continue the loop, try next clause
	 )))
     (rplacd ,env (car undo)) ; restore env
     (pop undo))))


(defmacro pro-and11 (goal1 goal env que not_flg)
  `(let (envy  cur-fact  rrr rr)

    (setq cur-fact *facts*)

    (setq rr (pro-or cur-fact ,goal1 ,goal ,env ,que ,not_flg))
    (cond
     ((eql rr :no-match)
      (cond
       (,not_flg 
	(setq envy (cons ':ENVY nil )) ;get new cons dynamically
	(setq rrr (pro-and () envy (cons(cons(cdr ,goal),env),que) NIL))
	;(format t " rrrN=~s " rrr)
	(cond
	 ((eql rrr :not-t)
	  NIL)
	 ((eql rrr t)
	  T)
	 ((eql rrr :cut-fail)
	  :cut-fail)
	 (t  ;fail
	  NIL)))
       (T NIL)))
     (t rr))))

(defmacro pro-and1 (goal env que)
 `(let (goal1  (not_flg NIL) (cut_flg nil)gomi rrr)
    (setq goal1 (car ,goal))
    (when (eql goal1 '!)
      ;(format t " CUT-in-pro-and ")
      (setq cut_flg T)(setq goal1(car(setq ,goal (cdr ,goal)))))

    (when (eql goal1 '~)
      ;(format t " NOT-in-pro-and ")
      (setq not_flg T)(setq goal1(car(setq ,goal (cdr ,goal)))))

    (cond
     ((and (listp goal1)(eql (car goal1) '*SYSTEM*)) ;Built-in predicate
      (setq rrr
	    (and (eval (tangle-var (cdr goal1) ,env))
		 (pro-and () () (cons(cons(cdr ,goal),env),que) nil))))
     ((and(listp goal1)(eql (car goal1) '*SYSTEM-FUNC*)) ;Built-in Function
      (setq rrr
	    (and
	     (setq gomi (tangle-var (cdr goal1) ,env))
	     (apply (car gomi)(cons ,env(cdr gomi)))
	     (pro-and () () (cons(cons(cdr ,goal),env),que) nil))))
     (t
      (setq rrr
	    (pro-and11 goal1 ,goal ,env ,que not_flg))))
;(format t " pro-and1:rrr=~a " rrr)
    (cond
     ((eql rrr T) T)
     ((eql rrr :cut-fail) :cut-fail)
     (t (if cut_flg  :cut-fail
	  nil)))))

(defun pro-and (goal env que do_not)
  (let ()
;(format t "goal=~s que=~s do_not=~s~%" goal que do_not)
    (when (not(null goal))
      ;(pro-format t "goal=~s~%" goal)
      (pro-format t "goal=~s~%" (tangle-var goal env)))
    (cond
     ((null goal)
      (cond
       (do_not
	;(format t " return-NOT-NIL ")
	:not-t) ; ~ (true)
       (t
	(cond
	 ((null que) (if do_not NIL T))
	 (t 
	  (pro-and (caar que)(cdar que)(cdr que) nil))))))
     (t
      (pro-and1 goal env que)))))



;;;	normal Prolog , Top Level


;; 1 query
(defmacro pro(goal)
  `(let(env result)
     (setq env (cons :ENV ())) ; get new cons dynamically 
     (setq result (pro-and ,goal env NIL nil))
     ;(format t "~%result=~s, env=~s~%" result env)
     ;(format t "*** Final choiced SAN値=~s ***" *sanchi-choiced-sanchi*)
     (format t "~%result=~s~%" result)
     (format t "reduced-goal=~s~%" (tangle-var ,goal env))
     ))

;; top level loop
(defmacro sanchi-pro()
  `(let()
     (setq *print-circle* t)
     ;(format t "to quit prolog,input simple symbol END~%")
     (do ((endf nil)(goal))
	 (endf  t)
	 (format t "~%にゃ?-")
#+sbcl	 (SB-INT:FLUSH-STANDARD-OUTPUT-STREAMS)
	 (setq goal (read))
    (format t "SAN値=~s~%" *sanchi*)
    (setq *sanchi-choiced-clause* nil)
    (setq *sanchi-last-diff* 10000)
    (setq *facts*
	  (append (sanchi-built_in)
		  *sanchi-facts*))
	 (cond
	  ((eql goal 'end) (setq endf t))
	  ((eql goal 'trace)(pro-trace t))
	  ((eql goal 'notrace)(pro-trace nil))
	  ((not(listp goal))
	   (cond
	    ((boundp goal)
		  (format t "lisp value=~s" (eval goal)))
	    (t
	     (format t "to quit prolog,type-in END~%"))))
	  ((not(listp (car goal)))
	   (format t "lisp value=~s" (eval goal)))
	  (t
	   (pro goal))))))

;;;
;;;	SANCHI Prolog
;;;

; this function may be called from Prolog top level
(defun set-sanchi (x)
  (setq *sanchi* x))

;;;
;;;	Built in Functions
;;;

(defun pro_sanchi (env var-z)
  (let (x)
    (setq x *sanchi*)
    (cond
     ((not(var? var-z))
      (equal x var-z))
     (t
      (bind
       (cons '*z env)
       (cons x ':ENVY))
      T))))


(defun pro_read (env var-z)
  (let (x)
    (setq x(read))
    (cond
     ((not(var? var-z))
      (equal x var-z))
     (t
      (bind
       (cons '*z env)
       (cons x ':ENVY))
      T))))



(defun pro+ (env var-x var-y var-z)
  (cond
   ((not(var? var-z))
    (eql (+ var-x var-y) var-z))
   (t
    (bind
     (cons '*z env)
     (cons (+ var-x var-y) ':ENVY))
    T)))


(defun pro- (env var-x var-y var-z)
  (cond
   ((not(var? var-z)) 
    (eql (- var-x var-y) var-z))
   (t
    (bind
     (cons '*z env)
     (cons (- var-x var-y) ':ENVY))
    T)))

(defun pro* (env var-x var-y var-z)
 (cond
  ((not(var? var-z))
   (eql (* var-x var-y) var-z))
  (t
   (bind
    (cons '*z env)
    (cons (* var-x var-y) ':ENVY))
   T)))

(defun pro/ (env var-x var-y var-z)
 (cond
  ((not(var? var-z))
   (eql (/ var-x var-y) var-z))
  (t
   (bind
    (cons '*z env)
    (cons (/ var-x var-y) ':ENVY))
   T)))


;;;
;;;	Prolog Subroutines
;;;
(defun pro-trace (x)
  (format t "trace ~s" x)
  (setq *pro-debug-print* x))


;;; default definitions

;;;
;;;
;;; sanchi-prolog default definitions
;;;
(defun sanchi-built_in ()
 '(
   ((T + *x *y *z) (*SYSTEM-FUNC*   .(pro+ *x *y *z)))
   ((T - *x *y *z) (*SYSTEM-FUNC*   .(pro- *x *y *z)))
   ((T mul *x *y *z) (*SYSTEM-FUNC* .(pro* *x *y *z)))
   ((T / *x *y *z) (*SYSTEM-FUNC*   .(pro/ *x *y *z)))
   ((T < *x *y)  (*SYSTEM* . (< (quote *x)(quote *y))))
   ((T <= *x *y) (*SYSTEM* . (<= (quote *x)(quote *y))))
   ((T =< *x *y) (*SYSTEM* . (<= (quote *x)(quote *y))))
   ((T > *x *y)  (*SYSTEM* . (> (quote *x)(quote *y))))
   ((T >= *x *y) (*SYSTEM* . (>= (quote *x)(quote *y))))
   ((T == *x *x) )

   ((T set-sanchi *x) (*SYSTEM* .(progn (setq *sanchi* (quote *x))T)))
   ((T sanchi *z)  (*SYSTEM-FUNC* .(pro_sanchi *z)))
   ((T read *z)  (*SYSTEM-FUNC* .(pro_read *z)))
   ((T print *x) (*SYSTEM* . (progn (format t "~s~%" (quote *x))T)))
   ((T prin1 *x) (*SYSTEM* . (progn (format t "~s" (quote *x))T)))
   ((T terpri)   (*SYSTEM* . (progn (format t "~%" )T)))

#|
   ((T assert *x)
    (*SYSTEM* .(setq *facts* (append *facts* (cons (quote *x)NIL)))))
|#
))


;  90:foo("(」・ω・)」うー").
;  60:foo("(／・ω・)／にゃー！").
;  30:foo("xxx").
;  (set-sanchi 90)
;  (set-sanchi 65)
;  (set-sanchi 25)
;   ((foo *x))
;
;  90:plus(*x,*y,*z) :- *z = *x + *y.
;  60:plus(*x,*y,*z) :- *z1 = *x + *y, *z = *z1 + 1.
;  30:plus(*x,*y,*z) :- *z = mul(*x ,  *y) .
;  (set-sanchi 90)
;  (set-sanchi 65)
;  (set-sanchi 25)
;  ((plus 2 5 *x))
;;
;;; ((append *x *y (a s d))(prin1 *x)(f))
;;; ((append (a s d) (q w e) *x))
;;; ((xap on))
;;; ((xap off))
;;; ((zz (1 2 3 4)(2 1 5 4)))
;;; hanoi test
;; ((hanoi 3 a b via))
;; ((fa 6 *x))
;;
(setq *sanchi-facts*
  '(
    ;; SANchi Prolog Clauses
    ((90 plus *x *y *z)(+ *x *y *z))
    ((60 plus *x *y *z)(+ *x *y *z1)(+ *z1 1 *z))
    ((30 plus *x *y *z)(mul *x *y *z))
    ((90 foo "(」・ω・)」うー"))
    ((60 foo "(／・ω・)／にゃー！"))
    ((30 foo "xxx" ))
    ;; normal prolog clauses
    ((t hanoi 1 *f *t *v) (prin1 *f)(prin1 ->)(print *t))
    ((t hanoi *n *f *t *v) (- *n 1 *n1)
          (hanoi *n1 *f *v *t)
	  (hanoi 1 *f *t *v)
	  (hanoi *n1 *v *t *f))
    ((t append () *x *x))
    ((t append (*a . *x) *y (*a . *z))  (append *x *y *z))
    ((t fa 0 1))
    ((t fa *n *x) (- *n 1 *n1)(fa *n1 *x1)(mul *x1 *n *x))
    ((t zz () *x))
    ((t zz *x ()))
    ((t zz (*a . *x)(*b . *y)) (z *a *b)(zz *x *y))
    ((t z *x *y) (>= *x *y)(prin1 *x)(prin1 >=)(prin1 *y)(terpri))
    ((t z *x *y) (prin1 *x)(prin1 <)(prin1 *y)(terpri))
    ((t xap *sw) (append *x *y (a s d)) (prin1 *x)(print *y) ~ (check *sw) (print " 1 anser only"))
    ((t check on))))


;(setq *facts*
;      (append (sanchi-built_in)
;	      *sanchi-facts*))


;;;
;;;	Prolog Subroutines
;;;     Called from prolog top level
;;;

(defun pro-assert-new (facts)
  (setq *sanchi-facts*  facts))

(defun pro-assert (facts)
  (setq *sanchi-facts* (append facts *sanchi-facts*)))


#|
(pro-assert-new
 '(
   ((90 foo "(」・ω・)」うー"))
   ((60 foo "(／・ω・)／にゃー！"))
   ((30 foo "xxx" ))))
; ((foo *x))
; ((set-sanchi 90))
; ((set-sanchi 65))
; ((set-sanchi 25))

(pro-assert-new
 '(
   ((t bar) (foo *x)(sanchi *ss)(babar *ss))
   ((t babar *ss)(> *ss 70)(set-sanchi 55))
   ((t babar *ss)(> *ss 40)(set-sanchi 25))
   ((t babar *ss)(set-sanchi 99))
   ((90 foo "(」・ω・)」うー"))
   ((60 foo "(／・ω・)／にゃー！"))
   ((30 foo "xxx" ))))
; ((bar))
; ((sanchi *x))
; ((> 55 40))
; ((set-sanchi 60))


(pro-assert-new
 '(
    ((90 plus *x *y *z)(+ *x *y *z))
    ((60 plus *x *y *z)(+ *x *y *z1)(+ *z1 1 *z))
    ((30 plus *x *y *z)(mul *x *y *z))))
; ((plus 2 4 *x))

(pro-assert-new
 '(
    ((t hanoi 1 *f *t *v) (prin1 *f)(prin1 ->)(print *t))
    ((t hanoi *n *f *t *v) (- *n 1 *n1)
          (hanoi *n1 *f *v *t)
	  (hanoi 1 *f *t *v)
	  (hanoi *n1 *v *t *f))))
; ((hanoi 3 a b via))

(pro-assert-new
 '(
   ((t aaa *x ) (bbb *x ))
   ((t aaa *x ) (print qqq)(+ *x 1 *y)(bbb *x ))
   ((t bbb *x) (+ 1 1 *x) (print a))
   ((t bbb *x) (+ 1 2 *x) (print b))
   ((t bbb *x) (+ 1 3 *x)! (print c)(fail))
   ((t bbb *x) (+ 1 4 *x) (print d))))

((aaa 4 ))

(pro-assert-new
 '(
   ((t aaa *x *y) (bbb *x *y))
   ((t aaa *x ) (print qqq)(+ *x 1 *y)(bbb *x ))
   ((t bbb *x *y) !(> *x *y) (pr b)(fail))
   ((t bbb *x *y) !(> *x *y) (pr bb)(fail))
   ((t bbb *x *y) (< *x *y) (pr a))
   ((t bbb *x *y) (== *x *y) (pr c)(f))
   ((t pr *x) !(print *x))))

((aaa 5 4))
trace
end
;;; (load "sanchi-pro.lsp")
;;; (sanchi-pro)
|#

;;
#+sbcl (defun bye () (SB-EXT:QUIT))

;;; EOF
