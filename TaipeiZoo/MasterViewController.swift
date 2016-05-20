//
//  MasterViewController.swift
//  TaipeiZoo
//
//  Created by fangwiehsu on 2016/5/20.
//  Copyright © 2016年 fangwiehsu. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, NSURLSessionDelegate, NSURLSessionDownloadDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()

    var dataArray = [AnyObject]()// using to store the animals data

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        
        //getting data from taipei open data
        
        //set the url
        let url = NSURL(string: "http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=a3e2b221-75e0-45c1-8f97-75acbd43d613")
        
        //建立一般的session設定
        let sessionWithConfigure = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        //設定委任對象為自己
        let session = NSURLSession(configuration: sessionWithConfigure, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        //set the downloading url
        let dataTask = session.downloadTaskWithURL(url!)
        
        //重啟or重新下載動作
        dataTask.resume()
        
        if let split = self.splitViewController{
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
        }
        
      
        
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        do{
            
            //processing json data at here
            let datadic = try NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: location)!, options: NSJSONReadingOptions.MutableContainers) as! [String:[String:AnyObject]]
            
            //find the construction of result 
            dataArray = datadic["result"]!["result"] as! [AnyObject]
            
            //refreshing the tableview
            self.tableView.reloadData()
            
            
        }catch{
            
            print("error !!")
            
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        //顯示動物的中文名稱於Table View中
        cell.textLabel?.text = dataArray[indexPath.row]["A_Name_Ch"] as? String
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

