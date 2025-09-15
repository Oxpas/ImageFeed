//
//  TabBarController.swift
//  Image Feed
//
//  Created by Николай Замараев on 14.09.2025.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage?
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
