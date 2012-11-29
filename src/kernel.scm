(##namespace ("laguz#"))
(##include "~~/lib/gambit#.scm")

(include "reflect#.scm")
(include "monad-plus#.scm")
(include "kernel#.scm")

;(declare (standard-bindings)
	 ;(extended-bindings)
	 ;(block)
	 ;(not safe)
	 ;(fixnum))

(define *-var-* (list 'var))

(define (occur? v b)
  (let occur ((b b))
    (cond
     ((eq? b v) #t)
     ((variable? b) (occur (subst b)))
     ((pair? b)
      (or (occur (car b))
          (occur (cdr b))))
     (else #f))))

(define (subst v)
  (cond
   ((variable? v)
    (let ((val (variable-value v)))
      (if (eq? val #!void) v (subst val))))
   ((pair? v)
    (cons (subst (car v))
          (subst (cdr v))))
   (else v)))

(define (reset-variables! ms m0)
  (let reset ((xs ms) (ys '()))
    (if (eq? xs m0) ys
        (begin
          (variable-value-set! (car xs) #!void)
          (reset (cdr xs) (cons (car xs) ys))))))

(define unify
  (lambda+ (a b)
           (reflect (mv oc ct bt)
                    (begin
                      (let unify ((a a) (b b) (mv mv) (cn (lambda (r mv1) (if r (ct #t mv1 oc bt) (bt #f mv1)))))
                        (cond
                         ((eq? a b) (cn #t mv))
                         
                         ((variable? a) ;; occur check
                          (let((val (variable-value a)))
                            (if (eq? val #!void)
                                (if (and oc (occur? a b))
                                    (cn #f mv)
                                    (begin
                                      (variable-value-set! a b)
                                      (cn #t (cons a mv))))
                                (unify val b mv cn))))
                         
                         ((variable? b)
			  (unify b a mv cn))
			 
                         ((and (pair? a) (pair? b))
                          (unify (car a) (car b) mv
                                 (lambda (r mv1)
                                   (if r (unify (cdr a) (cdr b) mv1 cn) (cn r mv1)))))
			 
			 ;; ((and (##structure? a) (##structure? b) (##structure-instance-of? a (##type-id (##structure-type b))))
			  
			 ;;  ;; a subtype of b (i.e try to unify if a is a subtype of b
			 ;; ((and (##structure? a) (##structure? b) (##structure-instance-of? a (##type-id (##structure-type b))))
			 ;;  (unify (fields a (##structure-type b))
			 ;; 	 (fields b (##structure-type b))
			 ;; 	 mv cn))
			 ;; ;; b subtype of a 
			 ;; ((and (##structure? a) (##structure? b) (##structure-instance-of? b (##type-id (##structure-type a))))
			 ;;  (unify (fields a (##structure-type a))
			 ;; 	 (fields b (##structure-type a))
			 ;; 	 mv cn))
                         (else
                          (cn #f mv))))))))



 
