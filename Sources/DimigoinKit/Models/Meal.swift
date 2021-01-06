//
//  File.swift
//  
//
//  Created by 변경민 on 2020/11/15.
//

import Foundation
import Alamofire
import SwiftyJSON

public struct Dimibob: Codable, Identifiable {
    public init(breakfast: String, lunch: String, dinner: String) {
        self.breakfast = breakfast
        self.lunch = lunch
        self.dinner = dinner
    }
    public init() {
        self.breakfast = "급식 정보가 없습니다."
        self.lunch = "급식 정보가 없습니다."
        self.dinner = "급식 정보가 없습니다."
    }
    public var id = UUID()
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

/// 디미고인 급식 관련 API
public class MealAPI: ObservableObject {
    @Published public var meals = [Dimibob(), Dimibob(), Dimibob(), Dimibob(), Dimibob(), Dimibob(), Dimibob()]
    public var tokenAPI: TokenAPI = TokenAPI()
    public init() {
        getWeeklyMeals()
    }
    
    /// 일주일치 급식을 조회합니다.
    public func getWeeklyMeals() {
        getMeals(from: .mon)
        getMeals(from: .tue)
        getMeals(from: .wed)
        getMeals(from: .thu)
        getMeals(from: .fri)
        getMeals(from: .sat)
        getMeals(from: .sun)
    }
    
    /// http://edison.dimigo.hs.kr/meal/yyyy-mm-dd
    /// 같은 주의 N요일의 급식을 가져옵니다.
    public func getMeals(from weekDay: Weekday){
        LOG("get meals from \(get8DigitDateString(weekday: weekDay))")
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(tokenAPI.accessToken)"
        ]
        let url = "http://edison.dimigo.hs.kr/meal/\(get8DigitDateString(weekday: weekDay))"
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseData { response in
            if let status = response.response?.statusCode {
                switch(status) {
                case 200:
                    let json = JSON(response.value ?? "")
                    
                    self.meals[weekDay.rawValue-1].breakfast = self.bindingMenus(menu: json["meal"]["breakfast"])
                    self.meals[weekDay.rawValue-1].lunch = self.bindingMenus(menu: json["meal"]["breakfast"])
                    self.meals[weekDay.rawValue-1].dinner = self.bindingMenus(menu: json["meal"]["breakfast"])
//                    self.dubugMeal()
                case 404:
                    self.meals[weekDay.rawValue-1].breakfast = "급식 정보가 없습니다."
                    self.meals[weekDay.rawValue-1].lunch = "급식 정보가 없습니다."
                    self.meals[weekDay.rawValue-1].dinner =  "급식 정보가 없습니다."
//                    self.dubugMeal()
                default:
                    self.tokenAPI.refreshTokens()
                    self.getMeals(from: weekDay)
                }
            }
        }
    }
    
    /// 오늘의 급식을 조회합니다.
    public func getTodayMeal() -> Dimibob{
        return meals[getTodayDayOfWeekInt()-1]
    }
    
    /// 급식을 출력합니다.
    public func dubugMeal() {
        for i in 0..<meals.count {
            LOG("\(meals[i].breakfast), \(meals[i].lunch), \(meals[i].dinner)")
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
}

/// 급식 모델에서 끼니별로 급식을 반환합니다.
public func getMealMenu(meal: Dimibob, mealType: MealType) -> String{
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
public let dummyMeal = Dimibob(
    breakfast: "카레라이스 | 쌀밥 | 콩나물국 | 너비아니조림 | 어묵야채볶음 | 포기김치 | 모듬과일",
    lunch: "라면&보조밥 | 소떡소떡 | 야끼만두&초간장 | 참나물만다린무침 | 단무지 | 포기김치 | 우유빙수",
    dinner: "김치참치마요덮밥 | 쌀밥 | 콩나물국 | 치즈스틱 | 실곤약치커리무침 | 깍두기 | 미니딸기파이"
)




