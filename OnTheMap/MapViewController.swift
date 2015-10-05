//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Rodrigo Webler on 9/30/15.
//  Copyright (c) 2015 Rodrigo Webler. All rights reserved.
//

import UIKit
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate, OnTheMapController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reload()
    }

    func reload() {
        ParseClient.sharedInstance().getStudentInfo({(success, studentInfo, error) in
            if success {
                var annotations = [MKPointAnnotation]()
                
                if let studentInfo = studentInfo {
                    for info in studentInfo {
                        
                        let lat = CLLocationDegrees(info.latitude)
                        let long = CLLocationDegrees(info.longitude)
                        
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        
                        let first = info.firstName
                        let last = info.lastName
                        let mediaURL = info.mediaURL
                        
                        var annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(first) \(last)"
                        annotation.subtitle = mediaURL
                        
                        println(annotation)
                        
                        annotations.append(annotation)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.mapView.addAnnotations(annotations)
                    })
                }
            } else {
                println(error)
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayError(error)
                })
            }
        })
    }
    
    func displayError(errorString: String?) {
        if let errorString = errorString {
            
            //display alert with error message
            var alert = UIAlertController(title: "Map Loading Failed", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    //Map Delegate Functions
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        println("In viewForAnnotation")
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        println("In tap callout")
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
}
