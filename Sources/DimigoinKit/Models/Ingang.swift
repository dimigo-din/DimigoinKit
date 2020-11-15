//
//  File.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import SwiftUI

public struct Ingang: Hashable, Codable {
    public init(idx: Int, day: String, title: String, time: Int, request_start_date: Int, request_end_date: Int, status: Bool, present: Int, max_user: Int){
        self.idx = idx
        self.day  = day
        self.title = title
        self.time = time
        self.request_start_date = request_start_date
        self.request_end_date = request_end_date
        self.status = status
        self.present = present
        self.max_user = max_user
    }
    public var idx: Int?
    public var day: String?
    public var title: String?
    public var time: Int?
    public var request_start_date: Int?
    public var request_end_date: Int?
    public var status: Bool?
    public var present: Int?
    public var max_user: Int?
}

public struct Applicant: Identifiable, Hashable, Codable {
    public init(idx: Int, name: String, grade: Int, klass: Int, number: Int, serial: Int){
        self.idx = idx
        self.name  = name
        self.grade = grade
        self.klass = klass
        self.number = number
        self.serial = serial
    }
    public var id = UUID()
    public var idx: Int?
    public var name: String?
    public var grade: Int?
    public var klass: Int?
    public var number: Int?
    public var serial: Int?
}

public enum IngangStatus: Int {
    case none = 0
    case success = 200
    case usedAllTicket = 403
    case noIngang = 404
    case timeout = 405
    case blacklisted = 406
    case full = 409
}
