//
//  CUETokenizer_Tests.swift
//  
//
//  Created by Pavlo Moisieienko on 20.08.2023.
//

import XCTest
@testable import CUESheet

final class CUETokenizer_Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_hasNext_empty_string() throws {
        let source = ""
        let tokenizer = CUETokenizer(text: source)
        print(tokenizer)
        XCTAssertFalse(tokenizer.hasNext())
    }
    
    func test_hasNext() throws {
        let source = "not empty string"
        let tokenizer = CUETokenizer(text: source)
        print(tokenizer)
        XCTAssertTrue(tokenizer.hasNext())
        tokenizer.position = tokenizer.text.index(tokenizer.position, offsetBy: 7)
        XCTAssertTrue(tokenizer.hasNext())
        tokenizer.position = tokenizer.text.endIndex
        XCTAssertFalse(tokenizer.hasNext())
    }
    func test_next_first() throws {
        let sources = [
            "token",
            "     token  ",
            "\ttoken\t",
            "\t token \t",
            "\t token\t ",
            "token\n",
            "token \n"
        ]
        let expected = "token"
        let expectedPos = [
            expected.startIndex,
            expected.index(expected.startIndex, offsetBy: 5),
            expected.index(expected.startIndex, offsetBy: 1),
            expected.index(expected.startIndex, offsetBy: 2),
            expected.index(expected.startIndex, offsetBy: 2),
            expected.startIndex,
            expected.startIndex
        ]
        var i = -1
        for src in sources {
            let tokenizer = CUETokenizer(text: src)
            XCTAssertTrue(tokenizer.hasNext())
            let actual1 = tokenizer.next()
            XCTAssertNotNil(actual1)
            XCTAssertEqual(expected, actual1?.name)
            i += 1
            let expectedPosition = expectedPos[i]
            XCTAssertEqual(expectedPosition, actual1?.start,
                           "\(expectedPosition.utf16Offset(in: expected)) != \(String(describing: actual1?.start.utf16Offset(in: expected)))")
            let actual2 = tokenizer.next()
            XCTAssertNil(actual2)
        }
    }
    
    func test_next() throws {
        let source = "\t one\ttwo  three\t  four \tfive\t\t   six\n"
        let tokenizer = CUETokenizer(text: source)
        
        
        XCTAssertTrue(tokenizer.hasNext())
        let expected1 = createExpected(source: source, name: "one", offset: 2)
        let actual1 = tokenizer.next()
        XCTAssertEqual(expected1, actual1)
        
        XCTAssertTrue(tokenizer.hasNext())
        let actual2 = tokenizer.next()
        let expected2 = createExpected(source: source, name: "two", offset: 6)
        XCTAssertEqual(expected2, actual2)
        
        XCTAssertTrue(tokenizer.hasNext())
        let actual3 = tokenizer.next()
        let expected3 = createExpected(source: source, name: "three", offset: 11)
        XCTAssertEqual(expected3, actual3)
        
        XCTAssertTrue(tokenizer.hasNext())
        let actual4 = tokenizer.next()
        let expected4 = createExpected(source: source, name: "four", offset: 19)
        XCTAssertEqual(expected4, actual4)
        
        XCTAssertTrue(tokenizer.hasNext())
        let actual5 = tokenizer.next()
        let expected5 = createExpected(source: source, name: "five", offset: 25)
        XCTAssertEqual(expected5, actual5)
        
        XCTAssertTrue(tokenizer.hasNext())
        let actual6 = tokenizer.next()
        let expected6 = createExpected(source: source, name: "six", offset: 34)
        XCTAssertEqual(expected6, actual6)
        
        XCTAssertTrue(tokenizer.hasNext())
        let actual7 = tokenizer.next()
        XCTAssertNil(actual7)
        
        XCTAssertFalse(tokenizer.hasNext())
    }

    func test_start_with_whitespaces() throws {
        let source = " \t one \t\t\t two\t\t   three\n"
        let tokenizer = CUETokenizer(text: source)
        _ = tokenizer.next()
        let two = tokenizer.next()
        let expected = createExpected(source: source, name: "two", offset: 11)
        XCTAssertEqual(expected, two)
        
        let tokenizer2 = CUETokenizer(text: source, position: two!.start)
        XCTAssertTrue(tokenizer2.hasNext())
        let actual = tokenizer2.next()
        XCTAssertEqual(expected, actual)
        
        let three = tokenizer2.next()
        XCTAssertEqual(createExpected(source: source, name: "three", offset: 19), three)
    }
    func test_ending() throws {
        let source = "  one \ttwo   \n"
        let tokenizer = CUETokenizer(text: source)
        _ = tokenizer.next()
        let ending = tokenizer.ending()
        XCTAssertEqual("two", ending)
    }
    func test_ending_no_whitespace_at_the_end() throws {
        let source = "one\t  \t\t two"
        let tokenizer = CUETokenizer(text: source)
        _ = tokenizer.next()
        let ending = tokenizer.ending()
        XCTAssertEqual("two", ending)
    }
    func test_next_double_quotes() throws {
        let source = " one \"two  three\" four"
        let tokenizer = CUETokenizer(text: source)
        let one = tokenizer.next()
        XCTAssertEqual(createExpected(source: source, name: "one", offset: 1), one)
        let actual = tokenizer.next()
        XCTAssertEqual(createExpected(source: source, name: "\"two  three\"", offset: 5), actual)
        let four = tokenizer.next()
        XCTAssertEqual(createExpected(source: source, name: "four", offset: 18), four)
    }
    func test_next_single_quotes() throws {
        let source = " one 'two  three' four"
        let tokenizer = CUETokenizer(text: source)
        let one = tokenizer.next()
        XCTAssertEqual(createExpected(source: source, name: "one", offset: 1), one)
        let actual = tokenizer.next()
        XCTAssertEqual(createExpected(source: source, name: "'two  three'", offset: 5), actual)
        let four = tokenizer.next()
        XCTAssertEqual(createExpected(source: source, name: "four", offset: 18), four)
    }
    func test_lastToken() throws {
        let source = "one two  "
        let tokenizer = CUETokenizer(text: source)
        let one = tokenizer.next()
        XCTAssertNotNil(tokenizer.lastToken)
        XCTAssertEqual(one, tokenizer.lastToken)
        let two = tokenizer.next()
        XCTAssertNotNil(tokenizer.lastToken)
        XCTAssertEqual(two, tokenizer.lastToken)
        let noToken = tokenizer.next()
        XCTAssertNil(noToken)
        XCTAssertNotNil(tokenizer.lastToken)
        XCTAssertEqual(two, tokenizer.lastToken)
    }

    func testPerformance_next() throws {
        // This is an example of a performance test case.
        let source = "\t one\ttwo  three\t  four \tfive\t\t   six\n"
        let tokenizer = CUETokenizer(text: source)
        var tokens: [CUEToken] = []
        self.measure {
            // Put the code you want to measure the time of here.
            while tokenizer.hasNext() {
                if let token = tokenizer.next() {
                    tokens.append(token)
                }
            }
        }
        XCTAssertEqual(6, tokens.count)
    }

}

func createExpected(source: String, name: String, offset: Int) -> CUEToken {
    CUEToken(name: name, start: source.index(source.startIndex, offsetBy: offset))
}
