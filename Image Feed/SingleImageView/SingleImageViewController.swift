import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }

            imageView.image = image
            imageView.frame.size = image.size

            rescaleAndCenterImageInScrollView(image: image)
        }
    }

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25

        guard let image else { return }
        imageView.image = image
        
        imageView.frame.size = image.size
        
        rescaleAndCenterImageInScrollView(image: image)
        
    }

    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size
        
        // Рассчитываем масштаб для заполнения экрана
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let scale = max(widthScale, heightScale) // Берем максимальный масштаб для заполнения
        
        scrollView.minimumZoomScale = scale
        scrollView.maximumZoomScale = scale * 3 // Оставляем возможность увеличения
        scrollView.zoomScale = scale
        
        // Центрируем изображение
        let contentSize = scrollView.contentSize
        let offsetX = max(0, (contentSize.width - scrollViewSize.width) / 2)
        let offsetY = max(0, (contentSize.height - scrollViewSize.height) / 2)
        scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
