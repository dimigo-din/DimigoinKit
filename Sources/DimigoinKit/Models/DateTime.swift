//
//  File.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import Foundation


/// 월요일 ~ 일요일을 1~7로 맵핑
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

public func getDay() -> String {
    let now = Date()
    let date = DateFormatter()
    date.locale = Locale(identifier: "ko_kr")
    date.timeZone = TimeZone(abbreviation: "KST")
    date.dateFormat = "E"
    return date.string(from: now)
}

public func getDay(_ day: Int) -> String {
    var dayString: String = "error"
    switch day {
        case 1: dayString = "월"
        case 2: dayString =  "화"
        case 3: dayString =  "수"
        case 4: dayString =  "목"
        case 5: dayString =  "금"
        case 6: dayString =  "토"
        case 7: dayString =  "일"
        default: return "error"
    }
    return dayString
}

public func getDayFromString(_ day: String) -> Int {
    var dayString: Int = 0
    switch day {
        case "월": dayString = 1
        case "화": dayString = 2
        case "수": dayString = 3
        case "목": dayString = 4
        case "금": dayString = 5
        case "토": dayString = 6
        case "일": dayString = 7
        default: return 0
    }
    return dayString
}
public func getIntDay() -> Int {
    return getDayFromString(getDay())
}

public func getDate() -> String {
    let now = Date()
    let date = DateFormatter()
    date.locale = Locale(identifier: "ko_kr")
    date.timeZone = TimeZone(abbreviation: "KST")
    date.dateFormat = "M월 d일"

    return "\(date.string(from: now)) \(getDay())요일"
}

public func getAPIDate() -> String {
    var now = Date()
    let hour = Calendar.current.component(.hour, from: now)
    if(Int(hour) >= 22) { // after 10pm, show tomorrow meals
        now = tomorrow()
    }
    let date = DateFormatter()
    date.locale = Locale(identifier: "ko_kr")
    date.timeZone = TimeZone(abbreviation: "KST")
    date.dateFormat = "yyyyMMdd"
    return date.string(from: now)
}
public func getFormattedDate(weekday: Weekday) -> String {
    let amount = weekday.rawValue - getIntDay()
    let calendar = Calendar.current
    let date = calendar.date(byAdding: .day, value: amount, to: Date())
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    return dateFormatter.string(from: date!)
}
public func getFormattedDate() -> String {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    return dateFormatter.string(from: date)
}
public func tomorrow() -> Date {
    
    var dateComponents = DateComponents()
    dateComponents.setValue(1, for: .day); // +1 day
    
    let now = Date() // Current date
    let tomorrow = Calendar.current.date(byAdding: dateComponents, to: now)  // Add the DateComponents
    
    return tomorrow!
}

public func isWeekday() -> Bool {
    let today = getDay()
    if(today == "토" || today == "일") {
        return false
    }
    else {
       return true
    }
}
extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    public var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    public var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    public var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    public var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    public var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}

public func IntToWeekDay(day: Int) -> Weekday {
    switch day {
    case 1: return .mon
    case 2: return .tue
    case 3: return .wed
    case 4: return .thu
    case 5: return .fri
    case 6: return .sat
    case 7: return .sun
    default:
        return .today
    }
}

