//
//  TabBarController.swift
//  Image Feed
//
//  Created by Николай Замараев on 14.09.2025.
//

import Foundation

struct ProfileImage: Codable {
    let small: String?
    let medium: String?
    let large: String?
    
    private enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}
