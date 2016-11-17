//
//  DataManager.swift
//  ArmyOfOnes
//
//  Created by Fabian Mariño on 11/4/16.
//  Copyright © 2016 Fabian Mariño. All rights reserved.
//

import Foundation

enum RatesEndpoint : String {
    case ratesBaseUrl = "https://api.fixer.io/latest?base=USD&symbols=", joiner = ",", requestMethod = "GET"
}

enum Error : Swift.Error {
    case noConnectionError
}

struct DataManager {
    
    func fetchJsonData(_ suffixes:[String], callback:@escaping CurrenciesCallback) -> Void {
        
        let ratesUrl = formatUrl(suffixes)
        
        let session = URLSession.shared
        
        var request = URLRequest(url: URL(string: ratesUrl)!)
        request.httpMethod = RatesEndpoint.requestMethod.rawValue
        
        session.dataTask(with: request) { data, response, err in
            print("Entered the completionHandler")
            
            guard data != nil else {
                print("data is nil")
                let emptyCurrencies = [Currency]()
                callback(emptyCurrencies, Error.noConnectionError)
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                do{
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
                    
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

            
            }.resume()
    }
    
    func formatUrl(_ suffixes: [String]) -> String {
        let joiner = RatesEndpoint.joiner.rawValue
        let baseUrl = RatesEndpoint.ratesBaseUrl.rawValue
        let symbols = suffixes.joined(separator: joiner)
        let ratesUrl = "\(baseUrl)\(symbols)"
        
        return ratesUrl
    }
}
