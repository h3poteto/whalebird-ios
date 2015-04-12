//
//  BigInteger.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/23.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import Foundation

class BigInteger: NSObject {
    //=============================================
    //  instance variables
    //=============================================
    var quads:Array<Int> = []
    var negative = false
    
    //=============================================
    //  instance methods
    //=============================================
    override init() {
        super.init()
    }
    
    init(string: String) {
        super.init()
        var first = true
        for c in string {
            if first {
                first = false
                if c == "-" {
                    self.negative = true
                }
            } else {
            }
            let i = String(c).toInt()
            if i != nil {
                self.quads.append(i!)
            }
        }
    }
    
    func decrement() -> String{
        var decStr = ""
        var carry = 0
        var first = true
        for num in self.quads.reverse() {
            var decnum = 0
            if first {
                first = false
                decnum = 1
            }
            var res = num - carry - decnum
            if (res < 0) {
                res = 10 - carry - decnum
                carry = 1
            } else {
                carry = 0
            }
            
            decStr = String(res) + decStr
        }
        return decStr
    }
}
