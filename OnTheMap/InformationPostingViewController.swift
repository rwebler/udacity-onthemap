//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Rodrigo Webler on 10/3/15.
//  Copyright (c) 2015 Rodrigo Webler. All rights reserved.
//

import UIKit
import MapKit

class InformatonPostingViewController : UIViewController {
    
    @IBOutlet weak var infoTextField: UITextField!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var infoButton: UIButton!
    
    @IBOutlet weak var infoMapView: MKMapView!
    
    @IBOutlet weak var browseURLView: UIWebView!

    @IBOutlet weak var infoActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var browseURLButton: UIButton!

    var info = [String : AnyObject]()
    
    var backgroundColor : UIColor?
    
    // determines radius of area shown in map after zooming to the new pin
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        infoActivityIndicator.stopAnimating()
        
        info["firstName"] = UdacityClient.sharedInstance().userFirstName
        info["lastName"] = UdacityClient.sharedInstance().userLastName
        info["uniqueKey"] = UdacityClient.sharedInstance().userKey
        
        infoLabel.text = "Where are you studying today?"
        infoTextField.placeholder = "Type a city or location"
        infoTextField.keyboardType = UIKeyboardType.Default
        infoButton.setTitle("Submit", forState: .Normal)
        infoButton.removeTarget(self, action: "sendLocation:", forControlEvents: UIControlEvents.TouchUpInside)
        infoButton.addTarget(self, action: "sendLocation:", forControlEvents: UIControlEvents.TouchUpInside)
        
        browseURLButton.hidden = true
        browseURLView.hidden = true
        
        infoMapView!.hidden = true
        
        backgroundColor = view.backgroundColor
    }

    func sendLocation(sender: UIButton) {
        println("In sendLocation")
        
        infoActivityIndicator.startAnimating()
        view.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        let address = infoTextField.text
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            
            self.infoActivityIndicator.stopAnimating()
            self.view.backgroundColor = self.backgroundColor
            
            if let placemark = placemarks?[0] as? CLPlacemark {
                self.infoMapView.hidden = false
                
                self.info["latitude"] = placemark.location.coordinate.latitude
                self.info["longitude"] = placemark.location.coordinate.longitude
                self.info["mapString"] = address
                
                let location = CLLocation(latitude: placemark.location.coordinate.latitude, longitude: placemark.location.coordinate.longitude)
                self.centerMapOnLocation(location)

                self.infoMapView.addAnnotation(MKPlacemark(placemark: placemark))
                
                self.infoLabel.text = "What's the link?"
                self.infoTextField.text = ""
                self.infoTextField.placeholder = "Type a URL"
                self.infoTextField.keyboardType = UIKeyboardType.URL
                self.infoButton.setTitle("Submit", forState: .Normal)
                self.infoButton.removeTarget(self, action: "sendLocation:", forControlEvents: UIControlEvents.TouchUpInside)
                self.infoButton.addTarget(self, action: "sendURL:", forControlEvents: UIControlEvents.TouchUpInside)
                
                self.browseURLButton.addTarget(self, action: "browseURL:", forControlEvents: UIControlEvents.TouchUpInside)
                self.browseURLButton.hidden = false
            } else {
                self.displayError("No location found for that address")
            }
        })
    }
    
    func sendURL(sender: UIButton) {
        println("In sendURL")

        infoActivityIndicator.startAnimating()
        view.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        info["mediaURL"] = infoTextField.text
        
        ParseClient.sharedInstance().postStudentInfo(info) {(success, error) in
            dispatch_async(dispatch_get_main_queue(), {
                
                self.infoActivityIndicator.stopAnimating()
                self.view.backgroundColor = self.backgroundColor
                
                if success {
                    self.dismissViewControllerAnimated(true, completion: {});
                } else {
                    println(error)
                    self.displayError(error)
                }
            })
        }
    }
    
    func browseURL(sender: UIButton) {
        browseURLView.hidden = false
        browseURLView.loadRequest(NSURLRequest(URL: NSURL(string: infoTextField.text!)!))
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        browseURLView.hidden = true
        browseURLButton.hidden = true
        dismissViewControllerAnimated(true, completion: {});
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        self.infoMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func displayError(errorString: String?) {
        if let errorString = errorString {
            
            //display alert with error message
            var alert = UIAlertController(title: "Information Posting Failed", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
}
