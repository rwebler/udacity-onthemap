//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Rodrigo Webler on 10/1/15.
//  Copyright (c) 2015 Rodrigo Webler. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var rightPinBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin"), style: .Plain, target: self, action: "addPin:")
        var rightReloadBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reloadPins:")
        self.navigationItem.setRightBarButtonItems([rightReloadBarButtonItem, rightPinBarButtonItem], animated: true)
    }

    func reloadPins(sender:UIButton) {
        println("reload pressed")
        let selectedViewController = self.selectedViewController as! OnTheMapController
        selectedViewController.reload()
    }

    func addPin (sender:UIButton) {
        println("add pressed")
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func doLogout(sender: UIBarButtonItem) {
        println("Logout")
        UdacityClient.sharedInstance().logout({ (success, errorString) in
            if success {
                self.completeLogout()
            } else {
                self.displayError(errorString)
            }
        })
    }
    
    func completeLogout() {
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                
                //display alert with error message
                var alert = UIAlertController(title: "Logout Failed", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        })
    }
}
