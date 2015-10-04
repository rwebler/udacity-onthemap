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
    
    @IBOutlet weak var infoActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var infoActivityEffectView: UIVisualEffectView!

    var info = [String : AnyObject]()
    
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
        infoButton.setTitle("Submit", forState: .Normal)
        infoButton.addTarget(self, action: "sendLocation:", forControlEvents: UIControlEvents.TouchUpInside)
        
        infoMapView!.hidden = true
    }

    func sendLocation(sender: UIButton) {
        println("In sendLocation")
        
        infoActivityIndicator.startAnimating()
        infoActivityEffectView.hidden = false
        
        let address = infoTextField.text
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            
            self.infoActivityIndicator.stopAnimating()
            self.infoActivityEffectView.hidden = true

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
                self.infoButton.setTitle("Submit", forState: .Normal)
                self.infoButton.removeTarget(self, action: "sendLocation:", forControlEvents: UIControlEvents.TouchUpInside)
                self.infoButton.addTarget(self, action: "sendURL:", forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                self.displayError("No location found for that address")
            }
        })
    }
    
    func sendURL(sender: UIButton) {
        println("In sendURL")

        infoActivityIndicator.startAnimating()
        
        info["mediaURL"] = infoTextField.text
        
        ParseClient.sharedInstance().postStudentInfo(info) {(success, error) in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.dismissViewControllerAnimated(true, completion: {});
                } else {
                    println(error)
                    self.displayError(error)
                }
            })
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {});
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
