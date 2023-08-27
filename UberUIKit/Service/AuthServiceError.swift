//
//  AuthServiceError.swift
//  UberUIKit
//
//  Created by Maciej on 26/08/2023.
//

import Foundation

enum AuthServiceError: Error {
    case fieldsEmpty
    case passwordsDontMatch
}

extension AuthServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fieldsEmpty:
            return NSLocalizedString("None of the fields should be empty.", comment: "Empty field(s)")
        case .passwordsDontMatch:
            return NSLocalizedString("Passwors don't match.\nPlease try again.", comment: "Passwords don't match")
        }
    }
}
