//
//  MinuteTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/13.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

protocol MinuteTableViewControllerDelegate {
    func rewriteTweetWithMinute(minute: NSDictionary, index: Int)
}

class MinuteTableViewController: UITableViewController {

    //=============================================
    //  instance variables
    //=============================================
    var minuteModel: MinuteModel!
    var delegate: MinuteTableViewControllerDelegate!
    
    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.minuteModel = MinuteModel()     
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    convenience init() {
        self.init(style: UITableViewStyle.Plain)
        self.minuteModel = MinuteModel()
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
        return self.minuteModel.count()
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "MinuteCell")
        if let minute = self.minuteModel.getMinuteAtIndex(indexPath.row) {
            cell.textLabel?.text = minute.objectForKey("text") as? String
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let minute = self.minuteModel.getMinuteAtIndex(indexPath.row) {
            self.delegate.rewriteTweetWithMinute(minute, index: indexPath.row)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }


    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            self.minuteModel.saveMinuteAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // 配列の先頭に下書きを追加して，NSUserDefaultにも保存
    func addMinute(minuteString: String!, minuteReplyToID: String?) {
        self.minuteModel.addMinuteAtFirst(minuteString, replyToID: minuteReplyToID)
    }
    
    func deleteMinute(index: Int!) {
        self.minuteModel.deleteMinuteAtIndex(index)
    }

}
