import UIKit

typealias Parameters = [String: Any]
var mainURL = ""

class WebAPIManager: NSObject {
    
    class func makeAPIRequest(method: String = "POST", isFormDataRequest: Bool, header: [String : String], path: String, isImageUpload: Bool,images:[Media], auth: Bool = false, authDic: [String:Any] = [:], params: [String:Any], baseUrl: String = baseURL, boundary:String, completion: @escaping (_ response: [AnyHashable: Any],_ status: Int) -> Void) {
        
        if GlobalFunction.getBaseUrl() != "" {
            mainURL = GlobalFunction.getBaseUrl() + "/" + path
        } else {
            mainURL = baseUrl + path
        }

        var request = URLRequest(url: URL(string: mainURL)!)
        request.httpMethod = method
        
        if header.count > 0{
            for i in 0..<header.count{
                request.addValue(Array(header.values)[i], forHTTPHeaderField: Array(header.keys)[i])
            }
        }
        
        if isImageUpload{
            let dataBody = WebAPIManager().createDataBody(withParameters: params, media: images, boundary: boundary)
            request.httpBody = dataBody
        }else{
            if method == "GET" {
                
            } else {
                guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
                    return
                }
                request.httpBody = httpBody
            }
        }
        
        if auth {
            request.setBasicAuth(username: ((authDic["username"] as? String) ?? ""), password: ((authDic["password"] as? String) ?? ""))
        }
        
        let session = URLSession.shared
        session.dataTask(with: request){ (data,response,error) in
            if let data = data {
                do {
                    if mainURL == "\(String(describing: response!.url!))" {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
                        completion(json ?? [:], (json!["code"] as? Int) ?? 200)
                    } else {
                        var dict = [AnyHashable: Any]()
                        dict["imgUrl"] = response?.url
                        completion(dict, (response as? HTTPURLResponse)?.statusCode ?? 200)
                    }
                    
                } catch {
                    var dict = [AnyHashable: Any]()
                    dict["error"] = "Oops! Something went wrong. Please try again."
                    if (((response as? HTTPURLResponse)?.statusCode) ?? 0) == 409 || (((response as? HTTPURLResponse)?.statusCode) ?? 0) == 204{
                        dict["status"] = (((response as? HTTPURLResponse)?.statusCode) ?? 0)
                        completion(dict, (((response as? HTTPURLResponse)?.statusCode) ?? 0))
                    } else {
                        print(error)
                        dict["status"] = 0
                        completion(dict, 0)
                    }
                }
            }
        }.resume()
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value as! String + lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
}

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = "kyleleeheadiconimage234567.jpg"
        
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        self.data = data
    }
    
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension URLRequest {
    mutating func setBasicAuth(username: String, password: String) {
        let encodedAuthInfo = String(format: "%@:%@", username, password)
            .data(using: String.Encoding.utf8)!
            .base64EncodedString()
        addValue("Basic \(encodedAuthInfo)", forHTTPHeaderField: "Authorization")
    }
}

class BackgroundSession: NSObject {
    static let shared = BackgroundSession()
    
    static let identifier = "com.domain.app.bg"
    
    private var session: URLSession!

    #if !os(macOS)
    var savedCompletionHandler: (() -> Void)?
    #endif
    
    private override init() {
        super.init()
        
        let configuration = URLSessionConfiguration.background(withIdentifier: BackgroundSession.identifier)
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func start(_ request: URLRequest) {
        session.downloadTask(with: request).resume()
    }
}

extension BackgroundSession: URLSessionDelegate {
    #if !os(macOS)
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.savedCompletionHandler?()
            self.savedCompletionHandler = nil
        }
    }
    #endif
}

extension BackgroundSession: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            // handle failure here
            print("\(error.localizedDescription)")
        }
    }
}

extension BackgroundSession: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            let json = try JSONSerialization.jsonObject(with: data)
            
            print("\(json)")
            // do something with json
        } catch {
            print("\(error.localizedDescription)")
        }
    }
}
