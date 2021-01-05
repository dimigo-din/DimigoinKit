//
//  SwiftUIView.swift
//  
//
//  Created by 변경민 on 2020/11/20.
//

import Foundation

public var debugMode: Bool = true

public func LOG(filename: String = #file, line: Int = #line, funcname: String = #function, _ output:Any...) {
    if debugMode {
        let now = NSDate()
        print("[\(now.description)][\(filename)][\(funcname)][Line \(line)] \(output)")
    }
}

