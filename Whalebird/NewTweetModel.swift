//
//  NewTweetModel.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/08/22.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

class NewTweetModel: NSObject {
    var tagRange: NSRange?
    var screenNameRange: NSRange?
    
    func findTagRange(viewText: String, text: String, range: NSRange, finishSelect: ()-> Void, completeFindText: (Array<String>)-> Void) {
        if text == "#" {
            self.clearRange()
            self.tagRange = NSRange(location: range.location, length: 0)
        } else if text == " " || text == "　" {
            self.tagRange = nil
            // ここでテーブルremove
            finishSelect()
        }
        
        if self.tagRange != nil {
            self.tagRange!.length = range.location - self.tagRange!.location
            var tag = ((viewText as NSString).substringWithRange(self.tagRange!) + text)
            if count(tag) > 0 {
                // 頭の#を切り捨てる
                var tag_name = (tag as NSString).substringFromIndex(1)
                // ここでリスト取得＆テーブル更新
                TagsList.sharedClient.searchTags(tag_name, callback: { (tags) -> Void in
                    completeFindText(tags)
                })
            } else {
                // table削除
                self.tagRange = nil
                finishSelect()
            }
        }
    }

    func findScreenNameRange(viewText: String, text: String, range: NSRange, finishSelect: ()-> Void, completeFindText: (Array<String>)-> Void) {
        if text == "@" {
            self.clearRange()
            self.screenNameRange = NSRange(location: range.location, length: 0)
        } else if text == " " || text == "　" {
            self.screenNameRange = nil
            // ここでテーブルremove
            finishSelect()
        }
        
        if self.screenNameRange != nil {
            self.screenNameRange!.length = range.location - self.screenNameRange!.location
            var name = ((viewText as NSString).substringWithRange(self.screenNameRange!) + text)
            if count(name) > 0 {
                // 頭の@を切り捨てる
                var screen_name = (name as NSString).substringFromIndex(1)
                // ここでリスト取得＆テーブル更新
                FriendsList.sharedClient.searchFriends(screen_name, callback: { (friends) -> Void in
                    completeFindText(friends)
                })
            } else {
                // table削除
                self.screenNameRange = nil
                finishSelect()
            }
        }
    }
    
    func clearRange() {
        self.screenNameRange = nil
        self.tagRange = nil
    }
}
