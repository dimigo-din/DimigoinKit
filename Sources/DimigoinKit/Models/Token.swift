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

public enum TokenError: Error {
    case authFailed
    case unknown
}

/// 디미고인 유저 토큰 관련
public class TokenAPI: ObservableObject {
    @Published public var accessToken: String = ""
    @Published public var refreshToken: String = ""
    @Published public var tokenStatus: TokenStatus = .none
    
    private var username: String = ""
    private var password: String = ""
    
    public init() {
        checkTokenStatus()
        saveTokens()
    }
    
    /// Username과 Password를 설정
    public func setUsernamePassword(username: String, password: String) -> Void{
        self.username = username
        self.password = password
    }
    
    /// https://edison.dimigo.hs.kr/auth
    /// 토큰을 가져옵니다. ([POST] /auth)
    public func getTokens() -> Void {
        LOG("get token")
        let parameters: [String: String] = [
            "username": "\(self.username)",
            "password": "\(self.password)"
        ]
        let endPoint = "/auth"
        let method: HTTPMethod = .post
        AF.request(rootURL+endPoint, method: method, parameters: parameters, encoding: JSONEncoding.default).response { response in
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
    
    public func getTokens(_ username: String, _ password: String, completion: @escaping (Result<(accessToken: String, refreshToken: String), TokenError>) -> Void) {
        LOG("get token")
        let parameters: [String: String] = [
            "username": "\(username)",
            "password": "\(password)"
        ]
        let endPoint = "/auth"
        let method: HTTPMethod = .post
        AF.request(rootURL+endPoint, method: method, parameters: parameters, encoding: JSONEncoding.default).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    let accessToken = json["accessToken"].string!
                    let refreshToken = json["refreshToken"].string!
                    self.debugToken()
                    self.saveTokens()
                    self.tokenStatus = .exist
                    completion(.success((accessToken, refreshToken)))
                case 401: completion(.failure(.authFailed))
                default: completion(.failure(.unknown))
                }
            }
        }
    }
    
    /// http://edison.dimigo.hs.kr/auth/refresh
    /// 토큰을 새로고침 합니다.([POST] /auth/refresh)
    public func refreshTokens() {
        LOG("refresh tokens")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(self.refreshToken)"
        ]
        let endPoint = "/auth/refresh"
        let method: HTTPMethod = .post
        AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.accessToken = json["accessToken"].string!
                    self.refreshToken = json["refreshToken"].string!
                    self.debugToken()
                    self.saveTokens()
                    withAnimation() {
                        self.tokenStatus = .exist
                    }
                case 400:
                    LOG("어딧냐 토큰??")
                default:
                    LOG("refresh token failed")
                    if debugMode {
                        debugPrint(response)
                    }
                }
            }
        }
    }

    /// 토큰을 출력합니다.
    public func debugToken() {
        LOG("accessToken : \(accessToken)")
        LOG("refreshToken : \(refreshToken)")
    }
    
    /// 토큰을 기기에 저장합니다.
    public func saveTokens() {
        LOG("save tokens")
        UserDefaults.standard.setValue(self.accessToken, forKey: "accessToken")
        UserDefaults.standard.setValue(self.refreshToken, forKey: "refreshToken")
        
        // for dimigoin App service only
        UserDefaults(suiteName: appGroupName)?.setValue(self.accessToken, forKey: "accessToken")
        UserDefaults(suiteName: appGroupName)?.setValue(self.refreshToken, forKey: "refreshToken")
    }
    
    /// 저장된 토큰을 불러옵니다.
    public func loadTokens() {
        LOG("load tokens")
        self.accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        self.refreshToken = UserDefaults.standard.string(forKey: "refreshToken") ?? ""
    }
    
    /// 저장된 토큰 유무를 확인합니다. (= 로그인 이력 조회)
    public func checkTokenStatus(){
        if UserDefaults.standard.string(forKey: "accessToken") != nil && UserDefaults.standard.string(forKey: "refreshToken") != nil {
            self.loadTokens()
            self.tokenStatus = .exist
        } else {
            tokenStatus = .none
        }
    }
    
    /// 저장된 토큰을 삭제합니다. (로그아웃)
    public func clearTokens() {
        LOG("Remove tokens")
        
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        
        
        // for dimigoin App service only
        UserDefaults(suiteName: appGroupName)?.removeObject(forKey: "accessToken")
        UserDefaults(suiteName: appGroupName)?.removeObject(forKey: "refreshToken")
        withAnimation() {
            self.tokenStatus = .none
        }
    }
    
}


/// 토큰을 기기에 저장합니다.
public func saveTokens(_ accessToken: String, _ refreshToken: String) {
    LOG("save tokens")
    UserDefaults.standard.setValue(accessToken, forKey: "accessToken")
    UserDefaults.standard.setValue(refreshToken, forKey: "refreshToken")
    
    // for dimigoin App service only
    UserDefaults(suiteName: appGroupName)?.setValue(accessToken, forKey: "accessToken")
    UserDefaults(suiteName: appGroupName)?.setValue(refreshToken, forKey: "refreshToken")
}
