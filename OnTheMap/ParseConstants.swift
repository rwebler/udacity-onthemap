//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Rodrigo Webler on 10/1/15.
//  Copyright (c) 2015 Rodrigo Webler. All rights reserved.
//

extension ParseClient {
    
    struct Constants {
        static let AppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let BaseURLSecure : String = "https://api.parse.com/1/classes/"
    }
    
    struct Methods {
        static let StudentLocation = "StudentLocation"
        static let StudentLocationWithObjectID = "StudentLocation/{objectId}"
    }
    
    struct ParameterKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
        static let ObjectID = "objectId"
    }
    
    struct JSONResponseKeys {
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
}