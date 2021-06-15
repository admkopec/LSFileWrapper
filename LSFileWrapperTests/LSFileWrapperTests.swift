//
//  LSFileWrapperTests.swift
//  LSFileWrapperTests
//
//  Created by Adam Kopeć on 12/02/2021.
//  Copyright © 2021 Adam Kopeć.
//
//  Licensed under the MIT License
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
    
    #if os(iOS)
    var sampleImage: UIImage {
        let rect = CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.CGImage else { return nil }
        return UIImage(CGImage: cgImage)
    }
    #else
    var sampleImage: NSImage {
        NSImage(named: "NSApplicationIcon") ?? NSImage()
    }
    #endif

    func testUpdateContent() {
        // This is a test case for testing update(newContent:) method
        let fileWrapper = LSFileWrapper(file: ())
        fileWrapper.update(newContent: "Hello World!" as NSString)
        
        XCTAssertNotNil(fileWrapper.string())
        XCTAssertEqual(fileWrapper.string(), "Hello World!")
    }
    
    func testUpdateDataContent() {
        // This is a test case for testing update(newContent:) method using raw Data
        let fileWrapper = LSFileWrapper(file: ())
        fileWrapper.update(newContent: Data("Hello World!".utf8) as NSData)
        
        XCTAssertNotNil(fileWrapper.data())
        XCTAssertEqual(fileWrapper.data(), Data("Hello World!".utf8))
        XCTAssertEqual(fileWrapper.string(), "Hello World!") // This sets the type
        XCTAssertNil(fileWrapper.data()) // So here data() should be nil
    }
    
    func testUpdateDictionaryContent() {
        // This is a test case for testing update(newContent:) method using simple Dictionary
        let testDict = ["Name": "LSFileWrapper", "Platforms": "macOS, iOS", "Version": "2"]
        let fileWrapper = LSFileWrapper(file: ())
        fileWrapper.update(newContent: testDict as NSDictionary)
        
        XCTAssertNotNil(fileWrapper.dictionary())
        XCTAssertEqual(fileWrapper.dictionary() as? [String: String], testDict)
    }
    
    func testUpdateAnyDictionaryContent() {
        // This is a test case for testing update(newContent:) method using an advanced Dictionary
        let testDict = ["Name": "LSFileWrapper", "Platforms": ["macOS", "iOS"], "Version": 2] as [String : Any]
        let fileWrapper = LSFileWrapper(file: ())
        fileWrapper.update(newContent: testDict as NSDictionary)
        
        XCTAssertNotNil(fileWrapper.dictionary())
        let dict = fileWrapper.dictionary() as? [String: Any]
        XCTAssertNotNil(dict)
        XCTAssertEqual(dict?["Name"] as? String, (testDict["Name"] as! String))
        XCTAssertEqual(dict?["Version"] as? Int, (testDict["Version"] as! Int))
        XCTAssertEqual(dict?["Platforms"] as? [String], (testDict["Platforms"] as! [String]))
    }
    
    func testUpdateImageContent() {
        // This is a test case for testing update(newContent:) method using an Image
        let testImg = sampleImage
        let fileWrapper = LSFileWrapper(file: ())
        fileWrapper.update(newContent: testImg)
        
        XCTAssertNotNil(fileWrapper.image())
        XCTAssertEqual(fileWrapper.image()?.size, testImg.size) // More or less enough
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
    
    func testSetContent() {
        // This is a test case for testing set(content: withFilename:) method
        let wrapper = LSFileWrapper(directory: ())
        wrapper.set(content: "Hello World!" as NSString, withFilename: "hello.txt")
        
        let fileWrapper = wrapper.wrapper(with: "hello.txt")
        
        XCTAssertNotNil(fileWrapper)
        XCTAssertNotNil(fileWrapper?.string())
        
        XCTAssertEqual(fileWrapper?.string(), "Hello World!")
    }
    
    func testAddContentNameAlteration() {
        // This is a test case for testing add(content: withFilename:) method when a file already exists
        let wrapper = LSFileWrapper(directory: ())
        wrapper.add(content: "Hello World!" as NSString, withFilename: "hello.txt")
        let newName = wrapper.add(content: "Hello Altered World!" as NSString, withFilename: "hello.txt")
        
        XCTAssertNotEqual(newName, "hello.txt")
        XCTAssertEqual(newName, "hello 1.txt")
        
        let fileWrapper = wrapper.wrapper(with: "hello.txt")
        let secondWrapper = wrapper.wrapper(with: newName)
        
        XCTAssertNotNil(fileWrapper)
        XCTAssertNotNil(fileWrapper?.string())
        
        XCTAssertEqual(fileWrapper?.string(), "Hello World!")
        
        XCTAssertNotNil(secondWrapper)
        XCTAssertNotNil(secondWrapper?.string())
        
        XCTAssertEqual(secondWrapper?.string(), "Hello Altered World!")
    }
    
    func testSetContentReplacement() {
        // This is a test case for testing set(content: withFilename:) method when a file already exists
        let wrapper = LSFileWrapper(directory: ())
        wrapper.add(content: "Hello World!" as NSString, withFilename: "hello.txt")
                
        let fileWrapper = wrapper.wrapper(with: "hello.txt")
        
        XCTAssertNotNil(fileWrapper)
        XCTAssertNotNil(fileWrapper?.string())
        
        XCTAssertEqual(fileWrapper?.string(), "Hello World!")
        
        wrapper.set(content: "Hello Altered World!" as NSString, withFilename: "hello.txt")
        let secondWrapper = wrapper.wrapper(with: "hello.txt")
        
        XCTAssertNotNil(secondWrapper)
        XCTAssertNotNil(secondWrapper?.string())
        
        XCTAssertEqual(secondWrapper?.string(), "Hello Altered World!")
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
    
    func testWriteToURL() throws {
        // This is a test case for testing write(to:) method
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("testWrite.package")
        let testDict = ["Name": "LSFileWrapper", "Platforms": ["macOS", "iOS"], "Version": 2] as [String : Any]
        let testImg = sampleImage
        let wrapper = LSFileWrapper(directory: ())
        wrapper.add(content: "Hello World!" as NSString, withFilename: "hello.txt")
        wrapper.add(content: testDict as NSDictionary, withFilename: "hello.plist")
        wrapper.add(content: testImg, withFilename: "hello.jpeg")
        wrapper.add(wrapper: LSFileWrapper(directory: ()), withFilename: "directory")

        try wrapper.write(to: url)
        
        let writtenWrapper = LSFileWrapper(url: url, isDirectory: true)
        
        XCTAssertNotNil(writtenWrapper)
        XCTAssert(writtenWrapper?.isDirectory == true)
        
        XCTAssertNotNil(writtenWrapper?.wrapper(with: "hello.txt"))
        XCTAssert(writtenWrapper?.wrapper(with: "hello.txt")?.isDirectory == false)
        XCTAssertNotNil(writtenWrapper?.wrapper(with: "hello.plist"))
        XCTAssert(writtenWrapper?.wrapper(with: "hello.plist")?.isDirectory == false)
        XCTAssertNotNil(writtenWrapper?.wrapper(with: "hello.jpeg"))
        XCTAssert(writtenWrapper?.wrapper(with: "hello.jpeg")?.isDirectory == false)
        XCTAssertNotNil(writtenWrapper?.wrapper(with: "directory"))
        XCTAssert(writtenWrapper?.wrapper(with: "directory")?.isDirectory == true)
        
        XCTAssertEqual(writtenWrapper?.wrapper(with: "hello.txt")?.string(), "Hello World!")
        XCTAssertEqual(writtenWrapper?.wrapper(with: "hello.jpeg")?.image()?.size, testImg.size) // More or less enough
        
        let dict = writtenWrapper?.wrapper(with: "hello.plist")?.dictionary() as? [String: Any]
        XCTAssertNotNil(dict)
        XCTAssertEqual(dict?["Name"] as? String, (testDict["Name"] as! String))
        XCTAssertEqual(dict?["Version"] as? Int, (testDict["Version"] as! Int))
        XCTAssertEqual(dict?["Platforms"] as? [String], (testDict["Platforms"] as! [String]))
        
        try FileManager.default.removeItem(at: url)
    }
    
    func testWriteFileToURL() throws {
        // This is a test case for testing write(to:) method on regular file wrappers
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("hello.txt")
        let fileWrapper = LSFileWrapper(file: ())
        fileWrapper.update(newContent: "Hello World!" as NSString)

        try fileWrapper.write(to: url)
        
        let writtenFileWrapper = LSFileWrapper(url: url, isDirectory: false)
        
        XCTAssertNotNil(writtenFileWrapper)
        
        XCTAssert(writtenFileWrapper?.isDirectory == false)
        
        XCTAssertEqual(writtenFileWrapper?.data(), Data("Hello World!".utf8))
        XCTAssertEqual(writtenFileWrapper?.string(), "Hello World!") // This sets the type
        XCTAssertNil(writtenFileWrapper?.data()) // So here data() should be nil
        
        try FileManager.default.removeItem(at: url)
    }
    
    func testInitWithContentsAutomaticDirDiscovery() throws {
        // This is a test case for testing initializer's isDirectory property
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("testAutoDir.package")
        let wrapper = LSFileWrapper(directory: ())
        wrapper.add(content: "Hello World!" as NSString, withFilename: "hello.txt")

        try wrapper.write(to: url)
        
        let writtenWrapper = LSFileWrapper(url: url, isDirectory: false)
        
        XCTAssertNotNil(writtenWrapper)
        
        XCTAssert(writtenWrapper?.isDirectory == true)
        
        XCTAssertNotNil(writtenWrapper?.wrapper(with: "hello.txt"))
        XCTAssert(writtenWrapper?.wrapper(with: "hello.txt")?.isDirectory == false)
        
        try FileManager.default.removeItem(at: url)
    }
    
    func testWriteUpdatesToURL() throws {
        // This is a test case for testing writeUpdates(to:) method
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("testWriteUpdates.package")
        let wrapper = LSFileWrapper(directory: ())
        wrapper.add(content: "Hello World!" as NSString, withFilename: "hello.txt")

        try wrapper.write(to: url)
        
        let writtenWrapper = LSFileWrapper(url: url, isDirectory: true)
        
        XCTAssertNotNil(writtenWrapper)
        XCTAssert(writtenWrapper?.isDirectory == true)
        
        XCTAssertNotNil(writtenWrapper?.wrapper(with: "hello.txt"))
        XCTAssert(writtenWrapper?.wrapper(with: "hello.txt")?.isDirectory == false)
        
        XCTAssertEqual(writtenWrapper?.wrapper(with: "hello.txt")?.string(), "Hello World!")
        
        wrapper.wrapper(with: "hello.txt")?.update(newContent: "Hello Updated World!" as NSString)
        XCTAssertEqual(wrapper.wrapper(with: "hello.txt")?.string(), "Hello Updated World!")
        
        try wrapper.writeUpdates(to: url)
        
        let updatedWrapper = LSFileWrapper(url: url, isDirectory: true)
        
        XCTAssertNotNil(updatedWrapper)
        XCTAssert(updatedWrapper?.isDirectory == true)
        
        XCTAssertNotNil(updatedWrapper?.wrapper(with: "hello.txt"))
        XCTAssert(updatedWrapper?.wrapper(with: "hello.txt")?.isDirectory == false)
        
        XCTAssertEqual(updatedWrapper?.wrapper(with: "hello.txt")?.string(), "Hello Updated World!")
        
        try FileManager.default.removeItem(at: url)
    }
}
