;; (declare
;;  (standard-bindings)
;;  (extended-bindings)
;;  (fixnum)
;;  (block)
;;  (not safe))

(##include "~~lib/gambit#.scm")
(include "~~laguz/laguz#.scm")


(laguz 
 (:- (list-append () U U))
 (:- (list-append (A . X) Y (A . Z)) (list-append X Y Z))

 (:- (list-reverse () ()))
 (:- (list-reverse (A . As) Bs)
     (list-reverse As Sa)
     (list-append Sa (list A) Bs))
 
 (:- (father-child a b))
 (:- (father-child b c))
 (:- (father-child c d))
 
 (:- (ancestor A B) (father-child A X) (ancestor X B))
 (:- (ancestor A B) (father-child A B)))

(define (to-list r)
  (if (null? r) '()
      (cons (car r) (to-list ((cdr r))))))

(define (times n fn)
  (if (>= n 0)
      (begin
        (fn)
        (times (- n 1) fn))))

(define l (string->list "e ricordati che devi morire!"))

(for-each (lambda (set) 
	    (for-each (lambda (pair) (for-each display (list (car pair) "=" (cdr pair) #\newline)))
		      set))
	  (time (to-list (?- (list-reverse l X)))))
