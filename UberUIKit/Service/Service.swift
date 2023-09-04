//
//  Service.swift
//  UberUIKit
//
//  Created by Maciej on 29/08/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

enum ServiceConstants {
    static let usersCollection = Firestore.firestore().collection("users")
    static let ridesCollection = Firestore.firestore().collection("rides")
}

struct Service {
    static let shared = Service()
}

// MARK: - Public API
extension Service {
    func uploadUserData(_ user: User) async throws {
        do {
            try ServiceConstants.usersCollection.document(user.id).setData(from: user)
        } catch {
            throw error
        }
    }
    
    func loadCurrentUserData() async throws -> User? {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return nil }
            
            let snapshot = try await ServiceConstants.usersCollection.document(uid).getDocument()
            let user = try snapshot.data(as: User.self)
            return user
        } catch {
            throw error
        }
    }
    
    func loadUserData(uid: String?) async throws -> User? {
        do {
            guard let uid else { return nil }
            
            let snapshot = try await ServiceConstants.usersCollection.document(uid).getDocument()
            let user = try snapshot.data(as: User.self)
            return user
        } catch {
            throw error
        }
    }
}

