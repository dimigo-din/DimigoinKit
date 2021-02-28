//
//  DimigoinAPI.swift
//  DimigoinKit
//
//  Created by 변경민 on 2021/01/26.
//

import SwiftUI

/// 기본적인 API 에러타입 입니다. 특수한 HTTP response error가 없을 때 사용합니다.
public enum defaultError: Error {
    /// 토큰 만료
    case tokenExpired
    /// 알 수 없는 에러(500)
    case unknown
}

/**
 디미고인 iOS앱 app group identifier
 
 # 사용예시 #
 ```
 UserDefaults(suiteName: appGroupName)?
 ```
 */
public var appGroupName: String = "group.in.dimigo.ios"

/**
 API request를 보낼 root url
 
 - Version: 2020 디미고인 백엔드(V3)
 
 # 사용예시 #
 ```
 let url = URL(string: rootURL)
 ```
*/
public var rootURL: String = "https://api.dimigo.in"

/**
 Swift 에서 디미고인 API를 손쉽게 사용할 수 있습니다. MVVM아키텍쳐 중 ViewModel에 해당하는 부분을 구현해두었습니다 🚀
 
 - Version: 2020 디미고인 백엔드(V3)
 
 # Example #
 ```
 @ObseredObejct var api: DimigoinAPI = DimigoinAPI()
 ```
 */
final public class DimigoinAPI: ObservableObject {
    @Published public var isFetching = true
//    {
//        didSet {
//            if isFetching == true {
//                self.fetchAllData { }
//            }
//        }
//    }
    /// 디미고인 API 전반에 걸쳐 활용되는 JWT토큰
    @Published public var accessToken = ""
    
    /// 토큰 새로고침에 사용되는 `refreshToken`
    @Published public var refreshToken = ""
    
    /// 로그인 이력이 있으면 `true` 없으면 `false`
    @Published public var isLoggedIn = false
    
    /// 이름, 학년, 반 등 사용자에 대한 데이터
    @Published public var user = User()
    
    /// 주간 급식 - `meals[0]`부터 월요일 급식
    @Published public var meals = [Meal](repeating: Meal(), count: 7)
    
    /// 인원 체크
    @Published public var attendanceList: [Attendance] = []
    
    @Published public var allAttendanceList: [[Attendance]] = []
    
    /// 모바일용 사용자 맞춤 `Place`
    @Published public var primaryPlaces: [Place] = []
    
    /// 디미고내 모든 장소 `Place`
    @Published public var allPlaces: [Place] = []
    
    /// 사용자의 최근 `Place`
    @Published public var currentPlace: Place = Place()
    
    /// 시간표
    @Published public var timetable = Timetable()
    
    /// 인강 데이터
    @Published public var ingangs: [Ingang] = []
    
    /// 공지사항
    @Published public var notices: [Notice] = []
    
    /// 주간 최대 인강실 신청
    @Published public var weeklyTicketCount: Int = 0
    
    /// 주간 사용한 인강실 신청 티켓
    @Published public var weeklyUsedTicket: Int = 0
    
    /// 주간 남은 인강실 신청 티켓
    @Published public var weeklyRemainTicket: Int = 0
    
    /// 선언과 동시에 모든 API데이터를 패치합니다.
    public init() {
        fetchAllData {
            withAnimation(.easeInOut(duration: 0.5)) { self.isFetching = false }
        }
    }
    
    /// 모든 API데이터를 패치합니다.
    public func fetchAllData(completion: @escaping () -> Void) {
        fetchTokens {
            self.printTokens()
            self.fetchMealData()
            self.fetchAllPlaceData {}
            self.fetchUserData {
                if self.user.type == .teacher {
                    self.fetchAllPlaceData {
                        completion()
                    }
                } else {
                    self.fetchIngangData { }
                    self.fetchTimetableData {
                        saveTimetable(self.timetable)
                    }
                    self.fetchNotices { }
                    self.fetchPrimaryPlaceData {
                        self.fetchUserCurrentPlace {}
                        self.fetchAttendanceListData {
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: -
    /**
     모든 데이터를 삭제하고 로그아웃합니다.
     
     # 사용예시 #
     ```
     dimigoinAPI.logout()
     ```
     */
    public func logout() {
        removeTokens {
            withAnimation(.easeInOut) {
                self.isLoggedIn = false
            }
        }
    }
    
    /**
     유저네임, 패스워드와 함께 로그인을 하고 토큰을 받습니다.
     
     로그인에 성공하면 `accessToken`과  `refreshToken`을 저장합니다.
     
     - Parameters:
         - username: 유저네임
         - password: 비밀번호
         - completion: Bool
     
     - returns: `comletion`을 통해 성공하면 `true`, 실패하면 `false`를 반환합니다.

     # 사용예시 #
     ```
     dimigoinAPI.login("username here", "password here") { result in
        if result == true {
            // 로그인 성공
        }
        else {
            // 로그인 실패
        }
     }
     ```
     */
    public func login(_ username: String, _ password: String, _ fcmToken: String, completion: @escaping (Bool) -> Void) {
        getTokens(username, password) { result in
            switch result {
                case .success((let accessToken, let refreshToken)):
                    withAnimation(.easeInOut) {
                        self.isLoggedIn = true
                    }
                    self.accessToken = accessToken
                    self.refreshToken = refreshToken
                    self.fetchFCMToken(fcmToken: fcmToken) { }
                    self.fetchAllData { }
                    completion(true)
                case.failure(_):
                    completion(false)
            }
        }
    }
    
    /**
     기기에 저장된 토큰을 패치합니다.
     
     - Parameters:
     - completion: Void
     
     # 사용예시 #
     ```
     dimigoinAPI.fetchTokens {
        // 패치 후 작업
     }
     ```
     */
    public func fetchTokens(completion: @escaping () -> Void) {
        loadSavedTokens() { result in
            switch result {
            case .success((let accessToken, let refreshToken)):
                withAnimation(.easeInOut) { self.isLoggedIn = true }
                self.accessToken = accessToken
                self.refreshToken = refreshToken
            case .failure(_):
                withAnimation(.easeInOut) { self.isLoggedIn = false }
            }
            completion()
        }
    }
    
    public func fetchFCMToken(fcmToken: String, completion: @escaping () -> Void) {
        deleteFCMToken(accessToken) {
            registerFCMToken(self.accessToken, fcmToken) { result in
                switch result {
                case .success(()):
                    completion()
                case .failure(_):
                    completion()
                }
            }
        }
    }
    /**
     🔄 토큰을 새로고침 합니다. 🔄
     
     - Parameters:
     - completion: Void
     
     # 사용예시 #
     ```
     dimigoinAPI.refreshTokens {
        // 새로고침 후 작업
     }
     ```
     */
    public func refreshTokens(completion: @escaping() -> Void) {
        getTokens(refreshToken) { result in
            switch result {
            case .success((let accessToken, let refreshToken)):
                self.isLoggedIn = true
                self.accessToken = accessToken
                self.refreshToken = refreshToken
            case .failure(_):
                self.isLoggedIn = false
            }
            completion()
        }
    }
    
    public func printTokens() {
        print("AccessToken: \(accessToken)")
        print("refreshToken: \(refreshToken)")

    }
    
    
    
    // MARK: -
    
    public func fetchNotices(completion: @escaping() -> Void) {
        getRecentNotice(accessToken) { result in
            switch result {
            case .success((let notices)):
                self.notices = notices
            case .failure(_):
                print("notice fail")
            }
            completion()
        }
    }
    
    // MARK: -
    /**
     🍴 오늘의 급식 정보를 반환합니다. 🍴
     
     - returns: `Meal`타입 급식 정보를 반환합니다.
     
     # 사용예시 #
     ```
     dimigoinAPI.getTodayMeal()
     ```
     */
    public func getTodayMeal() -> Meal {
        meals[getTodayDayOfWeekInt()-1]
    }
    
    /**
     일주일치 급식을 패치합니다.
     
     # 사용예시 #
     ```
     dimigoinAPI.fetchMealData()
     ```
    */
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
    
    // MARK: -
    /**
     인강 데이터 중 자신이 신청한 인강의 `isApplied`를 `true`로 바꿉니다.
     
     - Warning: `fetchIngang()` 이후에 실행되어야합니다.
     
     # 사용예시 #
     ```
     dimigoinAPI.checkIfApplied()
     ```
     */
    public func checkIfApplied() {
       for i in 0..<ingangs.count {
           for applicant in ingangs[i].applicants {
                if(applicant.name == user.name) {
                   ingangs[i].isApplied = true
               }
           }
       }
    }
    
    public func getApplicant(_ time: IngangTime, _ applicantIdx: Int) -> Applicant {
        if applicantIdx <= ingangs[time == .NSS1 ? 0 : 1].applicants.count {
            return ingangs[time == .NSS1 ? 0 : 1].applicants[applicantIdx-1]
        } else {
            return Applicant()
        }
        
    }
    
    /**
     인강을 신청합니다.
     
     - Parameters:
         - time: `.NSS1` 또는 `.NSS2`
         - completion: `Result<(Void), IngangError>`
     
     - returns: 실패하면 `IngangError`를 반환합니다.
     
     # 사용예시 #
     ```
     dimigoinAPI.applyIngang(time: .NSS1) { result in
         switch result {
         case .success(()):
             // 신청 성공
         case .failure(let error):
             // 신청 실패 (error)
         }
     }
     ```
     */
    public func applyIngang(ingang: Ingang, completion: @escaping (Result<(Void), IngangError>) -> Void) {
        let ingangTime:Int = ingang.time == .NSS1 ? 0 : 1
        withAnimation(.easeInOut) { ingangs[ingangTime].isFetching = true }
        manageIngang(accessToken, ingang: ingang, method: .post) { result in
            switch result {
            case .success(()):
                self.fetchIngangData() {
                    withAnimation(.easeInOut) { self.ingangs[ingangTime].isFetching = false }
                    completion(.success(()))
                }
            case .failure(let error):
                withAnimation(.easeInOut) { self.ingangs[ingangTime].isFetching = false }
                completion(.failure(error))
            }
        }
    }
    
    /**
     인강을 취소합니다.
     
     - Parameters:
         - time: `.NSS1` 또는 `.NSS2`
         - completion: `Result<(Void), IngangError>`
     
     - returns: 실패하면 `IngangError`를 반환합니다.
     
     # 사용예시 #
     ```
     dimigoinAPI.cancelIngang(time: .NSS1) { result in
         switch result {
         case .success(()):
             // 취소 성공
         case .failure(let error):
             // 취소 실패 (error)
         }
     }
     ```
     */
    public func cancelIngang(ingang: Ingang, completion: @escaping (Result<(Void), IngangError>) -> Void) {
        let ingangTime:Int = ingang.time == .NSS1 ? 0 : 1
        withAnimation(.easeInOut) { ingangs[ingangTime].isFetching = true }
        manageIngang(accessToken, ingang: ingang, method: .delete) { result in
            switch result {
            case .success(()):
                self.fetchIngangData() {
                    withAnimation(.easeInOut) { self.ingangs[ingangTime].isFetching = false }
                    completion(.success(()))
                }
            case .failure(let error):
                withAnimation(.easeInOut) { self.ingangs[ingangTime].isFetching = false }
                completion(.failure(error))
            }
        }
    }
    
    /**
     인강 데이터를 새로고침 합니다.
     
     # 사용예시 #
     ```
     dimigoinAPI.fetchIngangData() {
        // 패치 후 작업
     }
     ```
     */
    public func fetchIngangData(completion: @escaping () -> Void) {
        getIngangData(accessToken, name: user.name) { result in
            switch result {
            case .success((let weeklyTicketCount, let weeklyUsedTicket, let weeklyRemainTicket, let ingangs)):
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.weeklyTicketCount = weeklyTicketCount
                    self.weeklyUsedTicket = weeklyUsedTicket
                    self.weeklyRemainTicket = weeklyRemainTicket
                    self.ingangs = ingangs
                }
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    self.refreshTokens {}
                default:
                    print("fetch Ingang Data error : unknown")
                }
            }
            completion()
        }
    }
    
    // MARK: -
    /**
     사용자의 위치를 바꿉니다.
     
     - Parameters:
         - placeName: 바뀐 장소 이름
         - remark: 사유
         - completion: Bool
     
     - returns: `Result<(Bool), AttendanceError>`
     
     # API Method #
     `POST`
     
     # API EndPoint #
     `{rootURL}/attendance-log`
     
     # 사용예시 #
     ```
     dimigoinAPI.changeUserPlace(placeName: "교장실", remark: "면담좀 ..") { result in
         switch result {
         case .success(()):
             // 변경 성공
         case .failure(let error):
             // 변경 실패 (error)
         }
     }
     ```
     */
    public func changeUserPlace(placeName: String, remark: String, completion: @escaping (Result<Void, AttendanceError>) -> Void) {
        setUserPlace(accessToken, placeName: placeName, places: allPlaces, remark: remark) { result in
            switch result {
            case .success(_):
                self.fetchUserCurrentPlace {
                    completion(.success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func isPrimaryPlace(place: Place) -> Bool {
        for primaryPlace in primaryPlaces {
            if primaryPlace.id == place.id {
                return true
            }
        }
        return false
    }
    
    public func findPrimaryPlaceByLabel(label: String) -> Place{
        return findPlaceByLabel(label: label, from: primaryPlaces)
    }
    
    // MARK: -
    /**
     사용자의 반의 시간표 중 수업 이름을 가져옵니다.
     
     - Parameters:
         - weekDay: N요일, 월요일 = 1 부터 금요일 = 5 맵핑
         - period: N교시, 데이터가 없다면 비어있는 문자열 반환
     
     - returns: 수업 이름
     
     # 사용예시 #
     ```
     // 월요일 5교시 수업 이름
     dimigoinAPI.getLectureName(weekDay: 1, period: 5)
     ```
     */
//    public func getLectureName(weekDay: Int, period: Int) -> String {
//        for i in 0..<lectureList.count {
//            if(lectureList[i].weekDay == weekDay && lectureList[i].period == period) {
//                return lectureList[i].subject
//            }
//        }
//        return ""
//    }

    /**
     사용자의 학년, 반에 맞는 시간표를 패치 합니다,
     
     - Warning: `fetchUserData()` 이후에 실행되어야 합니다.
     
     # API Method #
     `GET`
     
     # API EndPoint #
     `{rootURL}/timetable/weekly/grade/{학년}/class/{반}`
     
     # 사용예시 #
     ```
     dimigoinAPI.fetchLectureData {
        // 패치 후 작업
     }
     ```
     */
    public func fetchTimetableData(completion: @escaping () -> Void) {
        getTimetable(accessToken, grade: user.grade, klass: user.klass) { result in
            switch result {
            case .success((let timetable)):
                self.timetable = timetable
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    self.refreshTokens {}
                default:
                    print("fetch Lecture Data error : unknown")
                }
            }
            completion()
        }
    }
    
    /**
     사용자 데이터를 패치합니다.
     
     # API Method #
     `GET`
     
     # API EndPoint #
     `{rootURL}/user/me`
     
     # 사용예시 #
     ```
     dimigoinAPI.fetchUserData {
        // 패치 후 작업
     }
     ```
     */
    public func fetchUserData(completion: @escaping () -> Void) {
        getUserData(accessToken) { result in
            switch result {
            case .success((let user)):
                self.user = user
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    self.refreshTokens {}
                default:
                    print("fetch User Data error : unknown")
                }
            }
            completion()
        }
    }
    
    /**
     사용자 맞춤 장소 데이터를 패치합니다.
     
     - Warning: `fetchUserData()` 이후에 실행되어야 합니다.
     
     # API Method #
     `GET`
     
     # API EndPoint #
     `{rootURL}/place/primary`
     
     # 사용예시 #
     ```
     dimigoinAPI.fetchPrimaryPlaceData {
        // 패치 후 작업
     }
     ```
     */
    public func fetchPrimaryPlaceData(completion: @escaping () -> Void) {
        getPrimaryPlace(accessToken) { result in
            switch result {
            case .success((let places)):
                withAnimation() {
                    self.primaryPlaces = places
                }
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    self.refreshTokens {}
                default:
                    print("fetch Primary Place Data error : unknown")
                }
            }
            completion()
        }
    }
    
    /**
     디미고 내 모든 장소 데이터를 패치합니다.
     
     - Warning: `fetchUserData()` 이후에 실행되어야 합니다.
     
     # API Method #
     `GET`
     
     # API EndPoint #
     `{rootURL}/place`
     
     # 사용예시 #
     ```
     dimigoinAPI.fetchAllPlaceData {
        // 패치 후 작업
     }
     ```
     */
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
                    print("fetch All Place Data error : unknown")
                }
            }
            completion()
        }
    }
    /**
     사용자 최근 장소 정보를 받아옵니다.
     
     # API Method #
     `GET`
     
     # API EndPoint #
     `{rootURL}/attendance-log/my-status`
     
     # 사용예시 #
     ```
     dimigoinAPI.fetchUserCurrentPlace {
        // 패치 후 작업
     }
     ```
     */
    public func fetchUserCurrentPlace(completion: @escaping () -> Void) {
        getUserCurrentPlace(accessToken, places: allPlaces, myPlaces: primaryPlaces) { result in
            switch result {
            case .success((let place)):
                withAnimation(.easeInOut) { self.currentPlace = place }
                completion()
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    self.refreshTokens {
                    }
                case .noSuchPlace:
                    self.currentPlace = findPlaceByLabel(label: "교실", from: self.primaryPlaces)
                case .notRightTime:
                    print("fetch User Current Place Data error : notRightTime")
                case .unknown:
                    print("fetch User Current Place Data error : unknown")
                }
                completion()
            }
        }
    }
    
    public func fetchAttendanceListData(completion: @escaping () -> Void) {
        getAttendenceList(accessToken, user: user) { result in
            switch result {
            case .success((let attendanceList)):
                withAnimation(.easeInOut) { self.attendanceList = attendanceList }
                completion()
            case .failure(let error):
                switch error {
                case .tokenExpired:
                    self.refreshTokens {
                    }
                case .noSuchPlace:
                    print("no Such Place")
                default:
                    print("fetch Attendance Data error : unknown")
                }
                completion()
            }
        }
    }
    
    public func fetchAllAttendanceListData(completion: @escaping () -> Void) {
        for grade in 1...3 {
            for klass in 1...6 {
                getAttendenceList(accessToken, grade: grade, klass: klass) { result in
                    switch result {
                    case .success((let attendanceList)):
                        self.attendanceList = attendanceList
                        completion()
                    case .failure(let error):
                        switch error {
                        case .tokenExpired:
                            self.refreshTokens {
                            }
                        case .noSuchPlace:
                            print("no Such Place")
                        default:
                            print("fetch Attendance Data error : unknown")
                        }
                        completion()
                    }
                }
            }
        }
    }
}
