//
//  Message.swift
//  PredicateTree
//
//  Created by Axel Andersson on 2023-10-25.
//

import Foundation

struct Message {
    let number: Int
    let title: String

    static func mock() -> Self {
        .init(number: .random(in: 1...10), title: .random(ofLength: 10))
    }
}

extension String {
    static func random(ofLength length: Int) -> String {
        let letters = "abc"

        return String((0 ..< length).map { _ in letters.randomElement()! })
    }
}
