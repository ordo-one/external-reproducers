import CppTarget


struct Foo {
    func foo(
        events: [UInt8],
        onHandle: @escaping (Int64) -> Void
    ) {
        executeInThread(.init({
            var fooEvents = FooEvents()
            for event in events {
                fooEvents.push_back(event)
            }
            cpp_foo(fooEvents, .init({ handle in
                onHandle(handle)
            }))
        }))
    }
}
