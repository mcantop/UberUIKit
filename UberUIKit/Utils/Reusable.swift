//
//  Reusable.swift
//  UberUIKit
//
//  Created by Maciej on 27/08/2023.
//

import Foundation

protocol Reusable { }

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
