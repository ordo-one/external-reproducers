// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

struct PredicateKeyPath<ObjectType> {
    let rootKeyPath: PartialKeyPath<ObjectType>
    let leafKeyPath: AnyKeyPath?
}

protocol PredicateKeyPathProviding {
    static var keyPaths: [PredicateKeyPath<Self>] { get }
}

struct Root: PredicateKeyPathProviding {
    static var keyPaths: [PredicateKeyPath<Self>] {
        [
            .init(rootKeyPath: \Self.value, leafKeyPath: nil),
            .init(rootKeyPath: \Self.optionalLeaf, leafKeyPath: \Leaf.optionalValue),
        ]
    }

    struct Leaf {
        let optionalValue: Int?
    }

    let value: Int
    let optionalLeaf: Leaf?
}

@main
struct PredicateKeyPathProvidingCommand: ParsableCommand {
    mutating func run() throws {
        let factory = PredicateFactory<Root>()

        let predicate1 = factory.createPredicate1()

        print("predicate1=\(predicate1)")

        let workingType = Root.Leaf.self
        let failingType = type(of: Root.keyPaths[1].leafKeyPath!).rootType

        print("workingType=\(workingType)")
        print("failingType=\(failingType)")

        let predicate2 = factory.createPredicate2(ofType: workingType)

        print("predicate2=\(predicate2)")
    }
}

struct PredicateFactory<RootType: PredicateKeyPathProviding> {
    func createPredicate1() -> any PredicateExpression {
        let rootVariable = PredicateExpressions.Variable<RootType>()
        let rootKeyPath = RootType.keyPaths[0].rootKeyPath

        guard let keyPath = rootKeyPath as? KeyPath<RootType, Int> else {
            fatalError()
        }

        return PredicateExpressions.Equal(
            lhs: PredicateExpressions.KeyPath(root: rootVariable, keyPath: keyPath),
            rhs: PredicateExpressions.Value(1)
        )
    }

    func createPredicate2<LeafType>(ofType: LeafType.Type) -> any PredicateExpression {
        let rootVariable = PredicateExpressions.Variable<RootType>()

        guard let rootKeyPath = RootType.keyPaths[1].rootKeyPath as? KeyPath<RootType, LeafType?> else {
            fatalError()
        }

        guard let leafKeyPath = RootType.keyPaths[1].leafKeyPath as? KeyPath<LeafType, Int?> else {
            fatalError()
        }

        let rootExpression = PredicateExpressions.KeyPath(root: rootVariable, keyPath: rootKeyPath)

        return PredicateExpressions.NilCoalesce(
            lhs: PredicateExpressions.OptionalFlatMap(rootExpression, { leafVariable in
                PredicateExpressions.Equal(
                    lhs: PredicateExpressions.KeyPath(root: leafVariable, keyPath: leafKeyPath),
                    rhs: PredicateExpressions.Value(1))
            }),
            rhs: PredicateExpressions.Value(false)
        )
    }
}
