import UIKit

final class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - ProfileImageCode
        let profileImage = UIImage(named: "avatar")
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        //MARK: - NameLabelCode
        let profileName = UILabel()
        profileName.text = "Екатерина Новикова"
        profileName.textColor = .white
        profileName.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        profileName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileName)
        profileName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        profileName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        
        let nickName = UILabel()
        nickName.text = "@ekaterina_nov"
        nickName.textColor = .systemGray
        nickName.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        nickName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickName)
        nickName.leadingAnchor.constraint(equalTo: profileName.leadingAnchor).isActive = true
        nickName.topAnchor.constraint(equalTo: profileName.bottomAnchor, constant: 8).isActive = true
        
        let aboutMe = UILabel()
        aboutMe.text = "Hello, world!"
        aboutMe.textColor = .white
        aboutMe.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        aboutMe.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(aboutMe)
        aboutMe.leadingAnchor.constraint(equalTo: nickName.leadingAnchor).isActive = true
        aboutMe.topAnchor.constraint(equalTo: nickName.bottomAnchor, constant: 8).isActive = true
        
        //MARK: - ExitButtonCode
        let exitButton = UIButton(type: .custom)
        exitButton.setImage(UIImage(named: "logout_button"), for: .normal)
        exitButton.imageView?.contentMode = .scaleAspectFit
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        
    }
}
