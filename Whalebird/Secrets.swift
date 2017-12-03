//
//  Secrets.swift
//  Whalebird
//
//  Created by akirafukushima on 2017/12/03.
//  Copyright © 2017年 AkiraFukushima. All rights reserved.
//
import Foundation

protocol Secrets: class {
    static var ApplicationPlain: NSString { get }
    static func Token() -> String
}

extension Secrets {
    static func Token() -> String {
        return "SampleToken"
    }
}
