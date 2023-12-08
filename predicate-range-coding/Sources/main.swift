import Foundation

struct Dummy: PredicateCodableKeyPathProviding {
    static var predicateCodableKeyPaths: [String: PartialKeyPath<Dummy>] {
        ["value": \.value]
    }

    let value: Int
}

var configuration = PredicateCodableConfiguration.standardConfiguration
configuration.allowKeyPathsForPropertiesProvided(by: Dummy.self)

// Uncommenting this makes the 'failingPredicate' encoding below work
//configuration.allowType(PredicateExpressions.RangeExpressionContains<PredicateExpressions.ClosedRange<
//                        PredicateExpressions.Value<Int>, PredicateExpressions.Value<Int>>,
//                        PredicateExpressions.KeyPath<PredicateExpressions.Variable<Dummy>, Int>>.self)

// Uncommenting this also makes the 'failingPredicate' encoding below work???
//let workingPredicate = #Predicate<Dummy> {
//    $0.value > 0
//}
//
//do {
//    _ = try JSONEncoder().encode(workingPredicate, configuration: configuration)
//} catch {
//    fatalError("Exception while encoding 'workingPredicate': \(error)")
//}

let failingPredicate = #Predicate<Dummy> {
    (0...10).contains($0.value)
}

do {
    _ = try JSONEncoder().encode(failingPredicate, configuration: configuration)
} catch {
    print("Exception while encoding 'failingPredicate': \(error)")
    print("\(configuration)")
}
