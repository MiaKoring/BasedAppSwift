import Alamofire
import Foundation
import SwiftUI

public class NetworkHandler {
    private var evaluators: [String: ServerTrustEvaluating]
    public var manager: ServerTrustManager
    public let host: String
    
    public init(host: String){
        self.evaluators = [host: PublicKeysTrustEvaluator()]
        self.manager = ServerTrustManager(evaluators: self.evaluators)
        self.host = host
    }
    
    public func printCertificates(){
        print(Bundle.main.af.certificates)
    }
    
    ///sends a usercreation request
    public func createUser(_ session: Session, loginMethod: LoginMethod, recoveryCodes: [String], completion: @escaping (Result<String, Error>) -> Void) {
        let jsonParameters = ["recoveryCodes": recoveryCodes]
        
        session.request("https://\(self.host)/user/\(loginMethod.rawValue)", method: .post, parameters: jsonParameters, encoder: JSONParameterEncoder.default, headers: HTTPHeaders()).responseString { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    ///tries to register a device
    public func loginWithDevice(_ session: Session, loginMethod: LoginMethod, login: Login, publicKey: String, deviceID: String, completion: @escaping (Result<String, Error>) -> Void){
        switch login{
        case .TOTP(let id, let code):
            let login = UserLoginTOTP(userID: id, totp: code, publicKey: publicKey, deviceID: deviceID)
            session.request("https://\(self.host)/device/\(loginMethod.rawValue)", method: .post, parameters: login, encoder: JSONParameterEncoder.default, headers: HTTPHeaders()).responseString { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            break
        case .mail(let mail, let password):
            break
        }
    }
    //TODO:
    public func sendMessage(_ session: Session, token: String, completion: @escaping (Result<String, Error>) -> Void) async throws {
        session.request("https://\(self.host)/messages/send", method: .post, headers: HTTPHeaders([.authorization(bearerToken: token)])).responseString { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
            
    }
    
    public func downloadAttachment(_ session: Session, token: String, fileUUID: String, progressBinding: @Binding Double?)async {
        let downloadURL = "https://\(self.host)/files/\(fileUUID)"
           let destination: DownloadRequest.Destination = { _, _ in
               let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
               let fileURL = documentsURL.appendingPathComponent("\(fileUUID).txt")
               return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
           }

           do {
               let response = try await AF.download(downloadURL, to: destination)
                   .downloadProgress { progress in
                       progressBinding.wrappedValue = progress.fractionCompleted
                       print("Download Progress: \(progress.fractionCompleted)")
                   }
                   .response(){response in
                       debugPrint(response)
                   }
           } catch {
               print("Error downloading file: \(error)")
           }
    }
    
}

public enum LoginMethod: String{
    case TOTP = "TOTP"
    case mail = "mail"
}

public enum Login{
    case TOTP(Int, String)
    case mail(String, String)
}

struct UserLoginTOTP: Codable{
    let userID: Int
    let totp: String
    let publicKey: String
    let deviceID: String
}

public struct UserCreation: Codable {
    public let userID: Int
    public let access: String
}
