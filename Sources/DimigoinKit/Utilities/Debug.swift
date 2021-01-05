//
//  SwiftUIView.swift
//  
//
//  Created by 변경민 on 2020/11/20.
//

import Foundation

public var debugMode: Bool = true

public func LOG(line: Int = #line, funcname: String = #function, _ output:Any...) {
    if debugMode {
        let now = NSDate()
        print("👨‍💻 \(funcname) - Line \(line) \(output)")
    }
}

