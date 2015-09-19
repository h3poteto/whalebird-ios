//
//  StackListTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/16.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol StackListTableViewControllerDelegate {
    func decidedStackStreamList(stackStreamList: StreamList)
}

class StackListTableViewController: UITableViewController {

    //=============================================
    //  instance variables
    //=============================================
    var twitterScreenName: String?
    var stackStreamList: StreamList!
    
    var delegate: StackListTableViewControllerDelegate!

    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.title = "リストを選択"
        let userDefault = NSUserDefaults.standardUserDefaults()
        self.twitterScreenName = userDefault.objectForKey("username") as? String
    }
    
    convenience init() {
        self.init(style: UITableViewStyle.Plain)
        self.stackStreamList = StreamList()
        self.stackStreamList.initStreamList()
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        let selectButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Done, target: self, action: "decideSelected:")
        self.navigationItem.rightBarButtonItem = selectButton
        
        self.tableView.allowsMultipleSelection = true
        
        
        if (self.twitterScreenName != nil) {
            let params: Dictionary<String, String> = [
                "screen_name" : self.twitterScreenName!
            ]
            let cParameter: Dictionary<String, AnyObject> = [
                "settings" : params
            ]
            SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
            WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/lists.json", displayError: true, params: cParameter,
                completed: { (aStackList) -> Void in
                    let q_main = dispatch_get_main_queue()
                    print(aStackList)
                    dispatch_async(q_main, {()->Void in
                        for list in aStackList {
                            self.stackStreamList.addNewStream(
                                "",
                                name: list.objectForKey("full_name") as! String,
                                type: "list",
                                uri: list.objectForKey("uri") as! String,
                                id: list.objectForKey("id_str") as! String
                            )
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
        return self.stackStreamList.count()
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = self.stackStreamList.getStreamAtIndex(indexPath.row).name
        cell.textLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 16)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.None
    }
    

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func decideSelected(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        if let selectedArray = self.tableView.indexPathsForSelectedRows as Array? {
            if (selectedArray.count > 0) {
                let selectedStreamList = StreamList()
                selectedStreamList.initWithEmpty()
                for index in selectedArray {
                    selectedStreamList.add(self.stackStreamList.getStreamAtIndex(index.row))
                }
                self.delegate.decidedStackStreamList(selectedStreamList)
            }
        }
        // ListTableViewをアップデートする
    }
}
