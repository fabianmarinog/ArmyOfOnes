//
//  DataManager.swift
//  ArmyOfOnes
//
//  Created by Fabian Mariño on 11/4/16.
//  Copyright © 2016 Fabian Mariño. All rights reserved.
//

import Foundation

enum RatesEndpoint : String {
    case ratesBaseUrl = "https://api.fixer.io/latest?base=USD&symbols=", joiner = ","
}

struct DataManager {
    
    func fetchJsonData(suffixes:[String])->Void{
        let joiner = RatesEndpoint.joiner.rawValue
        let baseUrl = RatesEndpoint.ratesBaseUrl.rawValue
        let symbols = suffixes.joinWithSeparator(joiner)
        let ratesUrl = "\(baseUrl)\(symbols)"
        
        print("ratesUrl \(ratesUrl)")
        
        let requestURL: NSURL = NSURL(string: ratesUrl)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("JSON get ok")
            }
        }
        
        task.resume()
    }
}