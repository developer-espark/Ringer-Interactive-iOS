//
//  temp.swift
//  QRCodeScanner
//
//  Created by HariKrishna Kundariya on 25/01/21.
//

import UIKit

typealias Parameters = [String: Any]

class WebAPIManager: NSObject {
    
    class func makeAPIRequest(method: String = "POST", isFormDataRequest: Bool, header: [String : String], path: String, isImageUpload: Bool,images:[Media], params: [String:Any], baseUrl: String = baseURL, boundary:String, completion: @escaping (_ response: [AnyHashable: Any],_ status: Int) -> Void) {
        
        
        let baseURL = baseUrl + path

        var request = URLRequest(url: URL(string: baseURL)!)
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
        
        let session = URLSession.shared
        session.dataTask(with: request){ (data,response,error) in
            if let response = response{
                print(response)
            }

            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
                    completion(json ?? [:], json!["code"] as? Int ?? 200)
                } catch {
                    var dict = [AnyHashable: Any]()
                    dict["error"] = "Oops! Something went wrong. Please try again."
                    dict["status"] = 0
                    print(error)
                    completion(dict, 0)
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
