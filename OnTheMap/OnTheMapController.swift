//
//  OnTheMapController.swift
//  OnTheMap
//
//  Created by Rodrigo Webler on 10/3/15.
//  Copyright (c) 2015 Rodrigo Webler. All rights reserved.
//

import UIKit

// Used in TabBarController.reloadPins, to access the reload() method in the current controller
protocol OnTheMapController {
    func reload() -> Void
}
