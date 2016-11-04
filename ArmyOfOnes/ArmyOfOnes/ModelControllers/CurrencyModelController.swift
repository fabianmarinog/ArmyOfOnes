//
//  CurrencyModelController.swift
//  ArmyOfOnes
//
//  Created by Fabian Mariño on 11/4/16.
//  Copyright © 2016 Fabian Mariño. All rights reserved.
//

import Foundation

typealias CurrenciesCallback = ([Currency]?, NSError?)->Void

protocol CurrencyControllerProtocol {
    func fetchRates(countries:[Country], callback:CurrenciesCallback)-> Void
}

struct MockCurrencyController : CurrencyControllerProtocol{
    func fetchRates(countries:[Country], callback:CurrenciesCallback)->Void{
        var currencies = [Currency]()
        for i in 0..<countries.count{
            let currency = Currency(currencyCountry: countries[i], currencyValue: Double(10.56))
            currencies.append(currency)
        }
        callback(currencies,nil)
    }
}