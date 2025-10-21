import XCTest
@testable import Image_Feed

// MARK: - Mocks

final class MockImagesListViewController: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    var updateTableViewIndexes: [Int] = []
    var showSingleImageCalled = false
    var showSingleImageURL: String?
    var showLoadingIndicatorCalled = false
    var hideLoadingIndicatorCalled = false
    var showErrorCalled = false
    var showError: Error?
    var loadImageCalled = false
    var loadImageCell: ImagesListCell?
    var loadImageURL: String?
    
    func updateTableViewAnimated(with newIndexes: [Int]) {
        updateTableViewAnimatedCalled = true
        updateTableViewIndexes = newIndexes
    }
    
    func showSingleImage(for imageURL: String) {
        showSingleImageCalled = true
        showSingleImageURL = imageURL
    }
    
    func showLoadingIndicator() {
        showLoadingIndicatorCalled = true
    }
    
    func hideLoadingIndicator() {
        hideLoadingIndicatorCalled = true
    }
    
    func showError(_ error: Error) {
        showErrorCalled = true
        self.showError = error
    }
    
    func loadImage(for cell: ImagesListCell, with urlString: String) {
        loadImageCalled = true
        loadImageCell = cell
        loadImageURL = urlString
    }
}

    final class MockImagesListService: ImagesListService {
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    var changeLikePhotoId: String?
    var changeLikeIsLike: Bool?
    
    var mockPhotos: [Photo] = []
    
    override init() {
        super.init()
        // Инициализация без вызова родительского инициализатора чтобы избежать зависимостей
    }
    
    override var photos: [Photo] {
        get { return mockPhotos }
        set { mockPhotos = newValue }
    }
    
    override func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    override func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        changeLikePhotoId = photoId
        changeLikeIsLike = isLike
        
        // Симулируем успешное изменение лайка
        if let index = mockPhotos.firstIndex(where: { $0.id == photoId }) {
            var photo = mockPhotos[index]
            let newPhoto = Photo(
                id: photo.id,
                size: photo.size,
                createdAt: photo.createdAt,
                welcomeDescription: photo.welcomeDescription,
                thumbImageURL: photo.thumbImageURL,
                largeImageURL: photo.largeImageURL,
                isLiked: !photo.isLiked
            )
            mockPhotos[index] = newPhoto
            completion(.success(()))
        } else {
            completion(.failure(NSError(domain: "TestError", code: 404)))
        }
    }
}

final class MockImagesListCell: ImagesListCell {
    var setIsLikedCalled = false
    var setIsLikedValue: Bool?
    var setLikeButtonEnabledCalled = false
    var setLikeButtonEnabledValue: Bool?
    
    override func setIsLiked(_ isLiked: Bool) {
        setIsLikedCalled = true
        setIsLikedValue = isLiked
    }
    
    override func setLikeButtonEnabled(_ isEnabled: Bool) {
        setLikeButtonEnabledCalled = true
        setLikeButtonEnabledValue = isEnabled
    }
}

// MARK: - Test Data

extension Photo {
    static func createMockPhotos(count: Int) -> [Photo] {
        return (0..<count).map { index in
            Photo(
                id: "photo_\(index)",
                size: CGSize(width: 1000 + index, height: 800 + index),
                createdAt: Date(),
                welcomeDescription: "Description \(index)",
                thumbImageURL: "https://example.com/thumb\(index).jpg",
                largeImageURL: "https://example.com/large\(index).jpg",
                isLiked: index % 2 == 0
            )
        }
    }
}

// MARK: - ImagesListPresenterTests

final class ImagesListPresenterTests: XCTestCase {
    
    private var presenter: ImagesListPresenter!
    private var mockViewController: MockImagesListViewController!
    private var mockService: MockImagesListService!
    
    override func setUp() {
        super.setUp()
        mockViewController = MockImagesListViewController()
        mockService = MockImagesListService()
        presenter = ImagesListPresenter(imagesListService: mockService)
        presenter.view = mockViewController
    }
    
    override func tearDown() {
        presenter = nil
        mockViewController = nil
        mockService = nil
        super.tearDown()
    }
    
    func testViewDidLoad() {
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockService.fetchPhotosNextPageCalled, "При viewDidLoad должна вызываться загрузка фотографий")
    }
    
    func testPhotosCount() {
        // Given
        let mockPhotos = Photo.createMockPhotos(count: 5)
        mockService.mockPhotos = mockPhotos
        
        // When
        let count = presenter.photosCount
        
        // Then
        XCTAssertEqual(count, 5, "photosCount должен возвращать корректное количество фотографий")
    }
    
    func testWillDisplayCellTriggersFetchWhenLastCell() {
        // Given
        let mockPhotos = Photo.createMockPhotos(count: 10)
        mockService.mockPhotos = mockPhotos
        
        // When
        presenter.willDisplayCell(at: 9) // Последняя ячейка
        
        // Then
        XCTAssertTrue(mockService.fetchPhotosNextPageCalled, "При отображении последней ячейки должна вызываться загрузка следующей страницы")
    }
    
    func testWillDisplayCellDoesNotTriggerFetchWhenNotLastCell() {
        // Given
        let mockPhotos = Photo.createMockPhotos(count: 10)
        mockService.mockPhotos = mockPhotos
        mockService.fetchPhotosNextPageCalled = false
        
        // When
        presenter.willDisplayCell(at: 5) // Не последняя ячейка
        
        // Then
        XCTAssertFalse(mockService.fetchPhotosNextPageCalled, "При отображении не последней ячейки не должна вызываться загрузка следующей страницы")
    }
    
    func testDidSelectCellReturnsCorrectImageURL() {
        // Given
        let mockPhotos = Photo.createMockPhotos(count: 3)
        mockService.mockPhotos = mockPhotos
        
        // When
        let imageURL = presenter.didSelectCell(at: 1)
        
        // Then
        XCTAssertEqual(imageURL, mockPhotos[1].largeImageURL, "didSelectCell должен возвращать largeImageURL выбранной фотографии")
    }
    
    func testDidSelectCellReturnsNilForInvalidIndex() {
        // Given
        let mockPhotos = Photo.createMockPhotos(count: 3)
        mockService.mockPhotos = mockPhotos
        
        // When
        let imageURL = presenter.didSelectCell(at: 10) // Неверный индекс
        
        // Then
        XCTAssertNil(imageURL, "didSelectCell должен возвращать nil для неверного индекса")
    }
    
    func testConfigCellConfiguresCellCorrectly() {
        // Given
        let mockPhotos = Photo.createMockPhotos(count: 3)
        mockService.mockPhotos = mockPhotos
        let mockCell = MockImagesListCell()
        
        // When
        presenter.configCell(for: mockCell, at: 1)
        
        // Then
        XCTAssertTrue(mockViewController.loadImageCalled, "configCell должен вызывать загрузку изображения")
        XCTAssertEqual(mockViewController.loadImageURL, mockPhotos[1].thumbImageURL, "Должен передаваться корректный URL для загрузки")
        XCTAssertTrue(mockCell.setIsLikedCalled, "configCell должен устанавливать состояние лайка")
        XCTAssertEqual(mockCell.setIsLikedValue, mockPhotos[1].isLiked, "Должно устанавливаться корректное состояние лайка")
    }
    
    func testDidTapLikeCallsServiceWithCorrectParameters() {
        // Given
        let mockPhotos = Photo.createMockPhotos(count: 3)
        mockService.mockPhotos = mockPhotos
        let mockCell = MockImagesListCell()
        
        // When
        presenter.didTapLike(for: mockCell, at: 1)
        
        // Then
        XCTAssertTrue(mockService.changeLikeCalled, "didTapLike должен вызывать сервис изменения лайка")
        XCTAssertEqual(mockService.changeLikePhotoId, mockPhotos[1].id, "Должен передаваться корректный photoId")
        XCTAssertEqual(mockService.changeLikeIsLike, !mockPhotos[1].isLiked, "Должен передаваться инвертированный isLiked")
        XCTAssertTrue(mockViewController.showLoadingIndicatorCalled, "Должен показываться индикатор загрузки")
    }
    
    func testHeightForRowCalculatesCorrectHeight() {
        // Given
        let mockPhotos = [
            Photo(
                id: "test",
                size: CGSize(width: 1000, height: 800),
                createdAt: Date(),
                welcomeDescription: "Test",
                thumbImageURL: "https://example.com/thumb.jpg",
                largeImageURL: "https://example.com/large.jpg",
                isLiked: false
            )
        ]
        mockService.mockPhotos = mockPhotos
        let tableViewWidth: CGFloat = 375
        
        // When
        let height = presenter.heightForRow(at: 0, tableViewWidth: tableViewWidth)
        
        // Then
        let expectedHeight = (800 * (tableViewWidth - 32) / 1000) + 8 // imageInsets: 4+4=8
        XCTAssertEqual(height, expectedHeight, accuracy: 0.1, "Высота ячейки должна рассчитываться корректно")
    }
    
    func testGetPhotoReturnsCorrectPhoto() {
        // Given
        let mockPhotos = Photo.createMockPhotos(count: 3)
        mockService.mockPhotos = mockPhotos
        
        // When
        let photo = presenter.getPhoto(at: 1)
        
        // Then
        XCTAssertEqual(photo?.id, mockPhotos[1].id, "getPhoto должен возвращать корректную фотографию")
    }
    
    func testGetPhotoReturnsNilForInvalidIndex() {
        // Given
        let mockPhotos = Photo.createMockPhotos(count: 3)
        mockService.mockPhotos = mockPhotos
        
        // When
        let photo = presenter.getPhoto(at: 10)
        
        // Then
        XCTAssertNil(photo, "getPhoto должен возвращать nil для неверного индекса")
    }
    
    func testUpdatePhotosNotificationUpdatesData() {
        // Given
        let initialPhotos = Photo.createMockPhotos(count: 5)
        let newPhotos = Photo.createMockPhotos(count: 10)
        mockService.mockPhotos = initialPhotos
        
        // When
        mockService.mockPhotos = newPhotos
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: mockService
        )
        
        // Then
        // Ждем немного для асинхронного обновления
        let expectation = self.expectation(description: "Wait for notification")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        
        XCTAssertTrue(mockViewController.updateTableViewAnimatedCalled, "При получении нотификации должен обновляться tableView")
        XCTAssertEqual(mockViewController.updateTableViewIndexes, [5, 6, 7, 8, 9], "Должны добавляться корректные индексы")
    }
}
