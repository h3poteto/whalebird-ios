//
//  ListTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/16.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct Stream {
        var image: String = ""
        var name: String = ""
        var type: String = ""
        var uri: String = ""
        var id: String = ""
    }
    
    
    var streamList: Array<Stream> = []
    var addItemButton: UIBarButtonItem!
    
    // TODO: 検索から結果を保存できるようにしておく
    //==============================================
    //  instance method
    //==============================================
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "リスト"
        self.tabBarItem.image = UIImage(named: "List-Boxes.png")
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init() {
        super.init()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.editButtonItem().title = "編集"
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.addItemButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewItem:")
        self.navigationItem.leftBarButtonItem = self.addItemButton
        
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var userStreamList = userDefaults.arrayForKey("streamList") as Array?
        if (userStreamList != nil) {
            self.streamList.removeAll()
            for streamList in userStreamList! {
                self.streamList.insert(Stream(
                    image: streamList.objectForKey("image") as String,
                    name: streamList.objectForKey("name") as String,
                    type: streamList.objectForKey("type") as String,
                    uri: streamList.objectForKey("uri") as String,
                    id: streamList.objectForKey("id") as String),
                    atIndex: 0)
            }
        } else {
            var favStream = ListTableViewController.Stream(
                image: "",
                name: "お気に入り",
                type: "myself",
                uri: "users/apis/user_favorites.json",
                id: "")
            var myselfStream = ListTableViewController.Stream(
                image: "",
                name: "送信済みツイート",
                type: "myself",
                uri: "users/apis/user_timeline.json",
                id: "")
            self.streamList.append(myselfStream)
            self.streamList.append(favStream)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        
        var safeArray = NSMutableArray()
        if (self.streamList.count > 0) {
            for i in 0...self.streamList.count-1 {
                var list = self.streamList[i]
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.streamList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        cell.textLabel!.text = self.streamList[indexPath.row].name
        switch self.streamList[indexPath.row].type {
        case "list":
            cell.imageView?.image = UIImage(named: "List-Dots.png")
            break
        case "myself":
            cell.imageView?.image = UIImage(named: "Profile-Filled.png")
            break
        default:
            break
        }


        return cell
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            self.streamList.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        // streamListを入れ替える
        var fromCellData = self.streamList[fromIndexPath.row]
        var toCellData = self.streamList[toIndexPath.row]
        self.streamList[fromIndexPath.row] = toCellData
        self.streamList[toIndexPath.row] = fromCellData
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var streamTableView = StreamTableViewController(aStreamElement: self.streamList[indexPath.row], aPageIndex: indexPath.row, aParentController: self)
        self.navigationController?.pushViewController(streamTableView, animated: true)
    }


    func addNewItem(sender: AnyObject) {
        var stackListTableView = StackListTableViewController()
        self.navigationController?.pushViewController(stackListTableView, animated: true)
    }
}
