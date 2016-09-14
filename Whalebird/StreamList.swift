//
//  StreamList.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/07/26.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

class StreamList: NSObject {
    struct Stream {
        var image: String = ""
        var name: String = ""
        var type: String = ""
        var uri: String = ""
        var id: String = ""
    }
    var lists: Array<Stream> = []
    
    override init() {
        super.init()
        let userDefaults = UserDefaults.standard
        if let userStreamList = userDefaults.array(forKey: "streamList") as Array? {
            self.lists.removeAll()
            for streamList in userStreamList {
                self.lists.insert(Stream(
                    image: (streamList as AnyObject).object(forKey: "image") as! String,
                    name: (streamList as AnyObject).object(forKey: "name") as! String,
                    type: (streamList as AnyObject).object(forKey: "type") as! String,
                    uri: (streamList as AnyObject).object(forKey: "uri") as! String,
                    id: (streamList as AnyObject).object(forKey: "id") as! String),
                    at: 0)
            }
        } else {
            self.initStreamList()
        }
    }
    
    func initWithEmpty() {
        self.lists.removeAll()
    }
    
    func initStreamList() {
        self.lists.removeAll()
        let favStream = type(of: self).Stream(
            image: "",
            name: "お気に入り",
            type: "myself",
            uri: "users/apis/user_favorites.json",
            id: "")
        let myselfStream = type(of: self).Stream(
            image: "",
            name: "送信済みツイート",
            type: "myself",
            uri: "users/apis/user_timeline.json",
            id: "")
        self.lists.append(myselfStream)
        self.lists.append(favStream)
    }
    
    func saveStreamList() {
        let userDefaults = UserDefaults.standard
        
        let safeArray = NSMutableArray()
        if (self.lists.count > 0) {
            for i in 0...self.lists.count-1 {
                let list = self.lists[i]
                let dictionary = NSMutableDictionary()
                dictionary.setObject((list.image as String), forKey: "image" as NSCopying)
                dictionary.setObject((list.name as String), forKey: "name" as NSCopying)
                dictionary.setObject((list.type as String), forKey: "type" as NSCopying)
                dictionary.setObject((list.uri as String), forKey: "uri" as NSCopying)
                dictionary.setObject((list.id as String), forKey: "id" as NSCopying)
                safeArray.insert(dictionary, at: 0)
            }
        }
        userDefaults.set(safeArray, forKey: "streamList")
    }
    
    func count()-> Int {
        return self.lists.count
    }
    
    func getStreamAtIndex(_ index: Int)-> Stream {
        return self.lists[index]
    }
    
    func deleteStreamAtIndex(_ index: Int) {
        self.lists.remove(at: index)
    }
    
    func moveStreamAtIndex(_ fromIndex: Int, toIndex: Int) {
        let fromCellData = self.lists[fromIndex]
        let toCellData = self.lists[toIndex]
        self.lists[fromIndex] = toCellData
        self.lists[toIndex] = fromCellData
    }
    
    func addNewStream(_ image: String, name: String, type: String, uri: String, id: String) {
        let newStream = Stream(image: image, name: name, type: type, uri: uri, id: id)
        self.lists.append(newStream)
    }
    
    func add(_ stream: Stream) {
        self.lists.append(stream)
    }
    
    func mergeStreamList(_ streamList: StreamList) {
        self.lists += streamList.lists
    }
    
    func clearData() {
        self.initStreamList()
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: "streamList")
    }
}
