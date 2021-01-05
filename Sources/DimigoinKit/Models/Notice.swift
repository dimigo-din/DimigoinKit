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

public class NoticeAPI: ObservableObject {
    @Published public var notices: [Notice] = []
    public var tokenAPI: TokenAPI = TokenAPI()
    
    public init() {
        getNotice()
    }
    
    /// http://edison.dimigo.hs.kr/notice/currnet
    /// 최근 공지사항을 불러옵니다.
    public func getNotice() {
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
                    self.getNotice()
                }
            }
        }
    }
    
    /// 공지사항을 출력합니다.
    public func debugNotice() {
        LOG(notices)
    }
}
