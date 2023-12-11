import Foundation

// Commenting out 'workingPredicate' makes 'failingPredicate' behave as expected
let workingPredicate = #Predicate<Int> {
    $0 > 0
}

// Expected: Comparison<Variable<Int>, Value<Int>>
print("workingPredicate=\(type(of: workingPredicate.expression))")

let failingPredicate = #Predicate<Int> {
    (0...10).contains($0)
}

// Expected: RangeExpressionContains<ClosedRange<Value<Int>, Value<Int>>, Variable<Int>>
print("failingPredicate=\(type(of: failingPredicate.expression))")
