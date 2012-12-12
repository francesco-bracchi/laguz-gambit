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
 (:- (ancestor A B) (father-child A B))

 )

;; hand written relation list-reverse 

(define-relation (list-reverse-1 a b)
  (cat (<- A (newvar))
       (unify A a)
       (<- B (newvar))
       (unify B b)
       (list-reverse-1-aux A B '())))


(define-relation (list-reverse-1-aux a b c)
  (vel (cat (unify a '())
	     (<- As (newvar))
	     (unify b As)
	     (unify c As))
	(cat (<- A (newvar))
	     (<- As (newvar))
	     (unify a (cons A As))
	     (<- Bs (newvar))
	     (unify b Bs)
	     (<- Cs (newvar))
	     (unify c Cs)
	     (list-reverse-1-aux As Bs (cons A Cs)))))

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
  (string->list 
   (string-append 
    "this is not a simple random sequence of characters that will be transformed in a list and then inverted except the last"
    "this is not a simple random sequence of characters that will be transformed in a list and then inverted except the last"
    "this is not a simple random sequence of characters that will be transformed in a list and then inverted except the last"
    "this is not a simple random sequence of characters that will be transformed in a list and then inverted except the last")))

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
	  (time (show-results (times 300 (to-list (?- (,relation test-list (cons X XS)))))))))

(display "Testing naive list-reverse")
(test-reverting list-reverse-naive)

;(test-reverting list-reverse-naive)
(display "Testing hand written relation\n")
(test-reverting list-reverse-1)

(display "Testing horn encoded relation\n")
(test-reverting list-reverse)
