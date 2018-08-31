//
//  Result.swift
//  CoinWatcher
//
//  Created by Andrew Mackarous on 2018-08-31.
//  Copyright © 2018 Brave. All rights reserved.
//

import Foundation

enum Result<S> {
    case success(S)
    case error(Error)
}
