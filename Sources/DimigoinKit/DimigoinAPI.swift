//
//  DimigoinAPI.swift
//  DimigoinKit
//
//  Created by 변경민 on 2021/01/26.
//

import SwiftUI

public enum defaultError: Error {
    case tokenExpired
    case unknown
}
public var appGroupName: String = "group.in.dimigo.ios"

public var rootURL = "http://edison.dimigo.hs.kr"

public class DimigoinAPI: ObservableObject {
    @Published public var accessToken = ""
    @Published public var refreshToken = ""
    @Published public var isFirstLogin = true
    @Published public var user = User()
    @Published public var meals = [Meal](repeating: Meal(), count: 7)
    @Published public var myPlaces: [Place] = []
    @Published public var allPlaces: [Place] = []
    @Published public var currentPlace: Place = Place()
    @Published public var ingangs: [Ingang] = [
       Ingang(date: getToday8DigitDateString(), time: .NSS1, applicants: []),
       Ingang(date: getToday8DigitDateString(), time: .NSS2, applicants: [])
    ]
    @Published public var weeklyTicketCount: Int = 0
    @Published public var weeklyUsedTicket: Int = 0
    @Published public var weeklyRemainTicket: Int = 0
    
    public init() {
        fetchAllData()
    }
    
    // MARK: 토큰 API 관련
    /// 로그아웃
    public func logout() {
        removeTokens {
            self.isFirstLogin = true
        }
    }
    
    /// 로그인
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
    
    // MARK: 급식 API 관련
    /// 오늘의 급식을 반환 합니다.
    public func getTodayMeal() -> Meal {
        Meal()
    }
    
    // MARK: 인강 API 관련
    /// 인강 신청자 내역 중 자신의 이름이 있는지 검사하고, 맞다면 신청된 상태로 만듭니다.
    /// * fetchUserData() 이후에 실행되어야합니다.
    public func checkIfApplied() {
       for i in 0..<ingangs.count {
           for applicant in ingangs[i].applicants {
                if(applicant.name == user.name) {
                   ingangs[i].isApplied = true
               }
           }
       }
    }
    
    /// 인강을 신청합니다.
    public func applyIngang(time: IngangTime, completion: @escaping (Result<(Void), IngangError>) -> Void) {
        manageIngang(accessToken, time: time, method: .post) { result in
            switch result {
            case .success(()):
                self.fetchIngangData()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 인강을 취소합니다.
    public func cancelIngang(time: IngangTime, completion: @escaping (Result<(Void), IngangError>) -> Void) {
        manageIngang(accessToken, time: time, method: .delete) { result in
            switch result {
            case .success(()):
                self.fetchIngangData()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 인강 데이터를 새로고침합니다.
    public func fetchIngangData() {
        fetchIngang(accessToken, name: user.name) { result in
            switch result {
            case .success((let weeklyTicketCount, let weeklyUsedTicket, let weeklyRemainTicket, let ingangs)):
                self.weeklyTicketCount = weeklyTicketCount
                self.weeklyUsedTicket = weeklyUsedTicket
                self.weeklyRemainTicket = weeklyRemainTicket
                self.ingangs = ingangs
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    print("tokenExpired")
                default:
                    print("unknown")
                }
            }
        }
    }
    
    // MARK: Attendance Log API 관련
    public func changeUserPlace(placeName: String, remark: String, completion: @escaping (Result<(Bool), AttendanceError>) -> Void) {
        setUserPlace(accessToken, placeName: placeName, places: allPlaces, remark: remark) { result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// 모든 API데이터를 패치합니다.
    public func fetchAllData() {
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
        
        fetchUserData(accessToken) { result in
            switch result {
            case .success((let user)):
                self.user = user
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    print("tokenExpired")
                default:
                    print("unknown")
                }
            }
        }
        fetchWeeklyMeal() { result in
            self.meals = result
        }
        fetchIngang(accessToken, name: user.name) { result in
            switch result {
            case .success((let weeklyTicketCount, let weeklyUsedTicket, let weeklyRemainTicket, let ingangs)):
                self.weeklyTicketCount = weeklyTicketCount
                self.weeklyUsedTicket = weeklyUsedTicket
                self.weeklyRemainTicket = weeklyRemainTicket
                self.ingangs = ingangs
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    print("tokenExpired")
                default:
                    print("unknown")
                }
            }
        }
        fetchMyPlaces(accessToken) { result in
            switch result {
            case .success((let places)):
                self.myPlaces = places
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    print("tokenExpired")
                default:
                    print("unknown")
                }
            }
        }
        fetchAllPlaces(accessToken) { result in
            switch result {
            case .success((let places)):
                self.allPlaces = places
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    print("tokenExpired")
                default:
                    print("unknown")
                }
            }
        }
        fetchMyCurrentPlace(accessToken, places: allPlaces, myPlaces: myPlaces) { result in
            switch result {
            case .success((let place)):
                self.currentPlace = place
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    print("tokenExpired")
                default:
                    print("unknown")
                }
            }
        }
    }
}
