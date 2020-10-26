
//
//  ForexViewModel.swift
//  ForexWatchlist
//
//  Created by Deepansh Jagga on 26/10/2020.
//  Copyright © 2020 Deepansh Jagga. All rights reserved.
//

import Foundation

struct ForexViewModel {
    
    let forex: Forex
    
    init(_ forex: Forex) {
        self.forex = forex
    }
    
}

extension ForexViewModel {
    func updateEquity() {
        if (self.forex.averageBuyPrice != 0){
            self.forex.equity = (self.forex.balance/self.forex.averageBuyPrice) * self.forex.sellRate
        }else{
            self.forex.equity = self.forex.balance
        }
    }
    
    func updateProfitAndLoss() {
        self.forex.profitLoss = (self.forex.equity - self.forex.balance)
    }
    
    func updateChange(){
        self.forex.change = ((self.forex.buyRate - self.forex.openRate)/self.forex.buyRate)
    }
    
    func updateBuyAndSellRate(){
        let oldBuyRate = self.forex.buyRate
        let oldSellrate = self.forex.sellRate
        
        self.forex.buyRate = self.forex.rate + (self.forex.rate * Double(self.forex.pip))
        if (oldBuyRate < self.forex.buyRate) {
            self.forex.buyRateBlinkColor = "Green"
        }else if (oldBuyRate > self.forex.buyRate) {
            self.forex.buyRateBlinkColor = "Red"
        }else{
            self.forex.buyRateBlinkColor = "None"
        }
        
        self.forex.sellRate = self.forex.rate - (self.forex.rate * Double(self.forex.pip))
        if (oldSellrate < self.forex.sellRate) {
            self.forex.sellRateBlinkColor = "Green"
        }else if (oldSellrate > self.forex.sellRate) {
            self.forex.sellRateBlinkColor = "Red"
        }else{
            self.forex.sellRateBlinkColor = "None"
        }
    }
}
