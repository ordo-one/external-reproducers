//
//  PredicateTree.swift
//  PredicateTree
//
//  Created by Axel Andersson on 2023-10-25.
//

import Foundation

extension Predicate {
    var tree: PredicateTree {
        PredicateTree(self)
    }
}

fileprivate protocol PredicateParsing {
    func parse(into tree: inout PredicateTree)
}

fileprivate protocol PredicateNode {
    var expression: (any PredicateExpression)? { get }
}

struct PredicateTree: PredicateNode {
    fileprivate var rootNode: PredicateNode?

    fileprivate var expression: (any PredicateExpression)? {
        return rootNode?.expression
    }

    fileprivate init(_ parsing: PredicateParsing) {
        parsing.parse(into: &self)
    }

    func predicate<T>() -> Predicate<T> {
        Predicate<T> { _ in
            guard let expression = rootNode?.expression as? any StandardPredicateExpression<Bool> else {
                fatalError("PredicateTree.predicate: can't create expression")
            }

            return expression
        }
    }
}

extension Predicate: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        guard let expression = expression as? PredicateParsing else {
            fatalError("Predicate.parse: expression not castable")
        }

        expression.parse(into: &tree)
    }
}

extension PredicateExpressions.Arithmetic: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.Arithmetic.parse: not implemented")
    }
}

extension PredicateExpressions.ClosedRange: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.ClosedRange.parse: not implemented")
    }
}

extension PredicateExpressions.CollectionContainsCollection: PredicateParsing where Base: PredicateParsing, Other: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        tree.rootNode = PredicateCollectionContainsCollection(self)
    }
}

extension PredicateExpressions.CollectionIndexSubscript: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.CollectionIndexSubscript: not implemented")
    }
}

extension PredicateExpressions.CollectionRangeSubscript: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.CollectionRangeSubscript: not implemented")
    }
}

extension PredicateExpressions.Comparison: PredicateParsing where LHS: PredicateParsing, RHS: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.Comparison: not implemented")
    }
}

extension PredicateExpressions.Conditional: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.Conditional: not implemented")
    }
}

extension PredicateExpressions.ConditionalCast: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.ConditionalCast: not implemented")
    }
}

extension PredicateExpressions.Conjunction: PredicateParsing where LHS: PredicateParsing, RHS: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        tree.rootNode = PredicateConjunction(self)
    }
}

extension PredicateExpressions.DictionaryKeyDefaultValueSubscript: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.DictionaryKeyDefaultValueSubscript: not implemented")
    }
}

extension PredicateExpressions.DictionaryKeySubscript: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.DictionaryKeySubscript: not implemented")
    }
}

extension PredicateExpressions.Disjunction: PredicateParsing where LHS: PredicateParsing, RHS: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.Disjunction: not implemented")
    }
}

extension PredicateExpressions.Equal: PredicateParsing where LHS: PredicateParsing, RHS: PredicateParsing, LHS.Output == Bool {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.Equal: not implemented")
    }
}

extension PredicateExpressions.Filter: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.Filter: not implemented")
    }
}

extension PredicateExpressions.FloatDivision: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.FloatDivision: not implemented")
    }
}

extension PredicateExpressions.ForceCast: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.ForceCast: not implemented")
    }
}

extension PredicateExpressions.ForcedUnwrap: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.ForcedUnwrap: not implemented")
    }
}

extension PredicateExpressions.IntDivision: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.IntDivision: not implemented")
    }
}

extension PredicateExpressions.IntRemainder: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.IntRemainder: not implemented")
    }
}

extension PredicateExpressions.KeyPath: PredicateParsing where Root: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        tree.rootNode = PredicateKeyPath(self)
    }
}

extension PredicateExpressions.Negation: PredicateParsing where Wrapped: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.Negation: not implemented")
    }
}

extension PredicateExpressions.NilCoalesce: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.NilCoalesce: not implemented")
    }
}

extension PredicateExpressions.NilLiteral: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.NilLiteral: not implemented")
    }
}

extension PredicateExpressions.NotEqual: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.NotEqual: not implemented")
    }
}

extension PredicateExpressions.OptionalFlatMap: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.OptionalFlatMap: not implemented")
    }
}

extension PredicateExpressions.Range: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.Range: not implemented")
    }
}

extension PredicateExpressions.RangeExpressionContains: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.RangeExpressionContains: not implemented")
    }
}

extension PredicateExpressions.SequenceAllSatisfy: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.SequenceAllSatisfy: not implemented")
    }
}

extension PredicateExpressions.SequenceContains: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.SequenceContains: not implemented")
    }
}

extension PredicateExpressions.SequenceContainsWhere: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.SequenceContainsWhere: not implemented")
    }
}

extension PredicateExpressions.SequenceMaximum: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.SequenceMaximum: not implemented")
    }
}

extension PredicateExpressions.SequenceMinimum: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.SequenceMinimum: not implemented")
    }
}

extension PredicateExpressions.SequenceStartsWith: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.SequenceStartsWith: not implemented")
    }
}

extension PredicateExpressions.StringCaseInsensitiveCompare: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.StringCaseInsensitiveCompare: not implemented")
    }
}

extension PredicateExpressions.StringLocalizedCompare: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.StringLocalizedCompare: not implemented")
    }
}

extension PredicateExpressions.StringLocalizedStandardContains: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.StringLocalizedStandardContains: not implemented")
    }
}

extension PredicateExpressions.TypeCheck: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.TypeCheck: not implemented")
    }
}

extension PredicateExpressions.UnaryMinus: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.UnaryMinus: not implemented")
    }
}

extension PredicateExpressions.Value: PredicateParsing where Output: Codable {
    fileprivate func parse(into tree: inout PredicateTree) {
        tree.rootNode = PredicateValue(self)
    }
}

extension PredicateExpressions.Variable: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        tree.rootNode = PredicateVariable(self)
    }
}

extension PredicateExpressions.VariableID: PredicateParsing {
    fileprivate func parse(into tree: inout PredicateTree) {
        fatalError("PredicateExpressions.VariableID: not implemented")
    }
}

fileprivate struct PredicateCollectionContainsCollection<Base, Other>: PredicateNode where Base: PredicateExpression & PredicateParsing, Other: PredicateExpression & PredicateParsing, Base.Output: Collection, Other.Output: Collection, Base.Output.Element: Equatable, Base.Output.Element == Other.Output.Element {
    fileprivate let collectionContainsCollection: PredicateExpressions.CollectionContainsCollection<Base, Other>
    fileprivate let baseTree: PredicateTree
    fileprivate let otherTree: PredicateTree

    var expression: (any PredicateExpression)? {
        collectionContainsCollection
    }

    init(_ collectionContainsCollection: PredicateExpressions.CollectionContainsCollection<Base, Other>) {
        self.collectionContainsCollection = collectionContainsCollection
        self.baseTree = PredicateTree(collectionContainsCollection.base)
        self.otherTree = PredicateTree(collectionContainsCollection.other)
    }
}

fileprivate struct PredicateConjunction<LHS, RHS>: PredicateNode where LHS: PredicateExpression & PredicateParsing, RHS: PredicateExpression & PredicateParsing, LHS.Output == Bool, RHS.Output == Bool {
    fileprivate let conjunction: PredicateExpressions.Conjunction<LHS, RHS>
    fileprivate let lhsTree: PredicateTree
    fileprivate let rhsTree: PredicateTree

    var expression: (any PredicateExpression)? {
        conjunction
    }

    init(_ conjunction: PredicateExpressions.Conjunction<LHS, RHS>) {
        self.conjunction = conjunction
        self.lhsTree = PredicateTree(conjunction.lhs)
        self.rhsTree = PredicateTree(conjunction.rhs)
    }
}

fileprivate struct PredicateKeyPath<Root, Output>: PredicateNode where Root: PredicateExpression & PredicateParsing {
    fileprivate let keyPath: PredicateExpressions.KeyPath<Root, Output>
    fileprivate let rootTree: PredicateTree

    var expression: (any PredicateExpression)? {
        keyPath
    }

    init(_ keyPath: PredicateExpressions.KeyPath<Root, Output>) {
        self.keyPath = keyPath
        self.rootTree = PredicateTree(keyPath.root)
    }
}

fileprivate struct PredicateValue<Output>: PredicateNode {
    fileprivate let value: PredicateExpressions.Value<Output>

    var expression: (any PredicateExpression)? {
        value
    }

    init(_ value: PredicateExpressions.Value<Output>) {
        self.value = value
    }
}

fileprivate struct PredicateVariable<Output>: PredicateNode {
    fileprivate let variable: PredicateExpressions.Variable<Output>

    var expression: (any PredicateExpression)? {
        variable
    }

    init(_ variable: PredicateExpressions.Variable<Output>) {
        self.variable = variable
    }
}
