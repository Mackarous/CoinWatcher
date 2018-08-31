//
//  Decimal+NumberFormatter.swift
//  CoinWatcher
//
//  Created by Andrew Mackarous on 2018-08-31.
//  Copyright © 2018 Brave. All rights reserved.
//

import Foundation

extension Decimal {
    var currencyString: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: self as NSDecimalNumber)
    }
}
