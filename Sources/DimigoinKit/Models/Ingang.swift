//
//  File.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import Foundation
import Alamofire
import SwiftyJSON

/// 인강 시간대 정의
public enum IngangTime: String, Hashable, Codable {
    case NSS1 = "NSS1"
    case NSS2 = "NSS2"
}

/// 인강 모델
public struct Ingang: Hashable, Codable {
    public var date: String = ""
    public var time: IngangTime
    public var isApplied: Bool = false
    public var applicants: [Applicant] = []
    public var title: String = ""
    public var timeString: String = ""
    public func getApplicantStringList() -> String {
        var str = ""
        for applicant in applicants {
            str += "\(applicant.name)"
            if i != applicants.count {
                str += " "
            }
        }

        return str
    }
}

/// 인강 신청자 모델
public struct Applicant: Identifiable, Hashable, Codable {
    public var id = UUID()
    public var name: String = ""
    public var grade: Int = 0
    public var klass: Int = 0
    public var number: Int = 0
    public var serial: Int = 0
}

/// Ingang Status of request
public enum IngangStatus: Int {
    case none = 0
    case success = 200
    case full = 403
    case noIngang = 404
    case alreadyApplied = 409
    case timeout = 500
}
/// 디미고인 인강 관련 API
public class IngangAPI: ObservableObject {
    @Published public var ingangs: [Ingang] = [
        Ingang(date: getToday8DigitDateString(), time: .NSS1, applicants: []),
        Ingang(date: getToday8DigitDateString(), time: .NSS2, applicants: [])
    ]
    
    public var tokenAPI = TokenAPI()
    public var userAPI = UserAPI()
    public var weeklyTicketCount: Int = 0
    public var weeklyUsedTicket: Int = 0
    public var weeklyRemainTicket: Int = 0
    public var ingangMaxApplier: Int = 0
    
    public init() {
        self.getIngangStatus()
        self.setIngangTitles()
    }
    
    /// 신청자를 받아서 인강에 차곡차곡 정리합니다.
    public func sortApplicants(applicants: JSON) {
        clearApplicantList()
        for i in 0..<applicants.count {
            
            let newApplicant = Applicant(name: applicants[i]["applier"]["name"].string!,
                                       grade: applicants[i]["applier"]["grade"].int!,
                                       klass: applicants[i]["applier"]["class"].int!,
                                       number: applicants[i]["applier"]["number"].int!,
                                       serial: applicants[i]["applier"]["serial"].int!)
            if(applicants[i]["time"] == "NSS1") {
                ingangs[0].applicants.append(newApplicant)
            }
            else if(applicants[i]["time"] == "NSS2") {
                ingangs[1].applicants.append(newApplicant)
            }
        }
        
            
    }
    /// 인강 신청자 내역 중 자신의 이름이 있는지 검사하고, 맞다면 신청된 상태로 만듭니다.
    public func checkIsApplied() {
        for i in 0..<ingangs.count {
            for applicant in ingangs[i].applicants {
                if(applicant.name == userAPI.user.name) {
                    print("😍😍😍")
                    ingangs[i].isApplied = true
                }
            }
        }
    }
    
    /// 인강 신청자 내역을 비웁니다.
    public func clearApplicantList() {
        ingangs[0].applicants.removeAll()
        ingangs[1].applicants.removeAll()
    }
    
    /// 인강의 이름을 설정합니다.
    public func setIngangTitles() {
        for i in 0...1 {
            ingangs[i].timeString = "\(ingangTime[i])"
            if(ingangs[i].time == .NSS1) {
                ingangs[i].title = "야간자율학습 1타임"
            }
            else if(ingangs[i].time == .NSS2) {
                ingangs[i].title = "야간자율학습 2타임"
            }
        }
    }
    
    /// 모든 인강정보(티켓, 신청자) 조회 ([GET] /ingang-application/status)
    public func getIngangStatus() {
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let url = "http://edison.dimigo.hs.kr/ingang-application/status"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.weeklyTicketCount = json["weeklyTicketCount"].int!
                    self.weeklyUsedTicket = json["weeklyUsedTicket"].int!
                    self.weeklyRemainTicket = json["weeklyRemainTicket"].int!
                    self.ingangMaxApplier = json["ingangMaxApplier"].int!
                    self.sortApplicants(applicants: json["applicationsInClass"])
                    self.setIngangTitles()
                    self.checkIsApplied()
                    self.debugIngangs()
                default:
                    if debugMode {
                        debugPrint(response)
                    }
                    self.tokenAPI.refreshTokens()
                    self.getIngangStatus()
                
                }
            }
        }
    }
    
    /// 인강신청하기([POST] /ingang-application)
    public func applyIngang(time: IngangTime) -> IngangStatus{
        LOG("apply ingang : \(getToday8DigitDateString())-\(time.rawValue)")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let parameters: [String: String] = [
            "time": "\(time.rawValue)"
        ]
        let url = "http://edison.dimigo.hs.kr/ingang-application"
        var ingangStatus: IngangStatus = .none
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200: //success
                    ingangStatus = .success
                    LOG("인강 신청 성공 : 200")
                case 403: // 최대 인강실 인원을 초과했습니다.
                    ingangStatus = .full
                    LOG("인강 신청 실패 : 403")
                case 404: // 해당 시간 신청한 인강실이 없습니다.
                    ingangStatus = .noIngang
                    LOG("인강이 없음 : 404")
                case 409: //이미 해당 시간 인강실을 신청했습니다.
                    ingangStatus = .full
                    LOG("인강 이미 신청: 409")
                case 500:
                    ingangStatus = .timeout
                    LOG("500")
                default:
                    if debugMode {
                        debugPrint(response)
                    }
                    self.tokenAPI.refreshTokens()
                    ingangStatus = self.applyIngang(time: time)
                }
            }
        }
        return ingangStatus
    }
    
    /// 인강취소하기([DELETE] /ingang-application)
    public func cancelIngang(time: IngangTime) -> IngangStatus{
        LOG("cancel ingang : \(getToday8DigitDateString())-\(time.rawValue)")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let parameters: [String: String] = [
            "time": "\(time.rawValue)"
        ]
        let url = "http://edison.dimigo.hs.kr/ingang-application"
        var ingangStatus: IngangStatus = .none
        AF.request(url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200: //success
                    ingangStatus = .success
                    LOG("인강 취소 성공 : 200")
                case 403: // 최대 인강실 인원을 초과했습니다.
                    ingangStatus = .full
                    LOG("인강 취소 실패 : 403")
                case 404: // 해당 시간 신청한 인강실이 없습니다.
                    ingangStatus = .noIngang
                    LOG("인강이 없음 : 404")
                case 409: //이미 해당 시간 인강실을 신청했습니다.
                    ingangStatus = .full
                    LOG("인강 이미 취소: 409")
                case 500:
                    ingangStatus = .timeout
                    LOG("500")
                default:
                    if debugMode {
                        debugPrint(response)
                    }
                    self.tokenAPI.refreshTokens()
                    ingangStatus = self.applyIngang(time: time)
                }
            }
        }
        return ingangStatus
    }
    
    /// ingang 디버그
    public func debugIngangs() {
        LOG("get ticket status \(self.weeklyUsedTicket) / \(self.weeklyTicketCount)")
        for i in 0...1 {
            var str = ""
            str +=  "\(ingangs[i].time.rawValue) : "
            for applicant in ingangs[i].applicants {
                str +=  "\(applicant.name) | "
            }
            LOG(str)
        }
    }
    
    /// 인강 신청자들을 문자열로 정리해서 반환
    public func getApplicantStringList(time: IngangTime) -> String {
        var str = ""
        for i in 0...1 {
            if(ingangs[i].time == time) {
                for applicant in ingangs[i].applicants {
                    str += "\(applicant.name)"
                    if i != ingangs[i].applicants.count {
                        str += " "
                    }
                }
            }
        }
        return str
    }
}

/// 야자 1, 2타임 시간
public let ingangTime = [
    "19:50 - 21:10",
    "21:30 - 22:30"
]
