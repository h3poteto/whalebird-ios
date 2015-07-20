//
//  StackListTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/16.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class StackListTableViewController: UITableViewController {

    //=============================================
    //  instance variables
    //=============================================
    var twitterScreenName: String?
    var stackListArray: Array<ListTableViewController.Stream> = []

    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "リストを選択"
        var userDefault = NSUserDefaults.standardUserDefaults()
        self.twitterScreenName = userDefault.objectForKey("username") as? String
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    init() {
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
        self.stackListArray.append(myselfStream)
        self.stackListArray.append(favStream)
        super.init(style: UITableViewStyle.Plain)
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        var selectButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Done, target: self, action: "decideSelected:")
        self.navigationItem.rightBarButtonItem = selectButton
        
        self.tableView.allowsMultipleSelection = true
        
        
        if (self.twitterScreenName != nil) {
            var params: Dictionary<String, String> = [
                "screen_name" : self.twitterScreenName!
            ]
            let cParameter: Dictionary<String, AnyObject> = [
                "settings" : params
            ]
            SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
            WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/lists.json", displayError: true, params: cParameter,
                completed: { (aStackList) -> Void in
                    var q_main = dispatch_get_main_queue()
                    println(aStackList)
                    dispatch_async(q_main, {()->Void in
                        for list in aStackList {
                            var streamElement = ListTableViewController.Stream(
                                image: "",
                                name: list.objectForKey("full_name") as! String,
                                type: "list",
                                uri: list.objectForKey("uri") as! String,
                                id: list.objectForKey("id_str") as! String)
                            self.stackListArray.append(streamElement)
                        }
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                    })
                }, failed: { () -> Void in
                }
            )
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return self.stackListArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = self.stackListArray[indexPath.row].name
        cell.textLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 16)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.None
    }
    

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func decideSelected(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        if let selectedArray = self.tableView.indexPathsForSelectedRows() as Array? {
            if (selectedArray.count > 0) {
                let cViewControllers = self.navigationController!.viewControllers as NSArray
                let cViewControllersCount = cViewControllers.count as Int
                if let cParentController = cViewControllers.objectAtIndex(cViewControllersCount - 1) as? ListTableViewController {
                    for index in selectedArray {
                        cParentController.streamList.append(self.stackListArray[index.row])
                    }
                }
            }
        }
    }
}
