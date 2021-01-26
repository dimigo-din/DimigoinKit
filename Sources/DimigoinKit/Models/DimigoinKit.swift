import Foundation

public var appGroupName: String = "group.in.dimigo.ios"

public func setAccentColor(_ color: String) {
    UserDefaults.standard.setValue(color, forKey: "accentColor")
    
    // for dimigoin App service only
    UserDefaults(suiteName: appGroupName)?.setValue(color, forKey: "accentColor")
}

public func getAccentColor() -> String {
    return UserDefaults.standard.string(forKey: "accentColor") ?? "accent"
}
