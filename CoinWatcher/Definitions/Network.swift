//
//  Network.swift
//  CoinWatcher
//
//  Created by Andrew Mackarous on 2018-09-01.
//  Copyright © 2018 Brave. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case unknown
}

protocol Network {
    func fetchData(from url: URL, completion: @escaping (Result<Data>) -> Void)
}
