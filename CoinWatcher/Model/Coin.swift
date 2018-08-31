//
//  Model.swift
//  CoinWatcher
//
//  Created by Andrew Mackarous on 2018-08-31.
//  Copyright © 2018 Brave. All rights reserved.
//

import Foundation

struct FetchedCoin: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, name
        case price = "price_cad"
    }
    let id: String
    let name: String
    let price: Decimal
    var isFavorited = false
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let priceString = try container.decode(String.self, forKey: .price)
        price = Decimal(string: priceString) ?? 0
    }
}
