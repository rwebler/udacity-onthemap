//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Rodrigo Webler on 9/28/15.
//  Copyright (c) 2015 Rodrigo Webler. All rights reserved.
//

extension UdacityClient {
    
    struct Constants {
        static let FacebookApiKey : String = "365362206864879"
        static let FacebookURLSchemeSuffix: String = "onthemap"
        static let BaseURLSecure : String = "https://www.udacity.com/api/"
    }
    
    struct Methods {
        static let Session = "session"
        static let UserWithID = "users/{id}"
    }
    
    struct ParameterKeys {
        static let AccessToken = "access_token"
        static let Query = "query"
    }

    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    struct JSONResponseKeys {
        static let AccountDictionary = "account"
        static let AcctRegistered = "registered"
        static let AcctKey = "key"
        static let SessionDictionary = "session"
        static let SessId = "id"
        static let SessExpiration = "expiration"
        static let StatusMessage = ""
    }
}