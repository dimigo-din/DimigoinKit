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

/// 디미고인 시간표 관련 API
public class TimetableAPI: ObservableObject {
    public init() {
        
    }
    
    public func getTimetable(grade: Int, klass: Int) -> Timetable {
        let data: [[Timetable]] = [[Timetable(data: [["통합사회", "음악", "영어", "한국사", "컴그", "컴그", "수학"],
                                                     ["상경", "사회", "국어", "과학", "체육"],
                                                     ["영어", "상경", "음악", "한국사", "과학", "수학"],
                                                     ["컴그", "컴그", "상경", "사회", "체육", "국어"],
                                                     ["수학", "영어", "한국사", "과학", "국어", "음악", "진로"]]),
                                    Timetable(data: [["한국사", "사회", "수학", "영어", "미술", "미술", "상경"],
                                                     ["국어", "컴그", "컴그", "사회", "과학"],
                                                     ["과학", "국어", "체육", "상경", "컴그", "컴그"],
                                                     ["사회", "상경", "영어", "한국사", "수학", "미술"],
                                                     ["수학", "과학", "국어", "진로", "영어", "체육", "한국사"]]),
                                    Timetable(data: [["영어", "자료구조", "자료구조", "음악", "자료구조", "자료구조", "수학"],
                                                     ["수학", "과학", "체육", "음악", "컴일"],
                                                     ["자료구조", "영어", "진로", "국어", "사회", "수학"],
                                                     ["컴일", "과학", "사회", "국어", "음악", "체육"],
                                                     ["국어", "사회", "자료구조", "컴일", "자료구조", "과학", "영어"]]),
                                    Timetable(data: [["진로", "자료구조", "음악", "국어", "사회", "수학", "과학"],
                                                     ["자료구조", "자료구조", "영어", "컴일", "국어"],
                                                     ["수학", "체육", "자료구조", "사회", "영어", "과학"],
                                                     ["음악", "국어", "과학", "컴일", "자료구조", "자료구조"],
                                                     ["사회", "컴일", "음악", "영어", "체육", "수학", "자료구조"]]),
                                    Timetable(data: [["자료구조", "과학", "사회", "수학", "자료구조", "체육", "국어"],
                                                     ["컴일", "미술", "미술", "영어", "수학"],
                                                     ["사회", "컴일", "과학", "미술", "체육", "국어"],
                                                     ["진로", "자료구조", "자료구조", "자료구조", "과학", "영어"],
                                                     ["자료구조", "자료구조", "수학", "사회", "컴일", "국어", "영어"]]),
                                    Timetable(data: [["수학", "미술", "국어", "과학", "체육", "영어", "자료구조"],
                                                     ["사회", "자료구조", "자료구조", "국어", "진로"],
                                                     ["자료구조", "자료구조", "사회", "자료구조", "컴일", "체육"],
                                                     ["영어", "컴일", "미술", "미술", "수학", "과학"],
                                                     ["과학", "수학", "국어", "자료구조", "사회", "영어", "컴일"]])],
                                    [Timetable(data: [["광콘", "광콘", "회계", "문학", "중국어", "정처", "정처"],
                                                     ["문학", "문콘", "문콘", "수학", "상경"],
                                                     ["문학", "음콘", "회계", "광콘", "영어", "진로"],
                                                     ["수학", "중국어", "영어", "광콘", "상경", "음콘"],
                                                     ["중국어", "음콘", "체육", "회계", "영어", "상경", "수학"]]),
                                    Timetable(data: [["상경", "수학", "정처", "정처", "회계", "문학", "중국어"],
                                                     ["음콘", "영어", "회계", "체육", "진로"],
                                                     ["영어", "문학", "광콘", "광콘", "음콘", "상경"],
                                                     ["광콘", "회계", "중국어", "수학", "문콘", "문콘"],
                                                     ["문학", "상경", "중국어", "영어", "수학", "체육", "음콘"]]),
                                     Timetable(data:[["중국어", "성직", "응프화", "영어", "화학", "정통", "수학"],
                                                     ["공수", "체육", "수학", "응프화", "정통"],
                                                     ["응개", "응개", "진로", "공수", "자료구조", "화학"],
                                                     ["응개", "응개", "화학", "문학", "수학", "공수"],
                                                     ["영어", "화학", "자료구조", "문학", "중국어", "성직", "체육"]]),
                                     Timetable(data:[["성직", "화학", "체육", "응개", "응개", "영어", "정통"],
                                                     ["자료구조", "공수", "성직", "문학", "수학"],
                                                     ["화학", "응프화", "공수", "수학", "중국어", "영어"],
                                                     ["응프화", "문학", "체육", "자료구조", "화학", "진로"],
                                                     ["수학", "정통", "응개", "응개", "공수", "중국어", "화학"]]),
                                     Timetable(data:[["화학", "자료구조", "수학", "정보보호", "정보보호", "성직", "응프화"],
                                                     ["중국어", "화학", "공수", "진로", "영어"],
                                                     ["수학", "정통", "화학", "문학", "공수", "자료구조"],
                                                     ["성직", "응프화", "수학", "영어", "중국어", "문학"],
                                                     ["자료구조", "체육", "정보보호", "정보보호", "정통", "화학", "공수"]]),
                                     Timetable(data:[["문학", "정보보호", "정보보호", "화학", "응프화", "수학", "체육"],
                                                     ["수학", "응프화", "화학", "공수", "중국어"],
                                                     ["정통", "영어", "자료구조", "성직", "화학", "중국어"],
                                                     ["영어", "체육", "문학", "성직", "자료구조", "공수"],
                                                     ["정보보호", "정보보호", "화학", "공수", "진로", "수학", "정통"]])],
                                    [Timetable(data:[["비즈니스", "고전", "공수", "전자거래", "전자거래", "확통", "앱콘"],
                                                     ["회계", "확통", "앱콘", "영어", "마케팅"],
                                                     ["마케팅", "비즈니스", "고전", "진로", "회계", "앱콘"],
                                                     ["영어", "고전", "공수", "앱콘", "애콘", "애콘"],
                                                     ["애콘", "애콘", "비즈니스", "전자거래", "마케팅", "확통", "회계"]]),
                                     Timetable(data:[["확통", "공수", "비즈니스", "방콘", "방콘", "앱콘", "마케팅"],
                                                     ["공수", "고전", "확통", "앱콘", "회계"],
                                                     ["애콘", "애콘", "마케팅", "앱콘", "진로", "영어"],
                                                     ["회계", "비즈니스", "확통", "영어", "고전", "앱콘"],
                                                     ["고전", "회계", "마케팅", "방콘", "비즈니스", "애콘", "애콘"]]),
                                     Timetable(data:[["시스템", "시스템", "DB", "네트워크", "네트워크", "고전", "비즈니스"],
                                                     ["고전", "응개", "응개", "비즈니스", "진로"],
                                                     ["비즈니스", "공수", "수학", "DB", "응개", "응개"],
                                                     ["확통", "DB", "공일", "시스템", "시스템", "비즈니스"],
                                                     ["공일", "DB", "공수", "고전", "네트워크", "네트워크", "수학"]]),
                                     Timetable(data:[["응개", "응개", "고전", "DB", "비즈니스", "확통", "공수"],
                                                     ["비즈니스", "시스템", "시스템", "네트워크", "네트워크"],
                                                     ["고전", "진로", "DB", "수학", "시스템", "시스템"],
                                                     ["공일", "네트워크", "네트워크", "응개", "응개", "DB"],
                                                     ["비즈니스", "고전", "비즈니스", "공수", "수학", "DB", "공일"]]),
                                     Timetable(data:[["네트워크", "네트워크", "공수", "비즈니스", "수학", "DB", "고전"],
                                                     ["비즈니스", "컴터보안", "컴터보안", "DB", "수학"],
                                                     ["공일", "네트워크", "네트워크", "고전", "컴터보안", "컴터보안"],
                                                     ["응개", "응개", "비즈니스", "DB", "비즈니스", "진로"],
                                                     ["공수", "수학", "DB", "공일", "고전", "응개", "응개"]]),
                                     Timetable(data:[["컴터보안", "컴터보안", "비즈니스", "공일", "응개", "응개", "DB"],
                                                     ["네트워크", "네트워크", "수학", "고전", "DB"],
                                                     ["응개", "응개", "비즈니스", "공수", "진로", "고전"],
                                                     ["DB", "공수", "고전", "컴터보안", "컴터보안", "수학"],
                                                     ["네트워크", "네트워크", "수학", "비즈니스", "공일", "비즈니스", "DB"]])],
                                    [Timetable(data:[["-", "-", "-", "-", "-", "-", "-"],
                                                     ["-", "-", "-", "-", "-", "-", "-"],
                                                     ["-", "-", "-", "-", "-", "-", "-"],
                                                     ["-", "-", "-", "-", "-", "-", "-"],
                                                     ["-", "-", "-", "-", "-", "-", "-"]])]]

        return data[grade-1][klass-1]
    }
}

public let dummyTimeTable = Timetable(data: [["영어", "응개", "문학", "물리학1", "중국어", "성직", "공수"],
                               ["자료구조", "공수", "물리학", "체육", "중국어"],
                               ["공수", "수학1", "응프화", "응개", "정통", "성직"],
                               ["응프화", "정통", "영어1", "물리학1", "수학1", "응개"],
                               ["응개", "수학1", "문학", "자료구조", "물리학1", "체육", "진로"]])