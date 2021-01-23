//
//  File.swift
//  
//
//  Created by 변경민 on 2021/01/05.
//

import Foundation
import Alamofire
import SwiftyJSON

public struct Attendance {
    public var id: String
    var name: String
    var currentLocation: Place
    init() {
        self.id = ""
        self.name = ""
        self.currentLocation = Place()
    }
    init(id: String, name: String, currentLocation: Place) {
        self.id = id
        self.name = name
        self.currentLocation = currentLocation
    }
}

public class AttendanceLogAPI: ObservableObject {
    @Published var attendances: [Attendance] = []
    @Published var myCurrentLocation: Place = Place()
    public var placeAPI = PlaceAPI()
    public var userAPI = UserAPI()
    public var tokenAPI = TokenAPI()
    
    public init() {
        getMyCurrentLocation()
//        getClassmatesStatus()
    }
    
    /// 사용자의 위치를 설정합니다 ([POST] /attendance-log)
    public func setMyLocation(place: Place) {
        LOG("set user location")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let parameters: [String: String] = [
            "place": place.id,
            "remark": place.location
        ]
        let endPoint = "/attendance-log"
        let method: HTTPMethod = .post
        AF.request(rootURL+endPoint, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    LOG("set user location to \(place.name)")
                case 400:
                    LOG("Place 못찾음")
                case 401:
                    // MARK: Token Expired
                    LOG("토큰 만료")
                    self.tokenAPI.refreshTokens()
                case 423:
                    LOG("출입인증을 할 수 있는 시간이 아님")
                default:
                    if debugMode {
                        debugPrint(response)
                    }
                    self.tokenAPI.refreshTokens()
//                    self.setMyLocation(place: place)
                }
            }
        }
    }
    
    /// 간단한 메세지와 함께 사용자의 위치를 설정합니다 ([POST] /attendance-log)
    public func setMyLocation(place: Place, remark: String) {
        LOG("set user location")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let parameters: [String: String] = [
            "place": place.id,
            "remark": remark
        ]
        let endPoint = "/attendance-log"
        let method: HTTPMethod = .post
        AF.request(rootURL+endPoint, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    LOG("set user location to \(place.name)")
                case 400:
                    LOG("Place 못찾음")
                case 401:
                    // MARK: Token Expired
                    LOG("토큰 만료")
                    self.tokenAPI.refreshTokens()
                case 423:
                    LOG("출입인증을 할 수 있는 시간이 아님")
                default:
                    if debugMode {
                        debugPrint(response)
                    }
                    self.tokenAPI.refreshTokens()
//                    self.setMyLocation(place: place)
                }
            }
        }
    }
    
    /// 사용자 교실 학생들의 현황을 불러옵니다. ([GET] /attendance-log/class-status)
    public func getClassmatesStatus() {
        LOG("get class mates attendance status")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let endPoint = "/attendance-log/class-status/date/\(getToday8DigitDateString())/grade/\(userAPI.user.grade)/class/\(userAPI.user.klass)"
        let method: HTTPMethod = .get
        AF.request(rootURL+endPoint, method: method, encoding: URLEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.sortAttendances(attendances: json)
                case 401:
                    // MARK: Token Expired
                    LOG("토큰 만료")
                    self.tokenAPI.refreshTokens()
                default:
                    if debugMode {
                        debugPrint(response)
                    }
                    self.tokenAPI.refreshTokens()
//                    self.getClassmatesStatus()
                }
            }
        }
    }
    
    public func sortAttendances(attendances: JSON) {
        print(attendances)
//        for i in 0..<attendances["classLogs"].count {
            print(attendances["classLogs"])
//        }
    }
    
    /// 자신의 최근 위치를 조회합니다. ([GET] /attendance-log/my-status)
    public func getMyCurrentLocation() {
        LOG("get my current Location")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let endPoint = "/attendance-log/my-status"
        let method: HTTPMethod = .get
        AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.myCurrentLocation = self.placeAPI.getMatchedPlace(name: json["myLogs"][0]["place"]["name"].string ?? "교실")
                    self.debugMyLocation()
                case 401:
                    // MARK: Token Expired
                    LOG("토큰 만료")
                    self.tokenAPI.refreshTokens()
                default:
                    if debugMode {
                        debugPrint(response)
                    }
                    self.tokenAPI.refreshTokens()
//                    self.getMyCurrentLocation()
                }
            }
        }
    }
    
    public func debugMyLocation() {
        LOG(self.myCurrentLocation)
    }
}
