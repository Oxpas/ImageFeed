//
//  ProfileSpy.swift
//  ProfileTests
//
//  Created by Николай Замараев on 19.10.2025.
//

import Foundation
@testable import Image_Feed
import XCTest

final class ProfileServiceSpy {
    var profile: Profile? = Profile(
        username: "user",
        name: "Test Name",
        loginName: "@test",
        bio: "Hello"
    )

    var clearDataCalled = false
    func clearData() { clearDataCalled = true }
}
