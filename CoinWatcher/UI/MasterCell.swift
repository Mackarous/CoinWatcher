//
//  MasterCell.swift
//  CoinWatcher
//
//  Created by Andrew Mackarous on 2018-08-31.
//  Copyright © 2018 Brave. All rights reserved.
//

import UIKit

final class MasterCell: UITableViewCell {
    public static let identifier = String(describing: MasterCell.self)
    
    var fetchedCoin: FetchedCoin! {
        didSet {
            nameLabel.text = fetchedCoin.name
            priceLabel.text = fetchedCoin.price.currencyString
        }
    }
    
    var isFavorited = false {
        didSet { setSelection(isFavorited) }
    }
    
    var didToggleFavorite: ((Bool) -> Void)?
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var favoriteButton: UIButton!
    
    private func setSelection(_ isSelecting: Bool) {
        favoriteButton.isSelected = isSelecting
        favoriteButton.tintColor = isSelecting ? .red : .lightGray
    }
    
    @IBAction private func favoriteSelected(_ sender: UIButton) {
        let isSelecting = !sender.isSelected
        setSelection(isSelecting)
        didToggleFavorite?(isSelecting)
    }
}
