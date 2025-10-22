//
//  ProfileViewPresenterTests.swift
//  ProfileTests
//
//  Created by Николай Замараев on 19.10.2025.
//

import Foundation
@testable import Image_Feed
import XCTest

final class ProfileresenterTests: XCTestCase {

    func testDidTapLogoutButton_ShowsAlert() {
        // given
        let view = ProfileViewControllerSpy()
        let sut = ProfilePresenter()
        view.presenter = sut

        // when
        sut.didTapLogout()

        // then
        XCTAssertTrue(view.showLogoutAlertCalled, "Ожидалось, что showLogoutAlert будет вызван")
    }

    func testViewDidLoad_UpdatesProfileAndAvatar() {
        // given
        let view = ProfileViewControllerSpy()
        let profileService = ProfileServiceSpy()
        let imageService = ProfileImageServiceSpy()
        let sut = ProfilePresenter()

        // when
        sut.viewDidLoad()

        // then
        XCTAssertTrue(view.updateProfileDetailsCalled, "updateProfileDetails() должен быть вызван")
        XCTAssertTrue(view.updateAvatarCalled, "updateAvatar() должен быть вызван")
    }
}
