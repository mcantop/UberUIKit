//
//  LocationSearchResultCell.swift
//  UberUIKit
//
//  Created by Maciej on 27/08/2023.
//

import UIKit
import MapKit

private enum Constants {
    static let padding = 16.0
}

final class LocationSearchResultCell: UITableViewCell, Reusable {
    // MARK: - Properties
    var placemark: MKPlacemark? {
        didSet {
            headlineLabel.text = placemark?.name
            subheadlineLabel.text = placemark?.address
        }
    }
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            headlineLabel,
            subheadlineLabel
        ])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private lazy var headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .set(size: .headline, weight: .semibold)
        return label
    }()
    
    private lazy var subheadlineLabel: UILabel = {
        let label = UILabel()
        label.font = .set(size: .subheadline, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LocationSearchResultCell {
    func setupUI() {
        addSubview(mainStack)
    }
    
    func setupConstraints() {
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding)
        ])
    }
}
