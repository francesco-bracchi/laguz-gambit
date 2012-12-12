(namespace ("laguz#" ?- case-unify case-relation laguz))

(define-macro (?- e)
  (letrec((variable-name?
           (lambda (n)
             (and (symbol? n)
                  (or (char-upper-case? (string-ref (symbol->string n) 0))
                      (char=? (string-ref (symbol->string n) 0) #\_)))))
          (variable-names
           (lambda (e)
             (cond
	      ((eq? e '_) '())
              ((variable-name? e) (list e))
              ((pair? e)
               (append (variable-names (car e))
                       (variable-names (cdr e))))
              (else '())))))
	      
    (let((vs (variable-names e))
         (vv (gensym 'vv))
         (mv (gensym 'mv))
         (ot (gensym 'ot))
         (bs (gensym 'bs))
         (bt (gensym 'bt)))
      `(run-monad (logic (cat ,@(append
                                (map (lambda (v) `(<- ,v (newvar))) vs)
                                (list e `(return (list ,@(map (lambda (v) `(cons ',v (subst ,v))) vs)))))))
                  '()
                  #f
                  (lambda (,vv ,mv ,ot ,bt) (cons ,vv (lambda () (,bt ,mv))))
                  (lambda (mv) '())))))

(define-macro+ (case-unify fs abs)
  (letrec((variable-name?
           (lambda (n)
             (and (symbol? n)
                  (or (char-upper-case? (string-ref (symbol->string n) 0))
                      (char=? (string-ref (symbol->string n) 0) #\_)))))
          (variables
           (lambda (e v0)
             (let variables ((e e) (vs '()))
               (cond
		((eq? e '_) vs)
                ((variable-name? e) (if (or (memq e v0) (memq e vs)) vs (cons e vs)))
                ((pair? e)
                 (variables (cdr e) (variables (car e) vs)))
                (else vs)))))
          
          (simple->quasiquoted
           (lambda (x)
             (cond
              ((variable-name? x) x)
              ((symbol? x) (list 'quote x))
              ((null? x) (list 'quote '()))
              ((and (pair? x) (eq? (car x) 'quote)) x)
              ((pair? x)
               (list 'cons (simple->quasiquoted (car x)) (simple->quasiquoted (cdr x))))
              (else x)))))
    `(logic ,(let case ((abs abs))
			(let* ((ab (car abs))
			       (det (eq? (car ab) '!))
			       (ab (if det (cdr ab) ab))
			       (as (car ab))
			       (bd (if (null? (cdr ab)) '() (cdr ab)))
			       (vs '()))
			  `(,(if det 'alt! 'alt)
			    (cat ,@(append
				    (apply append
					   (map (lambda (f a)
						  (let*((va (variables a vs)))
						    (set! vs (append vs va))
						    (append
						     (map (lambda (v) `(<- ,v (newvar))) va)
						     `((unify ,f ,(simple->quasiquoted a))))))
						fs as))
				    (let((vb (variables bd vs)))
				      (map (lambda (v) `(<- ,v (newvar))) vb))
				    bd))
			    ,@(if (null? (cdr abs)) '() (list (case (cdr abs))))))))))

    ;; `(logic (alt ,@(map (lambda (ab)
    ;;                      (let((as (car ab))
    ;;                           (bd (if (null? (cdr ab)) '() (cdr ab)))
    ;; 			      (vs '()))
    ;;                        `(cat ,@(append
    ;;                                (apply append
    ;;                                       (map (lambda (f a)
    ;;                                              (let*((va (variables a vs)))
    ;;                                                (set! vs (append vs va))
    ;;                                                (append
    ;;                                                 (map (lambda (v) `(<- ,v (newvar))) va)
    ;;                                                 `((unify ,f ,(simple->quasiquoted a))))))
    ;; 					       fs as))
    ;;                                (let((vb (variables bd vs)))
    ;;                                  (map (lambda (v) `(<- ,v (newvar))) vb))
    ;;                                bd))))
    ;;                    abs)))))

(define-macro (case-relation a . as)
  (let ((fp (map (lambda (_) (gensym 'f)) (if (eq? (car a) '!) (cadr a) (car a)))))
    `(relation ,fp (case-unify ,fp ,(cons a as)))))

(define-macro (laguz . as)
  (let((relations
        (let rels ((as as) (rs '()))
          (cond
           ((null? as) (reverse rs))
	   ((not (memq (caar as) '(:- !-)))
            (error "every laguz row should start with :- or !-"))
           ((not (memq (car (cadr (car as))) rs))
            (rels (cdr as) (cons (car (cadr (car as))) rs)))
           (else
            (rels (cdr as) rs)))))
       (make-case-relation
        (lambda (rel)
          `(define ,rel (case-relation 
                         ,@(let filter ((as as) (rs '()))
                             (cond
                              ((null? as) (reverse rs))
                              ((eq? (car (cadr (car as))) rel)
                               (let* ((a (car as))
                                      (pt (cdr (cadr a)))
                                      (bd (cddr a))
				      (deterministic (eq? (car a) '!-))
				      (line (if deterministic `(! ,pt ,@bd) (cons pt bd))))
                                 (filter (cdr as) (cons line rs))))
                              (else
                               (filter (cdr as) rs)))))))))
    `(begin ,@(map make-case-relation relations))))
