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

/// 디미고인 API(토큰, 유저 정보, 급식, 장소, 인강, 시간표 등)
public class DimigoinAPI: ObservableObject {
    @Published public var accessToken = ""
    @Published public var refreshToken = ""
    @Published public var isFirstLogin = true
    @Published public var user = User()
    @Published public var meals = [Meal](repeating: Meal(), count: 7)
    @Published public var myPlaces: [Place] = []
    @Published public var allPlaces: [Place] = []
    @Published public var currentPlace: Place = Place()
    @Published public var lectureList: [Lecture] = []
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
    
    /// 모든 API데이터를 패치합니다.
    public func fetchAllData() {
        fetchTokens {
            self.fetchMealData()
            self.fetchAllPlaceData {}
            self.fetchUserData {
                self.fetchIngangData {}
                self.fetchPrimaryPlaceData {}
                self.fetchUserCurrentPlace {}
            }
        }
    }
    
    // MARK: 토큰 API 관련
    // FIXME: 로그아웃 시 모든 데이터 삭제, 로그인 시 새로 패치
    /// 로그아웃
    public func logout() {
        removeTokens {
            withAnimation() {
                self.isFirstLogin = true
            }
        }
    }
    
    /// 로그인
    public func login(_ username: String, _ password: String, completion: @escaping (Bool) -> Void) {
        getTokens(username, password) { result in
            switch result {
                case .success((let accessToken, let refreshToken)):
                    withAnimation() {
                        self.isFirstLogin = false
                    }
                    self.accessToken = accessToken
                    self.refreshToken = refreshToken
                    completion(true)
                case.failure(_):
                    completion(false)
            }
        }
        fetchAllData()
    }
    
    /// 토큰을 패치합니다.
    public func fetchTokens(completion: @escaping () -> Void) {
        loadSavedTokens() { result in
            switch result {
            case .success((let accessToken, let refreshToken)):
                self.isFirstLogin = false
                self.accessToken = accessToken
                self.refreshToken = refreshToken
            case .failure(_):
                self.isFirstLogin = true
            }
            completion()
        }
    }
    
    /// 토큰을 새로고침 합니다.
    public func refreshTokens(completion: @escaping() -> Void) {
        getTokens(refreshToken) { result in
            switch result {
            case .success((let accessToken, let refreshToken)):
                self.isFirstLogin = false
                self.accessToken = accessToken
                self.refreshToken = refreshToken
            case .failure(_):
                self.isFirstLogin = true
            }
            completion()
        }
    }
    
    // MARK: 급식 API 관련
    /// 오늘의 급식을 반환 합니다.
    public func getTodayMeal() -> Meal {
        meals[getTodayDayOfWeekInt()-1]
    }
    
    /// 일주일치 급식을 업데이트 합니다.
    public func fetchMealData() {
        let dates:[String] = [get8DigitDateString(.mon),
                              get8DigitDateString(.tue),
                              get8DigitDateString(.wed),
                              get8DigitDateString(.thu),
                              get8DigitDateString(.fri),
                              get8DigitDateString(.sat),
                              get8DigitDateString(.sun)]
        for index in 0..<dates.count {
            getMeal(from: dates[index]) { result in
                self.meals[index] = result
            }
        }
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
                self.fetchIngangData() {
                    completion(.success(()))
                }
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
                self.fetchIngangData() {
                    completion(.success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 인강 데이터를 새로고침합니다.
    public func fetchIngangData(completion: @escaping () -> Void) {
        getIngangData(accessToken, name: user.name) { result in
            switch result {
            case .success((let weeklyTicketCount, let weeklyUsedTicket, let weeklyRemainTicket, let ingangs)):
                self.weeklyTicketCount = weeklyTicketCount
                self.weeklyUsedTicket = weeklyUsedTicket
                self.weeklyRemainTicket = weeklyRemainTicket
                self.ingangs = ingangs
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    self.refreshTokens {}
                default:
                    print("unknown")
                }
            }
            completion()
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
    
    // MARK: 시간표 API관련
    public func getLectureName(weekDay: Int, period: Int) -> String {
        for i in 0..<lectureList.count {
            if(lectureList[i].weekDay == weekDay && lectureList[i].period == period) {
                return lectureList[i].subject
            }
        }
        return ""
    }

    public func fetchLectureData(completion: @escaping () -> Void) {
        getLectureList(accessToken, grade: user.grade, klass: user.klass) { result in
            switch result {
            case .success((let lectureList)):
                self.lectureList = lectureList
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    self.refreshTokens {}
                default:
                    print("unknown")
                }
            }
            completion()
        }
    }
    public func fetchUserData(completion: @escaping () -> Void) {
        getUserData(accessToken) { result in
            switch result {
            case .success((let user)):
                self.user = user
                self.fetchLectureData() {
                    
                }
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    self.refreshTokens {}
                default:
                    print("unknown")
                }
            }
            completion()
        }
    }
    
    public func fetchPrimaryPlaceData(completion: @escaping () -> Void) {
        getPrimaryPlace(accessToken) { result in
            switch result {
            case .success((let places)):
                self.myPlaces = places
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    self.refreshTokens {}
                default:
                    print("unknown")
                }
            }
            completion()
        }
    }
    
    public func fetchAllPlaceData(completion: @escaping () -> Void) {
        getAllPlace(accessToken) { result in
            switch result {
            case .success((let places)):
                self.allPlaces = places
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    self.refreshTokens {}
                default:
                    print("unknown")
                }
            }
            completion()
        }
    }
    private func fetchUserCurrentPlace(completion: @escaping () -> Void) {
        getUserCurrentPlace(accessToken, places: allPlaces, myPlaces: myPlaces) { result in
            switch result {
            case .success((let place)):
                self.currentPlace = place
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    self.refreshTokens {}
                default:
                    print("unknown")
                }
            }
            completion()
        }
    }
}
