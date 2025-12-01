import CppTarget

extension Foo {
    @inlinable
    var string: String? {
        let opt = self.getStr()
        guard opt.hasValue else {
            return nil
        }
        return String(opt.pointee)
    }
}
