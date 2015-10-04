//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Rodrigo Webler on 9/27/15.
//  Copyright (c) 2015 Rodrigo Webler. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var fbButton = FBSDKLoginButton()
        fbButton.center = self.view.center
        fbButton.delegate = self
        self.view.addSubview(fbButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.loginMessageLabel.text = "Login to Udacity"
    }

    @IBAction func pressLoginButton(sender: UIButton) {
        loginMessageLabel.text = "Logging in..."
        UdacityClient.sharedInstance().authenticate(emailTextField.text, password: passwordTextField.text, completionHandler: { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.completeLogin()
                } else {
                    self.displayError(errorString)
                }
            })
        })
    }
    
    func completeLogin() {
        loginMessageLabel.text = "Logged in to Udacity"
        let controller = storyboard!.instantiateViewControllerWithIdentifier("StudentLocationsNavigationController") as! UINavigationController
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func displayError(errorString: String?) {
        if let errorString = errorString {
            
            //display alert with error message
            loginMessageLabel.text = "Login to Udacity"
            var alert = UIAlertController(title: "Login Failed", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            
            // shake the view
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.autoreverses = true
            animation.fromValue = NSValue(CGPoint: CGPointMake(view.center.x - 10, view.center.y))
            animation.toValue = NSValue(CGPoint: CGPointMake(view.center.x + 10, view.center.y))
            view.layer.addAnimation(animation, forKey: "position")
            
        }
    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In With FB")
        
        if ((error) != nil)
        {
            self.displayError(error.localizedDescription)
        }
        else if result.isCancelled {
            self.displayError("Facebook Login was cancelled")
        }
        else {
            if(FBSDKAccessToken.currentAccessToken() != nil) {
                UdacityClient.sharedInstance().authenticateWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (success, errorString) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if success {
                            self.completeLogin()
                        } else {
                            self.displayError(errorString)
                        }
                    })
                })
            } else {
                self.displayError("Facebook Login has failed")
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out With FB")
    }

}

