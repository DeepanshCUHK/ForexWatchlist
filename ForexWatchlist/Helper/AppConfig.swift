//
//  AppConfig.swift
//  ForexWatchlist
//
//  Created by Deepansh Jagga on 23/10/2020.
//  Copyright © 2020 Deepansh Jagga. All rights reserved.
//

import Foundation

struct AppConfig {
    
    let symbols = [
                    "AUDUSD",
                    "EURGBP",
                    "EURUSD",
                    "GBPUSD",
                    "NZDUSD",
                    "USDCAD",
                    "USDCHF",
                    "USDJPY",
                    "USDZAR"
                ]
    
    let pip = 0.0001
    
    let balance = 10000.00
    
    let rateRefreshInterval = 5
    
    func symbolDisplayFormat(symbol: String) -> String {
        return symbol.prefix(3) + "/" + symbol.suffix(3)
    }
    
    func rateDisplayFormat(rate: Double) -> String {
        return String(format: "%.4f%", Double(floor(10000*(rate))/10000))
    }
    
    func numberDisplayFormat(number: Double) -> String {
        return String(format: "%.2f%", Double(floor(100*(number))/100))
    }
    
    func numberWithCommaDisplayFormat(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        let formattedString = numberFormatter.string(from: NSNumber(value: number))
        
        return formattedString!
    }
    
    func changePercentDisplayFormat(change: Double) -> String {
        if (change > 0){
            return String(format: "+%.2f%%", Double(change*100))
        }else{
            return String(format: "%.2f%%", Double(change*100))
        }
    }
}
