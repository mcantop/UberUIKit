//
//  LoginController.swift
//  UberUIKit
//
//  Created by Maciej on 13/08/2023.
//

import UIKit
import JGProgressHUD

final class LoginController: UIViewController {
    // MARK: - Properties
    weak var delegate: HomeControllerDelegate?
    
    private let authService = AuthService.shared
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Uber"
        label.font = UIFont.set(size: .largeTitle, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var mainStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel, emailContainerView, passwordContainerView, loginButton
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 24
        return stackView
    }()
    
    private lazy var emailContainerView: UIView = {
        return UberTextFieldContainerView(image: SFSymbol.Auth.email, textfield: emailTextField)
    }()
    
    private lazy var passwordContainerView: UIView = {
        return UberTextFieldContainerView(image: SFSymbol.Auth.password, textfield: passwordTextField)
    }()
    
    private lazy var emailTextField: UITextField = {
        return UberTextField(placeholder: "Email")
    }()
    
    private lazy var passwordTextField: UITextField = {
        return UberTextField(placeholder: "Password", isSecure: true)
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UberWideButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.applyStyling()
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    // TODO: Refactor
    private lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(
            string: "Don't have an account? ",
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.colorSchemeForegroundColor.withOpacity(),
                NSAttributedString.Key.font : UIFont.set(size: .subheadline, weight: .thin)
            ])
        
        attributedTitle.append(NSAttributedString(
            string: "Register Now!",
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.systemBlue,
                NSAttributedString.Key.font : UIFont.set(size: .subheadline, weight: .semibold)
            ]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(presentRegisterView), for: .touchUpInside)
        
        return button
    }()
        
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        configureNavigationBar()
    }
    
    // MARK: - Selectors
    @objc private func presentRegisterView() {
        let registerController = RegisterController()
        registerController.delegate = delegate
        navigationController?.pushViewController(registerController, animated: true)
    }
    
    @objc private func handleLogin() {
        UberLoadingIndicator.show(in: view)
        
        Task {
            do {
                try await authService.loginUser(email: emailTextField.text, password: passwordTextField.text)
                                
                await UberLoadingIndicator.displaySuccess()
                                
                dismiss(animated: true)
                
                delegate?.handleUserLoggedInFlow()
            } catch {
                await UberLoadingIndicator.displaFail()
                
                presentErrorAlert(error)
            }
        }
    }
}

// MARK: - Private API
private extension LoginController {
    func setupUI() {
        view.setColorSchemeBackgroundColor()
        
        view.addSubview(mainStack)
        view.addSubview(dontHaveAccountButton)
    }
    
    func setupConstraints() {
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        dontHaveAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dontHaveAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dontHaveAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
}
