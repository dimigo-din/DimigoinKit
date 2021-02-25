//
//  FCMToken.swift
//  
//
//  Created by 변경민 on 2021/02/17.
//

import Foundation
import Alamofire
import SwiftyJSON

public enum DeviceTokenError: Error {
    case alreadyRegistered
    case noSuchDeviceToken
    case tokenExpired
    case unknown
}

public func registerFCMToken(_ accessToken: String, _ deviceToken:String, completion: @escaping (Result<Void, DeviceTokenError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization": "Bearer \(accessToken)"
    ]
    let parameters: [String:String] = [
        "deviceToken": "\(deviceToken)"
    ]
    let endPoint = "/fcm/token"
    let method: HTTPMethod = .post
    AF.request(rootURL+endPoint, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                completion(.success(()))
            case 404:
                completion(.failure(.noSuchDeviceToken))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}

public func deleteFCMToken(_ accessToken:String, completion: @escaping () -> Void) {
    let headers: HTTPHeaders = [
        "Authorization": "Bearer \(accessToken)"
    ]
    let endPoint = "/fcm/token"
    let method: HTTPMethod = .delete
    AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                completion()
            case 404:
                completion()
            default:
                completion()
            }
        }
    }
}
