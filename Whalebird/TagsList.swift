//
//  TagsList.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/08/22.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

class TagsList: NSObject {
    var tagsList: Array<String>?
    var userDefaults = NSUserDefaults.standardUserDefaults()
    
    class var sharedClient: TagsList {
        struct sharedStruct {
            static let _sharedClient = TagsList()
        }
        return sharedStruct._sharedClient
    }
    
    override init() {
        super.init()
        self.tagsList = loadTagsListFromCache()
    }
    
    func loadTagsListFromCache() -> Array<String> {
        if let tags = self.userDefaults.objectForKey("user_tags") as? Array<String> {
            return tags
        } else {
            return []
        }
    }
    
    func findAndAddtag(rawString: String) {
        for tag in TweetModel.listUpSentence(rawString, startCharacter: "#", fScreenName: false) {
            let tagString = tag.stringByReplacingOccurrencesOfString("#", withString: "", options: nil, range: nil)
            if count(tagString) > 0 {
                self.addTag(tagString)
            }
        }
    }
    
    func addTag(tag: String) {
        self.tagsList?.append(tag)
        if self.tagsList != nil {
            let set = NSOrderedSet(array: self.tagsList!)
            self.tagsList = set.array as? Array<String>
        }
    }
    
    func saveTagsListInCache() {
        // unique制約
        if self.tagsList != nil {
            let set = NSOrderedSet(array: self.tagsList!)
            if let uniqueSet = set.array as? Array<String> {
                self.userDefaults.setObject(self.tagsList, forKey: "user_tags")
            }
        }
    }
    
    func getTagsList() -> Array<String>? {
        return self.tagsList
    }
    
    func getTagAtIndex(index: Int) -> String? {
        return self.tagsList?[index]
    }
    
    func searchTags(tag: String, callback: (Array<String>)-> Void) {
        if count(tag) > 0 {
            if let list = self.getTagsList() {
                var matchTags:Array<String> = []
                for name in list {
                    if name.hasPrefix(tag) {
                        matchTags.append(name)
                    }
                }
                callback(matchTags)
            } else {
                callback([])
            }
        }
    }
    
    deinit {
        self.saveTagsListInCache()
    }

}
