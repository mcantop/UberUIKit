//
//  LocationInputActivationView.swift
//  UberUIKit
//
//  Created by Maciej on 27/08/2023.
//

import UIKit

protocol LocationInputActivationViewDelegate: AnyObject {
    func presentLocationInputView()
}

final class LocationInputActivationView: UIView {
    // MARK: - Properties
    weak var delegate: LocationInputActivationViewDelegate?
    
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .colorSchemeForegroundColor
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Where to?"
        label.font = .set(size: .headline, weight: .medium)
        return label
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
    @objc func presentLocationInputView() {
        delegate?.presentLocationInputView()
    }
}

// MARK: - Private API
private extension LocationInputActivationView {
    func setupUI() {
        addSubview(indicatorView)
        addSubview(placeholderLabel)
        
        backgroundColor = .colorSchemeBackgroundColor
        
        addShadow()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentLocationInputView))
        addGestureRecognizer(tap)
    }
    
    func setupConstraints() {
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            indicatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            indicatorView.widthAnchor.constraint(equalToConstant: 8),
            indicatorView.heightAnchor.constraint(equalToConstant: 8),
            
            placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: indicatorView.trailingAnchor, constant: 16)
        ])
    }
}
