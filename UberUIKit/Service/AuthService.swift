//
//  AuthService.swift
//  UberUIKit
//
//  Created by Maciej on 15/08/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

private enum Constants {
    static let usersCollection = Firestore.firestore().collection("users")
}

struct AuthService {
    static let shared = AuthService()
    
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
            
            try await uploadUserData(user)
        } catch {
            throw error
        }
    }
    
    func loadUserData() async throws -> User? {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return nil }
            
            let snapshot = try await Constants.usersCollection.document(uid).getDocument()
            let user = try snapshot.data(as: User.self)
            return user
        } catch {
            throw error
        }
    }
}

private extension AuthService {
    func uploadUserData(_ user: User) async throws {
        do {
            guard let userEncoded = try? Firestore.Encoder().encode(user) else { return }
            
            try await Constants.usersCollection.document(user.id).setData(userEncoded)
        } catch {
            throw error
        }
    }
}
