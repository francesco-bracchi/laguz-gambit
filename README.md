#DESCRIPTION
Laguz is a library that provides prolog style expressiveness

#USAGE
## Creating clauses
     (laguz 
      (:- (relation-name <params> ...) tail ...)
      ...)
the :- form introduce a relation clause. 
Relations can have multiple clauses in the same laguz context.
Conventionally symbols that starts in uppercase are considered variables.

<params> expressions unification involves pattern matching. 
I.E. if head is (foo (A . As) (a . Bs)) the rule will be  applied only if the first object passed
to the relation can be unified with the object created by plain scheme (cons (make-variable) (make-variable)),
and the second with (cons 'a (make-variable)).
right now only atomic values and pairs are supported in pattern matching, but I'd like adding vectors and 
gambit records as well.
Tail can be a sequence of relations, linked together with an & relation, I.E. 
(laguz ...
  (:- (foo-and A B) (bar A C) (baz C B))
  ...)

means that if exists an element C such that A and C are in relation bar AND C and B in relation baz,
then A and B are in relation foo.

expressing the logical or a new expression can be added
(laguz ...
  (:- (foo-or A B) (bar A B))
  (:- (foo-or  A B) (baz A B)))
means that if A and B Are in relation bar OR in relation baz, then A and B are in relation foo.

that's not the only way to express these, actually & (and) and v (or) operators can be used
 (:- (foo-and A B) (& (bar A C) (baz C B)))

 or
 (:- (foo-or A B) (v (bar A B) (baz A B)))

The last operator is ~ that is negation (pay attention using this) and is an unary operator.
    
###Cut
cut is implemented, but I'm not sure I correctly grokked the prolog cut!, in any case cut! is an
empty relation, used in this way:
(:- (foo A B) (r0 A C) (cut!) (r1 C B))
(:- (foo A B) (r2 A B))
suppose that during execution r0 succed, cut! always succeed, but r1 fails, this means that the 
second foo clause will never be reached.
if r0 fails r2 will be tested.
once execution traverse a cut point, and it backtracks back before cut!, the only thing that 
can happen is failure.