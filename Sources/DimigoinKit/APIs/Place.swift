//
//  Place.swift
//  DimigoinKit
//
//  Created by 변경민 on 2021/01/26.
//

import Foundation
import SwiftyJSON
import Alamofire

/// Place 모델 정의
public struct Place: Hashable {
    public var id: String
    public var label: String
    public var name: String
    public var location: String
    public var type: PlaceType
    public init() {
        self.id = ""
        self.label = ""
        self.name = ""
        self.location = ""
        self.type = .etc
    }
    public init(id: String, label: String, name: String, location: String, type: PlaceType) {
        self.id = id
        self.label = label
        self.name = name
        self.location = location
        self.type = type
    }
}

public enum PlaceType: Hashable {
    case etc
    case classroom
    case circle
    case ingang
}

/// Place API 오류 정의
public enum PlaceError: Error {
    case tokenExpired
    case notRegisteredPlace
    case unknown
}

/// API에 저장된 모든 장소 정보를 불러옵니다. ([GET] /place)
public func getAllPlace(_ accessToken: String, completion: @escaping (Result<[Place], PlaceError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let endPoint = "/place"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                let json = JSON(response.value!!)
                completion(.success(json2PlaceList(places: json["places"])))
            case 401:
                completion(.failure(.tokenExpired))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}

/// 사용자 맞춤 장소 정보를 불러옵니다.
public func getPrimaryPlace(_ accessToken: String, completion: @escaping (Result<[Place], PlaceError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let endPoint = "/place/primary"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                let json = JSON(response.value!!)
                completion(.success(json2PlaceList(places: json["places"])))
            case 401:
                completion(.failure(.tokenExpired))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}

/// 사용자 장소를 설정합니다.
public func setUserPlace(_ accessToken: String, placeName: String, description: String, places: [Place], completion: @escaping (Result<Void, PlaceError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization":"Bearer \(accessToken)"
    ]
    let parameters: [String: String] = [
        "name": "\(placeName)",
        "location": "\(findPlaceByName(name: placeName, from: places).location)",
        "description": "\(description)"
    ]
    let endPoint = "/place"
    let method: HTTPMethod = .post
    AF.request(rootURL+endPoint, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                completion(.success(()))
            case 401:
                completion(.failure(.tokenExpired))
            case 404:
                completion(.failure(.notRegisteredPlace))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}
    
/// API부터 전달 받은 JSON파일을 장소 데이터로 변환하여 차곡차곡 정리합니다.
public func json2PlaceList(places: JSON) -> [Place] {
    var placeList:[Place] = []
    for i in 0..<places.count {
        placeList.append(Place(id: places[i]["_id"].string!,
                               label: places[i]["label"].string ?? "",
                               name: places[i]["name"].string!,
                               location: places[i]["location"].string!,
                               type: getPlaceType(places[i]["type"].string!)))
    }
    return placeList.sorted(by: {$0.name < $1.name})
}

public func getPlaceType(_ placeType: String) -> PlaceType {
    switch placeType {
    case "ETC": return .etc
    case "CLASSROOM": return .classroom
    case "INGANG": return .ingang
    case "CIRCLE": return .circle
    default: return .etc
    }
}
    
public func placeType2String(_ placeType: PlaceType) -> String {
    switch placeType {
    case .etc: return "기타"
    case .classroom: return "교실"
    case .ingang: return "인강실"
    case .circle: return "동아리"
    }
    
}

/// 장소  레이블을 통해 장소를 반환합니다.
public func findPlaceByLabel(label: String, from places: [Place]) -> Place {
    for place in places {
        if(place.label == label) {
            return place
        }
    }
    return Place()
}

/// 장소 이름을 통해 장소를 반환합니다.
public func findPlaceByName(name: String, from places: [Place]) -> Place {
    for place in places {
        if(place.name == name) {
            return place
        }
    }
    return Place()
}

/// 장소 id를 통해 장소를 반환합니다.
public func findPlaceById(id: String, from places: [Place]) -> Place {
    for place in places {
        if(place.id == id) {
            return place
        }
    }
    return Place()
}
