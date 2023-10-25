//
//  PredicateParser.swift
//  PredicateParser
//
//  Created by Axel Andersson on 2023-10-25.
//

import Foundation

@main
struct PredicateParser {
    static let messages: [Message] = (0 ..< 10).map { _ in .mock() }

    static func main() {
        testPredicate("value", makeValuePredicate())
        testPredicate("conjunction", makeConjunctionPredicate())
        testPredicate("keypath", makeKeyPathPredicate("a"))
    }

    static func testPredicate(_ name: String, _ predicate: Predicate<Message>) {
        do {
            let recreatedPredicate: Predicate<Message> = predicate.tree.predicate()
            let count = try messages.filter(recreatedPredicate).count

            print("'\(name)' predicate matches \(count)/\(messages.count)")
        } catch let exception {
            print("'\(name)' predicate caught exception: \(exception)")
        }
    }

    static func makeValuePredicate() -> Predicate<Message> {
        Predicate<Message>({ _ in
            PredicateExpressions.Value(true)
        })
    }

    static func makeConjunctionPredicate() -> Predicate<Message> {
        Predicate<Message>({ _ in
            PredicateExpressions.Conjunction(
                lhs: PredicateExpressions.Value(true),
                rhs: PredicateExpressions.Value(true)
            )
        })
    }

    static func makeKeyPathPredicate(_ title: String) -> Predicate<Message> {
        Predicate<Message>({ input in
            PredicateExpressions.CollectionContainsCollection(
                base: PredicateExpressions.KeyPath(root: input, keyPath: \Message.title),
                other: PredicateExpressions.Value(title)
            )
        })
    }
}
