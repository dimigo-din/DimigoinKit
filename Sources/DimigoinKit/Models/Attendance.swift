//
//  File.swift
//  
//
//  Created by 변경민 on 2021/01/05.
//

import Foundation

public struct Attendance: Identifiable, Hashable, Codable {
    public var id: String
    var name: String
}

public class AttendanceAPI: ObservableObject {
    @Published var attendances: [Attendance] = []
    public var placeAPI = PlaceAPI()
    public var userAPI = UserAPI()
    
    public func getUserCurrentLocation() -> Place {
        //
        return Place()
    }
    
    public func setUserLocation(place: Place) {
        
    }
}
