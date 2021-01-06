//
//  File.swift
//  
//
//  Created by 변경민 on 2021/01/05.
//

import SwiftUI
import SwiftyJSON
import Alamofire

public struct Place: Codable, Identifiable {
    public var id: String
    var name: String
    var location: String
    var description: String
    public init(id: String, name: String, location: String, description: String) {
        self.id = id
        self.name = name
        self.location = location
        self.description = description
    }
    public init() {
        self.id = ""
        self.name = ""
        self.location = ""
        self.description = ""
    }
}

/// 디미고인 장소 관련 API
public class PlaceAPI: ObservableObject {
    @Published var places: [Place] = []
    
    /// API에 저장된 모든 장소 정보를 불러옵니다. ([GET] /place)
    public func getAllPlaces() {
        LOG("get all place data")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let url = "http://edison.dimigo.hs.kr/place"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).response { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value!!)
                    for i in 0..<json.count {
                        self.notices.append(Notice(title: json["notices"][i]["title"].string!, content: json["notices"][i]["content"].string!))
                    }
                    self.debugNotice()
                default:
                    debugPrint(response)
                    self.tokenAPI.refreshTokens()
                    self.getNotice()
                }
            }
        }
    }
    
    public func getMatchedPlaceName(id: String) -> String {
        var placeName = ""
        for place in places {
            if(place.id == id) {
                placeName = place.name
            }
        }
        return placeName
    }
    
    public func getPlace(name: String) -> Place {
        var plc = Place()
        for place in places {
            if(place.name == name) {
                plc = place
            }
        }
        return plc
    }
    
    
}


