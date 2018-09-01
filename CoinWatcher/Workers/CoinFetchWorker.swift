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
    }
    
    private let network: Network
    
    public init(network: Network) {
        self.network = network
    }
    
    func fetchCoins(completion: @escaping Completion) {
        guard let url = URL(string: "https://api.coinmarketcap.com/v1/ticker/?limit=25&convert=CAD") else {
            completion(.error(Error.malformedURL))
            return
        }
        network.fetchData(from: url) { result in
            switch result {
            case .error(let error):
                completion(.error(error))
            case .success(let data):
                do {
                    let coins = try JSONDecoder().decode([FetchedCoin].self, from: data)
                    completion(.success(coins))
                } catch {
                    completion(.error(error))
                }
            }
        }
    }
}
