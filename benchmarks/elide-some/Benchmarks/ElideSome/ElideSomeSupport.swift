protocol Incrementable {
    var count: Int { get }
}

protocol ClassIncrementable: Incrementable {
    func increment()
    func reset()
}

protocol StructIncrementable: Incrementable {
    mutating func increment()
    mutating func reset()
}

final class ClassUnderlier: ClassIncrementable {
    var count = 0
    var x = "", y = "", z = ""
    func increment() {
        count += 1
    }
    func reset() {
        count = 0
    }
    func str() -> String {
        return x + y + z
    }
}

struct ClassIncrementer {
    func existential(_ p: ClassIncrementable) {
        p.increment()
    }
    func generic<G: ClassIncrementable>(_ p: G) {
        p.increment()
    }
    func opaque(_ p: some ClassIncrementable) {
        p.increment()
    }
    func ioexistential(_ p: inout ClassIncrementable) {
        p.increment()
    }
    func iogeneric<G: ClassIncrementable>(_ p: inout G) {
        p.increment()
    }
    func ioopaque(_ p: inout some ClassIncrementable) {
        p.increment()
    }
}

struct StructUnderlier: StructIncrementable {
    var count = 0 // uncomment to make 25x slower (strangely)
    var x = "", y = "", z = ""
    mutating func increment() {
        count += 1
    }
    mutating func reset() {
        count = 0
    }
    func str() -> String {
        return x + y + z
    }
}

struct StructIncrementer {
    func existential(_ p: inout StructIncrementable) {
        p.increment()
    }
    func generic<G: StructIncrementable>(_ p: inout G) {
        p.increment()
    }
    func opaque(_ p: inout some StructIncrementable) {
        p.increment()
    }
}
