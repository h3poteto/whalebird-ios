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
        var userDefaults = NSUserDefaults.standardUserDefaults()
        if var userStreamList = userDefaults.arrayForKey("streamList") as Array? {
            self.lists.removeAll()
            for streamList in userStreamList {
                self.lists.insert(Stream(
                    image: streamList.objectForKey("image") as! String,
                    name: streamList.objectForKey("name") as! String,
                    type: streamList.objectForKey("type") as! String,
                    uri: streamList.objectForKey("uri") as! String,
                    id: streamList.objectForKey("id") as! String),
                    atIndex: 0)
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
        var favStream = self.dynamicType.Stream(
            image: "",
            name: "お気に入り",
            type: "myself",
            uri: "users/apis/user_favorites.json",
            id: "")
        var myselfStream = self.dynamicType.Stream(
            image: "",
            name: "送信済みツイート",
            type: "myself",
            uri: "users/apis/user_timeline.json",
            id: "")
        self.lists.append(myselfStream)
        self.lists.append(favStream)
    }
    
    func saveStreamList() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        
        var safeArray = NSMutableArray()
        if (self.lists.count > 0) {
            for i in 0...self.lists.count-1 {
                var list = self.lists[i]
                var dictionary = NSMutableDictionary()
                dictionary.setObject((list.image as String), forKey: "image")
                dictionary.setObject((list.name as String), forKey: "name")
                dictionary.setObject((list.type as String), forKey: "type")
                dictionary.setObject((list.uri as String), forKey: "uri")
                dictionary.setObject((list.id as String), forKey: "id")
                safeArray.insertObject(dictionary, atIndex: 0)
            }
        }
        userDefaults.setObject(safeArray, forKey: "streamList")
    }
    
    func count()-> Int {
        return self.lists.count
    }
    
    func getStreamAtIndex(index: Int)-> Stream {
        return self.lists[index]
    }
    
    func deleteStreamAtIndex(index: Int) {
        self.lists.removeAtIndex(index)
    }
    
    func moveStreamAtIndex(fromIndex: Int, toIndex: Int) {
        var fromCellData = self.lists[fromIndex]
        var toCellData = self.lists[toIndex]
        self.lists[fromIndex] = toCellData
        self.lists[toIndex] = fromCellData
    }
    
    func addNewStream(image: String, name: String, type: String, uri: String, id: String) {
        var newStream = Stream(image: image, name: name, type: type, uri: uri, id: id)
        self.lists.append(newStream)
    }
    
    func add(stream: Stream) {
        self.lists.append(stream)
    }
    
    func mergeStreamList(streamList: StreamList) {
        self.lists += streamList.lists
    }
    
    func clearData() {
        self.initStreamList()
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(nil, forKey: "streamList")
    }
}
