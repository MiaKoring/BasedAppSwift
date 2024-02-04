//
//  File.swift
//  
//
//  Created by Mia Koring on 19.01.24.
//

import Foundation
import CryptoKit

enum EncryptionAlgorithmType{
    case aes
    case rsa
}

enum CryptoManagerError: Error{
    case encryptionError(EncryptionAlgorithmType)
    case decryptionError(EncryptionAlgorithmType)
    case emptyKeyError(EncryptionAlgorithmType, String)
    case base64DecodingError
    case unexpectedEncryptionError(EncryptionAlgorithmType, Error? = nil)
    case unexpectedDecryptionError(EncryptionAlgorithmType, Error? = nil)
    case rsaKeygenError(Error)
}

protocol Encryptable {
    static func encrypt(data: Data, using algorithm: EncryptionAlgorithmType, symmetricKey: SymmetricKey?, publicKeyBase64: String?)throws -> String
    static func decrypt(base64encodedString: String, using algorithm: EncryptionAlgorithmType, symmetricKey: SymmetricKey?, privateKey: SecKey?)throws -> Data
}

///contains all cryptography related methods needed for basedApp
public class CryptoManager: Encryptable{
    ///encrypts Data with either RSA or AES, AES is default
    static func encrypt(data: Data, using algorithm: EncryptionAlgorithmType = .aes, symmetricKey: SymmetricKey? = nil, publicKeyBase64: String? = nil)throws -> String {
        switch algorithm{
        case .aes:
            if symmetricKey == nil{
                throw CryptoManagerError.emptyKeyError(.aes, "symmetricKey missing in function call")
            }
            do{
                if let combinedEnc = try AES.GCM.seal(data, using: symmetricKey!).combined{
                    return combinedEnc.base64EncodedString()
                }
                throw CryptoManagerError.unexpectedEncryptionError(.aes)
            }
            catch let error{
                throw CryptoManagerError.unexpectedEncryptionError(.aes, error)
            }
            
        case .rsa:
            if publicKeyBase64 == nil{
                throw CryptoManagerError.emptyKeyError(.rsa, "publicKeyBase64 missing in function call")
            }
            do{
                let encrypted = try RSA.encrypt(data, publicKeyBase64: publicKeyBase64)
                return encrypted.base64EncodedString()
            }
            catch let error {
                throw CryptoManagerError.unexpectedEncryptionError(.rsa, error)
            }
        }
    }
    ///decrypts base64endcoded Data
    static func decrypt(base64encodedString: String, using algorithm: EncryptionAlgorithmType, symmetricKey: SymmetricKey? = nil, privateKey: SecKey? = nil)throws -> Data{
        switch algorithm{
        case .aes:
            if symmetricKey == nil{
                throw CryptoManagerError.emptyKeyError(.aes, "missing symmetricKey in function call")
            }
            do{
                if let data = Data(base64Encoded: base64encodedString){
                    let box = try AES.GCM.SealedBox(combined: data)
                    return try AES.GCM.open(box, using: symmetricKey!)
                }
                throw CryptoManagerError.base64DecodingError
            }
            catch let error{
                throw CryptoManagerError.unexpectedDecryptionError(.aes, error)
            }
            
        case .rsa:
            if privateKey == nil{
                throw CryptoManagerError.emptyKeyError(.rsa, "missing privateKey in function call")
            }
            do{
                if let data = Data(base64Encoded: base64encodedString){
                    let decrypted = try RSA.decrypt(data, privateKey: privateKey!)
                    return decrypted
                }
                throw CryptoManagerError.base64DecodingError
            }
            catch let error{
                throw CryptoManagerError.unexpectedDecryptionError(.rsa, error)
            }
            
        }
    }
    
     ///generates an 256 bit AES key
    static func genAESKey(keySize: SymmetricKeySize)-> SymmetricKey{
        return SymmetricKey(size: .bits256)
    }
    
    ///generates a keypair for asymmetric encryption using the rsa algorithm
    static func genRSAKeyPair(_ keySize: RSAKeySize)throws -> RSAKeypair{
        do{
            let pair = try RSA.generateKeyPair(keySize)
            return pair
        }
        catch let error{
            throw CryptoManagerError.rsaKeygenError(error)
        }
    }
}
