// ImagesListPresenter.swift
import Foundation
import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func willDisplayCell(at index: Int)
    func didSelectCell(at index: Int) -> String?
    func configCell(for cell: ImagesListCell, at index: Int)
    func didTapLike(for cell: ImagesListCell, at index: Int)
    func heightForRow(at index: Int, tableViewWidth: CGFloat) -> CGFloat
    func getPhoto(at index: Int) -> Photo?
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService: ImagesListService
    private var photos: [Photo] = []
    
    var photosCount: Int {
        return photos.count
    }
    
    init(imagesListService: ImagesListService = ImagesListService.shared) {
        self.imagesListService = imagesListService
        setupNotifications()
    }
    
    func viewDidLoad() {
        fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func willDisplayCell(at index: Int) {
        if index == photos.count - 1 {
            fetchPhotosNextPage()
        }
    }
    
    func didSelectCell(at index: Int) -> String? {
        guard index < photos.count else { return nil }
        let photo = photos[index]
        return photo.largeImageURL
    }
    
    func configCell(for cell: ImagesListCell, at index: Int) {
        guard index < photos.count else { return }
        let photo = photos[index]
        
        // Установка даты
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = ImagesListPresenter.dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }
        
        // Установка состояния лайка
        cell.setIsLiked(photo.isLiked)
        
        // Передаем URL для загрузки изображения в ViewController
        view?.loadImage(for: cell, with: photo.thumbImageURL)
    }
    
    func getPhoto(at index: Int) -> Photo? {
        guard index < photos.count else { return nil }
        return photos[index]
    }
    
    func didTapLike(for cell: ImagesListCell, at index: Int) {
        guard index < photos.count else { return }
        let photo = photos[index]
        
        view?.showLoadingIndicator()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.view?.hideLoadingIndicator()
                
                switch result {
                case .success:
                    // Обновляем данные из сервиса
                    self.photos = self.imagesListService.photos
                    let updatedPhoto = self.photos[index]
                    cell.setIsLiked(updatedPhoto.isLiked)
                case .failure(let error):
                    self.view?.showError(error)
                }
            }
        }
    }
    
    func heightForRow(at index: Int, tableViewWidth: CGFloat) -> CGFloat {
        guard index < photos.count else { return 0 }
        let photo = photos[index]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageWidth != 0 ? imageViewWidth / imageWidth : 1.0
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    // MARK: - Private Methods
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePhotos),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func updatePhotos() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        guard newCount > oldCount else { return }
        
        let indexPaths = (oldCount..<newCount).map { $0 }
        DispatchQueue.main.async {
            self.view?.updateTableViewAnimated(with: indexPaths)
        }
    }
    
    // MARK: - Static Properties
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}
