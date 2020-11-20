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

/// 아침, 점심, 저녁 종류
public enum MealType {
    case breakfast
    case lunch
    case dinner
}

public class MealAPI: ObservableObject {
    @Published var meals = [Dimibob(), Dimibob(), Dimibob(), Dimibob(), Dimibob(), Dimibob(), Dimibob()]
    public init() {
        getWeeklyMeals()
    }
    
    /// 일주일치 급식 조회
    public func getWeeklyMeals() {
        getMeals(from: .mon)
        getMeals(from: .tue)
        getMeals(from: .wed)
        getMeals(from: .thu)
        getMeals(from: .fri)
        getMeals(from: .sat)
        getMeals(from: .sun)
    }
    
    /// 급식 조회
    public func getMeals(from weekDay: Weekday){
        LOG("get meals from \(get8DigitDateString(weekday: weekDay))")
        let url = "https://api.dimigo.in/dimibobs/\(get8DigitDateString(weekday: weekDay))"
        AF.request(url, method: .get, encoding: JSONEncoding.default).responseData { response in
            let json = JSON(response.value ?? "")
            self.meals[weekDay.rawValue-1].breakfast = json["breakfast"].string ?? "급식 정보가 없습니다."
            self.meals[weekDay.rawValue-1].lunch = json["lunch"].string ?? "급식 정보가 없습니다."
            self.meals[weekDay.rawValue-1].dinner = json["dinner"].string ?? "급식 정보가 없습니다."
            self.dubugMeal()
        }
    }
    
    /// 오늘의 급식 조회
    public func getTodayMeal() -> Dimibob{
        return meals[getTodayDayOfWeekInt()-1]
    }
    
    /// 급식 출력
    public func dubugMeal() {
        LOG(meals)
    }
}

/// 급식 모델에서 끼니별 급식 추출
public func getMealMenu(meal: Dimibob, mealType: MealType) -> String{
    switch mealType {
        case .breakfast: return meal.breakfast
        case .lunch: return meal.lunch
        case .dinner: return meal.dinner
    }
}

/// 시간대 별로 어떤 끼니가 다음 끼니인지를 반환
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




