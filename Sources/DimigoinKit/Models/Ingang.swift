//
//  File.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import Foundation
import Alamofire
import SwiftyJSON
import DimigoinKit

public struct Ingang: Hashable, Codable {
    public init(idx: Int, day: String, title: String, time: Int, request_start_date: Int, request_end_date: Int, status: Bool, present: Int, max_user: Int){
        self.idx = idx
        self.day  = day
        self.title = title
        self.time = time
        self.request_start_date = request_start_date
        self.request_end_date = request_end_date
        self.status = status
        self.present = present
        self.max_user = max_user
    }
    public var idx: Int?
    public var day: String?
    public var title: String?
    public var time: Int?
    public var request_start_date: Int?
    public var request_end_date: Int?
    public var status: Bool?
    public var present: Int?
    public var max_user: Int?
}

public struct Applicant: Identifiable, Hashable, Codable {
    public init(idx: Int, name: String, grade: Int, klass: Int, number: Int, serial: Int){
        self.idx = idx
        self.name  = name
        self.grade = grade
        self.klass = klass
        self.number = number
        self.serial = serial
    }
    public var id = UUID()
    public var idx: Int?
    public var name: String?
    public var grade: Int?
    public var klass: Int?
    public var number: Int?
    public var serial: Int?
}

public enum IngangStatus: Int {
    case none = 0
    case success = 200
    case usedAllTicket = 403
    case noIngang = 404
    case timeout = 405
    case blacklisted = 406
    case full = 409
}

public class IngangAPI: ObservableObject {
    @Published public var ingangs: [Ingang] = []
    @Published public var applicants: [Applicant] = []
    
    public var tokenAPI = TokenAPI()
    public var weekly_request_count: Int = 0
    public var daily_request_count: Int = 0
    public var weekly_ticket_num: Int = 0
    public var daily_ticket_num: Int = 0
    
    public init() {
        self.getIngangList()
        self.getApplicantList()
        self.getTickets()
    }
    public func getIngangList() {
        print("get ingang list")
        self.ingangs = []
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.token)"
        ]
        let url = "https://api.dimigo.in/ingang/"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    let ingangCnt = json["ingangs"].count
                    for idx in 0..<ingangCnt {
                        let newIngang = Ingang(idx: json["ingangs"][idx]["idx"].int!,
                                               day: json["ingangs"][idx]["day"].string!,
                                               title: json["ingangs"][idx]["title"].string!,
                                               time: json["ingangs"][idx]["time"].int!,
                                               request_start_date: json["ingangs"][idx]["idx"].int!,
                                               request_end_date: json["ingangs"][idx]["request_end_date"].int!,
                                               status: json["ingangs"][idx]["status"].bool!,
                                               present: json["ingangs"][idx]["present"].int!,
                                               max_user: json["ingangs"][idx]["max_user"].int!)
                        self.ingangs.append(newIngang)
                    }
                default:
                    debugPrint(response)
                    self.tokenAPI.refreshTokens()
                    self.getIngangList()
                }
            }
        }
    }
    public func getTickets() {
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.token)"
        ]
        let url = "https://api.dimigo.in/ingang/"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.weekly_request_count = json["weekly_request_count"].int!
                    self.daily_request_count = json["daily_request_count"].int!
                    self.weekly_ticket_num = json["weekly_ticket_num"].int!
                    self.daily_ticket_num = json["daily_ticket_num"].int!
                    print("get ticket status \(self.weekly_request_count) \(self.weekly_ticket_num)")
                default:
                    debugPrint(response)
                    self.tokenAPI.refreshTokens()
                    self.getTickets()
                }
            }
        }
    }
    public func getApplicantList() {
        print("get applicant list")
        self.applicants = []
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.token)"
        ]
        let url = "https://api.dimigo.in/ingang/users/myklass"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    let applicantCnt = json["users"].count
                    for idx in 0..<applicantCnt {
                        let newApplicant = Applicant(idx: json["users"][idx]["idx"].int!,
                                                     name: json["users"][idx]["name"].string!,
                                                     grade: json["users"][idx]["grade"].int!,
                                                     klass: json["users"][idx]["klass"].int!,
                                                     number: json["users"][idx]["number"].int!,
                                                     serial: json["users"][idx]["serial"].int!)
                        self.applicants.append(newApplicant)
                    }
                default:
                    debugPrint(response)
                    self.tokenAPI.refreshTokens()
                    self.getApplicantList()
                }
            }
        }
    }
    public func applyIngang(idx: Int) -> IngangStatus{
        print("apply ingang : \(idx)")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.token)"
        ]
        let parameters: [String: String] = [
            "ingang_idx": "\(String(idx))"
        ]
        let url = "https://api.dimigo.in/ingang/"
        var ingangStatus: IngangStatus = .none
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200: //success
                    ingangStatus = .success
                    print("인강 신청 성공 : 200")
                case 403: // 본인 학년&반 인강실이 아니거나 오늘(일주일)치 신청을 모두 했습니다.
                    ingangStatus = .usedAllTicket
                    print("인강 신청 실패 : 403")
                case 404: //인강실 신청이 없습니다.
                    ingangStatus = .noIngang
                    print("인강이 없음 : 404")
                case 405: // 신청 시간이 아닙니다
                    ingangStatus = .timeout
                    print("인강 신청 기간이 아님 : 405")
                case 406: // 인강실 블랙리스트이므로 신청할 수 없습니다.
                    ingangStatus = .blacklisted
                    print("인강 블랙리스트 : 406")
                case 409: // 이미 신청을 했거나 신청인원이 꽉 찼습니다.
                    ingangStatus = .full
                    print("인강 이미 신청: 409")
                case 500:
                    ingangStatus = .timeout
                    print("500")
                default:
                    self.tokenAPI.refreshTokens()
//                    debugPrint(response)
                    ingangStatus = self.applyIngang(idx: idx)
                }
            }
        }
        return ingangStatus
    }
    public func cancelIngang(idx: Int) -> IngangStatus{
        print("cancel ingang : \(idx)")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.token)"
        ]
        let parameters: [String: String] = [
            "ingang_idx": "\(String(idx))"
        ]
        let url = "https://api.dimigo.in/ingang/\(String(idx))/"
        var ingangStatus: IngangStatus = .success
        AF.request(url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200: //success
                    ingangStatus = .success
                case 403: // 본인 학년&반 인강실이 아니거나 오늘(일주일)치 신청을 모두 했습니다.
                    ingangStatus = .usedAllTicket
                case 404: //인강실 신청이 없습니다.
                    ingangStatus = .noIngang
                case 405: // 신청 시간이 아닙니다
                    ingangStatus = .timeout
                default:
                    self.tokenAPI.refreshTokens()
                    debugPrint(response)
                    ingangStatus = self.cancelIngang(idx: idx)
                }
            }
        }
        return ingangStatus
    }
    
    
    public func debugIngangs() {
        for ingang in self.ingangs {
            print(ingang)
        }
    }
}

public let ingangTime = [
    "",
    "19:50 - 21:10",
    "21:30 - 22:30"
]

//var dummyIngang:[Ingang] = [Ingang(idx: 1,
//                                   day: "sd",
//                                   title: "test",
//                                   time: 1,
//                                   request_start_date: 1,
//                                   request_end_date: 1,
//                                   status: true,
//                                   present: 2,
//                                   max_user: 3)]
