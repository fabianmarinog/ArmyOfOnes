//
//  Currency.swift
//  ArmyOfOnes
//
//  Created by Fabian Mariño on 11/4/16.
//  Copyright © 2016 Fabian Mariño. All rights reserved.
//

//{"base":"USD","date":"2016-11-04","rates":{"BRL":3.2449,"GBP":0.80058,"JPY":102.98,"EUR":0.90147}}

import Foundation

struct Currency {
    let country: Country
    let value: Double
}

enum Country : String {
    case brl = "BRL", gbp = "GBP", jpy = "JPY", eur = "EUR"
    
    static let allCountries = [brl, gbp, jpy, eur]
}
