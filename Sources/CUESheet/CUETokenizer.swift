//
//  File.swift
//  
//
//  Created by Pavlo Moisieienko on 20.08.2023.
//

import Foundation

struct CUEToken: CustomStringConvertible, Equatable {
    let name: String
    let start: String.Index
    var description: String {"CUEToken{name: '\(self.name)', start: \(self.start.encodedOffset)}"}
    init(name: String, start: String.Index) {
        self.name = name
        self.start = start
    }
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name && lhs.start == rhs.start
    }
}

class CUETokenizer: CustomStringConvertible {
    let text: String
    internal private(set) var lastToken: CUEToken
    var position: String.Index
    var description: String {
        "CUETokenizer{lastToken: \(self.lastToken), position: \(self.text.distance(from: self.text.startIndex, to: self.position)), text:'\(self.text)'}"
    }
    convenience init(text: String) {
        self.init(text: text, position: text.startIndex)
    }
    init(text: String, position: String.Index) {
        self.text = text
        self.lastToken = CUEToken(name: "", start: "".startIndex)
        self.position = position
    }
    func hasNext() -> Bool {
        return self.position < text.endIndex
    }
    func next() -> CUEToken? {
        var token = ""
        var start: String.Index?
        let end = self.text.endIndex
        while self.position < end {
            let ch = self.text[self.position]
            if !ch.isWhitespace {
                token += String(ch)
                if start == nil {
                    start = self.position
                }
            } else if start != nil {
                break
            }
            self.position = text.index(after: self.position)
        }
        if let start {
            return CUEToken(name: token, start: start)
        }
        return nil
    }
    func ending() -> String {
        String(self.text[self.position...self.text.index(before: self.text.endIndex)])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
