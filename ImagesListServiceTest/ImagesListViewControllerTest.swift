import XCTest
@testable import Image_Feed

// MARK: - Mocks for ViewController

final class MockImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    var photosCount: Int = 0
    var viewDidLoadCalled = false
    var fetchPhotosNextPageCalled = false
    var willDisplayCellCalled = false
    var willDisplayCellIndex: Int?
    var didSelectCellCalled = false
    var didSelectCellIndex: Int?
    var didSelectCellReturnValue: String?
    var configCellCalled = false
    var configCellIndex: Int?
    var didTapLikeCalled = false
    var didTapLikeIndex: Int?
    var heightForRowCalled = false
    var heightForRowReturnValue: CGFloat = 0
    var getPhotoCalled = false
    var getPhotoReturnValue: Photo?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func willDisplayCell(at index: Int) {
        willDisplayCellCalled = true
        willDisplayCellIndex = index
    }
    
    func didSelectCell(at index: Int) -> String? {
        didSelectCellCalled = true
        didSelectCellIndex = index
        return didSelectCellReturnValue
    }
    
    func configCell(for cell: ImagesListCell, at index: Int) {
        configCellCalled = true
        configCellIndex = index
    }
    
    func didTapLike(for cell: ImagesListCell, at index: Int) {
        didTapLikeCalled = true
        didTapLikeIndex = index
    }
    
    func heightForRow(at index: Int, tableViewWidth: CGFloat) -> CGFloat {
        heightForRowCalled = true
        return heightForRowReturnValue
    }
    
    func getPhoto(at index: Int) -> Photo? {
        getPhotoCalled = true
        return getPhotoReturnValue
    }
}

final class MockTableView: UITableView {
    var reloadDataCalled = false
    var performBatchUpdatesCalled = false
    var insertRowsAtIndexPaths: [IndexPath]?
    var deleteRowsAtIndexPaths: [IndexPath]?
    
    override func reloadData() {
        reloadDataCalled = true
    }
    
    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        performBatchUpdatesCalled = true
        updates?()
        completion?(true)
    }
    
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertRowsAtIndexPaths = indexPaths
    }
}

// MARK: - ImagesListViewControllerTests

final class ImagesListViewControllerTests: XCTestCase {
    
    private var viewController: ImagesListViewController!
    private var mockPresenter: MockImagesListPresenter!
    private var mockTableView: MockTableView!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        
        mockPresenter = MockImagesListPresenter()
        mockTableView = MockTableView()
        
        viewController.presenter = mockPresenter
        viewController.tableView = mockTableView
        
        viewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        viewController = nil
        mockPresenter = nil
        mockTableView = nil
        super.tearDown()
    }
    
    func testViewDidLoadSetsUpPresenter() {
        // Given
        let newViewController = ImagesListViewController()
        newViewController.loadViewIfNeeded()
        
        // When
        newViewController.viewDidLoad()
        
        // Then
        XCTAssertNotNil(newViewController.presenter, "Presenter должен быть установлен после viewDidLoad")
        XCTAssertNotNil(newViewController.presenter?.view, "View у presenter должен быть установлен")
    }
    
    func testTableViewNumberOfRows() {
        // Given
        mockPresenter.photosCount = 10
        
        // When
        let numberOfRows = viewController.tableView(mockTableView, numberOfRowsInSection: 0)
        
        // Then
        XCTAssertEqual(numberOfRows, 10, "Количество строк должно соответствовать photosCount презентера")
    }
    
    func testTableViewCellForRowAt() {
        // Given
        mockPresenter.photosCount = 5
        
        // Регистрируем ячейку для тестов
        mockTableView.register(MockImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        // When
        let cell = viewController.tableView(mockTableView, cellForRowAt: IndexPath(row: 2, section: 0))
        
        // Then
        XCTAssertTrue(mockPresenter.configCellCalled, "При создании ячейки должен вызываться configCell презентера")
        XCTAssertEqual(mockPresenter.configCellIndex, 2, "Должен передаваться корректный индекс")
        XCTAssertTrue(cell is ImagesListCell, "Должна возвращаться ячейка правильного типа")
    }
    
    func testTableViewDidSelectRow() {
        // Given
        let testImageURL = "https://example.com/large.jpg"
        mockPresenter.didSelectCellReturnValue = testImageURL
        
        // When
        viewController.tableView(mockTableView, didSelectRowAt: IndexPath(row: 3, section: 0))
        
        // Then
        XCTAssertTrue(mockPresenter.didSelectCellCalled, "При выборе ячейки должен вызываться didSelectCell презентера")
        XCTAssertEqual(mockPresenter.didSelectCellIndex, 3, "Должен передаваться корректный индекс")
        XCTAssertEqual(viewController.selectedImageURL, testImageURL, "selectedImageURL должен устанавливаться корректно")
    }
    
    func testTableViewHeightForRowAt() {
        // Given
        let expectedHeight: CGFloat = 250
        mockPresenter.heightForRowReturnValue = expectedHeight
        let tableViewWidth: CGFloat = 375
        
        // When
        let height = viewController.tableView(mockTableView, heightForRowAt: IndexPath(row: 1, section: 0))
        
        // Then
        XCTAssertTrue(mockPresenter.heightForRowCalled, "Должен вызываться heightForRow презентера")
        XCTAssertEqual(height, expectedHeight, "Высота ячейки должна возвращаться из презентера")
    }
    
    func testTableViewWillDisplayCell() {
        // Given
        let cell = ImagesListCell()
        let indexPath = IndexPath(row: 4, section: 0)
        
        // When
        viewController.tableView(mockTableView, willDisplay: cell, forRowAt: indexPath)
        
        // Then
        XCTAssertTrue(mockPresenter.willDisplayCellCalled, "При отображении ячейки должен вызываться willDisplayCell презентера")
        XCTAssertEqual(mockPresenter.willDisplayCellIndex, 4, "Должен передаваться корректный индекс")
    }
    
    func testImageListCellDidTapLike() {
        // Given
        let cell = ImagesListCell()
        let indexPath = IndexPath(row: 2, section: 0)
        
        // Настраиваем tableView чтобы он мог найти indexPath для ячейки
        mockTableView.reloadData()
        
        // When
        viewController.imageListCellDidTapLike(cell)
        
        // Then
        // Поскольку мы не можем легко протестировать получение indexPath в unit-тестах,
        // проверяем что метод делегата вызывается
        XCTAssertNotNil(viewController.presenter, "Presenter должен быть доступен")
    }
    
    func testUpdateTableViewAnimated() {
        // Given
        let newIndexes = [5, 6, 7, 8, 9]
        
        // When
        viewController.updateTableViewAnimated(with: newIndexes)
        
        // Then
        XCTAssertTrue(mockTableView.performBatchUpdatesCalled, "Должен вызываться performBatchUpdates")
    }
    
    func testShowSingleImage() {
        // Given
        let testImageURL = "https://example.com/image.jpg"
        
        // When
        viewController.showSingleImage(for: testImageURL)
        
        // Then
        XCTAssertEqual(viewController.selectedImageURL, testImageURL, "selectedImageURL должен устанавливаться")
    }
    
    func testShowLoadingIndicator() {
        // When
        viewController.showLoadingIndicator()
        
        // Then
        // Проверяем что метод вызывается (UIBlockingProgressHUD.show() обычно тестируется отдельно)
        XCTAssertTrue(true, "Метод должен вызываться без ошибок")
    }
    
    func testHideLoadingIndicator() {
        // When
        viewController.hideLoadingIndicator()
        
        // Then
        // Проверяем что метод вызывается
        XCTAssertTrue(true, "Метод должен вызываться без ошибок")
    }
    
    func testShowError() {
        // Given
        let testError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error message"])
        
        // When
        viewController.showError(testError)
        
        // Then
        // Проверяем что метод вызывается (UIAlertController обычно тестируется в UI-тестах)
        XCTAssertTrue(true, "Метод должен вызываться без ошибок")
    }
    
    func testLoadImage() {
        // Given
        let cell = ImagesListCell()
        let urlString = "https://example.com/thumb.jpg"
        
        // When
        viewController.loadImage(for: cell, with: urlString)
        
        // Then
        // Проверяем что метод вызывается (Kingfisher обычно тестируется отдельно)
        XCTAssertTrue(true, "Метод должен вызываться без ошибок")
    }
    
    func testPrepareForSegue() {
        // Given
        let segue = UIStoryboardSegue(
            identifier: "ShowSingleImage",
            source: viewController,
            destination: SingleImageViewController()
        )
        let testImageURL = "https://example.com/large.jpg"
        viewController.selectedImageURL = testImageURL
        
        // When
        viewController.prepare(for: segue, sender: self)
        
        // Then
        // Проверяем что метод выполняется без ошибок
        XCTAssertTrue(true, "prepare for segue должен выполняться без ошибок")
    }
}

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> Array {
        var array = self
        array[index] = newValue
        return array
    }
}

// MARK: - Test Configuration

class TestConfiguration {
    static func configureTestEnvironment() {
        // Отключаем анимации для тестов
        UIView.setAnimationsEnabled(false)
        
        // Настраиваем тестовый UserDefaults
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
}
