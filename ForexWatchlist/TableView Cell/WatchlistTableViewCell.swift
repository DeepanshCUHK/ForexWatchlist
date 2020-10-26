//
//  WatchlistTableViewCell.swift
//  ForexWatchlist
//
//  Created by Deepansh Jagga on 23/10/2020.
//  Copyright © 2020 Deepansh Jagga. All rights reserved.
//

import UIKit

class WatchlistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var buyPriceLabel: UILabel!
    @IBOutlet weak var sellPriceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var isOpenLabel: UILabel!
    @IBOutlet weak var averagePriceLabel: UILabel!
    
    var forex: Forex! {
        didSet {
            self.updateUI()
        }
    }
    
    func updateUI() {
        self.symbolLabel.text = AppConfig().symbolDisplayFormat(symbol: self.forex.symbol!)
        
        self.buyPriceLabel.text = AppConfig().rateDisplayFormat(rate: self.forex.buyRate)
        // Animate Color
        animateBackgroundWith(color: self.forex.buyRateBlinkColor == "Green" ? UIColor.green.cgColor : self.forex.buyRateBlinkColor == "Red" ? UIColor.red.cgColor : UIColor.clear.cgColor, label: self.buyPriceLabel)
        
        self.sellPriceLabel.text = AppConfig().rateDisplayFormat(rate: self.forex.sellRate)
        // Animate Color
        animateBackgroundWith(color: self.forex.sellRateBlinkColor == "Green" ? UIColor.green.cgColor : self.forex.sellRateBlinkColor == "Red" ? UIColor.red.cgColor : UIColor.clear.cgColor, label: self.sellPriceLabel)
        
        self.changeLabel.text = AppConfig().changePercentDisplayFormat(change:self.forex.change)
        self.changeLabel.backgroundColor = (Double(self.forex.change) < 0) ? UIColor.red : UIColor.systemGreen
        
        if self.forex.isPositionOpen == false{
            self.isOpenLabel.text = "--".uppercased()
            self.isOpenLabel.textColor = .systemRed
            self.averagePriceLabel.isHidden = true
        }else{
            self.isOpenLabel.text = "BUY".uppercased()
            self.isOpenLabel.textColor = .systemGreen
            self.averagePriceLabel.isHidden = false
            self.averagePriceLabel.text = "Avg \(AppConfig().rateDisplayFormat(rate: self.forex.averageBuyPrice))"
        }
    }
    
    func animateBackgroundWith(color: CGColor, label: UILabel) {
        label.layer.backgroundColor = color
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.autoreverse, .curveEaseInOut], animations: {
            label.layer.backgroundColor = UIColor.clear.cgColor
        }, completion: nil)
    }
}
