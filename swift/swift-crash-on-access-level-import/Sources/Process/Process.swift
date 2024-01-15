import ArgumentParser
import Foundation
import OrdoEssentials
import OrdoInternals
import OrdoPublic

@main
public struct Process: AsyncParsableCommand {
    public init() {}

    public mutating func run() async throws {
        print("Start process")
        
        Frostflake.setup(10)
        print("Frostflake configured")
        
        Markets.setMarkets(["XHEL", "XSTO", "XEUR"])

        let loader = PluginLoader()
        try await loader.loadPlugins(at: "../Plugin/.build/debug/")

        let plugin = try loader.instantiate(plugin: "Plugin", ofType: Plugin.self)

        /*
        var data = Data()
        var id: UInt64 = 123_456_789
        var micro: UInt64 = 987_654_321
        withUnsafeBytes(of: &id) { idPtr in
            withUnsafeBytes(of: &micro) { microPtr in
                data.append(idPtr.bindMemory(to: UInt8.self).baseAddress!, count: 8)
                data.append(microPtr.bindMemory(to: UInt8.self).baseAddress!, count: 8)
            }
        }
         */
      
        var _transaction = _TransactionStruct(id: 123_456_789)
        _transaction.time = Timestamp(987_654_321)
        _transaction.mic = MIC.XEUR

        var transaction = Transaction(storage: _transaction)
        if var transaction {
            print("OK: Transaction created by Process")
            let update = await plugin.handle(transaction)
            
            _transaction.merge(update.storage)      
            if let time = _transaction.time, time.micro == 987_654_421 {
                print("OK: _TransactionStruct updated time is correct")
            } else {
                print("FAIL: _TransactionStruct updated time is not correct")
            }

            transaction.merge(update)      
            if let time = transaction.time, time.micro == 987_654_421 {
                print("OK: Transaction updated time is correct")
            } else {
                print("FAIL: Transaction updated time is not correct")
            }
            
        } else {
            print("FAIL: Transaction can't be created by Process")
        }

        if let some = plugin as? SomeProtocol {
            await some.doSomething()
        } else {
            print("FAIL: Plugin doesn't conform to SomeProtocol")
        }

        print("Done")
    }
}
