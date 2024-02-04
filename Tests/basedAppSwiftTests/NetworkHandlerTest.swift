//
//  NetworkHandlerTest.swift
//  
//
//  Created by Mia Koring on 04.02.24.
//

import XCTest
@testable import BasedAppSwift

final class NetworkHandlerTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let handler = NetworkHandler()
        handler.printCertificates()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
