//
//  LocationDeniedController.swift
//  UberUIKit
//
//  Created by Maciej on 27/08/2023.
//

import UIKit

final class LocationDeniedController: UIViewController {
    // MARK: - Properties
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            label,
            goToSettingsButton
        ])
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Location Denied!"
        label.font = .set(size: .title1, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .colorSchemeForegroundColor
        return label
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Please allow us to use location services in the app settings."
        label.font = .set(size: .headline, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .colorSchemeForegroundColor
        return label
    }()
    
    private lazy var goToSettingsButton: UIButton = {
        let button = UberWideButton(type: .system)
        button.setTitle("Go To Settings", for: .normal)
        button.addTarget(self, action: #selector(goToSettingsHandler), for: .touchUpInside)
        button.applyStyling()
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Selectors
    @objc private func goToSettingsHandler() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}

// MARK: - Private API
private extension LocationDeniedController {
    func setupUI() {
        view.addSubview(mainStack)
        
        view.backgroundColor = .colorSchemeBackgroundColor
        
        navigationController?.isNavigationBarHidden = true
    }
    
    func setupConstraints() {
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
