//
//  MenuController.swift
//  UberUIKit
//
//  Created by Maciej on 05/10/2023.
//

import UIKit

final class MenuController: UITableViewController {
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Selectors
}

// MARK: - Private API
private extension MenuController {
    func setupUI() {
        view.backgroundColor = .colorSchemeBackgroundColor
    }
}
