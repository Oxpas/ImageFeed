
import XCTest
@testable import Image_Feed

final class ProfileViewControllerTests: XCTestCase {

    var sut: ProfileViewController!
    var presenterSpy: ProfilePresenterSpy!

    override func setUp() {
        super.setUp()
        
        presenterSpy = ProfilePresenterSpy()
        sut = ProfileViewController(presenter: presenterSpy)
        sut.configure(presenterSpy) // свяжем контроллер и презентер
        _ = sut.view  // заставляем view загрузиться
    }

    override func tearDown() {
        sut = nil
        presenterSpy = nil
        super.tearDown()
    }

    func testViewDidAppear_CallsPresenterViewDidLoad() {
        // when
        sut.viewDidAppear(false)

        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled, "При появлении экрана должен вызываться viewDidLoad у презентера")
    }

    func testShowLogoutAlert_PresentsUIAlertController() {
        // given
        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()

        // when
        sut.showLogoutConfirmation() 

        // then
        let presented = sut.presentedViewController as? UIAlertController
        XCTAssertNotNil(presented, "Должен быть показан UIAlertController")
        XCTAssertEqual(presented?.title, "Пока, пока!")
        XCTAssertEqual(presented?.actions.count, 2, "Ожидается 2 действия: Да и Нет")
    }

    func testConfigure_SetsPresenterAndView() {
        // then
        XCTAssertTrue(sut.presenter === presenterSpy)
        XCTAssertTrue(presenterSpy.view === sut)
    }
}
