//
//  BaseResponse.swift
//  nhworld
//
//  Created by Admin on 16/01/23.
//

import Foundation

struct BaseResponse<T : Codable>: Codable {
    
    let code: Int
    
    let message: String
    
    let result: T?
    
}
