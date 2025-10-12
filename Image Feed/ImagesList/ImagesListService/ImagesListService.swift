//
//  ImagesListService.swift
//  Image Feed
//
//  Created by Николай Замараев on 15.09.2025.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let likes: Int
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case description
        case likes
        case likedByUser = "liked_by_user"
        case urls
    }
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

enum httpMethods: String {
    case post = "POST"
    case del = "DELETE"
    var value: String { rawValue }
}

struct LikeResponse: Decodable {
    let photo: PhotoResult
}

final class ImagesListService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    static let shared = ImagesListService()
    
    private(set) var photos: [Photo] = []

    
    private var isFetching = false
    private var currentPage = 0
    private var tokenStorage = OAuth2TokenStorage.shared
    
    func resetPhotosArray() {
        photos = []
    }
    
    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        isFetching = true
        
        let nextPage = currentPage + 1
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=10") else {
            isFetching = false
            return
        }
        guard let token = tokenStorage.token else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            self.isFetching = false
            
            switch result {
            case .success(let results):
                let newPhotos = results.map { Photo(from: $0) }
                self.photos.append(contentsOf: newPhotos)
                self.currentPage = nextPage
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
            case .failure(let error):
                print("Ошибка загрузки: \(error)")
            }
        }
        
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let baseURL = Constants.defaultBaseURL else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        guard let token = tokenStorage.token else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let url = baseURL.appendingPathComponent("photos/\(photoId)/like")
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? httpMethods.post.rawValue : httpMethods.del.value
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { (result: Result<LikeResponse, Error>) in
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension Photo {
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    init(from result: PhotoResult) {
        var parsedDate: Date?
        if let createdAt = result.createdAt {
            parsedDate = Photo.dateFormatter.date(from: createdAt)
        }
        
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = parsedDate
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}
