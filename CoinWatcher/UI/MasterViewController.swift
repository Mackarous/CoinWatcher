//
//  MasterViewController.swift
//  CoinWatcher
//
//  Created by Joel Reis on 3/23/18.
//  Copyright © 2018 Brave. All rights reserved.
//

import UIKit
import CoreData

final class MasterViewController: UITableViewController {
    private enum DetailNavigationDirection {
        case back, forward
    }

    var coinFetchWorker: CoinFetchWorker!
    var coinData = [FetchedCoin]()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl?.beginRefreshing()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MasterCell.identifier, for: indexPath) as! MasterCell
        cell.fetchedCoin = coinData[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.fetchedCoin = coinData[indexPath.row]
        if let selectedRow = tableView.indexPathForSelectedRow?.row {
            detailVC.canGoBack = selectedRow > 0
            detailVC.canGoForward = selectedRow < coinData.count - 1
        }
        detailVC.didGoBack = { [unowned self] in
            self.navigateDetail(detailVC, direction: .back)
        }
        detailVC.didGoForward = { [unowned self] in
            self.navigateDetail(detailVC, direction: .forward)
        }
        detailVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        detailVC.navigationItem.leftItemsSupplementBackButton = true
        
        let controller = UINavigationController(rootViewController: detailVC)
        self.showDetailViewController(controller, sender: self)
    }
    
    // MARK: - Actions
    
    @IBAction private func refresh() {
        loadData()
    }
    
    // MARK: - Private functions
    
    private func loadData() {
        coinFetchWorker.fetchCoins { [unowned self] result in
            switch result {
            case .error(let error):
                self.presentError(error)
            case .success(let coins):
                self.coinData = coins
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }

    private func navigateDetail(_ detailVC: DetailViewController, direction: DetailNavigationDirection) {
        guard var selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
        switch direction {
        case .back:
            guard selectedIndexPath.row > 0 else { return }
            selectedIndexPath.row -= 1
        case .forward:
            guard selectedIndexPath.row < self.coinData.count - 1 else { return }
            selectedIndexPath.row += 1
        }
        self.tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .top)
        detailVC.fetchedCoin = self.coinData[selectedIndexPath.row]
        detailVC.canGoBack = selectedIndexPath.row > 0
        detailVC.canGoForward = selectedIndexPath.row < coinData.count - 1
    }
}

// MARK: - MasterCell

final class MasterCell: UITableViewCell {
    static let identifier = String(describing: MasterCell.self)
    
    var fetchedCoin: FetchedCoin! {
        didSet {
            nameLabel.text = fetchedCoin.name
            priceLabel.text = fetchedCoin.price.currencyString
            setSelection(isFavorited)
        }
    }
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var favoriteButton: UIButton!
    
    private var isFavorited: Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let coin = appDelegate.coin(id: fetchedCoin.id) else { return false }
        return coin.isFavorited
    }
    
    private func setSelection(_ isSelecting: Bool) {
        favoriteButton.isSelected = isSelecting
        favoriteButton.tintColor = isSelecting ? .red : .lightGray
    }
    
    @IBAction private func favoriteSelected(_ sender: UIButton) {
        let isSelecting = !sender.isSelected
        setSelection(isSelecting)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if isSelecting {
            appDelegate.insertNewFavoriteCoin(id: fetchedCoin.id)
        } else if let coin = appDelegate.coin(id: fetchedCoin.id) {
            appDelegate.persistentContainer.viewContext.delete(coin)
            appDelegate.saveContext()
        }
    }
}
