//
//  Forex.swift
//  ForexWatchlist
//
//  Created by Deepansh Jagga on 23/10/2020.
//  Copyright © 2020 Deepansh Jagga. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class Forex: Object {
    
    @objc dynamic var symbol: String? = ""
    @objc dynamic var rate: Double = 0.00
    @objc dynamic var openRate: Double = 0.00
    @objc dynamic var pip: Double = AppConfig().pip
    @objc dynamic var buyRate: Double = 0.00
    @objc dynamic var buyRateBlinkColor: String? = ""
    @objc dynamic var sellRate: Double = 0.00
    @objc dynamic var sellRateBlinkColor: String? = ""
    @objc dynamic var change: Double = 0.00
    @objc dynamic var timeStamp: Double = 0.00
    @objc dynamic var balance: Double = Double(AppConfig().balance)
    @objc dynamic var equity: Double = Double(AppConfig().balance)
    @objc dynamic var isPositionOpen: Bool = false
    @objc dynamic var averageBuyPrice: Double = 0.00
    @objc dynamic var profitLoss: Double = 0.00
    
    override static func primaryKey() -> String? {
        return "symbol"
    }
    
    convenience init(symbol: String, rate: Double, timeStamp: Double) {
        self.init()
        self.symbol = symbol
        self.rate = rate
        self.openRate = self.rate + (self.rate * self.pip)
        self.buyRate = self.rate + (self.rate * self.pip)
        self.sellRate = self.rate - (self.rate * self.pip)
        self.timeStamp = timeStamp
        self.change = 0.00
    }
    
}
