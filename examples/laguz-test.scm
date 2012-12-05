(declare
 (standard-bindings)
 (extended-bindings)
 ; (fixnum)
 (block)
 (not safe)
 )

(##include "~~lib/gambit#.scm")
(include "~~laguz/laguz#.scm")

(laguz 
 (:- (laguz-length () 0))
 (:- (laguz-length (X . Xs) N)
     (laguz-length Xs N1)
     (unify N (+ (subst N1) 1)))

 (:- (member? X (X . XS)))
 (:- (member? X (Y . YS)) (member? X YS))
     
 (:- (list-append () U U))
 (:- (list-append (A . X) Y (A . Z)) (list-append X Y Z))
 
 (:- (list-reverse-naive () ()))
 (:- (list-reverse-naive (A . As) Bs)
     (list-reverse-naive As Sa)
     (list-append Sa (list A) Bs))     

 (:- (list-reverse-aux () As As))
 (:- (list-reverse-aux (A . As) Bs Cs)
     (list-reverse-aux As Bs (cons A Cs)))

 (:- (list-reverse A B)
     (list-reverse-aux A B '()))
 
 (:- (father-child 'a 'b))
 (:- (father-child 'b 'c))
 (:- (father-child 'c 'd))
 
 (:- (ancestor A B) (father-child A X) (ancestor X B))
 (:- (ancestor A B) (father-child A B)))

(define (to-list r)
  (if (null? r) '()
      (cons (car r) (to-list ((cdr r))))))

(define (_times n fn)
  (if (>= n 0)
      (let ((r (fn) ))
	(_times (- n 1) fn)
	r)))

(define-macro (times n . e)
  `(_times ,n (lambda () ,@e)))

(define test-list
  (string->list "this is not a simple random sequence of characters that will be transformed in a list and then inverted except the last"))

(define (->string e)
  (cond
   ((char? e) (string e))
   ((number? e) (number->string e))
   ((pair? e) (list->string e))
   (else "dontnow")))

(define (show-results sets)
  (let ((show-pair (lambda (pair) (for-each display (list (car pair) "=" (->string (cdr pair)) #\newline)))))
    (for-each (lambda (set) (for-each show-pair set) (newline))
	      sets)))

(define-macro (test-reverting relation)
  `(begin (pp '(testing ,relation))
	  (time (show-results (times 1000 (to-list (?- (cat (,relation test-list (cons X XS))
							    (laguz-length XS L)))))))))

; (test-reverting list-reverse-naive)
(test-reverting list-reverse)

;; (show-results (to-list (?- (list-reverse test-list (cons X XS)))))
