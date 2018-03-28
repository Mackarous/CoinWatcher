//
//  MasterViewController.swift
//  CoinWatcher
//
//  Created by Joel Reis on 3/23/18.
//  Copyright © 2018 Brave. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {

    var coinData: Array<Dictionary<String, Any>>!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MasterCell.self, forCellReuseIdentifier: "Cell")
        coinData = getCoindata()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let individualCoin = coinData[indexPath.row]
        configureCell(cell, withString: individualCoin["name"] as! String)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.detailItem = coinData[indexPath.row]
        detailVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        detailVC.navigationItem.leftItemsSupplementBackButton = true
        
        let controller = UINavigationController(rootViewController: detailVC)
        self.showDetailViewController(controller, sender: self)
    }

    func configureCell(_ cell: UITableViewCell, withString string: String) {
        cell.textLabel!.text = string
    }
    
    // MARK: - Data
    
    @available(iOS, deprecated: 11.2)
    func getCoindata() -> Array<Dictionary<String, Any>>! {
        // Network request for data
        let url = URL(string: "https://api.coinmarketcap.com/v1/ticker/?limit=25")!
        let request = URLRequest(url: url)
        var response: URLResponse?
        let resultData = try! NSURLConnection.sendSynchronousRequest(request, returning: &response)
        return try? JSONSerialization.jsonObject(with: resultData, options: []) as! Array<Dictionary<String, Any>>
        
    }
}

private class MasterCell: UITableViewCell {
    
    var favBtn: UIButton = {
        var btn = UIButton()
        btn.setImage(UIImage(named: "heart.png")!, for: .normal)
        btn.tintColor = .lightGray
        return btn
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(favBtn)
        favBtn.translatesAutoresizingMaskIntoConstraints = false
        let c1 = NSLayoutConstraint.constraints(withVisualFormat: "[favBtn]-|", options: .alignAllCenterY, metrics: nil, views: ["favBtn": favBtn])
        let c2 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[favBtn]-|", options: .alignAllCenterY, metrics: nil, views: ["favBtn":
            favBtn])
        NSLayoutConstraint.activate(c1)
        NSLayoutConstraint.activate(c2)
        
        favBtn.addTarget(self, action: #selector(favoriteSelected), for: .touchUpInside)
    }
    
    @objc public func favoriteSelected(sender: UIButton) {
        // TODO: Save object in CD, see AppDelegate for CD interface
        print("TODO: Updadate CoreData record[s]")
        
        let isSelecting = !sender.isSelected
        sender.isSelected = isSelecting
        sender.tintColor = isSelecting ? .red : .lightGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
