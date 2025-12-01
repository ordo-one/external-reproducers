import CppTarget

extension Foo {
    @inlinable
    public var string: String? {
        self.getStr().value.map {
            .init($0)
        }
    }
}
