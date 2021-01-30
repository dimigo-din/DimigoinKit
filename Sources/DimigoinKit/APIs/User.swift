//
//  UserAPI.swift
//  DimigoinKitDemo
//
//  Created by 변경민 on 2021/01/26.
//

import SwiftUI
import Alamofire
import SwiftyJSON

/// 사용자 모델 정의
public struct User {
    public var name: String = ""
    public var idx: Int = 0
    public var type: UserType = .student
    public var grade: Int = 1
    public var klass: Int = 1
    public var number: Int = 0
    public var serial: Int = 0
    public var photoURL: URL = URL(string: "https://api.dimigo.hs.kr/")!
}

/// 유저 타입(선생님, 학생)
public enum UserType {
    case teacher
    case student
}

/// UserAPI 에러 타입
public enum UserError: Error {
    case tokenExpired
    case unknown
}

/// 사용자 정보를 가져옵니다.
public func getUserData(_ accessToken: String, completion: @escaping (Result<(User), UserError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization": "Bearer \(accessToken)"
    ]
    let endPoint = "/user/me"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                let json = JSON(response.value!!)
                let user = User(name: json["identity"]["name"].string!,
                     idx: json["identity"]["idx"].int!,
                     type: .student,
                     grade: json["identity"]["grade"].int!,
                     klass: json["identity"]["class"].int!,
                     number: json["identity"]["number"].int!,
                     serial: json["identity"]["serial"].int!,
                     photoURL: URL(string: "https://api.dimigo.hs.kr/user_photo/\(json["identity"]["photo"][0].string ?? "")")!)
                completion(.success(user))
            case 401:
                completion(.failure(.tokenExpired))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}

/// 반에 따른 학과를 반환합니다.
public func getMajorByClass(klass: Int) -> String {
    switch klass {
        case 1: return "이비즈니스과"
        case 2: return "디지털컨텐츠과"
        case 3: return "웹프로그래밍과"
        case 4: return "웹프로그래밍과"
        case 5: return "해킹방어과"
        case 6: return "해킹방어과"
        default: return "N/A"
    }
}
