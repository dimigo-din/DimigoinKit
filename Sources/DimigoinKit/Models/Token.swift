//
//  File.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import SwiftUI
import Alamofire
import SwiftyJSON

/// token의 존재 여부 (=로그인 이력)
public enum TokenStatus {
    case exist
    case none
}

public class TokenAPI: ObservableObject {
    @Published public var accessToken: String = ""
    @Published public var refreshToken: String = ""
    @Published public var tokenStatus: TokenStatus = .none
    
    private var username: String = ""
    private var password: String = ""
    
    public init() {
        checkTokenStatus()
    }
    
    /// ID와 Password를 설정
    public func setUsernamePassword(username: String, password: String) -> Void{
        self.username = username
        self.password = password
    }
    
    /// EndPoint:[POST] https://edison.dimigo.hs.kr/auth
    /// 토큰 가져오기
    public func getTokens() -> Void {
        LOG("get token")
        let parameters: [String: String] = [
            "username": "\(self.username)",
            "password": "\(self.password)"
        ]
        let url: String = "http://edison.dimigo.hs.kr/auth"
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.accessToken = json["accessToken"].string!
                    self.refreshToken = json["refreshToken"].string!
                    self.debugToken()
                    self.saveTokens()
                    self.tokenStatus = .exist
                default:
                    LOG("get token failed")
                    if debugMode {
                        debugPrint(response)
                    }
                    self.tokenStatus = .none
                }
            }
        }
    }
    
    /// EndPoint: http://edison.dimigo.hs.kr/auth/refresh
    /// 토큰 새로고침
    public func refreshTokens() {
        LOG("refresh tokens")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(self.refreshToken)"
        ]
        let url = "http://edison.dimigo.hs.kr/auth/refresh"
        AF.request(url, method: .post, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.accessToken = json["accessToken"].string!
                    self.refreshToken = json["refreshToken"].string!
                    self.debugToken()
                    self.saveTokens()
                    self.tokenStatus = .exist
                default:
                    LOG("refresh token failed")
                    self.refreshTokens()
                }
            }
        }
    }

    /// 토큰 디버그 출력
    public func debugToken() {
        LOG("accessToken : \(accessToken)")
        LOG("refreshToken : \(refreshToken)")
    }
    
    /// 토큰 저장
    public func saveTokens() {
        LOG("save tokens")
        UserDefaults.standard.setValue(self.accessToken, forKey: "accessToken")
        UserDefaults.standard.setValue(self.refreshToken, forKey: "refreshToken")
    }
    
    /// 저장된 토큰 로드
    public func loadTokens() {
        LOG("load tokens")
        self.accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        self.refreshToken = UserDefaults.standard.string(forKey: "refreshToken") ?? ""
    }
    
    /// 저장된 토큰의 여부검사 (=로그인 여부 검사)
    public func checkTokenStatus(){
        if UserDefaults.standard.string(forKey: "accessToken") != nil {
            self.tokenStatus = .exist
            self.loadTokens()
        } else {
            tokenStatus = .none
        }
    }
    
    /// 저장된 토큰 삭제
    public func clearTokens() {
        LOG("Remove tokens")
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        self.tokenStatus = .none
    }
    
}

