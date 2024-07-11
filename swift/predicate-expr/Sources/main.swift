import Foundation

protocol PredicateExpressionProviding {
    static func makeExpression() -> any PredicateExpression<Self>
}

extension String: PredicateExpressionProviding {
    static func makeExpression() -> any PredicateExpression<Self> {
        return PredicateExpressions.build_Arg("arg")
    }
}

func makeExpression<CompareType>(_ compareType: CompareType.Type) -> any PredicateExpression<Bool>? {
    if let compareType = compareType as? any PredicateExpressionProviding.Type {
        let lhs = compareType.makeExpression()
        let rhs = compareType.makeExpression()
        return PredicateExpressions.build_Equal(lhs: lhs, rhs: rhs)
    }
    return nil
}
