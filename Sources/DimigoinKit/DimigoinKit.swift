import Foundation
/// API 주소
public var rootURL: String = "http://edison.dimigo.hs.kr"


public var appGroupName: String = "group.in.dimigo.ios"


public var creditMember: [String] = ["김한경", "심재성", "장종우", "한우영", "강혁진", "민승현", "김세령", "김승민", "김승욱", "엄서훈", "우상윤", "이승민", "여준호", "박정한", "변경민"]

public func setAccentColor(_ color: String) {
    UserDefaults.standard.setValue(color, forKey: "accentColor")
    
    // for dimigoin App service only
    UserDefaults(suiteName: appGroupName)?.setValue(color, forKey: "accentColor")
}

public func getAccentColor() -> String {
    return UserDefaults.standard.string(forKey: "accentColor") ?? "accent"
}
