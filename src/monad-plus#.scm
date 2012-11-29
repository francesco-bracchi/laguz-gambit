(namespace ("laguz#"
	    lambda+
	    define+
	    return
	    bind
	    orelse
	    reset-variables!))

(define-macro (lambda+ f b)
  (let ((mv (gensym 'mv))
	(oc (gensym 'oc))
	(ct (gensym 'ct))
	(bt (gensym 'bt)))
    `(lambda ,(append f (list mv oc ct bt))
       (with-state (,mv ,oc ,ct ,bt) ,b))))

(define-macro (define+ a b)
  `(define ,(car a) (lambda+ ,(cdr a) ,@b)))

(define-macro (return v . x)
  (let ((mv (gensym 'mv))
	(oc (gensym 'oc))
	(ct (gensym 'ct))
	(bt (gensym 'bt)))
    `(with-state ,x (reflect (,mv ,oc ,ct ,bt) (,ct ,v ,mv ,oc ,bt)))))

(define-macro (bind p n . x)
  (let ((v (car p))
	(m (cadr p))
	(mm (gensym 'mm))
	(nn (gensym 'nn))
	(mv (gensym 'mv))
	(oc (gensym 'oc))
	(ct (gensym 'ct))
	(bt (gensym 'bt))
	(mv1 (gensym 'mv))
	(oc1 (gensym 'oc))
	(bt1 (gensym 'bt)))
    `(with-state ,x
                 (reify (,mm ,m)
                        (reify (,nn ,n)
                               (reflect (,mv ,oc ,ct ,bt)
                                        (,mm ,mv ,oc (lambda (,v ,mv1 ,oc1 ,bt1) (,nn ,mv1 ,oc1 ,ct ,bt1))
					     ,bt)))))))

(define-macro (orelse m n . x)
  (let((mm (gensym 'm))
       (nn (gensym 'n))
       (mv (gensym 'mv))
       (oc (gensym 'oc))
       (ct (gensym 'ct))
       (bt (gensym 'bt))
       (v (gensym 'v))
       (mv1 (gensym 'mv))
       (oc1 (gensym 'oc))
       (cut? (gensym 'cut))
       (bt1 (gensym 'bt1)))
    `(with-state ,x
                 (reify (,mm ,m)
                        (reify (,nn ,n)
                               (reflect (,mv ,oc ,ct ,bt)
                                        (,mm ,mv ,oc
                                             (lambda (,v ,mv1 ,oc1 ,bt1) (,ct ,v ,mv1 ,oc1 ,bt1))
                                             (lambda (,cut? ,mv1)
                                               (if ,cut? 
						   (,bt #t ,mv)
						   (begin 
						     (reset-variables! ,mv1 ,mv)
						     (,nn ,mv ,oc ,ct ,bt)))))))))))

(define-macro (define-macro+ h b)
  (let((mv (gensym 'mv))
       (oc (gensym 'oc))
       (ct (gensym 'ct))
       (bt (gensym 'bt)))    
    `(define-macro ,(append h (list mv oc ct bt))
       (list 'with-state (list ,mv ,oc ,ct ,bt) ,b))))
