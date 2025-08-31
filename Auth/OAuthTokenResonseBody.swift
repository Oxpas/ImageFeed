//
//  OAuthTokenResonseBode.swift
//  Image Feed
//
//  Created by Николай Замараев on 30.08.2025.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
