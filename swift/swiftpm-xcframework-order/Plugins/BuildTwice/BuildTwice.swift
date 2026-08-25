import Foundation
import PackagePlugin

/// Builds one product per argument (default: ConsumerA ConsumerB ConsumerA) through
/// `PackageManager.build`, exactly like a bundling plugin that builds products one by one.
/// After every build it snapshots `.build/release.yaml` (the generated llbuild manifest),
/// extracts the framework-directory inputs of the `Core` compile command, and reports
/// which modules were recompiled (from the verbose build log).
@main
struct BuildTwice: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let products = arguments.isEmpty ? ["ConsumerA", "ConsumerB", "ConsumerA"] : arguments
        // pluginWorkDirectory is .build/plugins/BuildTwice/outputs -> three levels up is .build
        let buildDir = context.pluginWorkDirectoryURL
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let manifestURL = buildDir.appending(path: "release.yaml")

        // Core.d is rewritten whenever the Core compile command actually re-runs.
        let coreDeps = buildDir.appending(path: "arm64-apple-macosx/release/Core.build/Core.d")
        func mtime(_ url: URL) -> Date? {
            (try? FileManager.default.attributesOfItem(atPath: url.path()))?[.modificationDate] as? Date
        }

        var orders: [[String]] = []
        for (index, product) in products.enumerated() {
            let before = mtime(coreDeps)
            let started = Date()
            let result = try packageManager.build(
                .product(product),
                parameters: PackageManager.BuildParameters(configuration: .release, logging: .verbose)
            )
            let seconds = String(format: "%.2f", Date().timeIntervalSince(started))
            let recompiled = compiledModules(in: result.logText)
            let coreReran = mtime(coreDeps).map { $0 != before } ?? false
            print("build #\(index + 1) product=\(product) succeeded=\(result.succeeded) time=\(seconds)s recompiled=\(recompiled.sorted()) coreCommandReran=\(coreReran)")
            try result.logText.write(to: context.pluginWorkDirectoryURL.appending(path: "build-\(index + 1)-\(product).log"), atomically: true, encoding: .utf8)

            let yaml = try String(contentsOf: manifestURL, encoding: .utf8)
            let snapshot = context.pluginWorkDirectoryURL.appending(path: "manifest-\(index + 1)-\(product).yaml")
            try yaml.write(to: snapshot, atomically: true, encoding: .utf8)
            let order = frameworkInputs(ofCommand: "C.Core-arm64-apple-macosx-release.module", in: yaml)
            orders.append(order)
            print("  Core compile inputs (framework dirs): \(order.joined(separator: " "))")
            print("  manifest snapshot: \(snapshot.path())")
        }

        let distinct = Set(orders.map { $0.joined(separator: "|") })
        if distinct.count > 1 {
            print("RESULT: framework input order differed between plans in this process (\(distinct.count) distinct orders) -> llbuild signatures changed")
        } else {
            print("RESULT: framework input order was stable within this process; compare snapshots across separate invocations")
        }
    }

    /// Module names from verbose build output: progress lines ("[3/9] Compiling Core Core.swift")
    /// and echoed compiler invocations ("swiftc -module-name Core ...").
    private func compiledModules(in log: String) -> Set<String> {
        var modules = Set<String>()
        for line in log.split(separator: "\n") {
            if let range = line.range(of: "Compiling ") {
                if let module = line[range.upperBound...].split(separator: " ").first { modules.insert(String(module)) }
            } else if line.contains("swiftc"), let range = line.range(of: "-module-name ") {
                if let module = line[range.upperBound...].split(separator: " ").first { modules.insert(String(module)) }
            }
        }
        return modules
    }

    /// The `*.framework/` entries of the `inputs:` list of one llbuild command block, in manifest order.
    private func frameworkInputs(ofCommand key: String, in yaml: String) -> [String] {
        guard let keyRange = yaml.range(of: "\"\(key)\":") else { return ["<command not found>"] }
        let after = yaml[keyRange.upperBound...]
        guard let inputsRange = after.range(of: "inputs: [") else { return ["<no inputs>"] }
        let fromInputs = after[inputsRange.upperBound...]
        guard let end = fromInputs.firstIndex(of: "]") else { return ["<unterminated>"] }
        let list = fromInputs[..<end]
        return list.split(separator: ",").map { $0.trimmingCharacters(in: .init(charactersIn: "\" ")) }
            .filter { $0.hasSuffix(".framework/") }
            .map { URL(fileURLWithPath: $0).lastPathComponent }
    }
}
