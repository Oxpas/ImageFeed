//
//  WebViewControllerSpy.swift
//  WebViewTest
//
//  Created by Николай Замараев on 19.10.2025.
//

import Foundation
import UIKit
@testable import Image_Feed

final class WebViewControllerSpy: WebViewControllerProtocol {
    var presenter: Image_Feed.WebViewPresenterProtocol?

    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {

    }

    func setProgressHidden(_ isHidden: Bool) {

    }
}
