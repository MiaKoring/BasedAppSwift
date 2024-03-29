//
//  File.swift
//  
//
//  Created by Mia Koring on 25.01.24.
//

import Foundation
import Security
import CoreFoundation

enum RSAKeySize: Int{
    case bit1024 = 1024
    case bit2048 = 2048
    case bit3072 = 3072
    case bit4096 = 4096
}

enum RSAError: Error{
    case keyGenerationError
    case encryptionInvalidArgumentError(String)
    case publicKeyRetrievalError
    case encryptionError
    case decryptionError
}

///Contains PublicKey for RSA as base64 endcoded String and a private key as reference
struct RSAKeypair{
    public let publicKey: String
    public let privateKey: SecKey
}

///Implementation of the RSA Public Key encryption algorithm using the Security framework
class RSA{
    ///generates a PrivateKey and the fitting PublicKey, the PublicKey is representated as base64 encoded String, the PrivateKey is a Reference to a locally stored key anc can't be transmitted
    static func generateKeyPair(_ keySize: RSAKeySize)throws -> RSAKeypair{
        
        //parameters for rsakey with size set in function call
        let keyPairAttr: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA, kSecAttrKeySizeInBits as String: keySize.rawValue]
        
        //if generation of key succeeded
        if let privateKey: SecKey = SecKeyCreateRandomKey(keyPairAttr as CFDictionary, nil){
            
            //if extraction of publickey from privatekey succeeded
            if let publicKey = SecKeyCopyPublicKey(privateKey),
               let publicKeyRepresentation = SecKeyCopyExternalRepresentation(publicKey, nil) as? Data{
                
                //keypair with base64encoded public key and reference to privatekey
                let keyPair = RSAKeypair(publicKey: publicKeyRepresentation.base64EncodedString(), privateKey: privateKey.self)
                return keyPair
            }
        }
        throw RSAError.keyGenerationError
    }
    
    ///encrypts Data using OAEPSHA384
    static func encrypt(_ data: Data, publicKey: SecKey? = nil, publicKeyBase64: String? = nil, keySize: RSAKeySize = .bit2048)throws -> Data{
        //attributes needed to encrypt with the rsa keys 
        let keyAttr: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA, kSecAttrKeySizeInBits as String: keySize.rawValue, kSecAttrKeyClass as String: kSecAttrKeyClassPublic]
        var key: SecKey?
        if publicKey != nil{
            key = publicKey!
        }
        else if publicKeyBase64 != nil{
            if let data = Data(base64Encoded: publicKeyBase64!),
               let convertedKey = SecKeyCreateWithData(data as CFData, keyAttr as CFDictionary, nil){
                key = convertedKey
            }
        }
        //no key given -> Error
        else{
            throw RSAError.encryptionInvalidArgumentError("missing key")
        }
        if key == nil{
            key = nil
            throw RSAError.publicKeyRetrievalError
        }
        if let encrypted = SecKeyCreateEncryptedData(key!, .rsaEncryptionOAEPSHA384, data as CFData, nil){
            return encrypted as Data
        }
        //encryption failed
        throw RSAError.encryptionError
    }
    
    ///decrypts OAEPSHA384 encrypted Data
    static func decrypt(_ data: Data, privateKey: SecKey)throws -> Data{
        if let clear = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionOAEPSHA384, data as CFData, nil){
            return clear as Data
        }
        //decryption failed
        throw RSAError.decryptionError
    }
}

