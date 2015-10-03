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
        
        self.reload()
    }
    
    func reload() {
        ParseClient.sharedInstance().getStudentInfo { success, studentInfo, error in
            if let studentInfo = studentInfo {
                self.linksTableView.reloadData()
            } else {
                println(error)
            }
        }
    }
    
    func add() {
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "OneTheMapTableViewCell"
        let pin = ParseClient.sharedInstance().studentInformationList![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        
        cell.textLabel!.text = "\(pin.firstName) \(pin.lastName)"
        cell.detailTextLabel!.text = pin.mediaURL
        
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
