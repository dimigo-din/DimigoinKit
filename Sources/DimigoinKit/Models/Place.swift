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

public class PlaceAPI: ObservableObject {
    @Published var places: [Place] = []
    
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
    
    public func getAllPlaces() {
        
    }
}


