//
//  File.swift
//  
//
//  Created by Pavlo Moisieienko on 20.08.2023.
//

import Foundation

fileprivate let doubleQuoter: Character = "\""
fileprivate let singleQuoter: Character = "'"

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
    internal private(set) var lastToken: CUEToken?
    var position: String.Index
    var description: String {
        "CUETokenizer{lastToken: \(String(describing: self.lastToken)), position: \(self.text.distance(from: self.text.startIndex, to: self.position)), text:'\(self.text)'}"
    }
    convenience init(text: String) {
        self.init(text: text, position: text.startIndex)
    }
    init(text: String, position: String.Index) {
        self.text = text
        self.position = position
        self.lastToken = nil
    }
    func hasNext() -> Bool {
        return self.position < text.endIndex
    }
    func next() -> CUEToken? {
        var token = ""
        var start: String.Index?
        let end = self.text.endIndex
        var quotes:UInt8 = 0
        while self.position < end {
            let ch = self.text[self.position]
            if !ch.isWhitespace {
                token += String(ch)
                if start == nil {
                    start = self.position
                    if ch.isDoubleQuote {
                        quotes = 2
                    } else if ch.isSingleQuote {
                        quotes = 1
                    }
                } else if quotes != 0 {
                    if (ch.isDoubleQuote && quotes == 2) || (ch.isSingleQuote && quotes == 1) {
                        quotes = 0
                    }
                }
            } else if start != nil {
                if quotes == 0 {
                    break
                } else {
                    token += String(ch)
                }
            }
            self.position = text.index(after: self.position)
        }
        if let start {
            self.lastToken = CUEToken(name: token, start: start)
            return self.lastToken
        }
        return nil
    }
    func ending() -> String {
        String(self.text[self.position...self.text.index(before: self.text.endIndex)])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Character {
    var isSingleQuote: Bool {self == singleQuoter}
    var isDoubleQuote: Bool {self == doubleQuoter}
}
