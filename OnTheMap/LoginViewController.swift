//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Rodrigo Webler on 9/27/15.
//  Copyright (c) 2015 Rodrigo Webler. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.loginMessageLabel.text = "Login to Udacity"
    }

    @IBAction func pressLoginButton(sender: UIButton) {
        loginMessageLabel.text = "Logging in..."
        UdacityClient.sharedInstance().authenticate(emailTextField.text, password: passwordTextField.text, completionHandler: { (success, errorString) in
            if success {
                self.completeLogin()
            } else {
                self.displayError(errorString)
            }
        })
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.loginMessageLabel.text = "Logged in to Udacity"
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapNavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                
                //display alert with error message
                self.loginMessageLabel.text = "Login to Udacity"
                var alert = UIAlertController(title: "Login Failed", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                // shake the view
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(CGPoint: CGPointMake(self.view.center.x - 10, self.view.center.y))
                animation.toValue = NSValue(CGPoint: CGPointMake(self.view.center.x + 10, self.view.center.y))
                self.view.layer.addAnimation(animation, forKey: "position")

            }
        })
    }

}

