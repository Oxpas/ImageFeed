//
//  ProfileImageServiceSpy.swift
//  ProfileTests
//
//  Created by Николай Замараев on 19.10.2025.
//

import Foundation
@testable import Image_Feed
import XCTest

final class ProfileImageServiceSpy {
    var avatarURL: String? = "https://example.com/avatar.jpg"
    static var didChangeNotification = Notification.Name("TestDidChange")
    func clearData() { }
}
