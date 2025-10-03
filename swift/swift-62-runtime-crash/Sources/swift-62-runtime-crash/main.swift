import Foundation
import Synchronization
import base
import impl


let predicate = #Predicate<TestIdentifiable> {
    $0.id == "test"
}

let cache = make(predicate: predicate)

print(try cache.entries())

