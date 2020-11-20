//
//  File.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import Foundation
import SwiftyJSON
import SwiftUI

public struct Timetable: Codable{
    public var data: [[String]]
}

public class TimetableAPI: ObservableObject {

    public func getTimetable(grade: Int, klass: Int) -> Timetable {
        let path = Bundle.main.path(forResource: "Timetable", ofType: "json")!
        let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
        let json = JSON(parseJSON: jsonString!)
        
        var data = Timetable(data:[[json["2"]["4"][0][0].stringValue, "-", "-", "-", "-", "-", "-"],
                                    ["-", "-", "-", "-", "-", "-", "-"],
                                    ["-", "-", "-", "-", "-", "-", "-"],
                                    ["-", "-", "-", "-", "-", "-", "-"],
                                    ["-", "-", "-", "-", "-", "-", "-"]])
//        var data = Timetable(data: [json["2"]["4"].arrayValue.map{[$0].stringValue},
//                                    json["2"]["4"][0].arrayValue,
//                                    json["2"]["4"][0].arrayValue,
//                                    json["2"]["4"][0].arrayValue,
//                                    json["2"]["4"][0].arrayValue])
        return data
    }
}

public let dummyTimeTable = Timetable(data: [["영어", "응개", "문학", "물리학1", "중국어", "성직", "공수"],
                               ["자료구조", "공수", "물리학", "체육", "중국어"],
                               ["공수", "수학1", "응프화", "응개", "정통", "성직"],
                               ["응프화", "정통", "영어1", "물리학1", "수학1", "응개"],
                               ["응개", "수학1", "문학", "자료구조", "물리학1", "체육", "진로"]])
