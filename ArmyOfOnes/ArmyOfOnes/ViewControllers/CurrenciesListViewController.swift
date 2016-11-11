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
    case inputOffset = 14, topInset = 43, tableTopInset = 70
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
        textField.textAlignment = .Center
        textField.keyboardType = UIKeyboardType.DecimalPad
        return textField
    }()
    
    let cellIdentifier = "CellIdentifier"
    let listTitle = "Army of Ones"
    
    var currencyRatesList = [String]()
    var currencyCountries = [String]()
    var currencyFormatter = NSNumberFormatter()
    
    var rates = [Currency]()
    
    //Mark: View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(LayoutConstraints.tableTopInset.rawValue, 0, 0, 0);
        tableView.scrollEnabled = false
        tableView.allowsSelection = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.delegate = self
        tableView.dataSource = self
        
        title = listTitle
        tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        // Gesture that recognices tap to hide keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action:Selector("endEditing:"))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture);
        
        setQuantityInputLayout()
        setupRates()
        
        view.setNeedsUpdateConstraints()
    }
    
    func setQuantityInputLayout()->Void {
        
        quantityInput.delegate = self
        quantityInput.addTarget(self, action: "textFieldChanged:", forControlEvents: UIControlEvents.EditingChanged)
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
        currencyRatesList.removeAll()
        currencyCountries.removeAll()
        
        for rate in rates {
            let countryValue = rate.currencyCountry.rawValue
            let rateValue = rate.currencyValue * dollarQuantity
            currencyFormatter.currencyCode = countryValue
            if let currencyFormatedValue = currencyFormatter.stringFromNumber(rateValue) {
                currencyRatesList.append("\(countryValue) \(currencyFormatedValue)")
                currencyCountries.append("\(countryValue)")
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
            
            quantityInput.snp_makeConstraints { make in
                make.height.equalTo(topInset)
                make.width.equalTo(superview).multipliedBy(0.95)
                make.top.equalTo(navigationController!.navigationBar.snp_bottom).offset(inputOffset)
                make.centerX.equalTo(superview)
            }
           
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    //MARK: quantityInput methods
    
    func textFieldChanged(textField: UITextField){
        if let dollarAmount = textField.text {
            if let convertedDollarAmount = Double(dollarAmount) {
                print("Converted: \(convertedDollarAmount)")
                dollarQuantity = convertedDollarAmount
                reloadRates()
            }
        }
    }
    
    func endEditing(recognizer: UITapGestureRecognizer) {
        //hides keyboard after touch
        quantityInput.resignFirstResponder()
    }
}

 //MARK: TableView methods
extension CurrenciesListViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as UITableViewCell
        
        cell.textLabel?.text = currencyRatesList[indexPath.row]
        let countryFlag = currencyCountries[indexPath.row]
        let CountryImage = UIImage(named: countryFlag)
        cell.imageView?.image = CountryImage
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyRatesList.count
    }
}

 //MARK: Textfield methods
extension CurrenciesListViewController: UITextFieldDelegate {

    
    func textField(textFieldToChange: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // limit to 4 characters
        let characterCountLimit = 15
        
        // We need to figure out how many characters would be in the string after the change happens
        let startingLength = textFieldToChange.text?.characters.count ?? 0
        let lengthToAdd = string.characters.count
        let lengthToReplace = range.length
        
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= characterCountLimit
    }
}
