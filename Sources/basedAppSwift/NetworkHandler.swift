import Alamofire
import Foundation

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
    
    public func createUser(_ session: Session, loginMethod: LoginMethod, recoveryCodes: [String], completion: @escaping (Result<String, Error>) -> Void) {
        let jsonParameters = ["recoveryCodes": recoveryCodes]
        
        session.request("https://\(self.host)/user/\(loginMethod.rawValue)", method: .post, parameters: jsonParameters, encoder: JSONParameterEncoder.default, headers: HTTPHeaders(["Content-Type": "Application/json"])).responseString { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func loginWithDevice(_ session: Session, loginMethod: LoginMethod, login: Login, publicKey: String, deviceID: String){
        switch login{
        case .TOTP(let id, let code):
            let jsonParameters: [
                "userId": id,
                "totp": code,
                "publicKey": publicKey,
                "deviceID": deviceID
            ]
            session.request("https://\(self.host)/device/\(loginMethod.rawValue)", method: .post, parameters: jsonParameters, encoder: JSONParameterEncoder.default, headers: HTTPHeaders(["Content-Type": "Application/json"])).responseString { response in
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
    
}

public enum LoginMethod: String{
    case TOTP = "TOTP"
    case mail = "mail"
}

public enum Login{
    case TOTP(Int, String)
    case mail(String, String)
}
