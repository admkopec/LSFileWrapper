//
//  LSFileWrapperTests.swift
//  LSFileWrapperTests
//
//  Created by Adam Kopeć on 12/02/2021.
//  Copyright © 2021 Adam Kopeć. All rights reserved.
//

import XCTest
@testable import LSFileWrapper

class LSFileWrapperTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdateContent() {
        // This is a test case for testing update(newContent:) method
        let fileWrapper = LSFileWrapper(file: ())
        fileWrapper.update(newContent: "Hello World!" as NSString)
        
        XCTAssertNotNil(fileWrapper.string())
        XCTAssertEqual(fileWrapper.string(), "Hello World!")
    }
    
    func testAddContent() {
        // This is a test case for testing add(content: withFilename:) method
        let wrapper = LSFileWrapper(directory: ())
        wrapper.add(content: "Hello World!" as NSString, withFilename: "hello.txt")
        
        let fileWrapper = wrapper.wrapper(with: "hello.txt")
        
        XCTAssertNotNil(fileWrapper)
        XCTAssertNotNil(fileWrapper?.string())
        
        XCTAssertEqual(fileWrapper?.string(), "Hello World!")
    }
    
    func testRemoveContent() {
        // This is a test case for testing add(content: withFilename:) method
        let wrapper = LSFileWrapper(directory: ())
        wrapper.add(content: "Hello World!" as NSString, withFilename: "hello.txt")
        wrapper.removeWrapper(with: "hello.txt")
        
        let fileWrapper = wrapper.wrapper(with: "hello.txt")
        
        XCTAssertNil(fileWrapper)
    }
    
    func testMultipleWrappers() {
        // This is a test case for testing add(content: withFilename:) method
        let wrapper = LSFileWrapper(directory: ())
        wrapper.add(content: "Hello World!" as NSString, withFilename: "hello.txt")
        wrapper.add(wrapper: LSFileWrapper(directory: ()), withFilename: "directory")
        
        let fileWrapper = wrapper.wrapper(with: "hello.txt")
        let dirWrapper = wrapper.wrapper(with: "directory")
        
        XCTAssertNotNil(fileWrapper)
        XCTAssertNotNil(dirWrapper)
        
        XCTAssertEqual(fileWrapper?.string(), "Hello World!")
        XCTAssertEqual(fileWrapper?.isDirectory, false)
        XCTAssertEqual(dirWrapper?.isDirectory, true)
    }
    
    func testWrapperEnumerator() {
        // This is a test case for testing wrappers(in:) method using "/" path
        let wrapper = LSFileWrapper(directory: ())
        wrapper.add(content: "Hello World!" as NSString, withFilename: "hello.txt")
        wrapper.add(wrapper: LSFileWrapper(directory: ()), withFilename: "directory")

        let wrappers = wrapper.wrappers(in: "/")
        
        let wrapperNames = wrappers.map({ $0.filename })
        
        XCTAssertEqual(wrapperNames.sorted(by: { $1 ?? "" < $0 ?? "" }), ["hello.txt", "directory"])
    }
    
    func testWrapperEnumeratorAlternatePath() {
        // This is a test case for testing wrappers(in:) method using "" path
        let wrapper = LSFileWrapper(directory: ())
        wrapper.add(content: "Hello World!" as NSString, withFilename: "hello.txt")
        wrapper.add(wrapper: LSFileWrapper(directory: ()), withFilename: "directory")

        let wrappers = wrapper.wrappers(in: "")
        
        let wrapperNames = wrappers.map({ $0.filename })
        
        XCTAssertEqual(wrapperNames.sorted(by: { $1 ?? "" < $0 ?? "" }), ["hello.txt", "directory"])
    }
}
