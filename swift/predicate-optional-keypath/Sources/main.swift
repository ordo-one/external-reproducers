import Foundation

struct Dummy {
    struct Sub {
        let string: String = "string"
        let optionalString: String? = "string"
    }

    let sub: Sub = .init()
    let optionalSub: Sub? = .init()
}

enum Result {
    case success(Bool)
    case failure(Error)
}

let dummy = Dummy()

func predicateCreatedWithMacro() -> Predicate<Dummy> {
    let workingPredicate1 = #Predicate<Dummy> { dummy in
        // 1. comparison with string in optional struct
        // works
        dummy.optionalSub?.string == "string"
    }

    let workingPredicate2 = #Predicate<Dummy> { dummy in
        // 2. comparison with optional string in optional struct
        // works
        dummy.optionalSub?.optionalString == "string"
    }

    return workingPredicate1
}

func predicateCreatedManually() throws -> Predicate<Dummy> {
    func workingPredicate(for variable: PredicateExpressions.Variable<Dummy>) -> any StandardPredicateExpression<Bool> {
        // 1. comparison with optional string in non-optional struct
        // works
        let lhsKeyPath = PredicateExpressions.KeyPath(root: variable, keyPath: \Dummy.sub.optionalString)
        let rhsValue = PredicateExpressions.Value<String?>("string")

        return PredicateExpressions.Equal(lhs: lhsKeyPath, rhs: rhsValue)
    }

    func failingPredicate(for variable: PredicateExpressions.Variable<Dummy>) -> any StandardPredicateExpression<Bool> {
        // 2. comparison with optional string in optional struct
        // fails: "Foundation/KeyPath+Inspection.swift:65: Fatal error: Predicate does not support keypaths with multiple components"
        let lhsKeyPath = PredicateExpressions.KeyPath(root: variable, keyPath: \Dummy.optionalSub?.optionalString)
        let rhsValue = PredicateExpressions.Value<String?>("string")

        return PredicateExpressions.Equal(lhs: lhsKeyPath, rhs: rhsValue)
    }

    return Predicate<Dummy> { variable in
//        workingPredicate(for: variable)
        failingPredicate(for: variable)
    }
}

func evaluateCreatedMacro() -> Result {
    do {
        if try predicateCreatedWithMacro().evaluate(dummy) {
            return .success(true)
        } else {
            return .success(false)
        }
    } catch {
        return .failure(error)
    }
}

switch evaluateCreatedMacro() {
case let .success(result):
    print("Macro created predicate evaluation succeeded: \(result ? "matches" : "does not match")")
case let .failure(error):
    print("Macro created predicate evaluation failed: \(error)")
}

func evaluateCreatedManually() -> Result {
    do {
        if try predicateCreatedManually().evaluate(dummy) {
            return .success(true)
        } else {
            return .success(false)
        }
    } catch {
        return .failure(error)
    }
}

switch evaluateCreatedManually() {
case let .success(result):
    print("Manually created predicate evaluation succeeded: \(result ? "matches" : "does not match")")
case let .failure(error):
    print("Manually created predicate evaluation failed: \(error)")
}
