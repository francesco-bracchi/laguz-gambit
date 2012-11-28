(namespace ("laguz#"
	    logic
	    relation
	    define-relation))

(define-macro+ (logic e)
  (cond
   ((and (pair? (car e)) (eq? (car e) '^))
    `(logic (,cat ,@(cdr e))))
   
   ((and (pair? (car e)) (eq? (car e) 'v))
    `(logic (,alt ,@(cdr e))))

   ((equal? e '(cat))
    `(success))

   ((equal? e '(alt))
    `(fail))
   ((and (pair? e) (eq? (car e) 'cat) (null? (cddr e)))
    `(logic ,(cadr e)))
   
   ((and (pair? e) (eq? (car e) 'cat) (pair? (cadr e)) (eq? (car (cadr e)) '<-))
    `(bind (,(cadr (cadr e)) (logic ,(caddr (cadr e)))) (logic (cat ,@(cddr e)))))
      
   ((and (pair? e) (eq? (car e) 'cat))
    `(sequence (logic ,(cadr e)) (logic (cat ,@(cddr e)))))
   
   ((and (pair? e) (eq? (car e) 'alt) (null? (cddr e)))
    `(logic ,(cadr e)))
   
   ((and (pair? e) (eq? (car e) 'alt))
    `(orelse (logic ,(cadr e)) (logic (alt ,@(cddr e)))))
   
   ((and (pair? e) (eq? (car e) '~))
    `(negate (logic ,(cadr e))))
   
   ((and (pair? e) (eq? (car e) 'if))
    `(if+ ,(cadr e) (logic ,(caddr e)) (logic ,(cadddr e))))
   
   ((and (pair? e) (eq? (car e) 'when))
    `(when+ ,(cadr e) (logic (cat ,@(cddr e)))))
   
   ((and (pair? e) (eq? (car e) 'let))
    `(let+ ,(cadr e) (logic (cat ,@(cddr e)))))
   
   ((and (pair? e) (eq? (car e) 'let*))
    `(let*+ ,(cadr e) (logic (cat ,@(cddr e)))))
      
   ((and (pair? e) (eq? (car e) 'letrec))
    `(letrec+ ,(cadr e) (logic (cat ,@(cddr e)))))
   
   (else e)))

(define-macro (relation f . b)
  `(lambda+ ,f (logic (cat ,@b))))

(define-macro (define-relation h . b)
  `(define ,(car h) (relation ,(cdr h) ,@b)))
