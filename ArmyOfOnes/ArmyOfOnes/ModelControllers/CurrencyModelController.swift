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
    func fetchRates(_ countries:[Country], callback: @escaping CurrenciesCallback) -> Void
}

struct CurrencyController : CurrencyControllerProtocol {
    internal func fetchRates(_ countries: [Country], callback: @escaping ([Currency]?, Error?) -> Void) {
        var currenciesSufixes = [String]()
        for country in Country.allCountries{
            currenciesSufixes.append(country.rawValue)
        }
        let dataManager = DataManager()
        dataManager.fetchJsonData(currenciesSufixes, callback: callback)
    }
}
