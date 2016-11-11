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
    
    func fetchJsonData(suffixes:[String], callback:CurrenciesCallback)->Void{
        
        let ratesUrl = formatUrl(suffixes)
        
        let requestURL: NSURL = NSURL(string: ratesUrl)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            guard data !== nil else {
                print("data is nil")
                let emptyCurrencies = [Currency]()
                callback(emptyCurrencies,nil)
                return
            }
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    if let rates = json["rates"] as? [String:Double] {
                        
                        var currencies = [Currency]()
                        for (country, rate) in rates {
                            if let countryReference = Country(rawValue: country) {
                                let currency = Currency(currencyCountry: countryReference, currencyValue: rate)
                                currencies.append(currency)
                            }
                        }
                        callback(currencies,nil)
                    }
                    
                } catch {
                    print("Error with Rates Json: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    func formatUrl(suffixes: [String])->String{
        let joiner = RatesEndpoint.joiner.rawValue
        let baseUrl = RatesEndpoint.ratesBaseUrl.rawValue
        let symbols = suffixes.joinWithSeparator(joiner)
        let ratesUrl = "\(baseUrl)\(symbols)"
        
        return ratesUrl
    }
}

