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
    public init(_ breakfast: String, _ lunch: String, _ dinner: String) {
        self.breakfast = breakfast
        self.lunch = lunch
        self.dinner = dinner
    }
    public init() {
        self.breakfast = "급식 정보가 없습니다."
        self.lunch = "급식 정보가 없습니다."
        self.dinner = "급식 정보가 없습니다."
    }
    public var breakfast: String
    public var lunch: String
    public var dinner: String
}

/// 급식 종류(아침, 점심, 저녁) Enum
public enum MealType {
    case breakfast
    case lunch
    case dinner
}

/// yyyy-MM-dd의 급식을 가져옵니다.
public func getMeal(from date: String, completion: @escaping (Meal) -> Void){
    let endPoint = "/meal/date/\(date)"
    let method: HTTPMethod = .get
    AF.request(rootURL+endPoint, method: method, encoding: JSONEncoding.default).responseData { response in
        let json = JSON(response.value ?? "")
        completion(Meal(bindingMenus(menu: json["meal"]["breakfast"]),
                        bindingMenus(menu: json["meal"]["lunch"]),
                        bindingMenus(menu: json["meal"]["dinner"])))
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

/// 급식 모델에서 끼니별로 급식을 반환합니다.
public func getMealMenu(meal: Meal, _ mealType: MealType) -> String{
    switch mealType {
        case .breakfast: return meal.breakfast
        case .lunch: return meal.lunch
        case .dinner: return meal.dinner
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
    "카레라이스 | 쌀밥 | 콩나물국 | 너비아니조림 | 어묵야채볶음 | 포기김치 | 모듬과일",
    "라면&보조밥 | 소떡소떡 | 야끼만두&초간장 | 참나물만다린무침 | 단무지 | 포기김치 | 우유빙수",
    "김치참치마요덮밥 | 쌀밥 | 콩나물국 | 치즈스틱 | 실곤약치커리무침 | 깍두기 | 미니딸기파이"
)
