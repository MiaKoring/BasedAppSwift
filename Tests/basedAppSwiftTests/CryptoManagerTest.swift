//
//  CryptoManagerTest.swift
//  
//
//  Created by Mia Koring on 19.01.24.
//

import XCTest
@testable import BasedAppSwift
import CryptoKit

final class CryptoManagerTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        /*let pair = CryptoManager.genRSAKeyPair(keySizeInBits: 2048)
        print(pair.privateKey)
        print(pair.publicKey)*/
    }
    
    func testAES() throws{
        let encrypted = try CryptoManager.encrypt(data: "Hallo".data(using: .utf8)!, using: .aes, symmetricKey: SymmetricKey(data: Data(base64Encoded: "sd9lbTzerkLh5Xq/s9CbAd7n18D9WAOmEa6/3FIkMn8=")!))
        let decrypted = try CryptoManager.decrypt(base64encodedString: encrypted, using: .aes, symmetricKey: SymmetricKey(data: Data(base64Encoded: "sd9lbTzerkLh5Xq/s9CbAd7n18D9WAOmEa6/3FIkMn8=")!))
        XCTAssertTrue(String(data: decrypted, encoding: .utf8)! == "Hallo")
    }
    
    func testRSA() throws{
        let testMessage = "Hello".data(using: .utf8)
        let keypair = try CryptoManager.genRSAKeyPair(.bit2048)
        let encrypted = try CryptoManager.encrypt(data: testMessage!, using: .rsa, publicKeyBase64: keypair.publicKey)
        let decrypted = try CryptoManager.decrypt(base64encodedString: encrypted, using: .rsa, privateKey: keypair.privateKey)
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
