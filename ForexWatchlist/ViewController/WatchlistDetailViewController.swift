//
//  WatchlistDetailViewController.swift
//  ForexWatchlist
//
//  Created by Deepansh Jagga on 24/10/2020.
//  Copyright © 2020 Deepansh Jagga. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class WatchlistDetailViewController: UIViewController {
    
    var forex: Forex!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var buyRateLabel: UILabel!
    @IBOutlet weak var sellRateLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var equityLabel: UILabel!
    @IBOutlet weak var averagePriceLabel: UILabel!
    @IBOutlet weak var openPriceLabel: UILabel!
    @IBOutlet weak var isOpenPosition: UILabel!
    @IBOutlet weak var profitLossLabel: UILabel!
    @IBOutlet weak var profitLossPercentageLabel: UILabel!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func buyButton(_ sender: Any) {
        
        if (self.forex.isPositionOpen == true){
            // Show confirmation Alert View Controller
            let alertVC = UIAlertController(title: "Sorry", message: "Your postion is already open for this product", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
        }else{
            // Show confirmation Alert View Controller
            let alertVC = UIAlertController(title: "Confirmation", message: "Your order will be placed now, Average Buy Price: \(AppConfig().rateDisplayFormat(rate: forex.buyRate))", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            let okAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
                //            self.showActivityIndicator()
                try! self.realm.write {
                    self.forex.isPositionOpen = true
                    self.forex.averageBuyPrice = self.forex.buyRate
                    self.isOpenPosition.isHidden = false
                    ForexViewModel(self.forex).updateEquity()
                    ForexViewModel(self.forex).updateProfitAndLoss()
                }
                self.averagePriceLabel.text = "\(AppConfig().rateDisplayFormat(rate: self.forex.averageBuyPrice))"
                
                self.equityLabel.text = "\(AppConfig().numberWithCommaDisplayFormat(number:self.forex.equity))"
                
                let profitLossPercentage = (self.forex.profitLoss/self.forex.balance)*100
                
                self.profitLossLabel.text = "\(AppConfig().numberWithCommaDisplayFormat(number: self.forex.profitLoss))"
                self.profitLossPercentageLabel.text =
                "(\(AppConfig().numberDisplayFormat(number: profitLossPercentage))%)"
                
                if(profitLossPercentage >= 0){
                self.profitLossPercentageLabel.textColor = .systemGreen
                }else{
                  self.profitLossPercentageLabel.textColor = .systemRed
                }
                    
            })
            alertVC.addAction(cancelAction)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func setupUI(){
        symbolLabel.text = AppConfig().symbolDisplayFormat(symbol: forex.symbol!)
        buyRateLabel.text = "\(AppConfig().rateDisplayFormat(rate: forex.buyRate))"
        sellRateLabel.text = "\(AppConfig().rateDisplayFormat(rate:forex.sellRate))"
        balanceLabel.text = "\(AppConfig().numberWithCommaDisplayFormat(number:forex.balance))"
        equityLabel.text = "\(AppConfig().numberWithCommaDisplayFormat(number:forex.equity))"
        openPriceLabel.text = "\(AppConfig().rateDisplayFormat(rate: forex.openRate))"
        
        if(self.forex.isPositionOpen == true){
            self.isOpenPosition.isHidden = false
            self.averagePriceLabel.text = "\(AppConfig().rateDisplayFormat(rate: forex.averageBuyPrice))"
            let profitLoss = (self.forex.equity - self.forex.balance)
            let profitLossPercentage = ((self.forex.equity - self.forex.balance)/self.forex.balance)*100
            
            self.profitLossLabel.text = "\(AppConfig().numberWithCommaDisplayFormat(number: profitLoss))"
            self.profitLossPercentageLabel.text =
            "(\(AppConfig().numberDisplayFormat(number: profitLossPercentage))%)"
            
            if(profitLoss >= 0){
            self.profitLossPercentageLabel.textColor = .green
            }else{
              self.profitLossPercentageLabel.textColor = .red
            }
        }else{
            self.isOpenPosition.isHidden = true
            self.averagePriceLabel.text = "--"
            self.profitLossLabel.text = "-"
            self.profitLossPercentageLabel.text = "-"
        }
    }
}
