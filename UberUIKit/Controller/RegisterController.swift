//
//  RegisterController.swift
//  UberUIKit
//
//  Created by Maciej on 14/08/2023.
//

import UIKit

final class RegisterController: UIViewController {
    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Uber"
        label.font = UIFont.set(size: .largeTitle, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var mainStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            emailContainerView,
            fullNameContainerView,
            passwordContainerView,
            confirmPasswordContainerView,
            accountTypeContainerView,
            registerButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var emailContainerView: UIView = {
        return UberTextFieldContainerView(image: SFSymbol.Auth.email, textfield: emailTextField)
    }()
    
    private lazy var fullNameContainerView: UIView = {
        return UberTextFieldContainerView(image: SFSymbol.Auth.fullName, textfield: fullNameTextField)
    }()
    
    private lazy var passwordContainerView: UIView = {
        return UberTextFieldContainerView(image: SFSymbol.Auth.password, textfield: passwordTextField)
    }()
    
    private lazy var confirmPasswordContainerView: UIView = {
        return UberTextFieldContainerView(image: SFSymbol.Auth.confirmPassword, textfield: confirmPasswordTextField)
    }()
    
    private lazy var accountTypeContainerView: UIView = {
        return UberTextFieldContainerView(image: SFSymbol.Auth.fullName, segmentedControl: accountTypeSegmentedControl)
    }()
    
    private lazy var emailTextField: UITextField = {
        return UberTextField(placeholder: "Email")
    }()
    
    private lazy var fullNameTextField: UITextField = {
        return UberTextField(placeholder: "Full Name")
    }()
    
    private lazy var passwordTextField: UITextField = {
        return UberTextField(placeholder: "Password", isSecure: true)
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        return UberTextField(placeholder: "Confirm Password", isSecure: true)
    }()
    
    private lazy var accountTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Rider", "Driver"])
        segmentedControl.backgroundColor = .colorSchemeBackgroundColor
        segmentedControl.tintColor = .colorSchemeForegroundColor
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UberWideButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.applyStyling()
        return button
    }()
    
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(
            string: "Already have an account? ",
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.colorSchemeForegroundColor.withOpacity(),
                NSAttributedString.Key.font : UIFont.set(size: .subheadline, weight: .thin)
            ])
        
        attributedTitle.append(NSAttributedString(
            string: "Log In Now",
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.systemBlue,
                NSAttributedString.Key.font : UIFont.set(size: .subheadline, weight: .semibold)
            ]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(dismissRegisterView), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Selectors
    @objc private func dismissRegisterView() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Private API
private extension RegisterController {
    func setupUI() {
        view.setColorSchemeBackgroundColor()
        
        view.addSubview(mainStack)
        view.addSubview(alreadyHaveAccountButton)
    }
    
    func setupConstraints() {
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        alreadyHaveAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            alreadyHaveAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alreadyHaveAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
