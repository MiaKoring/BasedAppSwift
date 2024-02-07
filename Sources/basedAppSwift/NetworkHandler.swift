import Alamofire
import Foundation

public class NetworkHandler {
    private var evaluators: [String: ServerTrustEvaluating]
    public var manager: ServerTrustManager
    
    public init(){
        self.evaluators = ["touchthegrass.de": PublicKeysTrustEvaluator()]
        self.manager = ServerTrustManager(evaluators: self.evaluators)
    }
    
    public func printCertificates(){
        print(Bundle.main.af.certificates)
    }
    
    public func getApiKey(_ session: Session, completion: @escaping (Result<String, Error>) -> Void) {
        let jsonParameters = ["recoveryCodes": [
            "8IVyt5SnYmLpuLDk",
            "DhjA2PKnd4OLTNFl",
            "A0jxxmMthNa6oNHB",
            "na2gK2Etfvn0Hitf",
            "GYpinMiHsDnjtRUZ"
        ]]
        
        session.request("https://touchthegrass.de/user/TOTP", method: .post, parameters: jsonParameters, encoder: JSONParameterEncoder.default, headers: HTTPHeaders(["Content-Type": "Application/json"])).responseString { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
