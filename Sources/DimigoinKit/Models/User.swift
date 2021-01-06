//
//  User.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import SDWebImageSwiftUI

/// 사용자 모델 정의
public struct User: Codable, Identifiable {
    public init() {
        
    }
    public var name: String = ""
    public var id: String = ""
    public var idx: Int = 0
    public var grade: Int = 4
    public var klass: Int = 1
    public var number: Int = 0
    public var serial: Int = 0
    public var photo: String = ""
    public var weeklyTicketCount: Int = 0
    public var weeklyUsedTicket: Int = 0
    public var weeklyRemainTicket: Int = 0
}

/// 디미고인 사용자 정보 관련 API
public class UserAPI: ObservableObject {
    @Published public var user = User()
    @Published public var userPhoto: WebImage = WebImage(url: URL(string: ""))
    public var tokenAPI: TokenAPI = TokenAPI()
    
    public init() {
        getUserData()
        getUserTicket()
    }
    
    /// http://edison.dimigo.hs.kr/user/me
    /// 사용자 정보를 조회합니다.([GET] /user/me)
    public func getUserData() {
        LOG("get User Data")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(tokenAPI.accessToken)"
        ]
        let url: String = "http://edison.dimigo.hs.kr/user/me"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.user.idx = json["identity"]["idx"].int!
                    self.user.name = json["identity"]["name"].string!
                    self.user.grade = json["identity"]["grade"].int!
                    self.user.klass = json["identity"]["class"].int!
                    self.user.number = json["identity"]["number"].int!
                    self.user.serial = json["identity"]["serial"].int!
                    self.user.photo = json["identity"]["photo"][0].string!
                    self.getUserPhoto()
                    LOG("User num : \(self.user.serial)")
                default:
                    self.tokenAPI.refreshTokens()
                    self.getUserData()
                }
            }
        }
    }
    
    /// http://edison.dimigo.hs.kr/ingang-application/status
    /// 사용자 티켓 정보를 조회합니다.([GET] /ingang-application/status)
    public func getUserTicket() {
        LOG("get user ticket status")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let url = "http://edison.dimigo.hs.kr/ingang-application/status"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.user.weeklyTicketCount = json["weeklyTicketCount"].int!
                    self.user.weeklyUsedTicket = json["weeklyUsedTicket"].int!
                    self.user.weeklyRemainTicket = self.user.weeklyTicketCount - self.user.weeklyUsedTicket
                default:
                    debugPrint(response)
                    self.tokenAPI.refreshTokens()
                    self.getUserTicket()
                }
            }
        }
    }
    /// 사용자의 프로필 사진을 불러옵니다.
    public func getUserPhoto() {
        self.userPhoto = WebImage(url: URL(string: "https://api.dimigo.hs.kr/user_photo/\(user.photo)"))

    }
    /// 사용자의 티켓 정보를 출력합니다.
    public func debugTicket() {
        LOG("weeklyUsedTicket : \(user.weeklyUsedTicket) \n weeklyRemainTicket : \(user.weeklyRemainTicket)")
    }
    
    /// 사용자의 학번과 이름 문자열을 반환합니다. 예) 1234 홍길동
    public func getUserNumberAndName() -> String {
        return "\(self.user.number) \(self.user.name)"
    }
}

/// 반에 따른 학과를 반환합니다.
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

/// 테스트용 더미 유저
public let dummyUser: User = User()

