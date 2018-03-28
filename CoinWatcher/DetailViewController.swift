//
//  DetailViewController.swift
//  CoinWatcher
//
//  Created by Joel Reis on 3/23/18.
//  Copyright © 2018 Brave. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    private lazy var detailView = { DetailView() }()
    
    override func loadView() {
        view = detailView
    }

    func configureView() {
        // Update the user interface with the detail item.
        if let detail = detailItem {
            detailView.detailDescriptionLlb.text = detail["name"] as? String
        }
    }

    var detailItem: Dictionary<String, Any>? {
        didSet {
            configureView()
        }
    }
}

private class DetailView: UIView {
    lazy var backBtn = UIButton()
    lazy var forwardBtn = UIButton()
    
    lazy var detailDescriptionLlb: UILabel = {
        let lbl = UILabel()
        self.addSubview(lbl)
        
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        lbl.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
       return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [backBtn, forwardBtn].forEach(addSubview(_:))
        
        // TODO: Setup constraints for buttons
        // TODO: Setup target action on buttons

        backBtn.setTitle("⟸", for: .normal)
        forwardBtn.setTitle("⟹", for: .normal)
        
        self.backgroundColor = .lightGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

