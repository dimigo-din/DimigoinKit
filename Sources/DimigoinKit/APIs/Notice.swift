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

public struct Notice {
    public var title: String
    public var content: String
}

public func getRecentNotice(_ accessToken: String, completion: @escaping (Result<[Notice], NoticeError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let endPoint = "/notice/current"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                let json = JSON(response.value!!)
                let notices = json2Notice(json: json)
                completion(.success(notices))
            case 401:
                completion(.failure(.tokenExpired))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}

public func json2Notice(json: JSON) -> [Notice] {
    var notices: [Notice] = []
    for i in 0..<json["notices"].count {
        notices.append(Notice(title: json["notices"][i]["title"].string!,
                              content: json["notices"][i]["content"].string!))
    }
    return notices.reversed()
}
