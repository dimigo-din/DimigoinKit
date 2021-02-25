//
//  AttendanceLog.swift
//  DimigoinKit
//
//  Created by 변경민 on 2021/01/26.
//

import Foundation
import Alamofire
import SwiftyJSON

/**
 사용자 인원체크 모델

 - id: 사용자 id
 - name: 이름
 - currentLoaction: 장소
 */
public struct Attendance: Hashable {
    public var id: String
    public var name: String
    public var grade: Int
    public var klass: Int
    public var number: Int
    public var attendanceLog: [Place]
    public var timeline: [String]
    public var isEnrolled: Bool
    public init() {
        self.id = ""
        self.name = ""
        self.grade = 0
        self.klass = 0
        self.number = 0
        self.attendanceLog = []
        self.timeline = []
        self.isEnrolled = false
    }
    public init(id: String, name: String, grade: Int, klass: Int, number: Int, attendanceLog: [Place], timeline: [String], isEnrolled: Bool) {
        self.id = id
        self.name = name
        self.grade = grade
        self.klass = klass
        self.number = number
        self.attendanceLog = attendanceLog
        self.timeline = timeline
        self.isEnrolled = isEnrolled
    }
}

/**
 사용자 인원체크 에러 타입

 - noSuchPlace: 요청한 장소가 없음
 - notRightTime: 인원체크 시간이 아님
 - tokenExpired: 토큰 만료
 - unknown: 알 수 없는 에러(500)
 */
public enum AttendanceError: Error {
    case noSuchPlace
    case notRightTime
    case tokenExpired
    case unknown
}
    
/**
 사용자 인원체크
 
 - Parameters:
    - accessToken: 토큰
    - placeName: 장소 이름
    - plalces: 장소 리스트
 
 - returns: Result<Bool, AttendanceError>
 
 # API Method #
 `POST`
 
 # API EndPoint #
 `{rootURL}/attendance-log`
 
 # 사용예시 #
 ```
 setUserPlace("accessToken here", placeName: "장소 이름", places: places) { result in
    
 }
 ```
 */
public func setUserPlace(_ accessToken:String, placeName: String, places: [Place], completion: @escaping (Result<Bool, AttendanceError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let parameters: [String: String] = [
        "place": findPlaceByName(name: placeName, from: places).id,
        "remark": findPlaceByName(name: placeName, from: places).label
    ]
    let endPoint = "/attendance"
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

/**
 간단한 메세지와 함께 사용자 인원체크
 
 - Parameters:
    - accessToken: 토큰
    - placeName: 장소 이름
    - places: 장소 리스트
 
 - returns: Result<Bool, AttendanceError>
 
 # API Method #
 `POST`
 
 # API EndPoint #
 `{rootURL}/attendance-log`
 
 # 사용예시 #
 ```
 setUserPlace("accessToken here", placeName: "장소 이름", places: places, remark: "이유") { result in
    
 }
 ```
 */
public func setUserPlace(_ accessToken:String, placeName: String, places: [Place], remark: String, completion: @escaping (Result<Bool, AttendanceError>) -> Void) {
    let endPoint = "/attendance"
    let requestBody = "{\"place\":\"\(findPlaceByName(name: placeName, from: places).id)\",\"remark\":\"\(remark)\"}"
    let jsonData = requestBody.data(using: .utf8, allowLossyConversion: false)!
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    var request = URLRequest(url: URL(string: "\(rootURL)\(endPoint)")!)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData
    request.headers = headers
    
    AF.request(request).response { response in
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

/**
 사용자 교실 학생들의 현황을 불러옵니다.
 
 - Parameters:
    - accessToken: 토큰
    - user: 사용자 정보
 
 - returns: Result<Bool, AttendanceError>
 
 # API Method #
 `GET`
 
 # API EndPoint #
 `{rootURL}/attendance-log/class-status/date/{yyyy-MM-dd}/grade/{grade}/class/{class}`
 
 # 사용예시 #
 ```
 getAttendenceList("accessToken here", user: User) { result in
    
 }
 ```
 */
public func getAttendenceList(_ accessToken: String, user: User, defaultPlace: Place, completion: @escaping (Result<([Attendance]), AttendanceError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let endPoint = "/attendance/date/\(getToday8DigitDateString())/grade/\(user.grade)/class/\(user.klass)"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: URLEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                let json = JSON(response.value!!)
                completion(.success(json2AttendanceList(json: json["status"], defaultPlace: defaultPlace)))
            case 401:
                completion(.failure(.tokenExpired))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}

public func getAttendenceList(_ accessToken: String, grade: Int, klass: Int, defaultPlace: Place, completion: @escaping (Result<([Attendance]), AttendanceError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let endPoint = "/attendance/date/\(getToday8DigitDateString())/grade/\(grade)/class/\(klass)"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: URLEncoding.default, headers: headers).response { response in
        debugPrint(response)
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                let json = JSON(response.value!!)
                completion(.success(json2AttendanceList(json: json["status"], defaultPlace: defaultPlace)))
            case 401:
                completion(.failure(.tokenExpired))
            default:
                completion(.failure(.unknown))
            }
        }
        
    }
}
 
/// json 데이터를 Attendance List로 변환하여 반환해 줍니다.
public func json2AttendanceList(json: JSON, defaultPlace: Place) -> [Attendance]{
    var attendanceList: [Attendance] = []
    for i in 0..<json.count {
        attendanceList.append(Attendance(id: json[i]["student"]["_id"].string!,
                               name: json[i]["student"]["name"].string!,
                               grade: json[i]["student"]["grade"].int!,
                               klass: json[i]["student"]["class"].int!,
                               number: json[i]["student"]["number"].int!,
                               attendanceLog: json2AttendanceLog(json: json["log"], defaultPlace: defaultPlace),
                               timeline: json2Timeline(json: json["log"]),
                               isEnrolled: json2Timeline(json: json["log"]).count == 0 ? false : true))
    }
    return attendanceList.sorted(by: {$0.number < $1.number})
}

public func json2AttendanceLog(json: JSON, defaultPlace: Place) -> [Place] {
    if json.count == 0 {
        return [defaultPlace]
    } else {
        var logs:[Place] = []
        for i in 0..<json.count {
            logs.append(Place(id: json["place"]["_id"].string!,
                              label: json["place"]["label"].string ?? "",
                              name: json["place"]["name"].string!,
                              location: json["place"]["location"].string!,
                              type: getPlaceType(json["place"]["type"].string!)))
        }
        return logs.reversed()
    }
}

public func json2Timeline(json: JSON) -> [String] {
    var timeline:[String] = []
    for i in 0..<json.count {
        let time = json["createdAt"].string!
        timeline.append("\(time[11..<13]):\(time[14..<16])")
    }
    return timeline.reversed()
}
    

/**
 자신의 최근 위치를 불러옵니다. 없다면, 교실을 반환합니다.
 
 - Parameters:
    - accessToken: 토큰
    - places: 장소 이름
    - myPlaces: 사용자 맞춤 장소 리스트
 
 - returns: Result<Bool, AttendanceError>
 
 # API Method #
 `GET`
 
 # API EndPoint #
 `{rootURL}/attendance/my-status`
 
 # 사용예시 #
 ```
 getAttendenceList("accessToken here", places: [Place], myPlaces: [Place]) { result in
    
 }
 ```
 */
public func getUserCurrentPlace(_ accessToken: String, places: [Place], myPlaces: [Place], completion: @escaping (Result<(Place),AttendanceError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let endPoint = "/attendance"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                let json = JSON(response.value!!)
                if let myCurrentPlace = json["logs"][0]["place"]["_id"].string {
                    completion(.success(findPlaceById(id: myCurrentPlace, from: places)))
                } else {
                    completion(.failure(.noSuchPlace))
                }
            case 401:
                completion(.failure(.tokenExpired))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}
