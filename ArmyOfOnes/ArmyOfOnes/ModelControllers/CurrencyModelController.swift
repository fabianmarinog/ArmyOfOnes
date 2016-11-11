//
//  CurrencyModelController.swift
//  ArmyOfOnes
//
//  Created by Fabian Mariño on 11/4/16.
//  Copyright © 2016 Fabian Mariño. All rights reserved.
//

import Foundation

typealias CurrenciesCallback = ([Currency]?, Error?) -> Void

protocol CurrencyControllerProtocol {
    func fetchRates(countries:[Country], callback:CurrenciesCallback) -> Void
}

struct CurrencyController : CurrencyControllerProtocol {
    func fetchRates(countries:[Country], callback:CurrenciesCallback) -> Void{
        
        var currenciesSufixes = [String]()
        for country in Country.allCountries{
            currenciesSufixes.append(country.rawValue)
        }
        let dataManager = DataManager()
        dataManager.fetchJsonData(currenciesSufixes, callback: callback)
    }
}
