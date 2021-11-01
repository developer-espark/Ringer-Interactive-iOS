import UIKit

extension RingerInteractiveNotification {
    
    public func ringerInteractiveLogin(username: String, password: String) {
        var header: [String : String] = [:]
        header["Content-Type"] = "application/json"
        header["Username"] = username
        header["Password"] = password
        
        let boundary = WebAPIManager().generateBoundary()
        
        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: Constant.Api.token_with_authorities, isImageUpload: false, images: [], params: [:], baseUrl: "https://sandbox.thrio.io/", boundary: boundary) { response, status in
            if status == 200 {
                let responseDataDic = response as! [String :Any]
                baseURL = "\(responseDataDic["location"] ?? "")/"
                UserDefaults.standard.set("\(responseDataDic["token"] ?? "")/", forKey: Constant.localStorage.token)
                UserDefaults.standard.set("\(responseDataDic["location"] ?? "")/", forKey: Constant.localStorage.baseUrl)
                ringerInteractiveGetContact()
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
    }
    
    func ringerInteractiveGetContact() {
        
        var header: [String : String] = [:]
        header["Content-Type"] = "application/json"
        header["Authorization"] = GlobalFunction.getUserToken()
        
        let boundary = WebAPIManager().generateBoundary()
        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: Constant.Api.getContact, isImageUpload: false, images: [], params: [:], boundary: boundary) { response, status in
            if status == 200 {
                let responseDataDic = response as! [String :Any]
                print(responseDataDic)
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
    }
}
