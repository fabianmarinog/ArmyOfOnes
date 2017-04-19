//
//  DataManager.swift
//  ArmyOfOnes
//
//  Created by Fabian Mariño on 11/4/16.
//  Copyright © 2016 Fabian Mariño. All rights reserved.
//

import Foundation

enum RatesEndpoint : String {
    case ratesBaseUrl = "https://api.fixer.io/latest",
    joiner = ",",
    requestMethod = "GET",
    baseParam = "base",
    baseValue = "USD",
    symbolsParam = "symbols"
}

enum RequestError : Error {
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
            return
        }
        
        var request = URLRequest(url: convertedUrl)
        request.httpMethod = RatesEndpoint.requestMethod.rawValue
        
        let emptyCurrencies = [Currency]() //sends empty data when error occurs
        
        session.dataTask(with: request) { data, response, err in
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                // Error handling
                callback(emptyCurrencies, RequestError.noStatusCode)
                return
            }
            
            guard statusCode == 200 else {
                // status code is different
                callback(emptyCurrencies, RequestError.wrongStatusCode)
                return
            }
            
            guard let data = data else {
                // No data handling
                callback(emptyCurrencies, RequestError.noConnection)
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
                callback(emptyCurrencies, RequestError.failedJsonParsing)
            }
            
            
            }.resume()
    }
    
    func formatUrl(_ suffixes: [String]) -> String {
        let defaultUrl = RatesEndpoint.ratesBaseUrl.rawValue
        
        guard var baseUrl = URLComponents(string: RatesEndpoint.ratesBaseUrl.rawValue) else {
            return defaultUrl
        }
        
        let symbols = suffixes.joined(separator: RatesEndpoint.joiner.rawValue)
        
        baseUrl.queryItems = [
            URLQueryItem(name: RatesEndpoint.baseParam.rawValue, value: RatesEndpoint.baseValue.rawValue),
            URLQueryItem(name: RatesEndpoint.symbolsParam.rawValue, value: symbols)
        ];
        
        guard let formatedUrl = baseUrl.string else {
            return defaultUrl
        }
        
        return formatedUrl
    }
}
