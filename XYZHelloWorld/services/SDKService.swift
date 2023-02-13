//
//  SDKService.swift
//  nhworld
//
//  Created by Admin on 18/01/23.
//

import Foundation
import Alamofire

// https://johncodeos.com/how-to-make-post-get-put-and-delete-requests-with-alamofire-using-swift

class SDKService {
    
    let encryptor = SDKEncryptor()
    
    var delegate: FaceServiceListener?
    
    func setup(reqId:String, timeout:Int) {
        let user = UserDefaults.standard
        user.setValue(reqId, forKey: "req_id")
        if user.string(forKey: "privatesdkf") == nil && user.string(forKey: "publicsdkf") == nil && user.string(forKey: "publicsdkfsrv") == nil {
            register(reqId: reqId)
            print("register cause nil")
        } else if user.string(forKey: "privatesdkf")!.isEmpty && user.string(forKey: "publicsdkf")!.isEmpty && user.string(forKey: "publicsdkfsrv")!.isEmpty {
            register(reqId: reqId)
            print("register cause empty")
        } else {
            auth()
            print("auth")
        }
    }

    // sdk/register
    func register(reqId:String) {
        encryptor.initialize()
        let user = UserDefaults.standard
        var body = SDKRegisterRequest()
        body.req_id = reqId
        body.ins_id = user.string(forKey: "ins_id")
        body.pub_key = user.string(forKey: "publicsdkf")
        let param = [
            "req_id": reqId,
            "ins_id": user.string(forKey: "ins_id"),
            "pub_key": user.string(forKey: "publicsdkfx509"),
            "platform": "iOS",
            "device_type": DeviceUtils.modelIdentifier(),
            "device_vendor": "apple"
        ]
        let headers: HTTPHeaders = []
        let request = AF.request(SDKConstant.init().baseUrl + "/sdk/register", method: .post, parameters: param, encoder: JSONParameterEncoder.default, headers: headers)
        request.validate(statusCode: 200 ..< 299).responseString() { response in
            switch response.result {
            case .success(let data):
                if data.isEmpty {
                    self.delegate?.onAuthFailed(1000, "empty response")
                    print("reponse empty")
                    return
                }
                if let messageDecrypted = self.encryptor.decryptTextLong(message: data) {
                    do {
                        let register = try JSONDecoder().decode(BaseResponse<RegisterResponse>.self, from: Data(messageDecrypted.utf8))
                        let registerCode = register.code
                        // is positive
                        if (200 != registerCode) {
                            self.delegate?.onAuthFailed(registerCode, "cannot get result response")
                            return
                        }
                        if let result = register.result, let pkey = result.pub_key {
                            // is positive
                            if pkey.isEmpty {
                                self.delegate?.onAuthFailed(1001, "cannot get result public key")
                                return
                            }
                            // is positive case start
                            print("response code \(register.code) pub \(pkey) end")
                            //
                            user.setValue(pkey, forKey: "publicsdkfsrv")
                            //
                            print("response code end")
                            // is positive case end
                            self.auth()
                            return
                        }
                        self.delegate?.onAuthFailed(1002, "cannot get result response")
                    } catch {
                        self.delegate?.onAuthFailed(1003, error.localizedDescription)
                    }
                    return
                }
                self.delegate?.onAuthFailed(1004, "failed convert body response")
            case .failure(let error):
                print(error)
                self.delegate?.onAuthFailed(1005, error.localizedDescription)
            }
        }
    }
    
    // sdk/auth
    func auth() {
        encryptor.initialize()
        let user = UserDefaults.standard
        //
        var headers: HTTPHeaders = [.init(name: "ins", value: user.string(forKey: "ins_id")!)]
        headers.add(name:  "Content-Type", value: "text/plain")
        var requestAuth = SDKAuthRequest()
        requestAuth.req_id = user.string(forKey: "req_id")
        do {
            let encodedData = try JSONEncoder().encode(requestAuth)
            let jsonString = String(data: encodedData, encoding: .utf8)
            // encrypt data
            if let message = encryptor.encryptTextLongServer(message: jsonString!) {
                print("auth message encrypted \(message)")
                let request = AF.request(SDKConstant.init().baseUrl + "/sdk/auth", method: .post, parameters: [:], encoding: message, headers: headers)
                request.validate(statusCode: 200 ..< 299).responseString() { response in
                    switch response.result {
                    case .success(let data):
                        if data.isEmpty {
                            self.delegate?.onAuthFailed(1000, "empty response")
                            print("reponse empty")
                            return
                        }
                        if let messageDecrypted = self.encryptor.decryptTextLong(message: data) {
                            do {
                                let replaced = messageDecrypted.replacingOccurrences(of: "\0", with: "")
                                let register = try JSONDecoder().decode(BaseResponse<AuthResponse>.self, from: Data(replaced.utf8))
//                                print("auth response \(register)")
                                let registerCode = register.code
                                // is positive
                                if (200 != registerCode) {
                                    self.delegate?.onAuthFailed(registerCode, "cannot get result response")
                                    return
                                }
                                if let result = register.result, let req_id = result.req_id {
                                    // is positive
                                    if req_id.isEmpty {
                                        self.delegate?.onAuthFailed(1001, "cannot get result public key")
                                        return
                                    }
                                    // is positive case start
                                    // print("response code \(register.code) pub \(req_id) end")
                                    // is positive case end
                                    self.delegate?.onAuthSuccess(req_id)
                                    return
                                }
                                self.delegate?.onAuthFailed(1002, "cannot get result response")
                            } catch {
                                print("error \(error.localizedDescription)")
                                self.delegate?.onAuthFailed(1003, error.localizedDescription)
                            }
                            return
                        }
                        self.delegate?.onAuthFailed(1004, "failed convert body response")
                    case .failure(let error):
                        print("error \(error)")
                        self.delegate?.onAuthFailed(1005, error.localizedDescription)
                    }
                }
            }
        } catch {
            print(error)
        }
        
    }
    
    // sdk/verify
    func verify(image: UIImage) {
        print("start verify image")
        encryptor.initialize()
        let user = UserDefaults.standard
        let param = [
            "req_id": encryptor.encryptTextLongServer(message: user.string(forKey: "req_id")!),
            "ins_id": encryptor.encryptTextLongServer(message: user.string(forKey: "ins_id")!),
            "image": convertImageToBase64String(img: image)
        ]
        let headers: HTTPHeaders = []
        let request = AF.request(SDKConstant.init().baseUrl + "/sdk/verify-liveness-ios", method: .post, parameters: param, encoder: JSONParameterEncoder.default, headers: headers)
        request.validate(statusCode: 200 ..< 299).responseString() { response in
            switch response.result {
            case .success(let data):
                print("reponse success verify")
                if data.isEmpty {
                    self.delegate?.onVerifyFailed(1000, "empty response")
                    print("reponse empty")
                    return
                }
                if let messageDecrypted = self.encryptor.decryptTextLong(message: data) {
                    do {
                        let replaced = messageDecrypted.replacingOccurrences(of: "\0", with: "")
                        let verify = try JSONDecoder().decode(BaseResponse<VerifyResponse>.self, from: Data(replaced.utf8))
                        print("verify response \(verify)")
                        let registerCode = verify.code
                        // is positive
                        if (200 != registerCode) {
                            self.delegate?.onVerifyFailed(registerCode, "cannot get result response")
                            return
                        }
                        self.delegate?.onVerifySuccess(verify)
                        return
                    } catch {
                        print("error \(error.localizedDescription)")
                        self.delegate?.onVerifyFailed(1003, error.localizedDescription)
                    }
                    return
                }
                self.delegate?.onVerifyFailed(1004, "failed convert body response")
            case .failure(let error):
                print("reponse error verify")
                print("error \(error)")
                self.delegate?.onVerifyFailed(1005, error.localizedDescription)
            }
        }
    }
    
    // utilities
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
}

protocol FaceServiceListener {
    
    func onAuthSuccess(_ reqId: String)
    
    func onAuthFailed(_ code:Int, _ message:String)
    
    func onVerifySuccess(_ verify: BaseResponse<VerifyResponse>)
    
    func onVerifyFailed(_ code:Int, _ message:String)
    
}
