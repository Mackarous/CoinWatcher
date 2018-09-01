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
        configureMasterCell(cell, with: filteredData[indexPath.section].items[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        configureDetailViewController(detailVC, with: filteredData[indexPath.section].items[indexPath.row])
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
    
    /// Reloads the table view data on the main thread and ends the refresh control
    private func reloadTableViewData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    /// Configure the master cell with the appropriate data from the fetched coin
    /// This configures the favorited state as well as the favorite toggle action
    ///
    /// - Parameters:
    ///   - cell: The `MasterCell` table view cell to configure
    ///   - fetchedCoin: The fetched coin used to configure the cell
    private func configureMasterCell(_ cell: MasterCell, with fetchedCoin: FetchedCoin) {
        cell.fetchedCoin = fetchedCoin
        cell.isFavorited = coinPersistenceWorker.coin(id: fetchedCoin.id)?.isFavorited ?? false
        cell.didToggleFavorite = { [unowned self] isSelecting in
            self.toggleFavorite(isSelecting, for: fetchedCoin)
        }
    }
    
    /// Configures the `DetailViewController` with the data retrieved from the fetched coin.
    /// This will configure the detailVC's UI as well as action callbacks
    ///
    /// - Parameters:
    ///   - detailVC: The `DetailViewController` that needs to be configured
    ///   - fetchedCoin: The fetched coin used to configure the view controller
    private func configureDetailViewController(_ detailVC: DetailViewController, with fetchedCoin: FetchedCoin) {
        detailVC.fetchedCoin = fetchedCoin
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
    }
    
    /// Load the fetched coins from the server
    ///
    /// - Parameter completion: The completion handler will run only upon completion, otherwise an error alert will be presented
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
    
    /// Updates the detail view controller's UI to enable back and forward buttons
    /// according to whether the user can navigate back or forward
    ///
    /// - Parameters:
    ///   - detailVC: The `DetailViewController` that needs UI updating
    ///   - selectedIndexPath: The currently selected index path in the tableview
    private func updateDetailCanGoForwardBack(_ detailVC: DetailViewController, selectedIndexPath: IndexPath) {
        let isInFirstSection = selectedIndexPath.section == 0
        detailVC.canGoBack = !isInFirstSection || (isInFirstSection && selectedIndexPath.row > 0)
        let isInLastSection = selectedIndexPath.section == filteredData.count - 1
        let lastCount = filteredData[filteredData.count - 1].items.count
        detailVC.canGoForward = !isInLastSection || (isInLastSection && selectedIndexPath.row < lastCount)
    }
    
    /// Toggles a coin as a favorite. This function will either save or remove the
    /// favorite from Core Data and update the UI accordingly
    ///
    /// - Parameters:
    ///   - isSelecting: Whether the coin is being selected or deslected as a favorite
    ///   - fetchedCoin: The coin that is being favorited or unfavorited
    private func toggleFavorite(_ isSelecting: Bool, for fetchedCoin: FetchedCoin) {
        if isSelecting {
            coinPersistenceWorker.insertNewFavoriteCoin(id: fetchedCoin.id)
        } else {
            coinPersistenceWorker.removeFavoriteCoin(id: fetchedCoin.id)
        }
        updateTableViewFavorites(for: fetchedCoin)
    }
    
    /// Updates the table view by adding or removing changed rows
    ///
    /// - Parameter fetchedCoin: The fetched coin that's being updated
    private func updateTableViewFavorites(for fetchedCoin: FetchedCoin) {
        guard let deleteIndexPath = indexPath(for: fetchedCoin) else { return }
        loadData { [unowned self] in
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                if let insertIndexPath = self.indexPath(for: fetchedCoin) {
                    self.tableView.insertRows(at: [insertIndexPath], with: .automatic)
                }
                self.tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
                self.tableView.endUpdates()
                guard let navController = self.splitViewController?.viewControllers.last as? UINavigationController else { return }
                guard let detailVC = navController.visibleViewController as? DetailViewController else { return }
                guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
                self.updateDetailCanGoForwardBack(detailVC, selectedIndexPath: selectedIndexPath)
            }
        }
    }
    
    /// Generates an index path for the given coin based on it's location in `filterdData`
    ///
    /// - Parameter fetchedCoin: The coin to generate an index path for
    /// - Returns: An index path for the coin based on it's location in `filterdData` or `nil`
    /// if it does not exist in the array. `nil` should never happen.
    private func indexPath(for fetchedCoin: FetchedCoin) -> IndexPath? {
        let data = filteredData
            .enumerated()
            .filter { $0.element.items.contains(where: { $0.id == fetchedCoin.id }) }
            .map { ($0, $1.items.index(where: { $0.id == fetchedCoin.id })) }
            .first
        guard let section = data?.0 else { return nil }
        guard let row = data?.1 else { return nil }
        return IndexPath(row: row, section: section)
    }
    
    /// Navigates between coins according to the direction given
    ///
    /// - Parameters:
    ///   - detailVC: The detail view controller to update the UI accordingly
    ///   - direction: The direction to select the next coin
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
