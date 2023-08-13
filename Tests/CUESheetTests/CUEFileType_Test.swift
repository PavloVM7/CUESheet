//
//  CUEFileType_Test.swift
//  
//
//  Created by Pavlo Moisieienko on 11.08.2023.
//

import XCTest
@testable import CUESheet
final class CUEFileType_Test: XCTestCase {

    func test_FromString() throws {
        let names = ["wave", "WAVE", "Wave",
                     "MP3", "mp3", "Mp3",
                     "unknown", "any", "Whatever"]
        let expected = [CUEFileType.WAVE, CUEFileType.WAVE, CUEFileType.WAVE,
                        CUEFileType.MP3, CUEFileType.MP3, CUEFileType.MP3,
                        CUEFileType.UNKNOWN, CUEFileType.UNKNOWN, CUEFileType.UNKNOWN]
        for i in 0..<names.count {
            let name = names[i]
            let expected = expected[i]
            let actual = CUEFileType.fromString(name)
            XCTAssertEqual(actual, expected, "expected: \(expected), actual: \(actual)")
        }
    }
}
