//
//  ViewController.swift
//  ArmyOfOnes
//
//  Created by Fabian Mariño on 11/4/16.
//  Copyright © 2016 Fabian Mariño. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let currencyController = MockCurrencyController()
        /*var countries = [String]()
        for country in Country.allCountries{
            countries.append(country.rawValue)
        }*/
        currencyController.fetchRates(Country.allCountries) {(currencies, err) -> Void in
            print("currencies \(currencies)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

