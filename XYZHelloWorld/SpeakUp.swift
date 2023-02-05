//
//  SpeakUp.swift
//  XYZHelloWorld
//
//  Created by Admin on 05/02/23.
//

import Foundation
import Alamofire

public class SpeakUp {
    
    public var delegate: SpeakUpListener?
    
    public init() {
        
    }

    
    public func sayHello() -> String {
        return "say hello"
    }
    
    public func callApi(url:String, param: [String:String]) {

        let headers: HTTPHeaders = []
        let request = AF.request(url, method: .post, parameters: param, encoder: JSONParameterEncoder.default, headers: headers)
        request.validate(statusCode: 200 ..< 299).responseString() { response in
            switch response.result {
            case .success(let data):
                self.delegate?.onResponse(data)
            case .failure(let error):
                self.delegate?.onResponse(error.localizedDescription)
            }
        }
    }
}

public protocol SpeakUpListener {
    
    func onResponse(_ responseStr: String)
}
