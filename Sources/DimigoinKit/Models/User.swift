//
//  User.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import Kingfisher

/// User Model
public struct User: Codable, Identifiable {
    public init() {
        
    }
    public var name: String = ""
    public var id: String = ""
    public var idx: Int = 0
    public var grade: Int = 4
    public var klass: Int = 1
    public var number: String = ""
    public var serial: String = ""
    public var email: String = ""
    public var photo: String = ""
    public var weekly_request_count: Int = 0
    public var daily_request_count: Int = 0
    public var weekly_ticket_num: Int = 0
    public var daily_ticket_num: Int = 0
}

public class UserAPI: ObservableObject {
    @Published public var user = User()
//    @Published var photo = KFImage(URL(string: "https://api.dimigo.hs.kr/user_photo/")!)
    public var tokenAPI: TokenAPI = TokenAPI()
    public init() {
        getUserData()
        getUserTicket()
    }
    
    /// EndPoint: https://api.dimigo.in/user/jwt/
    /// 사용자 정보 조회
    public func getUserData() {
        LOG("get User Data")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(tokenAPI.accessToken)"
        ]
        let url: String = "https://api.dimigo.in/user/jwt/"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.user.idx = json["idx"].int!
                    self.user.name = json["name"].string!
                    self.user.grade = Int(json["grade"].string!)!
                    self.user.klass = Int(json["klass"].string!)!
                    self.user.number = json["number"].string!
                    self.user.serial = json["serial"].string!
                    self.user.email = json["email"].string!
                default:
                    self.tokenAPI.refreshTokens()
                    self.getUserData()
                }
            }
        }
    }
    
    /// EndPoint: https://api.dimigo.in/ingang/
    /// 사용자 티켓 정보 조회
    public func getUserTicket() {
        LOG("get user ticket status")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let url = "https://api.dimigo.in/ingang/"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.user.weekly_request_count = json["weekly_request_count"].int!
                    self.user.daily_request_count = json["daily_request_count"].int!
                    self.user.weekly_ticket_num = json["weekly_ticket_num"].int!
                    self.user.daily_ticket_num = json["daily_ticket_num"].int!
                default:
                    debugPrint(response)
                    self.tokenAPI.refreshTokens()
                    self.getUserTicket()
                }
            }
        }
    }
    
    /// 티켓정보 디버그
    public func debugTicket() {
        LOG("weekly_ticket_num : \(user.weekly_ticket_num)")
        LOG("weekly_request_count : \(user.weekly_request_count)")
        LOG("daily_ticket_num : \(user.daily_ticket_num)")
        LOG("daily_request_count : \(user.daily_request_count)")
    }
}

/// 반에 따라 학과 반환
public func getMajor(klass: Int) -> String {
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

public let dummyUser: User = User()

