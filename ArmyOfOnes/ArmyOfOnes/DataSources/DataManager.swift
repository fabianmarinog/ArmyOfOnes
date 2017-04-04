//
//  DataManager.swift
//  ArmyOfOnes
//
//  Created by Fabian Mariño on 11/4/16.
//  Copyright © 2016 Fabian Mariño. All rights reserved.
//

import Foundation

enum RatesEndpoint : String {
    case ratesBaseUrl = "https://api.fixer.io/latest?base=USD&symbols=",
    joiner = ",",
    requestMethod = "GET"
}

enum Error : Swift.Error {
    case noConnection,
    noStatusCode,
    wrongStatusCode,
    failedJsonParsing
}

struct DataManager {
    
    func fetchJsonData(_ suffixes:[String], callback:@escaping CurrenciesCallback) -> Void {
        
        let ratesUrl = formatUrl(suffixes)
        
        let session = URLSession.shared
        
        guard let convertedUrl = URL(string: ratesUrl) else {
            print("no converted URL from string")
            return
        }
        
        var request = URLRequest(url: convertedUrl)
        request.httpMethod = RatesEndpoint.requestMethod.rawValue
        
        let emptyCurrencies = [Currency]() //sends empty data when error occurs
        
        session.dataTask(with: request) { data, response, err in
            print("Entered the completionHandler")
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                // Error handling
                print("no status Code")
                callback(emptyCurrencies, Error.noStatusCode)
                return
            }
            
            guard statusCode == 200 else {
                // status code is different
                print("status code is not 200")
                callback(emptyCurrencies, Error.wrongStatusCode)
                return
            }
            
            guard let data = data else {
                // No data handling
                print("data is nil")
                callback(emptyCurrencies, Error.noConnection)
                return
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as! [String:AnyObject]
                
                if let rates = json["rates"] as? [String:Double] {
                    
                    var currencies = [Currency]()
                    for (country, rate) in rates {
                        if let countryReference = Country(rawValue: country) {
                            let currency = Currency(country: countryReference, value: rate)
                            currencies.append(currency)
                        }
                    }
                    callback(currencies,nil)
                }
                
            } catch {
                print("Error with Rates Json: \(error)")
                callback(emptyCurrencies, Error.failedJsonParsing)
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
