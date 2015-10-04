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
    
    var info = [String : String]()
    
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        infoActivityIndicator.stopAnimating()
        
        info["firstName"] = UdacityClient.sharedInstance().userFirstName
        info["lastName"] = UdacityClient.sharedInstance().userLastName
        
        infoLabel.text = "Where are you studying today?"
        infoTextField.placeholder = "Type a city or location"
        infoButton.setTitle("Submit", forState: .Normal)
        infoButton.addTarget(self, action: "sendLocation:", forControlEvents: UIControlEvents.TouchUpInside)
        
        infoMapView!.hidden = true
    }

    func sendLocation(sender: UIButton) {
        println("In sendLocation")
        
        infoActivityIndicator.startAnimating()
        
        let address = infoTextField.text
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                self.infoActivityIndicator.stopAnimating()
                self.infoMapView.hidden = false
                
                let location = CLLocation(latitude: placemark.location.coordinate.latitude, longitude: placemark.location.coordinate.longitude)
                self.centerMapOnLocation(location)

                self.infoMapView.addAnnotation(MKPlacemark(placemark: placemark))
                
                self.infoLabel.text = "What's the link?"
                self.infoTextField.placeholder = "Type a URL"
                self.infoButton.setTitle("Submit", forState: .Normal)
                self.infoButton.addTarget(self, action: "sendURL:", forControlEvents: UIControlEvents.TouchUpInside)
            }
        })
    }
    
    func sendURL(sender: UIButton) {
        println("In sendURL")
        
        infoActivityIndicator.startAnimating()
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        self.infoMapView.setRegion(coordinateRegion, animated: true)
    }
    
}
