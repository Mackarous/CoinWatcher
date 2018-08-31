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
    var coinPersistenceWorker: CoinPersistenceWorker!
    var coinData = [FetchedCoin]()
    var filteredData: [(title: String, items: [FetchedCoin])] {
        return [
            ("Favorites", coinData.filter { $0.isFavorited }),
            ("Coins", coinData.filter { !$0.isFavorited })
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl?.beginRefreshing()
        loadData(completion: reloadTableViewData)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return filteredData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MasterCell.identifier, for: indexPath) as! MasterCell
        let fetchedCoin = filteredData[indexPath.section].items[indexPath.row]
        cell.fetchedCoin = fetchedCoin
        cell.isFavorited = coinPersistenceWorker.coin(id: fetchedCoin.id)?.isFavorited ?? false
        cell.didToggleFavorite = { [unowned self] isSelecting in
            self.toggleFavorite(isSelecting, for: fetchedCoin)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.fetchedCoin = filteredData[indexPath.section].items[indexPath.row]
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            updateDetailCanGoForwardBack(detailVC, selectedIndexPath: selectedIndexPath)
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filteredData[section].title
    }
    
    // MARK: - Actions
    
    @IBAction private func refresh() {
        loadData(completion: reloadTableViewData)
    }
    
    // MARK: - Private functions
    
    private func reloadTableViewData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func loadData(completion: @escaping (() -> Void)) {
        coinFetchWorker.fetchCoins { [unowned self] result in
            switch result {
            case .error(let error):
                self.presentError(error)
            case .success(let coins):
                self.coinData = coins.map { coin in
                    var coin = coin
                    coin.isFavorited = self.coinPersistenceWorker.coin(id: coin.id)?.isFavorited ?? false
                    return coin
                }
                completion()
            }
        }
    }
    
    private func updateDetailCanGoForwardBack(_ detailVC: DetailViewController, selectedIndexPath: IndexPath) {
        let isInFirstSection = selectedIndexPath.section == 0
        detailVC.canGoBack = !isInFirstSection || (isInFirstSection && selectedIndexPath.row > 0)
        let isInLastSection = selectedIndexPath.section == filteredData.count - 1
        let lastCount = filteredData[filteredData.count - 1].items.count
        detailVC.canGoForward = !isInLastSection || (isInLastSection && selectedIndexPath.row < lastCount)
    }
    
    private func toggleFavorite(_ isSelecting: Bool, for fetchedCoin: FetchedCoin) {
        var deleteSection = 0
        var insertSection = 0
        if isSelecting {
            coinPersistenceWorker.insertNewFavoriteCoin(id: fetchedCoin.id)
            deleteSection = 1
            insertSection = 0
        } else if let coin = coinPersistenceWorker.coin(id: fetchedCoin.id) {
            coinPersistenceWorker.persistentContainer.viewContext.delete(coin)
            coinPersistenceWorker.saveContext()
            deleteSection = 0
            insertSection = 1
        }
        let deleteIndexPath = IndexPath(row: filteredData[deleteSection].items.index(where: { $0.id == fetchedCoin.id })!, section: deleteSection)
        loadData { [unowned self] in
            let insertIndexPath = IndexPath(row: self.filteredData[insertSection].items.index(where: { $0.id == fetchedCoin.id })!, section: insertSection)
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [insertIndexPath], with: .automatic)
                self.tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
                self.tableView.endUpdates()
            }
        }

    }
    
    private func navigateDetail(_ detailVC: DetailViewController, direction: DetailNavigationDirection) {
        guard var selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        switch direction {
        case .back:
            if selectedIndexPath.section > 0 && selectedIndexPath.row == 0 {
                selectedIndexPath.section -= 1
                selectedIndexPath.row = filteredData[selectedIndexPath.section].items.count - 1
            } else if selectedIndexPath.row > 0 {
                selectedIndexPath.row -= 1
            }
        case .forward:
            if selectedIndexPath.section < filteredData.count - 1 && selectedIndexPath.row == filteredData[selectedIndexPath.section].items.count - 1 {
                selectedIndexPath.section += 1
                selectedIndexPath.row = 0
            } else if selectedIndexPath.row < filteredData[selectedIndexPath.section].items.count - 1 {
                selectedIndexPath.row += 1
            }
        }
        tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .top)
        detailVC.fetchedCoin = filteredData[selectedIndexPath.section].items[selectedIndexPath.row]
        updateDetailCanGoForwardBack(detailVC, selectedIndexPath: selectedIndexPath)
    }
}
