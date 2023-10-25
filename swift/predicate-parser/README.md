# predicate-parser

This package contains an attempt to parse a `#Predicate` expression into a tree
structure, and then use that structure to create a predicate. The goal is to
be able to use the tree structure for displaying/editing a predicate in a user
interface.

This approach works in most cases, but critically not for keypath predicates.
Trying to use re-created keypath predicates throws the exception "Encountered
an undefined variable". Printing the `PredicateExpressions.Variable`
shows a `PredicateExpressions.VariableID(id: N)` where N seems to be some
monotonically increasing number.

Sample output of running the test:

```
$ swift run
Building for debugging...
Build complete! (0.07s)
'value' predicate matches 10/10
'conjunction' predicate matches 10/10
'keypath' predicate caught exception: Encountered an undefined variable
```

