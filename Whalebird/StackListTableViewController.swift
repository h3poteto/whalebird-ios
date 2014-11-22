//
//  StackListTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/16.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class StackListTableViewController: UITableViewController {
    
    var twitterScreenName: String?
    var stackTarget: NSURL!
    var stackListArray = NSArray()
    var selectedIndex: Int?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "リストを選択"
        var userDefault = NSUserDefaults.standardUserDefaults()
        self.twitterScreenName = userDefault.objectForKey("username") as? NSString
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
    
    init(aStackTarget: NSURL) {
        super.init()
        self.stackTarget = aStackTarget
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        var selectButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Done, target: self, action: "decideSelected:")
        self.navigationItem.rightBarButtonItem = selectButton
        
        self.tableView.allowsMultipleSelection = false
        
        
        if (self.twitterScreenName != nil) {
            var params: Dictionary<String, String> = [
                "screen_name" : self.twitterScreenName!
            ]
            let cParameter: Dictionary<String, AnyObject> = [
                "settings" : params
            ]
            SVProgressHUD.showWithStatus("キャンセル", maskType: UInt(SVProgressHUDMaskTypeClear))
            WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/lists.json", params: cParameter) { (aStackList) -> Void in
                var q_main = dispatch_get_main_queue()
                println(aStackList)
                dispatch_async(q_main, {()->Void in
                    self.stackListArray = aStackList
                    self.tableView.reloadData()
                    SVProgressHUD.dismiss()
                })
            }
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
        cell.textLabel.text = (self.stackListArray.objectAtIndex(indexPath.row) as NSDictionary).objectForKey("full_name") as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        self.selectedIndex = indexPath.row
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.None
    }
    

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.selectedIndex != nil) {
            let cViewControllers = self.navigationController!.viewControllers as NSArray
            let cViewControllersCount = cViewControllers.count as Int
            let cParentController: ListTableViewController = cViewControllers.objectAtIndex(cViewControllersCount - 1) as ListTableViewController
            var streamElement = ListTableViewController.Stream(
                image: "",
                name: self.stackListArray.objectAtIndex(self.selectedIndex!).objectForKey("full_name") as String,
                type: "list", uri: self.stackListArray.objectAtIndex(self.selectedIndex!).objectForKey("uri") as String,
                id: self.stackListArray.objectAtIndex(self.selectedIndex!).objectForKey("id_str") as String)
            cParentController.streamList.append(streamElement)
        }
    }

    func decideSelected(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
}
