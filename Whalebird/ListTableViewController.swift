//
//  ListTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/16.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController, StackListTableViewControllerDelegate {
    
    //=============================================
    //  instance variables
    //=============================================
    var addItemButton: UIBarButtonItem!
    var searchItemButton: UIBarButtonItem!
    var streamList: StreamList!
    
    //==============================================
    //  instance methods
    //==============================================
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.title = "リスト"
        self.tabBarItem.image = UIImage(named: "List-Boxes")
        self.streamList = StreamList()
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.editButtonItem().title = "編集"
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.searchItemButton = UIBarButtonItem(image: UIImage(named: "Search-Line"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ListTableViewController.displaySearch))
        self.navigationItem.leftBarButtonItem = self.searchItemButton

        
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.separatorInset = UIEdgeInsetsZero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.streamList.saveStreamList()
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
        return self.streamList.count()
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = self.streamList.getStreamAtIndex(indexPath.row).name
        cell.textLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 16)
        switch self.streamList.getStreamAtIndex(indexPath.row).type {
        case "list":
            cell.imageView?.image = UIImage(named: "List-Dots")
            break
        case "myself":
            cell.imageView?.image = UIImage(named: "Profile-Filled")
            break
        case "search":
            cell.imageView?.image = UIImage(named: "Search-Line")
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

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if(self.editing){
            self.editButtonItem().title = "完了"
            self.addItemButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(ListTableViewController.addNewItem(_:)))
            self.navigationItem.leftBarButtonItem = self.addItemButton
        }else{
            self.editButtonItem().title = "編集"
            self.navigationItem.rightBarButtonItem = self.editButtonItem()
            self.navigationItem.leftBarButtonItem = self.searchItemButton
        }
    }

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            self.streamList.deleteStreamAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        // streamListを入れ替える
        self.streamList.moveStreamAtIndex(fromIndexPath.row, toIndex: toIndexPath.row)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let swipeView = SwipeViewController(aStreamList: self.streamList, aStartIndex: indexPath.row)
        self.navigationController?.pushViewController(swipeView, animated: true)
    }
    

    func addNewItem(sender: AnyObject) {
        let stackListTableView = StackListTableViewController()
        stackListTableView.delegate = self
        self.navigationController?.pushViewController(stackListTableView, animated: true)
    }

    func decidedStackStreamList(stackStreamList: StreamList) {
        self.streamList.mergeStreamList(stackStreamList)
    }
    
    func displaySearch() {
        let searchView = SearchTableViewController(aStreamList: self.streamList)
        self.navigationController?.pushViewController(searchView, animated: true)
    }
    
    
    func clearData() {
        self.streamList.clearData()
        self.tableView.reloadData()
    }
}
