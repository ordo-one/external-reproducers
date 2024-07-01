// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

struct Root {
    struct Leaf {
        let optionalValue: Int?
    }

    let optionalLeaf: Leaf?
}

@main
struct PredicateOptionalKeyPath: ParsableCommand {
    mutating func run() throws {
        // macro version
        let predicate1 = #Predicate<Root> {
            if $0.optionalLeaf == nil {
                true
            } else {
                false
            }
        }

        // manual version
        let predicate2 = Foundation.Predicate<Root>({
            PredicateExpressions.build_Conditional(
                PredicateExpressions.build_Equal(
                    lhs: PredicateExpressions.build_KeyPath(
                        root: PredicateExpressions.build_Arg($0),
                        keyPath: \.optionalLeaf
                    ),
                    rhs: PredicateExpressions.build_NilLiteral()
                ),
                PredicateExpressions.build_Arg(
                    true
                ),
                PredicateExpressions.build_Arg(
                    false
                )
            )
        })
    }
}
