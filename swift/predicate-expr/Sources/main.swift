import Foundation

protocol PredicateExpressionProviding {
    static func makeExpression() -> any PredicateExpression<Self>
    static func buildKeyPath(_ rootOutputTypeName: String) -> any PredicateExpression<Self>
    static func buildKeyPathWithRoot<T>(_ root: some PredicateExpression<T>) -> any PredicateExpression<Self>
}

struct MyStruct {
    let value: Int = 10
}

extension MyStruct: PredicateExpressionProviding {
    static func makeExpression() -> any PredicateExpression<Self> {
        PredicateExpressions.build_Arg(MyStruct())
    }
}

extension Int: PredicateExpressionProviding {
    static func makeExpression() -> any PredicateExpression<Self> {
        fatalError()
    }
}

extension PredicateExpressionProviding {
    static func buildKeyPath(_ rootOutputTypeName: String) -> any PredicateExpression<Self> {
        guard let rootOutputType = _typeByName(rootOutputTypeName) else { fatalError() }
        guard let rootOutputType = rootOutputType as? any PredicateExpressionProviding.Type else { fatalError() }
        let root = rootOutputType.makeExpression()
        return buildKeyPathWithRoot(root)
    }

    static func buildKeyPathWithRoot<T>(_ root: some PredicateExpression<T>) -> any PredicateExpression<Self> {
        let keyPath = \MyStruct.value as! KeyPath<T, Self>
        return PredicateExpressions.build_KeyPath(root: root, keyPath: keyPath)
    }
}

guard let rootOutputTypeName = _mangledTypeName(MyStruct.self) else { fatalError() }
let expr = Int.buildKeyPath(rootOutputTypeName)
print("\(type(of: expr))")
