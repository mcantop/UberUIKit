//
//  User.swift
//  UberUIKit
//
//  Created by Maciej on 26/08/2023.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullName: String
    let email: String
    let accountType: AccountType
}
