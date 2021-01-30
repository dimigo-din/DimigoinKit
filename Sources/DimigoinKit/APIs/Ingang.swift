//
//  Ingang.swift
//  DimigoinKit
//
//  Created by 변경민 on 2021/01/26.
//

import Foundation
import Alamofire
import SwiftyJSON

/**
 인강 시간대 정의
 
- `.NSS1`: 야간 자율 학습 1타임
- `.NSS1`: 야간 자율 학습 1타임

*/
public enum IngangTime: String {
    case NSS1 = "NSS1"
    case NSS2 = "NSS2"
}

/**
 인강 모델
 
- `date`: yyyy-MM-dd
- `time`: .NSS1 혹은 .NSS2
- `isApplied`: 사용자가 신청했으면 true, 아니면 false
- `applicants`: 교실 내 신청자 목록
- `maxApplier`: 인강 신청자 명수 제한
- `title`: 인강 타이틀
- `timeString`: 몇시 부터 몇시까진지
*/
public struct Ingang: Hashable {
    public var date: String = ""
    public var time: IngangTime = .NSS1
    public var isApplied: Bool = false
    public var applicants: [Applicant] = []
    public var maxApplier: Int = 0
    public var title: String = ""
    public var timeString: String = ""
}

/**
 인강 신청자 모델
 
- `id`: UUID
- `name`: 이름
- `grade`: 학년
- `klass`: 반
- `number`: 번호
- `serial`: 학번
*/
public struct Applicant: Codable, Hashable {
    public var id = UUID()
    public var name: String = ""
    public var grade: Int = 0
    public var klass: Int = 0
    public var number: Int = 0
    public var serial: Int = 0
}

/**
 인강 API 에러 타입

 - full: 이미 꽉참
 - noIngang: 신청할 인강이 없음
 - alreadyApplied: 이미 신청한 인강
 - timeout: 요청 시간초과
 - tokenExpired: 토큰 만료
 - unknown: 알 수 없는 에러(500)
 */
public enum IngangError: Error {
    case full
    case noIngang
    case alreadyApplied
    case timeout
    case tokenExpired
    case unknown
}

/**
 모든 인강정보(티켓, 신청자) 조회
 
 - Parameters:
     - accessToken: 토큰
     - name: 사용자 이름
 
 # API Method #
 `GET`
 
 # API EndPoint #
 `{rootURL}/ingang-application/status`
 
 # 사용예시 #
 ```
 getIngangData(accessToken, "홍길동") { result in
 
 }
 ```
 */
public func getIngangData(_ accessToken: String, name: String, completion: @escaping (Result<(weeklyTicketCount: Int, weeklyUsedTicket: Int, weeklyRemainTicket: Int, ingangs: [Ingang]), defaultError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let endPoint = "/ingang-application/status"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                let json = JSON(response.value!!)
                let weeklyTicketCount = json["weeklyTicketCount"].int!
                let weeklyUsedTicket = json["weeklyUsedTicket"].int!
                let weeklyRemainTicket = json["weeklyRemainTicket"].int!
                let maxApplier = json["ingangMaxApplier"].int!
                let ingangs = [
                    Ingang(date: getToday8DigitDateString(),
                           time: .NSS1,
                           isApplied: checkIsApplied(json["applicationsInClass"], time: .NSS1, name: name),
                           applicants: sortApplicants(applicants: json["applicationsInClass"], time: .NSS1),
                           maxApplier: maxApplier,
                           title: "야간자율학습 1타임",
                           timeString: "19:50 - 21:10"),
                    Ingang(date: getToday8DigitDateString(),
                           time: .NSS1,
                           isApplied: checkIsApplied(json["applicationsInClass"], time: .NSS2, name: name),
                           applicants: sortApplicants(applicants: json["applicationsInClass"], time: .NSS2),
                           maxApplier: maxApplier,
                           title: "야간자율학습 2타임",
                           timeString: "21:30 - 23:00")
                ]
                completion(.success((weeklyTicketCount, weeklyUsedTicket, weeklyRemainTicket, ingangs)))
            case 401:
                completion(.failure(.tokenExpired))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}

/// ([] )

/**
 인강신청/취소하기
 
 - Parameters:
     - accessToken: 토큰
     - time: 인강시간
     - method: .post 는 신청, .delete는 취소
 
 # API Method #
 `POST/DELETE`
 
 # API EndPoint #
 `{rootURL}/ingang-application`
 
 # 사용예시 #
 ```
 manageIngang(accessToken, time: .NSS1, method: .post) { result in
 
 }
 ```
 */
public func manageIngang(_ accessToken: String, time: IngangTime, method: HTTPMethod, completion: @escaping (Result<(Void), IngangError>) -> Void){
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let parameters: [String: String] = [
        "time": "\(time.rawValue)"
    ]
    let endPoint = "/ingang-application"
    AF.request(rootURL+endPoint, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200: //success
                completion(.success(()))
            case 401: // 토큰 만료
                completion(.failure(.tokenExpired))
            case 403: // 최대 인강실 인원을 초과했습니다.
                completion(.failure(.full))
            case 404: // 해당 시간 신청한 인강실이 없습니다.
                completion(.failure(.noIngang))
            case 409: //이미 해당 시간 인강실을 신청했습니다.
                completion(.failure(.alreadyApplied))
            case 500:
                completion(.failure(.timeout))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}

/// 인강 신청자 내역 중 자신의 이름이 있는지 검사하고 맞다면 참을 반환합니다.
public func checkIsApplied(_ applicants: JSON, time: IngangTime, name: String) -> Bool{
    for applicant in sortApplicants(applicants: applicants, time: time) {
        if(applicant.name == name) {
            return true
        }
    }
    return false
}

/// 인강모델에서 신청자 명단을 추출하여 문자열로 반환합니다.
public func getApplicantStringList(from ingang: Ingang) -> String {
    var str = ""
    for i in 0..<ingang.applicants.count {
        str += "\(ingang.applicants[i].name)"
        if  i != ingang.applicants.count {
            str += " "
        }
    }
    return str
}

// 신청자를 받아서 인강에 차곡차곡 정리합니다.
public func sortApplicants(applicants: JSON, time: IngangTime) -> [Applicant]{
    var applicantsList:[[Applicant]] = [[],[]]
    for i in 0..<applicants.count {
        let newApplicant = Applicant(name: applicants[i]["applier"]["name"].string!,
                                   grade: applicants[i]["applier"]["grade"].int!,
                                   klass: applicants[i]["applier"]["class"].int!,
                                   number: applicants[i]["applier"]["number"].int!,
                                   serial: applicants[i]["applier"]["serial"].int!)
        if(applicants[i]["time"] == "NSS1") {
            applicantsList[0].append(newApplicant)
        }
        else if(applicants[i]["time"] == "NSS2") {
            applicantsList[1].append(newApplicant)
        }
    }
    if time == .NSS1 {
        return applicantsList[0]
    }
    else {
        return applicantsList[1]
    }
}
