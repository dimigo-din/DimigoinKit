//
//  File.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import Foundation
import Alamofire
import SwiftyJSON

public struct Notice: Hashable, Codable, Identifiable {
    public init(type: String, registered: String, description: String) {
        self.type = type
        self.registered = registered
        self.description = description
    }
    public init() {
        self.type = "-"
        self.registered = "-"
        self.description = "-"
    }
    public var id = UUID()
    public var type: String
    public var registered: String
    public var description: String
}

public class NoticeAPI: ObservableObject {
    @Published public var notice = Notice()
    public var tokenAPI: TokenAPI = TokenAPI()
    
    public init() {
        getNotice()
    }
    
    /// 공지사항 조회
    public func getNotice() {
        LOG("get notice")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let url = "https://api.dimigo.in/notice/latest"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.notice.description = json["notice"][0]["description"].string!
                    self.debugNotice()
                default:
                    debugPrint(response)
                    self.tokenAPI.refreshTokens()
                    self.getNotice()
                }
            }
        }
    }
    
    /// 공지사항 출력
    public func debugNotice() {
        LOG(notice.description)
    }
}

