//
//  ProfileViewPresenterSpy.swift
//  ProfileTests
//
//  Created by Николай Замараев on 19.10.2025.
//

import Foundation
@testable import Image_Feed
import UIKit

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didTapLogoutCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
    
    func confirmLogout() {
        <#code#>
    }
}
