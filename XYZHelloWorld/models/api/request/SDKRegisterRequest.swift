//
//  SDKRegisterRequest.swift
//  nhworld
//
//  Created by Admin on 18/01/23.
//

import Foundation

struct SDKRegisterRequest: Codable {
    
     var req_id: String?
     var ins_id: String?
     var sdk_type: String?
     var sdk_os: String?
     var sdk_version_code: Int?
     var sdk_version: String?
     var platform = "IOS"
     var device_type: String?
     var device_vendor: String?
     var pub_key: String?
}
