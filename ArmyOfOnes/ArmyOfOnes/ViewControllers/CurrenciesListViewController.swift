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
    case inputOffset = 14,
    topInset = 43,
    tableTopInset = 70
}

enum textFieldLimit: Int {
    case max = 15
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
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.textAlignment = .center
        textField.keyboardType = UIKeyboardType.decimalPad
        return textField
    }()
    
    let cellIdentifier = "CellIdentifier"
    let listTitle = "Army of Ones"
    
    var currencyRatesList = [String]()
    var currencyCountries = [String]()
    var currencyFormatter = NumberFormatter()
    
    var rates = [Currency]()
    
    //Mark: View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(LayoutConstraints.tableTopInset.rawValue, 0, 0, 0);
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.delegate = self
        tableView.dataSource = self
        
        title = listTitle
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        // Gesture that recognices tap to hide keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(CurrenciesListViewController.endEditing(_:)))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture);
        
        setQuantityInputLayout()
        setupRates()
        
        view.setNeedsUpdateConstraints()
    }
    
    func setQuantityInputLayout() -> Void {
        
        quantityInput.delegate = self
        quantityInput.addTarget(self, action: #selector(CurrenciesListViewController.textFieldChanged(_:)), for: UIControlEvents.editingChanged)
        navigationController?.view.insertSubview(quantityInput, belowSubview: navigationController!.navigationBar)
        
        //sets format number style to currency
        currencyFormatter.numberStyle = NumberFormatter.Style.currency
    }
    
    func showNoConnectionMessage() -> Void {
        //shows an alert message when there is no internet connection
        let alert = UIAlertController(title: "Connection error", message: "Make sure you are connected to the Internet", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func setupRates() -> Void {
        
        let currencyController = CurrencyController()
        currencyController.fetchRates(Country.allCountries) {(fetchedRates, error) -> Void in
            
            
            guard let _ = error else  {
                
                guard let ratesList = fetchedRates else {
                    return
                }
                
                self.rates = ratesList
                self.reloadRates()
                
                return
            }
            
            self.showNoConnectionMessage()
            
        }

    }
    
    func reloadRates() -> Void {
        currencyRatesList.removeAll()
        currencyCountries.removeAll()
        
        for rate in rates {
            let countryValue = rate.country.rawValue
            let rateValue = rate.value * dollarQuantity
            currencyFormatter.currencyCode = countryValue
            let convertedRateValue = NSNumber(value: rateValue)

            if let currencyFormatedValue = currencyFormatter.string(from: convertedRateValue) {
                currencyRatesList.append("\(countryValue) \(currencyFormatedValue)")
                currencyCountries.append("\(countryValue)")
            }
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: Snapkit methods
    
    override func updateViewConstraints() {
        
        if (!didSetupConstraints) {
            
            if let superview = view {
                
                let inputOffset = LayoutConstraints.inputOffset.rawValue
                let topInset = LayoutConstraints.topInset.rawValue
                
                quantityInput.snp.makeConstraints { make in
                    make.height.equalTo(topInset)
                    make.width.equalTo(superview).multipliedBy(0.95)
                    make.top.equalTo(navigationController!.navigationBar.snp.bottom).offset(inputOffset)
                    make.centerX.equalTo(superview)
                }
                
                didSetupConstraints = true
            }
        }
        
        super.updateViewConstraints()
    }
    
    //MARK: quantityInput methods
    
    func textFieldChanged(_ textField: UITextField) {
        if let dollarAmount = textField.text {
            if let convertedDollarAmount = Double(dollarAmount) {
                dollarQuantity = convertedDollarAmount
                reloadRates()
            }
        }
    }
    
    func endEditing(_ recognizer: UITapGestureRecognizer) {
        //hides keyboard after touch
        quantityInput.resignFirstResponder()
    }
}

 //MARK: TableView methods
extension CurrenciesListViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)! as UITableViewCell
        
        cell.textLabel?.text = currencyRatesList[indexPath.row]
        let countryFlag = currencyCountries[indexPath.row]
        let CountryImage = UIImage(named: countryFlag)
        cell.imageView?.image = CountryImage
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyRatesList.count
    }
}

 //MARK: Textfield methods
extension CurrenciesListViewController: UITextFieldDelegate {

    
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // We need to figure out how many characters would be in the string after the change happens
        let startingLength = textFieldToChange.text?.characters.count ?? 0
        let lengthToAdd = string.characters.count
        let lengthToReplace = range.length
        
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= textFieldLimit.max.rawValue
    }
}
