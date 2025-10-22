import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? {get set}
    func viewDidLoad()
    func didTapLogout()
    func confirmLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {

    weak var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let logoutService = ProfileLogoutService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?

    func viewDidLoad() {
        setupObservers()
        updateProfileDetails()
        updateAvatar()
    }
    
    func didTapLogout() {
        view?.showLogoutConfirmation()
    }
    
    func confirmLogout() {
        logoutService.logout()
    }
    

    private func setupObservers() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }
    }
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        
        let displayName = profile.name.isEmpty ? "Имя не указано" : profile.name
        let displayLoginName = profile.loginName.isEmpty ?
            "@неизвестный_пользователь" : profile.loginName
        let displayBio = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio
        
        view?.updateProfileDetails(
            name: displayName,
            loginName: displayLoginName,
            bio: displayBio
        )
    }
    
    private func updateAvatar() {
        guard let avatarURL = profileImageService.avatarURL else { return }
        view?.updateAvatar(with: avatarURL)
    }
    

    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
