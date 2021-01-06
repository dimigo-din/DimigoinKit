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
    public init() {
        self.id = ""
        self.name = ""
        self.location = ""
        self.description = ""
    }
    public init(id: String, name: String, location: String, description: String) {
        self.id = id
        self.name = name
        self.location = location
        self.description = description
    }
}

/// 디미고인 장소 관련 API
public class PlaceAPI: ObservableObject {
    @Published var places: [Place] = []
    public var tokenAPI = TokenAPI()
    
    public init() {
        getAllPlaces()
    }
    
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
                    self.sortPlaces(places: json)
                    self.debugPlace()
                default:
                    debugPrint(response)
                    self.tokenAPI.refreshTokens()
                    self.getAllPlaces()
                }
            }
        }
    }
    
    /// API부터 전달 받은 JSON파일을 장소 데이터로 변환하여 차곡차곡 정리합니다.
    public func sortPlaces(places: JSON) {
        for i in 0..<places["places"].count {
            self.places.append(Place(id: places["places"][i]["_id"].string!,
                                     name: places["places"][i]["name"].string!,
                                     location: places["places"][i]["location"].string!,
                                     description: places["places"][i]["description"].string!))
        }
    }
    
    /// 장소 정보들을 출력합니다.
    public func debugPlace() -> Void {
        LOG("\(places.count) places were found")
    }
    
    /// Place ID를 통해 장소의 이름을 반환합니다.
    public func getMatchedPlaceName(id: String) -> String {
        var placeName = ""
        for place in places {
            if(place.id == id) {
                placeName = place.name
            }
        }
        return placeName
    }
    
    /// Place ID를 통해 장소를 반환합니다.
    public func getMatchedPlace(id: String) -> Place {
        for place in places {
            if(place.id == id) {
                return place
            }
        }
        return getMatchedPlace(name: "교실")
    }
    
    /// 장소 이름을 통해 장소를 반환합니다.
    public func getMatchedPlace(name: String) -> Place {
        for place in places {
            if(place.name == name) {
                return place
            }
        }
        return Place()
    }
}


