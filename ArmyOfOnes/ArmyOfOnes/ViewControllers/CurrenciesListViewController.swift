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
    var rates = [Currency]()
    var dollarQuantity = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets format number style to currency
        currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        title = listTitle
        
        tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        let currencyController = CurrencyController()
        currencyController.fetchRates(Country.allCountries) {(fetchedRates, err) -> Void in
            
            if let ratesList = fetchedRates {
                self.rates = ratesList
                self.reloadRates()
            }
        }
    }
    
    func reloadRates()->Void {
        for rate in rates {
            let countryValue = rate.currencyCountry.rawValue
            let rateValue = rate.currencyValue * dollarQuantity
            currencyFormatter.currencyCode = countryValue
            if let currencyFormatedValue = currencyFormatter.stringFromNumber(rateValue) {
                currencyRatesList.append("\(countryValue) \(currencyFormatedValue)")
            }
            tableView.reloadData()
        }
    }
    
    //MARK: TableView methods
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
