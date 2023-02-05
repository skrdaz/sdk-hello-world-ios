//
//  SpeakUp.swift
//  XYZHelloWorld
//
//  Created by Admin on 05/02/23.
//

import Foundation
import Alamofire

class SpeakUp {
    
    var delegate: SpeakUpListener?
    
    func sayHello() -> String {
        return "say hello"
    }
    
    func callApi(url:String, param: [String:String]) {

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

protocol SpeakUpListener {
    
    func onResponse(_ responseStr: String)
}
