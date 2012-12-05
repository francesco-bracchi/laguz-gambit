(##namespace ("laguz#"))
(##include "~~/lib/gambit#.scm")

(include "reflect#.scm")
(include "monad-plus#.scm")
(include "kernel#.scm")

(declare (standard-bindings)
	 (extended-bindings)
	 (block)
	 (not safe)
	 (fixnum))

(define (occur? v b)
  (let occur ((b b))
    (cond
     ((eq? b v) #t)
     ((variable? b) (occur (subst b)))
     ((pair? b)
      (or (occur (car b))
          (occur (cdr b))))
     (else #f))))

(define (vector-map fn v)
  (let* ((len (vector-length v))
	 (v1 (make-vector len)))
    (do ((j 0 (+ j 1)))
	((>= j len) v1)
      (vector-set! v1 j (fn (vector-ref v j))))))

(define (structure-map fn v)
  (let* ((len (##vector-length v))
	 (v1 (##make-vector len)))
    (do ((j 0 (+ j 1)))
	((>= j len) v1)
      (##vector-set! v1 j (fn (##vector-ref v j))))))
    
(define (memoize1 func #!key (test eq?))
  (let((*fail* (list 'fail))
       (*memo* (make-table test: test weak-keys: #t init: #f)))
    (lambda (key)
      (let((val (table-ref *memo* key *fail*)))
	(if (eq? val *fail*)
	    (let((val (func key)))
	      (table-set! *memo* key val)
	      val)
	    val)))))

(define (subst0 v)
  (cond
   ((variable? v)
    (subst0 (variable-value v)))
   ((pair? v)
    (cons (subst0 (car v)) (subst0 (cdr v))))
   ((vector? v)
    (vector-map subst0 v))
   ((##structure? v)
    (structure-map subst0 v))
   (else v)))

(define subst (memoize1 subst0))

(define (reset-variables! ms m0)
  (let reset ((xs ms) (ys '()))
    (if (eq? xs m0) ys
        (begin
          (variable-value-set! (car xs) #!void)
          (reset (cdr xs) (cons (car xs) ys))))))

(define (unify-generic a b vars oc ct bt)
  (cond
   ((eq? a b) (ct #t vars oc bt))
   ((variable? a) (unify-variable a b vars oc ct bt))
   ((variable? b) (unify-variable b a vars oc ct bt))
   ((and (pair? a) (pair? b)) (unify-pair a b vars oc ct bt))
   ((and (vector? a) (vector? b)) (unify-vector a b vars oc ct bt))
   ((and (##structure? a) (##structure? b)) (unify-structure a b vars oc ct bt))
   (else (bt vars))))

(define (unify-variable a b vars oc ct bt)
  (let ((val (variable-value a)))
    (if (eq? val #!void)
	(if (and oc (occur? a b))
	    (ct #t vars oc bt)
	    (begin
	      (variable-value-set! a b)
	      (ct #t (cons a vars) oc bt)))
	(unify-generic val b vars oc ct bt))))

(define (unify-structure a b vars oc ct bt)
  (let ((la (##vector-length a))
	(lb (##vector-length b)))
    (if (= la lb) 
	(let unify-structure ((j 0) (vars vars))
	  (cond
	   ((>= la) (ct #t vars oc bt))
	   (else (unify-generic (##vector-ref a j) (##vector-ref b j)
				vars
				oc
				(lambda (v vars oc bt) (unify-structure (+ j 1) vars))
				bt)))))))

(define (unify-vector a b vars oc ct bt)
  (let ((la (vector-length a))
	(lb (vector-length b)))
    (if (= la lb) 
	(let unify-vector ((j 0) (vars vars))
	  (cond
	   ((>= la) (ct #t vars oc bt))
	   (else (unify-generic (vector-ref a j) (vector-ref b j)
				vars
				oc
				(lambda (v vars oc bt) (unify-vector (+ j 1) vars))
				bt)))))))
  
(define (unify-pair a b vars oc ct bt)
  (unify-generic (car a) (car b) vars oc (lambda (v vars oc bt) (unify (cdr a) (cdr b) vars oc ct bt)) bt))

(define unify
  (lambda+ (a b)
           (reflect (vars oc ct bt)
		    (unify-generic a b vars oc ct bt))))
