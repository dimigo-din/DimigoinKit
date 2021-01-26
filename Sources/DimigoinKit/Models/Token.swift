//
//  TokenAPI.swift
//  DimigoinKit
//
//  Created by 변경민 on 2021/01/26.
//

import Foundation
import Alamofire
import SwiftyJSON

public enum TokenError: Error {
    case authFailed
    case firstLogin
    case unknown
    case emptyArguments
}

public struct TokenAPI {
    /// 토큰을 새로고침 합니다.
    func fetchTokens(_ refreshToken:String, completion: @escaping (Result<(accessToken: String, refreshToken: String), TokenError>) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(refreshToken)"
        ]
        let endPoint = "/auth/refresh"
        let method: HTTPMethod = .post
        AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    let accessToken = json["accessToken"].string!
                    let refreshToken = json["refreshToken"].string!
                    self.saveTokens(accessToken, refreshToken)
                    completion(.success((accessToken, refreshToken)))
                case 400:
                    completion(.failure(.emptyArguments))
                case 401:
                    completion(.failure(.authFailed))
                default:
                    print("refresh token failed")
                }
            }
        }
    }
    
    /// username과 password로 토큰을 발급받습니다.
    func fetchTokens(_ username: String, _ password: String, completion: @escaping (Result<(accessToken: String, refreshToken: String), TokenError>) -> Void) {
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
                    self.saveTokens(accessToken, refreshToken)
                    completion(.success((accessToken, refreshToken)))
                case 401:
                    completion(.failure(.authFailed))
                default: completion(.failure(.unknown))
                }
            }
        }
    }
    
    /// 기기에 토큰을 저장합니다.
    func saveTokens(_ accessToken: String, _ refreshToken: String) {
        UserDefaults.standard.setValue(accessToken, forKey: "accessToken")
        UserDefaults.standard.setValue(refreshToken, forKey: "refreshToken")
    }
    
    /// 저장된 토큰을 불러옵니다. 없다면 TokenError.firstLogin 에러를 반환합니다.
    func loadSavedTokens(completion: @escaping (Result<(accessToken: String, refreshToken: String), TokenError>) -> Void) {
        let accessToken: String = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        let refreshToken: String = UserDefaults.standard.string(forKey: "refreshToken") ?? ""
        
        if(accessToken == "" && refreshToken == "") {
            completion(.failure(.firstLogin))
        }
        else {
            completion(.success((accessToken, refreshToken)))
        }
    }
    
    /// 토큰을 삭제하고, 로그아웃합니다.
    func removeTokens(completion: @escaping () -> Void) {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        completion()
    }
}
