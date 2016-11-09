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
    
    var didSetupConstraints = false
    
    let quantityInput = UITextField()
    let cellIdentifier = "CellIdentifier"
    let listTitle = "Army of Ones"
    
    var currencyRatesList = [String]()
    var currencyFormatter = NSNumberFormatter()
    var dollarQuantity = 1.0
    
    let inputPlaceholder = "Type a valid dollar quantity"
    let topInset = CGFloat(43)
    
    var rates = [Currency]()
    
    //Mark: View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
        tableView.scrollEnabled = false
        
        quantityInput.backgroundColor = UIColor.lightGrayColor()
        quantityInput.textColor = UIColor.whiteColor()
        quantityInput.text = String(dollarQuantity)
        quantityInput.placeholder = inputPlaceholder
        navigationController?.view.insertSubview(quantityInput, belowSubview: navigationController!.navigationBar)
        
        //sets format number style to currency
        currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        title = listTitle
        
        tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        setupRates()
        
        view.setNeedsUpdateConstraints()
    }
    
    func setupRates()->Void {
        
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
    
    //MARK: Snapkit methods
    
    override func updateViewConstraints() {
        
        if (!didSetupConstraints) {
            
            quantityInput.snp_makeConstraints { make in
                make.height.equalTo(topInset)
                make.width.equalTo(view)
                make.top.equalTo(topInset + 22)
            }
           
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
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
}
