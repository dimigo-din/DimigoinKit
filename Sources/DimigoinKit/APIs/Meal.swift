//
//  MealAPI.swift
//  DimigoinKitDemo
//
//  Created by 변경민 on 2021/01/26.
//

import Foundation
import Alamofire
import SwiftyJSON

/// 급식 모델
public struct Meal {
    public init(_ breakfast: [String], _ lunch: [String], _ dinner: [String]) {
        self.breakfast = breakfast
        self.lunch = lunch
        self.dinner = dinner
    }
    public init() {
        self.breakfast = []
        self.lunch = []
        self.dinner = []
    }
    public var breakfast: [String]
    public var lunch: [String]
    public var dinner: [String]
    
    public func getBreakfastString() -> String {
        if breakfast.isEmpty {
            return "급식 정보가 없습니다."
        } else {
            return bindingMenus(menu: breakfast)
        }
    }
    
    public func getLunchString() -> String {
        if lunch.isEmpty {
            return "급식 정보가 없습니다."
        } else {
            return bindingMenus(menu: lunch)
        }
    }
    
    public func getDinnerString() -> String {
        if dinner.isEmpty {
            return "급식 정보가 없습니다."
        } else {
            return bindingMenus(menu: dinner)
        }
    }
    
//    public func getBreakfastAnyObject() -> AnyObject {
//        let anyObject: [AnyObject] = []
//
//    }
}

/// 급식 종류(아침, 점심, 저녁) Enum
public enum MealType {
    case breakfast
    case lunch
    case dinner
}

public enum MealError: Error {
    case alreadyExist
    case unknown
    case timeout
}

/// yyyy-MM-dd의 급식을 가져옵니다.
public func getMeal(from date: String, completion: @escaping (Meal) -> Void){
    let endPoint = "/meal/date/\(date)"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default).responseData { response in
        let json = JSON(response.value ?? "")
//        completion(Meal(bindingMenus(menu: json["meal"]["breakfast"]),
//                        bindingMenus(menu: json["meal"]["lunch"]),
//                        bindingMenus(menu: json["meal"]["dinner"])))
        completion(json2Meal(json: json["meal"]))
    }
}

public func json2Meal(json: JSON) -> Meal{
    var meal: Meal = Meal()
    for i in 0..<json["breakfast"].count {
        meal.breakfast.append(json["breakfast"][i].string!)
    }
    for i in 0..<json["lunch"].count {
        meal.lunch.append(json["lunch"][i].string!)
    }
    for i in 0..<json["dinner"].count {
        meal.dinner.append(json["dinner"][i].string!)
    }
    return meal
}

public func registerMeal(accessToken: String, date: Date, meal: Meal, completion: @escaping (Result<Void, MealError>) -> Void) {
    let headers: HTTPHeaders = [
        "Authorization": "Bearer \(accessToken)"
    ]
    let parameters: [String:Any] = [
        "breakfast": meal.breakfast,
        "lunch": meal.lunch,
        "dinner": meal.dinner
    ]
    print(parameters)

    let endPoint = "/meal/date/\(get8DigitDateString(from: date))"
    let method: HTTPMethod = .post
    AF.request(rootURL+endPoint, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
        debugPrint(response)
        if let status = response.response?.statusCode {
            switch(status) {
            case 200:
                completion(.success(()))
            case 409:
                completion(.failure(.alreadyExist))
            default:
                completion(.failure(.unknown))
            }
        }
    }
}

public func patchMeal(accessToken: String, date: Date, meal: Meal, completion: @escaping () -> Void) {
    let headers: HTTPHeaders = [
        "Authorization": "Bearer \(accessToken)"
    ]
    let parameters: [String:Any] = [
        "breakfast": meal.breakfast,
        "lunch": meal.lunch,
        "dinner": meal.dinner
    ]
    let endPoint = "/meal/date/\(get8DigitDateString(from: date))"
    let method: HTTPMethod = .patch
    AF.request(rootURL+endPoint, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
        completion()
    }
}

/// 모든 메뉴를 한개의 문자열로 묶습니다.
public func bindingMenus(menu json: JSON) -> String{
    var str = ""
    if(json.count == 0) {
        return "급식 정보가 없습니다."
    }
    for i in 0..<json.count {
        str += json[i].string!
        if(i != json.count - 1) {
            str += " | "
        }
    }
    return str
}

/// 모든 메뉴를 한개의 문자열로 묶습니다.
public func bindingMenus(menu: [String]) -> String{
    var str = ""
    if(menu.count == 0) {
        return "급식 정보가 없습니다."
    }
    for i in 0..<menu.count {
        str += menu[i]
        if(i != menu.count - 1) {
            str += " | "
        }
    }
    return str
}

/// 급식 모델에서 끼니별로 급식을 반환합니다.
public func getMealMenu(meal: Meal, _ mealType: MealType) -> String{
    switch mealType {
        case .breakfast: return meal.getBreakfastString()
        case .lunch: return meal.getLunchString()
        case .dinner: return meal.getDinnerString()
    }
}

/// 시간대 별로 어떤 끼니가 다음 끼니인지를 반환합니다.
public func getMealType() -> MealType {
    let hour = Calendar.current.component(.hour, from: Date())
    if Int(hour) <= 9 || Int(hour) >= 21 { // 오후 9시 ~ 오전 9시 -> 아침
        return .breakfast
    }
    else if Int(hour) <= 14 { // 오전 10시 ~ 오후 2시 -> 점심
        return .lunch
    }
    else if Int(hour) <= 21 { // 오후 3시 ~ 오후 9시 -> 저녁
        return .dinner
    }
    else {
        return .breakfast
    }
}

/// 예시 급식
public let sampleMeal = Meal(
    ["카레라이스", "쌀밥", "콩나물국", "너비아니조림", "어묵야채볶음", "포기김치", "모듬과일"],
    ["라면&보조밥", "소떡소떡", "야끼만두&초간장", "참나물만다린무침", "단무지", "포기김치", "우유빙수"],
    ["김치참치마요덮밥", "쌀밥", "콩나물국", "치즈스틱", "실곤약치커리무침", "깍두기", "미니딸기파이"]
)
