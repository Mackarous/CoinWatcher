//
//  SwinjectStoryboard.swift
//  CoinWatcher
//
//  Created by Andrew Mackarous on 2018-08-31.
//  Copyright © 2018 Brave. All rights reserved.
//

import SwinjectStoryboard

extension SwinjectStoryboard {
    @objc class func setup() {
        defaultContainer.register(Network.self) { _ in
            URLSessionNetwork()
        }
        
        defaultContainer.register(CoinFetchWorker.self) { r in
            let network = r.resolve(Network.self)!
            return CoinFetchWorker(network: network)
        }
        
        defaultContainer
            .register(CoinPersistenceWorker.self) { _ in CoinPersistenceWorker() }
            .inObjectScope(.weak)
        
        defaultContainer.storyboardInitCompleted(MasterViewController.self) { r, c in
            c.coinFetchWorker = r.resolve(CoinFetchWorker.self)
            c.coinPersistenceWorker = r.resolve(CoinPersistenceWorker.self)
        }
    }
}
