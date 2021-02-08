//
//  Notice.swift
//  
//
//  Created by 변경민 on 2021/02/07.
//

import Foundation
import SwiftyJSON
import Alamofire

public enum NoticeError: Error {
    case tokenExpired
    case unknown
}

public func getRecentNotice(_ accessToken: String, completion: @escaping (Result<String, NoticeError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let endPoint = "/notice"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                let json = JSON(response.value!!)
                let notice: String = ""
//                json2PlaceList(places: json["places"]))
                completion(.success(notice))
            case 401:
                completion(.failure(.tokenExpired))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}
