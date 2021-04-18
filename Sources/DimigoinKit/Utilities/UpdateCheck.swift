//
//  File.swift
//  
//
//  Created by 변경민 on 2021/03/04.
//

import Foundation

public func needsUpdate() -> Bool {
    let infoDictionary = Bundle.main.infoDictionary
    let appID = infoDictionary!["CFBundleIdentifier"] as! String
    let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)")!
    guard let data = try? Data(contentsOf: url) else {
      print("There is an error!")
      return false
    }
    let lookup = (try? JSONSerialization.jsonObject(with: data , options: [])) as? [String: Any]
    if let resultCount = lookup!["resultCount"] as? Int, resultCount == 1 {
        if let results = lookup!["results"] as? [[String:Any]] {
            if let appStoreVersion = results[0]["version"] as? String{
                let currentVersion = infoDictionary!["CFBundleShortVersionString"] as? String
                if !(appStoreVersion == currentVersion) {
                    print("Need to update [\(appStoreVersion) != \(currentVersion ?? "error")]")
                    return true
                }
            }
        }
    }
    return false
}

public func getLatestAppVersion() -> String {
    let infoDictionary = Bundle.main.infoDictionary
    let appID = infoDictionary!["CFBundleIdentifier"] as! String
    let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)")!
    guard let data = try? Data(contentsOf: url) else {
      return "error"
    }
    let lookup = (try? JSONSerialization.jsonObject(with: data , options: [])) as? [String: Any]
    if let resultCount = lookup!["resultCount"] as? Int, resultCount == 1 {
        if let results = lookup!["results"] as? [[String:Any]] {
            if let appStoreVersion = results[0]["version"] as? String{
                let currentVersion = infoDictionary!["CFBundleShortVersionString"] as? String
                if !(appStoreVersion == currentVersion) {
                    return appStoreVersion
                }
            }
        }
    }
    return "0.0.0"
}
