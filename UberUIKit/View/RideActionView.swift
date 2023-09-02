//
//  RideActionView.swift
//  UberUIKit
//
//  Created by Maciej on 31/08/2023.
//

import UIKit
import MapKit

private enum Constants {
    static let xCircleSize = 60.0
    static let screenWidth = UIScreen.main.bounds.width
    static let padding = 16.0
}

final class RideActionView: UIView {
    // MARK: - Properties
    var placemark: MKPlacemark? {
        didSet {
            titleLabel.text = placemark?.name
            addressLabel.text = placemark?.address
        }
    }
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            textStack,
            xUberStack,
            seperatorView,
            confirmButton
        ])
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Title & Address
    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            addressLabel
        ])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .set(size: .headline, weight: .semibold)
        label.text = "Test Title"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = .set(size: .subheadline, weight: .thin)
        label.text = "Test Address"
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - xUber
    private lazy var xUberStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            xUberInfoView,
            xUberInfoLabel
        ])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private lazy var xUberInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .colorSchemeForegroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.xCircleSize / 2
        
        let label = UILabel()
        label.font = .set(size: .title1, weight: .medium)
        label.textColor = .colorSchemeBackgroundColor
        label.text = "X"
        label.translatesAutoresizingMaskIntoConstraints = false
                
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            view.widthAnchor.constraint(equalToConstant: Constants.xCircleSize),
            view.heightAnchor.constraint(equalToConstant: Constants.xCircleSize),
        ])
        
        return view
    }()
    
    private lazy var xUberInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .set(size: .headline, weight: .semibold)
        label.textAlignment = .center
        label.text = "UberX"
        return label
    }()
    
    // MARK: -
    private lazy var seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 1),
            view.widthAnchor.constraint(equalToConstant: Constants.screenWidth - (Constants.padding * 2))
        ])
        
        print("[DEBUG] self.frame.width \(self.frame.width)")
        print("[DEBUG] view.frame.width \(view.frame.width)")
        
        return view
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UberWideButton(type: .system)
        button.setTitle("Confirm UberX", for: .normal)
        button.applyStyling()
        button.addTarget(self, action: #selector(handleConfirmTap), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: Constants.screenWidth)
        ])
        
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc private func handleConfirmTap() {
        print("[DEBUG] 123")
    }
}

private extension RideActionView {
    func setupUI() {
        addSubview(mainStack)
        
        backgroundColor = .colorSchemeBackgroundColor
        
        addShadow()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
        ])
    }
}
