//
//  foo.swift
//  package-test-interop
//
//  Created by Andrey Potemkin on 1.8.2025.
//

public struct Bar {
    private let value: Int

    public init(_ value: Int) {
        self.value = value
    }

    public func foo() {
        print("Bar value: \(value)")
    }
}

public protocol Proto1 {
    func foo()
}


extension Bar: Proto1 {
}

open class ProtoClass1 {
    let proto1: any Proto1
    public init(proto1: any Proto1) {
        self.proto1 = proto1
    }

    public init(_ proto1: some Proto1) {
        self.proto1 = proto1
    }

    public func foo() {
        proto1.foo()
    }
}
