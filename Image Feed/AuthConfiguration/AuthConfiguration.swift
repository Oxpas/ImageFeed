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
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    static let oauthTokenURL = URL(string: "https://unsplash.com/oauth/token")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let oauthTokenURL: URL
    let authURLString: String
    
    init(accesKey: String,
         secretKey: String,
         redirectURI: String,
         accessScope: String,
         defaultBaseURL: URL,
         oauthTokenURL: URL,
         authURLString: String)
    {
        self.accessKey = accesKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.oauthTokenURL = oauthTokenURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accesKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 defaultBaseURL: Constants.defaultBaseURL!,
                                 oauthTokenURL: Constants.oauthTokenURL,
                                 authURLString: Constants.unsplashAuthorizeURLString)
    }
}
