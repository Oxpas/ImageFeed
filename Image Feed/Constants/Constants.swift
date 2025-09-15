//
//  Constants.swift
//  Image Feed
//
//  Created by Николай Замараев on 14.09.2025.
//

import Foundation

enum Constants {
    static let accessKey = "flQfCqN0iq6LUuindAcWmzPA_yE4HdEm7aZtOkbMhow"
    static let secretKey = "_DaGEtbXdOPotJmPDgsQQPJ8n95KLcDTjrLsKJuNKZM"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let oauthTokenURL = URL(string: "https://unsplash.com/oauth/token")!
}
