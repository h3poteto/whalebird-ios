//
//  MinuteTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/13.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

class MinuteTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {

    //=============================================
    //  instance variables
    //=============================================
    var minutesArray: Array<AnyObject> = []
    
    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    convenience init() {
        self.init()
        // ここでNSUserDefaultから下書きを読み込み
        var userDefault = NSUserDefaults.standardUserDefaults()
        var readMinutesArray: AnyObject? = userDefault.objectForKey("minutesArray")
        if (readMinutesArray != nil ) {
            self.minutesArray = userDefault.objectForKey("minutesArray") as! Array<AnyObject>
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.editButtonItem().title = "編集"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if(self.editing){
            self.editButtonItem().title = "完了"
        }else{
            self.editButtonItem().title = "編集"
        }
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
        return self.minutesArray.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "MinuteCell")
        cell.textLabel!.text = (self.minutesArray[indexPath.row] as! NSDictionary).objectForKey("text") as? String

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cViewControllers = self.navigationController!.viewControllers as NSArray
        let cViewControllersCount = cViewControllers.count  as Int
        let cParentController: NewTweetViewController = cViewControllers.objectAtIndex(cViewControllersCount - 2) as! NewTweetViewController
        cParentController.newTweetText.text = (self.minutesArray[indexPath.row] as! NSDictionary).objectForKey("text") as! String
        cParentController.replyToID = (self.minutesArray[indexPath.row] as! NSDictionary).objectForKey("replyToID") as? String
        self.navigationController!.popViewControllerAnimated(true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            var userDefault = NSUserDefaults.standardUserDefaults()
            self.minutesArray.removeAtIndex(indexPath.row)
            userDefault.setObject(self.minutesArray, forKey: "minutesArray")
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // 配列の先頭に下書きを追加して，NSUserDefaultにも保存
    func addMinute(minuteString: String!, minuteReplyToID: String?) {
        var minuteDictionary = NSMutableDictionary(dictionary: ["text" : minuteString])
        if (minuteReplyToID != nil) {
            minuteDictionary.setValue(minuteReplyToID!, forKey: "replyToID")
        }
        self.minutesArray.insert(minuteDictionary, atIndex: 0)
        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(self.minutesArray, forKey: "minutesArray")
    }

}
