//
//  OAuth2TokenStorage.swift
//  Image Feed
//
//  Created by Николай Замараев on 28.08.2025.
//

import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
