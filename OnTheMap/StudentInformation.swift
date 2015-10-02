//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Rodrigo Webler on 9/28/15.
//  Copyright (c) 2015 Rodrigo Webler. All rights reserved.
//

struct StudentInformation {
    
    var objectID = ""
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    var mapString = ""
    var mediaURL = ""
    var latitude = 0.0
    var longitude = 0.0

    /* Construct from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        objectID = dictionary[ParseClient.JSONResponseKeys.ObjectID] as! String
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as! String
        firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as! String
        mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as! String
        latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as! Double
        longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as! Double
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of StudentInformation objects */
    static func studentInfoFromResults(results: [[String: AnyObject]]) -> [StudentInformation] {
        var studentInfo = [StudentInformation]()
        
        for result in results {
            studentInfo.append(StudentInformation(dictionary: result as! [String : AnyObject]))
        }
        
        return studentInfo
    }
}


