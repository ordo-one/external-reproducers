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
        let factory = PredicateFactory()

        let predicate1 = factory.rootPredicate(rootType: Root.self)
        print("predicate1=\(predicate1)")

        let hardcodedType = Root.Leaf.self
        print("hardcodedType=\(hardcodedType)")

        let predicate2 = factory.leafPredicate(rootType: Root.self, leafType: hardcodedType)
        print("predicate2=\(predicate2)")

        let dynamicType = type(of: Root.keyPaths[1].leafKeyPath!).rootType
        print("dynamicType=\(dynamicType)")

#if hasFeature(ImplicitOpenExistentials)
        let predicate3 = factory.leafPredicate(rootType: Root.self, leafType: dynamicType)
        print("predicate3=\(predicate3)")
#else
        func leaf<LeafType>(_: LeafType.Type) -> LeafType.Type {
            LeafType.self
        }

        let openedType = leaf(_openExistential(dynamicType, do: leaf))
        print("openedType=\(openedType)")

        let predicate3 = factory.leafPredicate(rootType: Root.self, leafType: openedType)
        print("predicate3=\(predicate3)")
#endif
    }
}

struct PredicateFactory {
    func rootPredicate<RootType: PredicateKeyPathProviding>(rootType: RootType.Type) -> any PredicateExpression {
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

    func leafPredicate<RootType: PredicateKeyPathProviding, LeafType>(rootType: RootType.Type, leafType: LeafType.Type) -> any PredicateExpression {
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
