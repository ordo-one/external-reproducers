import ArgumentParser

@main
public struct ExecMain: AsyncParsableCommand {
    enum Test: EnumerableFlag {
        case any
        case specific
        case generic
    }
    @Flag
    var test: Test
    
    public init() {
        
    }
    
    public mutating func run() async throws {
        switch test {
        case .any:
            let any = AnyLoading()
            try await any.run()
        case .specific:
            let specific = SpecificLoading()
            try await specific.run()
        case .generic:
            let generic = GenericLoading()
            try await generic.run()
        }
    }
}
