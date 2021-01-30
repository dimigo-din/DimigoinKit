//
//  File.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import Foundation
import Alamofire
import SwiftyJSON

/// 수업 모델 정의
public struct Lecture: Codable {
    public var subject: String
    public var weekDay: Int
    public var period: Int
}

/// 시간표 API 에러타입 정의
public enum TimetableError: Error {
    case unknown
    case tokenExpired
}

/// 시간표 데이터를 받아옵니다.
public func getLectureList(_ accessToken: String, grade: Int, klass: Int, completion: @escaping (Result<([Lecture]), TimetableError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let endPoint = "/timetable/weekly/grade/\(grade)/class/\(klass)"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                let json = JSON(response.value!!)
                completion(.success(json2LectureList(from: json["timetable"])))
            case 401:
                completion(.failure(.tokenExpired))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}

/// json데이터를 강의 리스트 데이터로 반환해줍니다.
public func json2LectureList(from json: JSON) -> [Lecture] {
    var lectureList: [Lecture] = []
//    for i in 0..<json.count {
//        let weekDay = getDayOfWeek(json[i]["date"].string![0..<10]) - 1
//        if(weekDay != 6 && weekDay != 7) {
//            lectureList.append(Lecture(subject: json[i]["subject"].string!, weekDay: weekDay, period: json[i]["period"].int!))
//        }
//    }
    return lectureList
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}
