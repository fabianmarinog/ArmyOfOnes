//
//  CurrenciesListViewController.swift
//  ArmyOfOnes
//
//  Created by Fabian Mariño on 11/8/16.
//  Copyright © 2016 Fabian Mariño. All rights reserved.
//

import UIKit
import SnapKit

class CurrenciesListViewController: UITableViewController {
    let cellIdentifier = "CellIdentifier"
    var currencyRatesList = [String]()
    let listTitle = "Army of Ones"
    var currencyFormatter = NSNumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets format number style to currency
        currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        self.title = listTitle
        
        self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        let currencyController = CurrencyController()
        currencyController.fetchRates(Country.allCountries) {(rates, err) -> Void in
            print("rate \(rates)")
            
            if let ratesList = rates {
                for rate in ratesList {
                    let countryValue = rate.currencyCountry.rawValue
                    let rateValue = rate.currencyValue
                    self.currencyFormatter.currencyCode = countryValue
                    
                    if let currencyFormatedValue = self.currencyFormatter.stringFromNumber(rateValue) {
                        self.currencyRatesList.append("\(countryValue) \(currencyFormatedValue)")
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as UITableViewCell
        
        cell.textLabel?.text = currencyRatesList[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyRatesList.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
