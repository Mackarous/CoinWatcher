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
        defaultContainer.register(CoinFetchWorker.self) { _ in
            CoinFetchWorker()
        }
        
        defaultContainer.storyboardInitCompleted(MasterViewController.self) { r, c in
            c.coinFetchWorker = r.resolve(CoinFetchWorker.self)
        }
        
    }
}
