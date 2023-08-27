//
//  AccountType.swift
//  UberUIKit
//
//  Created by Maciej on 26/08/2023.
//

import Foundation

enum AccountType: Int, Codable, CaseIterable {
    case rider
    case driver
    
    var name: String {
        switch self {
        case .rider:
            return "Rider"
        case .driver:
            return "Driver"
        }
    }
}
