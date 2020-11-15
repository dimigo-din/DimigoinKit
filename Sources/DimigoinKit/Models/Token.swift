//
//  File.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import SwiftUI
import Alamofire
import SwiftyJSON

public enum TokenStatus {
    case exist
    case none
}

public struct Tokens: Codable, Identifiable {
    public var id = UUID()
    public var token: String = ""
    public var refresh_token: String = ""
}

public class TokenAPI: ObservableObject {
    @Published public var tokens = Tokens()
    @Published public var tokenStatus: TokenStatus = .none
    private var id: String = ""
    private var password: String = ""
    
    public init() {
        checkTokenStatus()
    }
    public func set(id: String, password: String) -> Void{
        self.id = id
        self.password = password
    }
    public func getTokens() -> Void{
        print("get token")
        let parameters: [String: String] = [
            "id": "\(self.id)",
            "password": "\(self.password)"
        ]
        let url: String = "https://api.dimigo.in/auth/"
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.tokens.token = json["token"].string!
                    self.tokens.refresh_token = json["refresh_token"].string!
                    self.debugToken()
                    self.saveTokens()
                    self.tokenStatus = .exist
                default:
                    print("get token failed")
                    debugPrint(response)
                    self.tokenStatus = .none
                }
            }
        }
    }
    public func debugToken() {
        print("token : \(tokens.token)")
        print("refresh_token : \(tokens.refresh_token)")
    }
    public func saveTokens() {
        print("save tokens")
        UserDefaults.standard.setValue(self.tokens.token, forKey: "token")
        UserDefaults.standard.setValue(self.tokens.refresh_token, forKey: "refresh_token")
    }
    public func loadTokens() {
        print("load tokens")
        self.tokens.token = UserDefaults.standard.string(forKey: "token") ?? ""
        self.tokens.refresh_token = UserDefaults.standard.string(forKey: "refresh_token") ?? ""
    }
    public func checkTokenStatus(){
        if UserDefaults.standard.string(forKey: "token") != nil {
            self.tokenStatus = .exist
            self.loadTokens()
        } else {
            tokenStatus = .none
        }
    }
    public func clearTokens() {
        print("Remove tokens")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        self.tokenStatus = .none
    }
    public func refreshTokens() {
        print("refresh tokens")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(self.tokens.refresh_token)"
        ]
        let url = "https://api.dimigo.in/auth/token/refresh"
        AF.request(url, method: .post, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.tokens.token = json["token"].string!
                    self.tokens.refresh_token = json["refresh_token"].string!
                    self.debugToken()
                    self.saveTokens()
                    self.tokenStatus = .exist
                default:
                    self.tokenStatus = .none
                }
            }
        }
    }
}

