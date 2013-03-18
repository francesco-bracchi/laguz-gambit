#Description
Laguz is a library that provides prolog style expressiveness

#Compile
type

    $ make

#Install
type

    $ sudo make install

#Load/Include
    (load "~~laguz/laguz")
    (include "~~laguz/laguz#.scm")

#Example
There is an example in examples/laguz-test.scm to compile and run it type

    $ make example

#Usage

## Prolog style syntax

     (laguz 
      (:- (relation-name <params> ...) tail ...)
      ...)

the :- form introduce a relation clause. 
Relations can have multiple clauses in the same laguz context.
Symbols that starts in uppercase or underscore are considered variables.

<params> expressions unification involves pattern matching. 
I.E. if head is (foo (A . As)) the rule will be  applied only if the object passed
to the relation can be unified with the object created by plain scheme (cons (make-variable) (make-variable)).
Tail can be a sequence of relations, linked together with an and relation, I.E. 
    (laguz ...
      (:- (foo-and A B) (bar A C) (baz C B))
      ...)

means that if exists an element C such that A and C are in relation bar AND C and B in relation baz,
then A and B are in relation foo.

expressing the logical or a new expression can be added

    (laguz ...
     (:- (foo-or A B) (bar A B))
     (:- (foo-or A B) (baz A B)))

means that if A and B Are in relation bar OR in relation baz, then A and B are in relation foo.

that's not the only way to express these, actually et (and) and vel (or) operators can be used

    (:- (foo-and A B) (et (bar A C) (baz C B)))

 or

    (:- (foo-or A B) (vel (bar A B) (baz A B)))

The last operator is ~ that is negation (pay attention using this) and is an unary operator.
    
###Cut
cut is NOT implemented. but a special or operator is implemented that can be used for deterministic
deductions: !- that behaves like :- except that if the tail of the expression is successful, the 
latter expressions are not called.
i.e.

    (laguz
       (!- (foo A B) (bar A) (baz B))
       (!- (foo A B) (rar A) (raz B))
       (:- (main A B) (foo A B) (xxx A B))

bar and baz calls are successful, but xxx fails, the whole main relation fails, even if 
rar and raz and xxx are successful.
You can use it IF AND ONLY IF you are sure tha if (bar A) (baz B) are successful, then
(rar A) (raz B) fail.
As a general rule DO NOT USE !- or use it if you know what you are doing.

## relation syntax
TBD
### define-relation
### case-relation
### case unify