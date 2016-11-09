//
//  CurrenciesListViewController.swift
//  ArmyOfOnes
//
//  Created by Fabian Mariño on 11/8/16.
//  Copyright © 2016 Fabian Mariño. All rights reserved.
//

import UIKit
import SnapKit

enum LayoutConstraints: CGFloat {
    case inputOffset = 24, topInset = 43, tableTopInset = 50
}

class CurrenciesListViewController: UITableViewController {
    
    var didSetupConstraints = false
    var dollarQuantity = 1.0
    
    let quantityInput: UITextField = {
        
        let textField = UITextField()
        textField.text = String(1.0)
        textField.placeholder = "Type a valid dollar quantity"
        textField.layer.cornerRadius = 4.0
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor.lightGrayColor().CGColor
        textField.layer.borderWidth = 1.0
        return textField
    }()
    
    let cellIdentifier = "CellIdentifier"
    let listTitle = "Army of Ones"
    
    var currencyRatesList = [String]()
    var currencyFormatter = NSNumberFormatter()
    
    var rates = [Currency]()
    
    //Mark: View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(LayoutConstraints.tableTopInset.rawValue, 0, 0, 0);
        tableView.scrollEnabled = false
        tableView.allowsSelection = false
        
        title = listTitle
        tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        setQuantityInputLayout()
        setupRates()
        
        view.setNeedsUpdateConstraints()
    }
    
    func setQuantityInputLayout()->Void {
        navigationController?.view.insertSubview(quantityInput, belowSubview: navigationController!.navigationBar)
        
        //sets format number style to currency
        currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
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
        currencyRatesList = [String]()
        for rate in rates {
            let countryValue = rate.currencyCountry.rawValue
            let rateValue = rate.currencyValue * dollarQuantity
            currencyFormatter.currencyCode = countryValue
            if let currencyFormatedValue = currencyFormatter.stringFromNumber(rateValue) {
                currencyRatesList.append("\(countryValue) \(currencyFormatedValue)")
            }
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: Snapkit methods
    
    override func updateViewConstraints() {
        
        if (!didSetupConstraints) {
            let superview = view
            let inputOffset = LayoutConstraints.inputOffset.rawValue
            let topInset = LayoutConstraints.topInset.rawValue
            let inputTopPosition = topInset + inputOffset
            
            quantityInput.snp_makeConstraints { make in
                make.height.equalTo(topInset)
                make.width.equalTo(superview).multipliedBy(0.95)
                make.top.equalTo(superview).offset(inputTopPosition)
                make.centerX.equalTo(superview)
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
