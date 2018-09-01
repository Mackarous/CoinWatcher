//
//  DetailViewController.swift
//  CoinWatcher
//
//  Created by Joel Reis on 3/23/18.
//  Copyright © 2018 Brave. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var forwardButton: UIButton!

    var fetchedCoin: FetchedCoin? {
        didSet { configureView() }
    }
    var canGoBack = true {
        didSet { backButton.isEnabled = canGoBack }
    }
    var canGoForward = true {
        didSet { forwardButton.isEnabled = canGoForward }
    }
    var didGoBack: (() -> Void)?
    var didGoForward: (() -> Void)?
    
    private func configureView() {
        // Update the user interface with the detail item.
        loadViewIfNeeded()
        guard let coin = fetchedCoin else {
            stackView.isHidden = true
            return
        }
        nameLabel.text = coin.name
        priceLabel.text = coin.price.currencyString
        stackView.isHidden = false
    }
    
    @IBAction private func goBack() {
        didGoBack?()
    }
    
    @IBAction private func goForward() {
        didGoForward?()
    }
}
