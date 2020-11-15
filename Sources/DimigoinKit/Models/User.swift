//
//  User.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import SwiftUI

public struct User: Codable, Identifiable {
    public init() {
        
    }
    public var name: String = ""
    public var id: String = ""
    public var idx: Int = 0
    public var grade: Int = 4
    public var klass: Int = 1
    public var number: String = ""
    public var serial: String = ""
    public var email: String = ""
    public var photo: String = ""
    public var weekly_request_count: Int = 0
    public var daily_request_count: Int = 0
    public var weekly_ticket_num: Int = 0
    public var daily_ticket_num: Int = 0
}
