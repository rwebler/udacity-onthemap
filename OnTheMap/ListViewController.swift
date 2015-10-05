//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Rodrigo Webler on 10/3/15.
//  Copyright (c) 2015 Rodrigo Webler. All rights reserved.
//

import UIKit

class ListViewController : UITableViewController, UITableViewDelegate, UITableViewDataSource, OnTheMapController {
    
    @IBOutlet weak var linksTableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    func reload() {
        ParseClient.sharedInstance().getStudentInfo { success, studentInfo, error in
            dispatch_async(dispatch_get_main_queue(), {
                if let studentInfo = studentInfo {
                    self.linksTableView.reloadData()
                } else {
                    println(error)
                    self.displayError(error)
                }
            })
        }
    }
    
    func displayError(errorString: String?) {
        if let errorString = errorString {
            
            //display alert with error message
            var alert = UIAlertController(title: "List Loading Failed", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    //Table View Delegate Functions
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "OneTheMapTableViewCell"
        let pin = ParseClient.sharedInstance().studentInformationList![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        
        cell.textLabel!.text = "\(pin.firstName) \(pin.lastName)"
        cell.detailTextLabel!.text = pin.mediaURL
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance().studentInformationList!.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Row selected: \(indexPath.row)")
        
        let app = UIApplication.sharedApplication()
        let pin = ParseClient.sharedInstance().studentInformationList![indexPath.row]
        app.openURL(NSURL(string: pin.mediaURL)!)
    }
}
