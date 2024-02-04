import Alamofire
import Foundation

public class NetworkHandler {
    private var evaluators: [String: ServerTrustEvaluating]
    private var manager: ServerTrustManager
    
    public init(){
        self.evaluators = ["touchthegrass.de": PublicKeysTrustEvaluator()]
        self.manager = ServerTrustManager(evaluators: self.evaluators)
    }
    
    public func printCertificates(){
        print(Bundle.main.af.certificates)
    }
    
    public func getApiKey()async throws -> Void{
        let session = Session(serverTrustManager: self.manager)
        let jsonParameters = ["token": "u20eYvGHpUk082x8P5qEVXizcVKcnDYk"]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonParameters)
            let result = session.request("https://touchthegrass.de/token/iosApp", parameters: jsonData, headers: HTTPHeaders(["token": "u20eYvGHpUk082x8P5qEVXizcVKcnDYk"])).response
            print(result)
        } catch {
            print("Fehler bei der JSON-Serialisierung: \(error)")
        }
        
    }
    
}
