//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Rodrigo Webler on 9/30/15.
//  Copyright (c) 2015 Rodrigo Webler. All rights reserved.
//

import UIKit
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate, UITabBarDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
