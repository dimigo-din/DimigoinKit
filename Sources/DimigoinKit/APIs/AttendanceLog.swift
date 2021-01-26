//
//  AttendanceLog.swift
//  DimigoinKit
//
//  Created by 변경민 on 2021/01/26.
//

import Foundation
import Alamofire
import SwiftyJSON

/// Attendance 모델 정의
public struct Attendance {
    public var id: String
    var name: String
    var currentLocation: Place
    init() {
        self.id = ""
        self.name = ""
        self.currentLocation = Place()
    }
    init(id: String, name: String, currentLocation: Place) {
        self.id = id
        self.name = name
        self.currentLocation = currentLocation
    }
}

/// Attendance API 에러 타입 정의
public enum AttendanceError: Error {
    case noSuchPlace
    case notRightTime
    case tokenExpired
    case unknown
}
    
/// 사용자의 위치를 설정합니다 ([POST] /attendance-log)
public func setUserPlace(_ accessToken:String, placeName: String, places: [Place], completion: @escaping (Result<Bool, AttendanceError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let parameters: [String: String] = [
        "place": name2Place(name: placeName, from: places).id,
        "remark": name2Place(name: placeName, from: places).label
    ]
    let endPoint = "/attendance-log"
    let method: HTTPMethod = .post
    AF.request(rootURL+endPoint, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                completion(.success(true))
            case 400:
                completion(.failure(.noSuchPlace))
            case 401:
                completion(.failure(.tokenExpired))
            case 423:
                completion(.failure(.notRightTime))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}
    
/// 간단한 메세지와 함께 사용자의 위치를 설정합니다 ([POST] /attendance-log)
public func setUserPlace(_ accessToken:String, placeName: String, places: [Place], remark: String, completion: @escaping (Result<Bool, AttendanceError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let parameters: [String: String] = [
        "place": name2Place(name: placeName, from: places).id,
        "remark": remark
    ]
    let endPoint = "/attendance-log"
    let method: HTTPMethod = .post
    AF.request(rootURL+endPoint, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                completion(.success(true))
            case 400:
                completion(.failure(.noSuchPlace))
            case 401:
                completion(.failure(.tokenExpired))
            case 423:
                completion(.failure(.notRightTime))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}
    
/// 사용자 교실 학생들의 현황을 불러옵니다. ([GET] /attendance-log/class-status)
public func fetchAttandence(_ accessToken: String, user: User, completion: @escaping (Result<([Attendance]), AttendanceError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let endPoint = "/attendance-log/class-status/date/\(getToday8DigitDateString())/grade/\(user.grade)/class/\(user.klass)"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: URLEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                let json = JSON(response.value!!)
                completion(.success(json2AttendanceList(attendances: json["classLogs"])))
            case 401:
                completion(.failure(.tokenExpired))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}
 
/// json 데이터를 Attendance List로 변환하여 반환해 줍니다.
public func json2AttendanceList(attendances: JSON) -> [Attendance]{
//    var attendanceList: [Attendance] = []
//    for i in 0..<attendanceList.count {
//        Attendance(id: attendances[i][], name: <#T##String#>, currentLocation: <#T##Place#>)
//    }
    return []
}
    
/// 자신의 최근 위치를 조회합니다. ([GET] /attendance-log/my-status)
/// 정보가 없다면, 교실을 default값으로 지정합니다.
public func fetchMyCurrentPlace(_ accessToken: String, places: [Place], myPlaces: [Place], completion: @escaping (Result<(Place),AttendanceError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let endPoint = "/attendance-log/my-status"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                let json = JSON(response.value!!)
                if let myCurrentPlace = json["myLogs"][0]["place"]["_id"].string {
                    completion(.success(id2Place(id: myCurrentPlace, from: places)))
                } else {
                    completion(.success(label2Place(label: "교실", from: myPlaces)))
                }
            case 401:
                completion(.failure(.tokenExpired))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}
