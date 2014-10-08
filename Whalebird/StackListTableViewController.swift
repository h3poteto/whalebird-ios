//
//  StackListTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/16.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class StackListTableViewController: UITableViewController {
    
    var twitterScreenName: String!
    var stackTarget: NSURL!
    var stackListArray = NSArray()
    var selectedIndex: Int?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "リストを選択"
        let user_default = NSUserDefaults.standardUserDefaults()
        self.twitterScreenName = user_default.objectForKey("username") as NSString
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
    
    init(StackTarget: NSURL) {
        super.init()
        self.stackTarget = StackTarget
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        var selectButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Done, target: self, action: "decideSelected:")
        self.navigationItem.rightBarButtonItem = selectButton
        
        self.tableView.allowsMultipleSelection = false
        
        let params: Dictionary<String, String> = [
            "screen_name" : self.twitterScreenName
        ]
        
        TwitterAPIClient.sharedClient.getTimeline(self.stackTarget, params: params, callback: {stackList in
            var q_main = dispatch_get_main_queue()
            println(stackList)
            dispatch_async(q_main, {()->Void in
                self.stackListArray = stackList
                self.tableView.reloadData()
            })
        })
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
        let cell: UITableViewCell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = (self.stackListArray.objectAtIndex(indexPath.row) as NSDictionary).objectForKey("uri") as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        self.selectedIndex = indexPath.row
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.None
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.selectedIndex != nil) {
            let viewControllers = self.navigationController!.viewControllers as NSArray
            let viewControllersCount = viewControllers.count as Int
            let parentController: ListTableViewController = viewControllers.objectAtIndex(viewControllersCount - 1) as ListTableViewController
            var streamElement = ListTableViewController.Stream(
                image: "",
                name: self.stackListArray.objectAtIndex(self.selectedIndex!).objectForKey("full_name") as String,
                type: "list", uri: self.stackListArray.objectAtIndex(self.selectedIndex!).objectForKey("uri") as String,
                id: self.stackListArray.objectAtIndex(self.selectedIndex!).objectForKey("id_str") as String)
            parentController.streamList.append(streamElement)
        }
    }

    func decideSelected(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
}
