//
//  Debug.swift
//  dimigoin
//
//  Created by 변경민 on 2021/01/07.
//  Copyright © 2021 seohun. All rights reserved.
//

import Foundation

public var debugMode: Bool = true

public func LOG(line: Int = #line, funcname: String = #function, _ output:Any...) {
    if debugMode {
        print("👨‍💻 \(funcname) - Line \(line) \(output)")
    }
}

