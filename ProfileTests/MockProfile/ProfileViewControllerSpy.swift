//
//  ProfileViewControllerSpy.swift
//  ProfileTests
//
//  Created by Николай Замараев on 19.10.2025.
//

import Foundation
@testable import Image_Feed
import XCTest

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {

    
    var presenter: ProfilePresenterProtocol?

    var showLogoutAlertCalled = false
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    
    func updateProfileDetails(name: String, loginName: String, bio: String?) {
        updateProfileDetailsCalled = true
    }
    
    func updateAvatar(with avatarURL: String) {
        updateAvatarCalled = true
    }
    
    func showLogoutConfirmation() {
        showLogoutAlertCalled = true
    }
}
