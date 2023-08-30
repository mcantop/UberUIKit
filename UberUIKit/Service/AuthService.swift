//
//  AuthService.swift
//  UberUIKit
//
//  Created by Maciej on 15/08/2023.
//

import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct AuthService {
    // MARK: - Properties
    static let shared = AuthService()
    
    private let service = Service()
}

// MARK: - Public API
extension AuthService {
    func loginUser(email: String?, password: String?) async throws {
        guard let email,
              let password else { return }
        
        if email.isEmpty || password.isEmpty {
            throw AuthServiceError.fieldsEmpty
        }

        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw error
        }
    }
    
    func registerUser(email: String?, fullName: String?, password: String?, confirmPassword: String?, accountType: AccountType) async throws {
        guard let email,
              let fullName,
              let password,
              let confirmPassword else { return }
        
        if email.isEmpty || fullName.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            throw AuthServiceError.fieldsEmpty
        }
        
        if password != confirmPassword {
            throw AuthServiceError.passwordsDontMatch
        }
                
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = User(
                id: result.user.uid,
                fullName: fullName,
                email: email,
                accountType: accountType
            )
            
            try await service.uploadUserData(user)
        } catch {
            throw error
        }
    }
}
