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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        mapView.delegate = self
        reload()
    }
    
    func reload() {
        ParseClient.sharedInstance().getStudentInfo({(success, studentInfo, error) in
            if success {
                // We will create an MKPointAnnotation for each dictionary in "locations". The
                // point annotations will be stored in this array, and then provided to the map view.
                var annotations = [MKPointAnnotation]()
                
                // The "locations" array is loaded with the sample data below. We are using the dictionaries
                // to create map annotations. This would be more stylish if the dictionaries were being
                // used to create custom structs. Perhaps StudentLocation structs.
                
                if let studentInfo = studentInfo {
                    for info in studentInfo {
                        
                        // Notice that the float values are being used to create CLLocationDegree values.
                        // This is a version of the Double type.
                        let lat = CLLocationDegrees(info.latitude)
                        let long = CLLocationDegrees(info.longitude)
                        
                        // The lat and long are used to create a CLLocationCoordinates2D instance.
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        
                        let first = info.firstName
                        let last = info.lastName
                        let mediaURL = info.mediaURL
                        
                        // Here we create the annotation and set its coordiate, title, and subtitle properties
                        var annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(first) \(last)"
                        annotation.subtitle = mediaURL
                        
                        println(annotation)
                        
                        // Finally we place the annotation in an array of annotations.
                        annotations.append(annotation)
                    }
                    
                    // When the array is complete, we add the annotations to the map.
                    dispatch_async(dispatch_get_main_queue(), {
                        self.mapView.addAnnotations(annotations)
                    })
                }
            } else {
                println(error)
            }
        })
    }
    
    func add() {
        
    }
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
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
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        println("In tap callout")
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
}
