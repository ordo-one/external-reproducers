#if false

import Foundation

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

func overhead() {
    let repetitions = 1_000_000
    let formatwidth = 14
    let blank = String(repeating: " ", count: formatwidth+2)

    do {
        func benchmark(_ what: String, store: ClassIncrementable, code: () -> ()) {
            store.reset()
            var dt = Date.timeIntervalSinceReferenceDate
            code()
            dt = Date.timeIntervalSinceReferenceDate-dt
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            print("  "+nf.string(for: Double(store.count)/dt)!
                .padding(toLength: formatwidth, withPad: " ", startingAt: 0),
                  terminator: "")
            precondition(store.count == repetitions*10)
        }

        //final
        class ClassUnderlier: ClassIncrementable {
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
            func existential(p: ClassIncrementable) {
                p.increment()
            }
            func generic<G: ClassIncrementable>(p: G) {
                p.increment()
            }
            func opaque(p: some ClassIncrementable) {
                p.increment()
            }
            func ioexistential(p: inout ClassIncrementable) {
                p.increment()
            }
            func iogeneric<G: ClassIncrementable>(p: inout G) {
                p.increment()
            }
            func ioopaque(p: inout some ClassIncrementable) {
                p.increment()
            }
        }

        let target = ClassIncrementer()
        print("class underlier  <- calls/sec for argument type ->")
        print("let storage  existential     generic         opaque")

        do {
            let storage: any ClassIncrementable = ClassUnderlier()
            print("existential", terminator: "")
            benchmark("existential", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    i -= 1
                }
            }

            benchmark("generic", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    i -= 1
                }
            }

            benchmark("opaque", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    i -= 1
                }
            }
        }

        do {
            let storage: some ClassIncrementable = ClassUnderlier()
            print("\nopaque     ", terminator: "")
            benchmark("existential", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    i -= 1
                }
            }

            benchmark("generic", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    i -= 1
                }
            }

            benchmark("opaque", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    i -= 1
                }
            }
        }

        do {
            let storage = ClassUnderlier()
            print("\nconcrete   ", terminator: "")
            benchmark("existential", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    i -= 1
                }
            }

            benchmark("generic", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    i -= 1
                }
            }

            benchmark("opaque", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    i -= 1
                }
            }
        }

        print("\n\nclass underlier  <- calls/sec for argument type ->")
        print("var storage  existential     generic         opaque")

        do {
            var storage: any ClassIncrementable = ClassUnderlier()
            print("existential", terminator: "")
            benchmark("existential", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    i -= 1
                }
            }

            benchmark("generic", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    i -= 1
                }
            }

            benchmark("opaque", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    i -= 1
                }
            }
        }

        do {
            var storage: some ClassIncrementable = ClassUnderlier()
            print("\nopaque     ", terminator: "")
            benchmark("existential", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    i -= 1
                }
            }

            benchmark("generic", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    i -= 1
                }
            }

            benchmark("opaque", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    i -= 1
                }
            }
        }

        do {
            var storage = ClassUnderlier()
            print("\nconcrete   ", terminator: "")
            benchmark("existential", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    target.existential(p: storage)
                    i -= 1
                }
            }

            benchmark("generic", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    target.generic(p: storage)
                    i -= 1
                }
            }

            benchmark("opaque", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    target.opaque(p: storage)
                    i -= 1
                }
            }
        }

        print("\n\nclass underlier  <- calls/sec for inout argument type ->")
        print("var storage  existential     generic         opaque")

        do {
            var storage: any ClassIncrementable = ClassUnderlier()
            print("existential", terminator: "")
            benchmark("existential", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    i -= 1
                }
            }

            benchmark("generic", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    i -= 1
                }
            }

            benchmark("opaque", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    i -= 1
                }
            }
        }

        do {
            var storage: some ClassIncrementable = ClassUnderlier()
            print("\nopaque     ", terminator: "")
#if true
            print(blank, terminator:"")
#else
            benchmark("existential", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    i -= 1
                }
            }
#endif

            benchmark("generic", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    i -= 1
                }
            }

            benchmark("opaque", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    i -= 1
                }
            }
        }

        do {
            var storage = ClassUnderlier()
            print("\nconcrete   ", terminator: "")
#if true
            print(blank, terminator:"")
#else
            benchmark("existential", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    target.ioexistential(p: &storage)
                    i -= 1
                }
            }
#endif

            benchmark("generic", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    target.iogeneric(p: &storage)
                    i -= 1
                }
            }

            benchmark("opaque", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    target.ioopaque(p: &storage)
                    i -= 1
                }
            }
        }
    }

    do {
        func benchmark(_ what: String, store: StructIncrementable, code: () -> ()) {
            var dt = Date.timeIntervalSinceReferenceDate
            code()
            dt = Date.timeIntervalSinceReferenceDate-dt
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            print("  "+nf.string(for: Double(repetitions*10)/dt)!
                .padding(toLength: formatwidth, withPad: " ", startingAt: 0),
                  terminator: "")
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
            func existential(p: inout StructIncrementable) {
                p.increment()
            }
            func generic<G: StructIncrementable>(p: inout G) {
                p.increment()
            }
            func opaque(p: inout some StructIncrementable) {
                p.increment()
            }
        }

        let target = StructIncrementer()
        print("\n\nstruct underlier <- calls/sec for inout argument type ->")
        print("var storage  existential     generic         opaque")

        do {
            var storage: any StructIncrementable = StructUnderlier()
            print("existential", terminator: "")
            benchmark("existential", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    i -= 1
                }
            }
            storage.reset()

            benchmark("generic", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    i -= 1
                }
            }
            storage.reset()

            benchmark("opaque", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    i -= 1
                }
            }
            storage.reset()
        }

        do {
            var storage: some StructIncrementable = StructUnderlier()
            print("\nopaque     ", terminator: "")
#if true
            print(blank, terminator:"")
#else
            benchmark("existential", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    i -= 1
                }
            }
#endif
            benchmark("generic", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    i -= 1
                }
            }
            storage.reset()

            benchmark("opaque", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    i -= 1
                }
            }
            storage.reset()
        }

        do {
            var storage = StructUnderlier()
            print("\nconcrete   ", terminator: "")
#if true
            print(blank, terminator: "")
#else
            benchmark1("existential", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    target.existential(p: &storage)
                    i -= 1
                }
            }
#endif
            benchmark("generic", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    target.generic(p: &storage)
                    i -= 1
                }
            }
            storage.reset()

            benchmark("opaque", store: storage) {
                var i = repetitions
                while i != 0 {
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    target.opaque(p: &storage)
                    i -= 1
                }
                storage.reset()
            }
        }
    }

    print("\n")
}


#endif
