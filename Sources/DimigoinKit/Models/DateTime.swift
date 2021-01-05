//
//  File.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import Foundation

/// 월요일 ~ 일요일을 1~7 로 맵핑한 Enum
public enum Weekday: Int {
    case today = 0
    case mon = 1
    case tue = 2
    case wed = 3
    case thu = 4
    case fri = 5
    case sat = 6
    case sun = 7
}

/// 내일의 Date를 반환
public func tomorrow() -> Date {
    var dateComponents = DateComponents()
    dateComponents.setValue(1, for: .day); // +1 day
    let now = Date() // Current date
    let tomorrow = Calendar.current.date(byAdding: dateComponents, to: now)  // Add the DateComponents
    return tomorrow!
}

/// 평일이면 True, 주말이면 False를 반환
public func isWeekday() -> Bool {
    let today = getTodayDayOfWeekString()
    if(today == "토" || today == "일") {
        return false
    }
    else {
       return true
    }
}

/// 오늘의 요일을 반환
public func getTodayDayOfWeekString() -> String {
    let now = Date()
    let date = DateFormatter()
    date.locale = Locale(identifier: "ko_kr")
    date.timeZone = TimeZone(abbreviation: "KST")
    date.dateFormat = "E"
    return date.string(from: now)
}

/// ["", "월", "화", "수", "목", "금", "토", "일"] : dayOfWeek[1] = 월
public let dayOfWeek: [String] = ["", "월", "화", "수", "목", "금", "토", "일"]

/// 월요일 ~ 일요일 까지를 1 ~ 7로 맵핑하여 반환
public func getTodayDayOfWeekInt() -> Int {
    var dayInt: Int = 0
    switch getTodayDayOfWeekString() {
        case "월": dayInt = 1
        case "화": dayInt = 2
        case "수": dayInt = 3
        case "목": dayInt = 4
        case "금": dayInt = 5
        case "토": dayInt = 6
        case "일": dayInt = 7
        default: return 0
    }
    return dayInt
}

/// MM월 dd일 N요일 반환
public func getDateString() -> String {
    let now = Date()
    let date = DateFormatter()
    date.locale = Locale(identifier: "ko_kr")
    date.timeZone = TimeZone(abbreviation: "KST")
    date.dateFormat = "M월 d일"

    return "\(date.string(from: now)) \(getTodayDayOfWeekString())요일"
}

/// weekday에 따른 8 Digit date 반환(yyyyMMdd)
public func get8DigitDateString(weekday: Weekday) -> String {
    let amount = weekday.rawValue - getTodayDayOfWeekInt()
    let calendar = Calendar.current
    let date = calendar.date(byAdding: .day, value: amount, to: Date())
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date!)
}

/// 오늘의 8 Digit date 반환(yyyyMMdd)
public func getToday8DigitDateString() -> String {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
}

