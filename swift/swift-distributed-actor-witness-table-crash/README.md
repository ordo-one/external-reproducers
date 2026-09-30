# Swift 6.4: `-O` crash deserializing a distributed actor's witness table

Three modules: `Protocols` declares a protocol refining `DistributedActor` with one `distributed func`, `Implementation` has a public `distributed actor` conforming to it, and `Client` converts that actor to `any Service`.

```bash
swift build -c release   # swift-frontend crashes (signal 11); same with --build-system native
swift build              # debug builds fine
```

```text
3.	While evaluating request ExecuteSILPipelineRequest(... on SIL for Client)
4.	While running pass #10 SILModuleTransform "PerformanceSILLinker".
5.	While deserializing SIL witness table for protocol conformance ServiceActor: Service at 'ServiceActor' (in module 'Implementation')

swift::serialization::ModularizationError::diagnose(swift::ModuleFile const*, swift::DiagnosticBehavior) const
swift::ModuleFile::diagnoseModularizationError(llvm::Error, swift::DiagnosticBehavior) const
swift::ModuleFile::fatal(llvm::Error) const
swift::SILDeserializer::readWitnessTableEntries(...)
swift::SILDeserializer::readWitnessTableChecked(...)
swift::SILDeserializer::lookupWitnessTable(swift::SILWitnessTable*)
swift::SILLinkerVisitor::visitProtocolConformance(swift::ProtocolConformanceRef, bool)
```

Expected: the release build succeeds.

- Not needed to trigger: library evolution, `@Resolvable`, parameters, dynamic products.
- No crash when the protocol and the actor are in the same module, or when the protocol has no `distributed` requirements.
- Workaround: make the actor internal and create it through a public factory in its own module that returns `any Service`, so `Client` never references the conformance.

Apple Swift version 6.4 (swiftlang-6.4.0.34.1 clang-2100.3.34.1), macOS 27.0, arm64. Possibly related: swiftlang/swift#92222, swiftlang/swift#82990.
