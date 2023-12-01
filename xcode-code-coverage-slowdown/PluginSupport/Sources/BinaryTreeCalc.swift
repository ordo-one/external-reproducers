// https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/binarytrees-swift-5.html
//
// The Computer Language Benchmarks Game
// http://benchmarksgame.alioth.debian.org/
//
// Swift adaptation of binary-trees Go #8,
// that in turn is based on Rust #4
//
// based on Marcel Ibes Swift #2 and Ralph Ganszky Swift #1

import Dispatch
import Foundation

public struct BinaryTreeCalc {
    indirect enum Tree {
        case Empty
        case Node(left: Tree, right: Tree)
    }

    func itemCheck(_ tree: Tree) -> UInt32 {
        switch tree {
        case let .Node(left, right):
            switch (left, right) {
            case (.Empty, .Empty):
                return 1
            default:
                return 1 + itemCheck(left) + itemCheck(right)
            }
        case .Empty:
            return 1
        }
    }

    func bottomUpTree(_ depth: UInt32) -> Tree {
        if depth > 0 {
            return .Node(left: bottomUpTree(depth - 1),
                         right: bottomUpTree(depth - 1))
        }

        return .Node(left: .Empty, right: .Empty)
    }

    func inner(depth: UInt32, iterations: UInt32) -> String {
        var chk = UInt32(0)
        for _ in 0 ..< iterations {
            let a = bottomUpTree(depth)
            chk += itemCheck(a)
        }

        return "\(iterations)\t trees of depth \(depth)\t check: \(chk)"
    }

    /*
     if CommandLine.argc > 1 {
     n = UInt32(CommandLine.arguments[1]) ?? UInt32(10)
     } else {
     n = 21
     }*/

    public init() {}

    public func calculate() -> String {
        // let n: UInt32 = 21
        let n: UInt32 = 20
        let minDepth = UInt32(4)
        let maxDepth = (n > minDepth + 2) ? n : minDepth + 2
        var messages: [UInt32: String] = [:]
        // let depth = maxDepth + 1

        // Create big tree in first pool
        let tree = bottomUpTree(maxDepth + 1)
        let check = itemCheck(tree)
        print("stretch tree of depth \(maxDepth + 1)\t check: \(check)")

        // Clean first pool and allocate long living tree
        let longLivingTree = bottomUpTree(maxDepth)

        let group = DispatchGroup()

        let workerQueue = DispatchQueue(label: "workerQueue", qos: .userInteractive, attributes: .concurrent)
        let messageQueue = DispatchQueue(label: "messageQueue", qos: .background)

        let start = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
        group.enter()
        workerQueue.async {
            for halfDepth in (minDepth / 2) ..< (maxDepth / 2 + 1) {
                let depth = halfDepth * 2
                let iterations = UInt32(1 << (maxDepth - depth + minDepth))

                group.enter()
                workerQueue.async {
                    let msg = inner(depth: depth, iterations: iterations)
                    messageQueue.async {
                        messages[depth] = msg
                        group.leave()
                    }
                }
            }

            messageQueue.async {
                group.leave()
            }
        }

        group.wait()

        let end = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)

        /*
         for msg in messages.sorted(by: { $0.0 < $1.0 }) {
         print(msg.value)
         }

         // Check long living tree and print out check info

         */
        print("long lived tree of depth \(maxDepth)\t check: \(itemCheck(longLivingTree))")
        let duration = "Duration: \((end - start) / 1_000_000) ms"
        return duration
    }
}
