//
//  Notice.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import Foundation
import Alamofire
import SwiftyJSON

public struct Notice: Hashable, Codable, Identifiable {
    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
    public init() {
        self.title = "-"
        self.content = "-"
    }
    public var id = UUID()
    public var title: String
    public var content: String
}

/// 디미고인 공지사항 관련 API
public class NoticeAPI: ObservableObject {
    @Published public var notices: [Notice] = []
    public var tokenAPI: TokenAPI = TokenAPI()
    public var userAPI = UserAPI()
    public init() {
        getAllNotice()
    }
    
    /// http://edison.dimigo.hs.kr/notice/currnet
    /// 최근 공지사항을 불러옵니다.
    public func getCurrentNotice() {
        LOG("get notice")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let url = "http://edison.dimigo.hs.kr/notice/current"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    for i in 0..<json.count {
                        self.notices.append(Notice(title: json["notices"][i]["title"].string!, content: json["notices"][i]["content"].string!))
                    }
                    self.debugNotice()
                default:
                    debugPrint(response)
                    self.tokenAPI.refreshTokens()
                    self.getCurrentNotice()
                }
            }
        }
    }
    
    /// http://edison.dimigo.hs.kr/notice
    /// 모든 공지사항을 불러옵니다. ([GET] /notice)
    public func getAllNotice() {
        LOG("get all notice")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let url = "http://edison.dimigo.hs.kr/notice"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
//                    print(json)
                    self.sortNotices(notices: json)
//                    self.debugNotice()
                default:
                    debugPrint(response)
                    self.tokenAPI.refreshTokens()
                    self.getCurrentNotice()
                }
            }
        }
    }
    
    /// 모든 공지사항 중 자신의 학년에 맞는 공지사항만 추려내고 차곡차곡 정리합니다. ㅎㅎ
    public func sortNotices(notices: JSON) {
        for i in 0..<notices["notices"].count {
            for j in 0..<notices["notices"][i]["targetGrade"].count {
                if(notices["notices"][i]["targetGrade"][j].int! == userAPI.user.grade) {
                    self.notices.append(Notice(title: notices["notices"][i]["title"].string!, content: notices["notices"][i]["content"].string!))
                }
            }
            
        }
        debugNotice()
    }
    
    /// 공지사항을 출력합니다.
    public func debugNotice() {
        for notice in notices {
            var str = ""
            str += "title : \(notice.title), content: \(notice.content)"
            LOG(str)
        }
    }
}
