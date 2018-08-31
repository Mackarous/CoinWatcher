//
//  CoinFetchWorker.swift
//  CoinWatcher
//
//  Created by Andrew Mackarous on 2018-08-31.
//  Copyright © 2018 Brave. All rights reserved.
//

import Foundation

struct CoinFetchWorker {
    typealias Completion = (Result<[FetchedCoin]>) -> Void
    enum Error: Swift.Error {
        case malformedURL
        case unknown
    }
    
    func fetchCoins(completion: @escaping Completion) {
        guard let url = URL(string: "https://api.coinmarketcap.com/v1/ticker/?limit=25&convert=CAD") else {
            completion(.error(Error.malformedURL))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.error(error))
            } else if let data = data {
                do {
                    let coins = try JSONDecoder().decode([FetchedCoin].self, from: data)
                    completion(.success(coins))
                } catch {
                    completion(.error(error))
                }
            } else {
                completion(.error(Error.unknown))
            }
        }
        task.resume()
    }
}
