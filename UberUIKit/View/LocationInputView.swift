//
//  LocationInputView.swift
//  UberUIKit
//
//  Created by Maciej on 27/08/2023.
//

import UIKit

protocol LocationInputViewDelegate: AnyObject {
    func dismiss()
    func executeSearch(query: String)
}

private enum Constants {
    static let textFieldHeight = 30.0
    static let edgePaddding = 16.0
}

final class LocationInputView: UIView {
    // MARK: - Properties
    weak var delegate: LocationInputViewDelegate?
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = SFSymbol.backArrow?
            .style(size: .headline, weight: .bold)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return button
    }()
    
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Maciej Cantop"
        label.font = .set(size: .headline, weight: .semibold)
        label.textColor = .colorSchemeForegroundColor
        return label
    }()
    
    private lazy var startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 8 / 2
        return view
    }()
    
    private lazy var linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private lazy var destinationLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .colorSchemeForegroundColor
        return view
    }()
    
    private lazy var startLocationTextField: UITextField = {
        let textField = UITextField()
        textField.isEnabled = false
        textField.placeholder = "Current Location"
        textField.backgroundColor = .secondarySystemFill
        textField.font = .set(size: .callout, weight: .semibold)
        textField.leftView = createPaddingView(spacing: Constants.edgePaddding / 2)
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var destinationLocationTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.tintColor = .colorSchemeForegroundColor
        textField.placeholder = "Enter a Destination.."
        textField.backgroundColor = .systemGroupedBackground
        textField.returnKeyType = .search
        textField.font = .set(size: .callout, weight: .semibold)
        textField.leftView = createPaddingView(spacing: Constants.edgePaddding / 2)
        textField.leftViewMode = .always
        return textField
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
    
    /// Fix for changing shadow color when color scheme changes
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        addShadow()
        setNeedsDisplay()
    }
    
    // MARK: - Selectors
    @objc private func dismissView() {
        delegate?.dismiss()
    }
}

// MARK: - Public API
extension LocationInputView {
    func setFullNameLabel(_ fullName: String?) {
        fullNameLabel.text = fullName
    }
}

// MARK: - Private API
private extension LocationInputView {
    func setupUI() {
        addSubview(backButton)
        addSubview(fullNameLabel)
        addSubview(startLocationTextField)
        addSubview(destinationLocationTextField)
        addSubview(startLocationIndicatorView)
        addSubview(linkingView)
        addSubview(destinationLocationIndicatorView)
        
        backgroundColor = .colorSchemeBackgroundColor
        
        addShadow()
    }
    
    /// High Elo Constraints XD
    func setupConstraints() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        startLocationTextField.translatesAutoresizingMaskIntoConstraints = false
        startLocationIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        linkingView.translatesAutoresizingMaskIntoConstraints = false
        destinationLocationTextField.translatesAutoresizingMaskIntoConstraints = false
        destinationLocationIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            fullNameLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            fullNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            startLocationIndicatorView.centerYAnchor.constraint(equalTo: startLocationTextField.centerYAnchor),
            startLocationIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.edgePaddding),
            startLocationIndicatorView.widthAnchor.constraint(equalToConstant: 8),
            startLocationIndicatorView.heightAnchor.constraint(equalToConstant: 8),
            
            startLocationTextField.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: Constants.edgePaddding),
            startLocationTextField.leadingAnchor.constraint(equalTo: startLocationIndicatorView.trailingAnchor, constant: Constants.edgePaddding),
            startLocationTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.edgePaddding),
            startLocationTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            linkingView.centerXAnchor.constraint(equalTo: startLocationIndicatorView.centerXAnchor),
            linkingView.widthAnchor.constraint(equalToConstant: 2),
            linkingView.topAnchor.constraint(equalTo: startLocationIndicatorView.bottomAnchor, constant: 4),
            linkingView.bottomAnchor.constraint(equalTo: destinationLocationIndicatorView.topAnchor, constant: -4),
            
            destinationLocationIndicatorView.centerYAnchor.constraint(equalTo: destinationLocationTextField.centerYAnchor),
            destinationLocationIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.edgePaddding),
            destinationLocationIndicatorView.widthAnchor.constraint(equalToConstant: 8),
            destinationLocationIndicatorView.heightAnchor.constraint(equalToConstant: 8),
            
            destinationLocationTextField.topAnchor.constraint(equalTo: startLocationTextField.bottomAnchor, constant: Constants.edgePaddding / 2),
            destinationLocationTextField.leadingAnchor.constraint(equalTo: destinationLocationIndicatorView.trailingAnchor, constant: Constants.edgePaddding),
            destinationLocationTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.edgePaddding),
            destinationLocationTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension LocationInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false }
        
        delegate?.executeSearch(query: query)
        
        return true
    }
}
