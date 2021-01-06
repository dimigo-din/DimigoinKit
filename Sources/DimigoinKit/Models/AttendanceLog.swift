//
//  File.swift
//  
//
//  Created by 변경민 on 2021/01/05.
//

import Foundation
import Alamofire

public struct Attendance: Identifiable, Hashable, Codable {
    public var id: String
    var name: String
}

public class AttendanceLogAPI: ObservableObject {
    @Published var attendances: [Attendance] = []
    public var placeAPI = PlaceAPI()
    public var userAPI = UserAPI()
    public var tokenAPI = TokenAPI()
    
    public func getUserCurrentLocation() -> Place {
        //
        return Place()
    }
    
    public func setUserLocation(place: Place) {
        
    }
    
    /// 사용자 교실 학생들의 현황을 불러옵니다. ([GET] /attendance-log/class-status)
    public func getClassStatus() {
        LOG("get class attendance status")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let parameters: [String: Any] = [
            "grade": userAPI.user.grade,
            "class": userAPI.user.klass,
            "date": getToday8DigitDateString()
        ]
        let url = "http://edison.dimigo.hs.kr/attendance-log/class-status"
        AF.request(url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200: break //success
//                    ingangStatus = .success
//                    LOG("인강 취소 성공 : 200")
                default:
                    if debugMode {
                        debugPrint(response)
                    }
                    self.tokenAPI.refreshTokens()
//                    ingangStatus = self.applyIngang(time: time)
                }
            }
        }
    }
}
