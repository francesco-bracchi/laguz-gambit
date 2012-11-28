(namespace
 ("laguz#"
  success
  fail
  sequence
  not
  if+
  when+
  let+
  letenv+
  newvar
  occur-check-set!
  ~
  unify
  subst
  
  make-variable
  variable?
  variable-get
  variable-set!
  variable-reset!
  *-var-*
  ))

(define-macro (make-variable)
  `(cons *-var-* #!void))

(define-macro (variable-get v)
  `(cdr ,v))

(define-macro (variable-set! v vv)
  `(set-cdr! ,v ,vv))

(define-macro (variable-reset! v)
  `(variable-set! ,v #!void))

(define-macro (variable? v)
  `(and (pair? ,v) (eq? (car ,v) *-var-*)))

(define-macro+ (success) `(return #t))

(define-macro+ (fail)
  (let(
       (mv (gensym 'mv))
       (oc (gensym 'oc))
       (ct (gensym 'ct))
       (bt (gensym 'bt)))
  `(reflect (,mv ,oc ,ct ,bt) (,bt #f ,mv))))

(define-macro+ (sequence m n)
  `(bind (,(gensym 'ignore) ,m) ,n))

(define-macro+ (if+ t? m n)
  (let(
       (mv (gensym 'mv))
       (oc (gensym 'oc))
       (ct (gensym 'ct))
       (bt (gensym 'bt))
       (mm (gensym 'm))
       (nn (gensym 'n)))
    `(reify (,mm ,m)
            (reify (,nn ,n)
                   (reflect (,mv ,oc ,ct ,bt)
                            (if ,t?
                                (,mm ,mv ,oc ,ct ,bt)
                                (,nn ,mv ,oc ,ct ,bt)))))))

(define-macro+ (when+ t? m)
  (let(
       (mv (gensym 'mv))
       (oc (gensym 'oc))
       (ct (gensym 'ct))
       (bt (gensym 'bt))
       (mm (gensym 'm))
       (nn (gensym 'n)))
    `(reify (,mm ,m)
           (reflect (,mv ,oc ,ct ,bt)
                    (if ,t? (,mm ,mv ,oc ,ct ,bt) (,bt ,mv))))))

(define-macro+ (let+ v b)
  (let((bb (gensym 'b))
       (mv (gensym 'mv))
       (oc (gensym 'oc))
       (ct (gensym 'ct))
       (bt (gensym 'bt)))

    `(reify (,bb ,b)
            (reflect (,mv ,oc ,ct ,bt)
                     (let ,v (,bb ,mv ,oc ,ct ,bt))))))


(define-macro+ (letenv+ vs b)
  `(let+ ,(map (lambda (v) `(,v (make-variable))) vs)
     ,b))

(define-macro+ (newvar)
  (let((mv (gensym 'mv))
       (oc (gensym 'oc))
       (ct (gensym 'ct))
       (bt (gensym 'bt)))
    `(reflect (,mv ,oc ,ct ,bt)
              (,ct (make-variable) ,mv ,oc ,bt))))

(define-macro+ (occur-check-set! v)
  (let((mv (gensym 'mv))
       (oc (gensym 'oc))
       (ct (gensym 'ct))
       (bt (gensym 'bt)))
    `(reflect (,mv ,oc ,ct ,bt)
              (,ct ,v ,mv ,v ,bt))))

(define-macro+ (cut!)
  (let((mv (gensym 'mv))
       (oc (gensym 'oc))
       (ct (gensym 'ct))
       (bt (gensym 'bt))
       (bt1 (gensym 'bt))
       (mv1 (gensym 'mv)))
    `(reflect (,mv ,oc ,ct ,bt)
	      (,ct #t ,mv ,oc (lambda (,mv1) (,bt #t ,mv1))))))


