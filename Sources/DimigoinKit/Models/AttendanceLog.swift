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
    public func setUserLocation(place: Place) {
        LOG("set user location")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let parameters: [String: String] = [
            "place": place.id,
            "remark": place.location
        ]
        let url = "http://edison.dimigo.hs.kr/attendance-log"
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    LOG("set user location to \(place.name)")
                default:
                    if debugMode {
                        debugPrint(response)
                    }
                    self.tokenAPI.refreshTokens()
                    self.setUserLocation(place: place)
                }
            }
        }
    }
    
    /// 간단한 메세지와 함께 사용자의 위치를 설정합니다 ([POST] /attendance-log)
    public func setUserLocation(place: Place, remark: String) {
        LOG("set user location")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let parameters: [String: String] = [
            "place": place.id,
            "remark": remark
        ]
        let url = "http://edison.dimigo.hs.kr/attendance-log"
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    LOG("set user location to \(place.name)")
                default:
                    if debugMode {
                        debugPrint(response)
                    }
                    self.tokenAPI.refreshTokens()
                    self.setUserLocation(place: place)
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
        let url = "http://edison.dimigo.hs.kr/attendance-log/class-status/date/\(getToday8DigitDateString())/grade/\(userAPI.user.grade)/class/\(userAPI.user.klass)"
        AF.request(url, method: .get, encoding: URLEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.sortAttendances(attendances: json)
                default:
                    if debugMode {
                        debugPrint(response)
                    }
                    self.tokenAPI.refreshTokens()
                    self.getClassmatesStatus()
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
        let url = "http://edison.dimigo.hs.kr/attendance-log/my-status"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    self.myCurrentLocation = self.placeAPI.getMatchedPlace(id: json["myLogs"][0]["place"]["_id"].string!)
                    self.debugMyLocation()
                default:
                    if debugMode {
                        debugPrint(response)
                    }
                    self.tokenAPI.refreshTokens()
                    self.getMyCurrentLocation()
                }
            }
        }
    }
    
    public func debugMyLocation() {
        LOG(self.myCurrentLocation)
    }
}
