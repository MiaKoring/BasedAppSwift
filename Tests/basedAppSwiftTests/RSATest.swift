//
//  RSATest.swift
//  
//
//  Created by Mia Koring on 25.01.24.
//

import XCTest
@testable import BasedAppSwift

final class RSATest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRSAKeyGeneration() throws{
        let keypair = try RSA.generateKeyPair(.bit2048)
        print(keypair)
    }
    
    func testRSAEncDec() throws{
        let keypair = try RSA.generateKeyPair(.bit2048)
        let testStr = "Hello".data(using: .utf8)
        let encrypted = try RSA.encrypt(testStr!, publicKeyBase64: keypair.publicKey)
        let decrypted = try RSA.decrypt(encrypted, privateKey: keypair.privateKey)
        let decryptedString = String(data: decrypted, encoding: .utf8)
        XCTAssertTrue( "Hello" == decryptedString)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
