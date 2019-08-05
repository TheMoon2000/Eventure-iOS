//
//  EventureAPITests.swift
//  EventureAPITests
//
//  Created by Jia Rui Shan on 2019/5/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import XCTest
import SwiftyJSON

class EventureAPITests: XCTestCase {
    
    private let TIMEOUT = 7.0

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// Get user IP test & example (HTTP GET request).
    func testGetIP() {
        let expectation = XCTestExpectation(description: "Get IP test")
        
        let apiURL = URL(string: API_BASE_URL + "network/GetIP")!
        
        let task = CUSTOM_SESSION.dataTask(with: apiURL) {
            data, response, error in
            
            XCTAssertNil(error, "Error should be nil!");
            let ip = String(data: data!, encoding: .ascii)!
            
            if ip.components(separatedBy: ".").count == 4 {
                print("IP: \(ip).")
                expectation.fulfill()
            } else {
                XCTFail("Invalid IP.")
            }
            
        }
        
        task.resume()
        
        wait(for: [expectation], timeout: TIMEOUT)
    }

    /// Download file test & example.
    func testDownloadAPI() {
        let expectation = XCTestExpectation(description: "Download test")
        
        let parameters = ["filename": "examples/Unit sphere.pdf"]
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "download",
                           parameters: parameters)!
        
        var request = URLRequest(url: url)
        
        // HTTP POST method allows information to be passed to the API
        // as part of the request
        request.httpMethod = "POST"
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            XCTAssertNil(error, "Error should be nil!")
            
            let destination = CACHES.appendingPathComponent("Unit sphere.pdf")

            do {
                // Write the downloaded file to local storage
                try data!.write(to: destination)
                print("Wrote \(data!.count) bytes to \(destination.path)")
                
                // Clear up the temporary file
                try FileManager().removeItem(at: destination)
                
                expectation.fulfill()
            } catch {
                XCTFail("Unable to write file to destination '\(destination)'.")
            }
            
        }
        
        task.resume()
        
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    /// Upload file test & example.
    func testUploadAPI() {
        let expectation = XCTestExpectation(description: "Upload test")
        
        let parameters = ["path": "uploads/example file.pdf"]
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "upload",
                           parameters: parameters)!
        
        let resourceURL = Bundle.main.url(forResource: "Example file",
                                          withExtension: "pdf")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Authentication
        request.addAuthHeader()

        let task = CUSTOM_SESSION.uploadTask(with: request, fromFile: resourceURL) {
            data, response, error in
            
            XCTAssertNil(error, "Error should be nil!");
            
            if let msg = String(data: data!, encoding: .utf8) {
                print(msg)
                expectation.fulfill()
            } else {
                XCTFail("Returned message could not be parsed as string.")
            }
        }
        
        task.resume()
        
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testGetOrgInfo() {
        
        let expectation = XCTestExpectation(description: "Get org info")
        
        let url = URL.with(base: API_BASE_URL, API_Name: "account/GetOrgInfo", parameters: ["id": "社团"])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            XCTAssertNil(error, "error should be nil!")
            if let msg = String(data: data!, encoding: .utf8) {
                print(msg)
                expectation.fulfill()
            }
        }
        
        task.resume()
        
        wait(for: [expectation], timeout: TIMEOUT)
    }


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
