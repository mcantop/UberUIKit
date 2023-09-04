//
//  RideActionView.swift
//  UberUIKit
//
//  Created by Maciej on 31/08/2023.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: AnyObject {
    func confirmRide()
    func cancelRide()
}

private enum Constants {
    static let xCircleSize = 60.0
    static let screenWidth = UIScreen.main.bounds.width
    static let padding = 16.0
}

enum RideActionViewType {
    case requested
    case inProgress
    case accepted(AccountType?)
    
    var buttonText: String {
        switch self {
        case .requested:
            return "Confirm UberX"
        case .inProgress:
            return "Cancel"
        case .accepted(let accountType):
            return accountType == .driver ? "Get Directions" : "Cancel"
        }
    }
    
    var titleText: String? {
        switch self {
        case .requested:
            return nil
        case .inProgress:
            return nil
        case .accepted(let accountType):
            return accountType == .driver ? "En Route To Passenger" : "Driver En Route"
        }
    }
    
    var subheadlineText: String? {
        switch self {
        case .requested:
            return nil
        case .inProgress:
            return nil
        case .accepted(let accountType):
            return accountType == .driver ? nil : "Your driver is about to pick you up soon.."
        }
    }
}

final class RideActionView: UIView {
    // MARK: - Properties
    weak var delegate: RideActionViewDelegate?
        
    var placemark: MKPlacemark?
    var userType: AccountType?
    var secondUserName: String?
    
    var actionType: RideActionViewType? {
        didSet {
            guard let actionType else { return }
            updateUI(withType: actionType)
        }
    }
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            textStack,
            xUberStack,
            seperatorView,
            actionButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Title & Address
    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subheadlineLabel
        ])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .set(size: .headline, weight: .semibold)
        label.isHidden = label.text?.isEmpty == true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subheadlineLabel: UILabel = {
        let label = UILabel()
        label.font = .set(size: .subheadline, weight: .thin)
        label.isHidden = label.text?.isEmpty == true
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - xUber
    private lazy var xUberStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            xUberInfoView,
            xUberSubLabel
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()
    
    private lazy var xUberInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .colorSchemeForegroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.xCircleSize / 2
        view.addSubview(xUberHeadLabel)
        
        NSLayoutConstraint.activate([
            xUberHeadLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            xUberHeadLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            view.widthAnchor.constraint(equalToConstant: Constants.xCircleSize),
            view.heightAnchor.constraint(equalToConstant: Constants.xCircleSize),
        ])
        
        return view
    }()
    
    private lazy var xUberHeadLabel: UILabel = {
        let label = UILabel()
        label.font = .set(size: .title1, weight: .medium)
        label.textColor = .colorSchemeBackgroundColor
        label.text = "X"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var xUberSubLabel: UILabel = {
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
        
        return view
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UberWideButton(type: .system)
        button.setTitle("Confirm UberX", for: .normal)
        button.applyStyling()
        button.addTarget(self, action: #selector(handleActionButtonTap), for: .touchUpInside)
        
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
    @objc private func handleActionButtonTap() {
        switch actionType {
        case .requested:
            delegate?.confirmRide()
        case .inProgress:
            delegate?.cancelRide()
        case .accepted:
            if userType == .driver {
                print("[DEBUG] Get directions")
            } else {
                delegate?.cancelRide()
            }
        case .none:
            break
        }
    }
}

// MARK: - Private API
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
    
    func updateUI(withType type: RideActionViewType) {
        titleLabel.text = type.titleText
        subheadlineLabel.text = type.subheadlineText
        actionButton.setTitle(type.buttonText, for: .normal)
        
        if case .requested = type {
            titleLabel.text = placemark?.name
            subheadlineLabel.text = placemark?.address
            xUberHeadLabel.text = "X"
            xUberSubLabel.text = "UberX"
        }
        
        guard case .accepted(_) = type else { return }
        
        if let firstLetter = secondUserName?.first {
            xUberHeadLabel.text = String(firstLetter).uppercased()
        }
        
        xUberSubLabel.text = secondUserName
    }
}
