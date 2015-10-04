//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Rodrigo Webler on 9/28/15.
//  Copyright (c) 2015 Rodrigo Webler. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class UdacityClient : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    /* Authentication state */
    var sessionID : String? = nil
    var userKey : String? = nil
    var objectID : String? = nil
    var userFirstName : String? = nil
    var userLastName : String? = nil
    var facebookAccessToken : String? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func updateObjectID(objectID: String) {
        //keep only latest objectID, if list has more than one for the same student
        if self.objectID == nil {
            self.objectID = objectID
        }
    }
    
    func authenticate(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        println("In authenticate")
        
        let jsonBody = [JSONBodyKeys.Udacity: [JSONBodyKeys.Username: username, JSONBodyKeys.Password: password]]
        
        getSessionID(jsonBody) { (success, sessionID, userKey, errorString) in
            if success {
                if let sessionID = sessionID {
                    self.sessionID = sessionID
                }
                if let userKey = userKey {
                    self.userKey = userKey
                }
                self.getUserData() { (success, userData, errorString) in
                    if success {
                        println(userData)
                        if let userData = userData {
                            self.userLastName = userData[JSONResponseKeys.UserLastName] as? String
                            self.userFirstName = userData[JSONResponseKeys.UserFirstName] as? String
                        }
                    }
                    completionHandler(success: success, errorString: errorString)
                }
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    func authenticateWithFacebook(accessToken: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        println("In authenticate with FB")
        
        let jsonBody = [JSONBodyKeys.Facebook: [JSONBodyKeys.FacebookAccessToken: accessToken]]
        getSessionID(jsonBody) { (success, sessionID, userKey, errorString) in
            if success {
                self.facebookAccessToken = accessToken
                if let sessionID = sessionID {
                    self.sessionID = sessionID
                }
                if let userKey = userKey {
                    self.userKey = userKey
                }
                self.getUserData() { (success, userData, errorString) in
                    if success {
                        println(userData)
                        if let userData = userData {
                            self.userLastName = userData[JSONResponseKeys.UserLastName] as? String
                            self.userFirstName = userData[JSONResponseKeys.UserFirstName] as? String
                        }
                    }
                    completionHandler(success: success, errorString: errorString)
                }
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    func getSessionID (jsonBody: [String: AnyObject], completionHandler: (success: Bool, sessionID: String?, userKey: String?, errorString: String?) -> Void) {
        println("In login")
        taskForPOSTMethod(Methods.Session, jsonBody: jsonBody) { result, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, sessionID: nil, userKey: nil, errorString: "Login Failed (Session ID).")
            } else {
                if let dataDict = result as? [String: [String: AnyObject]] {
                    println("\(dataDict)")
                    let sessDict = dataDict[JSONResponseKeys.SessionDictionary]!
                    println("\(sessDict)")
                    let acctDict = dataDict[JSONResponseKeys.AccountDictionary]!
                    completionHandler(success: true, sessionID: sessDict[JSONResponseKeys.SessId] as? String, userKey: acctDict[JSONResponseKeys.AcctKey] as? String, errorString: nil)
                } else {
                    println("\(result)")
                    completionHandler(success: false, sessionID: nil, userKey: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }
    }
    
    func getUserData(completionHandler: (success: Bool, userData: [String: AnyObject]?, errorString: String?) -> Void) {
        println("In getUserData")
        taskForGETMethod(UdacityClient.substituteKeyInMethod(Methods.UserWithID, key: ParameterKeys.UserID, value: userKey!)!) { (result, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, userData: nil, errorString: "Get User Data Failed (Request)")
            } else {
                if let userDict = result.valueForKey(JSONResponseKeys.UserDataDictionary) as? [String: AnyObject] {
                    println("\(userDict)")
                    completionHandler(success: true, userData: userDict, errorString: nil)
                } else {
                    println("\(result)")
                    completionHandler(success: false, userData: nil, errorString: "Get User Data Failed (Parsing)")
                }
            }
        }
    }
    
    func logout(completionHandler: (success: Bool, errorString: String?) -> Void) {
        println("In logout")
        if facebookAccessToken == nil {
            taskForDELETEMethod("session") { (result, error) in
                if let error = error {
                    completionHandler(success: false, errorString: error.localizedDescription)
                } else {
                    completionHandler(success: true, errorString: nil)
                }
            }
        } else {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            completionHandler(success: true, errorString: nil)
        }
    }
    
    func taskForGETMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                /* 5/6. Parse the data and use the data (happens in completion handler) */
                UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func taskForPOSTMethod(method: String, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        println("in taskForPOSTMethod")
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            println(request)
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                /* 5/6. Parse the data and use the data (happens in completion handler) */
                UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func taskForDELETEMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        println("in taskForDELETEMethod")
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                /* 5/6. Parse the data and use the data (happens in completion handler) */
                UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        println("In parseJSONWithCompletionHandler \(data)")
        var parsingError: NSError? = nil
        
        if let data = data {
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
            
            if let error = parsingError {
                println(error)
                completionHandler(result: nil, error: error)
            } else {
                println(parsedResult)
                completionHandler(result: parsedResult, error: nil)
            }
        } else {
            completionHandler(result: nil, error: NSError(domain: "Internet Connection Error", code: 1, userInfo: nil))
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}