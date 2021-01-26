//
//  File.swift
//  
//
//  Created by 변경민 on 2021/01/26.
//

import SwiftUI

public var rootURL = "http://edison.dimigo.hs.kr"

public class DimigoinAPI: ObservableObject {
    @Published var accessToken = ""
    @Published var refreshToken = ""
    @Published var isFirstLogin = true

    public init() {
        loadSavedTokens() { result in
            switch result {
            case .success((let accessToken, let refreshToken)):
                self.isFirstLogin = false
                self.accessToken = accessToken
                self.refreshToken = refreshToken
            case .failure(_):
                self.isFirstLogin = true
            }
        }
    }
    
    public func logout() {
        removeTokens {
            self.isFirstLogin = true
        }
    }
    
    public func login(_ username: String, _ password: String, completion: @escaping (Bool) -> Void) {
        fetchTokens(username, password) { result in
            switch result {
                case .success((let accessToken, let refreshToken)):
                    self.isFirstLogin = false
                    self.accessToken = accessToken
                    self.refreshToken = refreshToken
                    completion(true)
                case.failure(_):
                    completion(false)
            }
        }
    }
    
    public func fetchAllData() {
        
    }
}
