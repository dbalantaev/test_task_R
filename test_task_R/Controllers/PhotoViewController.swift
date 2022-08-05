//
//  PhotoViewController.swift
//  test_task_R
//
//  Created by Дмитрий Балантаев on 27.07.2022.
//

import UIKit

final class PhotoViewController: UIViewController {

    var images = [UIImage]()

    var selectedImage: Int = 0

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.contentMode = .scaleAspectFit
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.backgroundColor = .black
        scroll.minimumZoomScale = 1
        scroll.maximumZoomScale = 6
        return scroll
    }()

    private let imageView: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.isUserInteractionEnabled = true
        return image
    }()

    private let countlbl: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var closeBtn: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "close")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        return button
    }()

    @objc func closeBtnTapped() {
        self.dismissView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        scrollView.delegate = self
        setupGesture()
        setupView()
        setupConstraints()
        loadImage()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(countlbl)
        view.addSubview(closeBtn)
    }

    private func setupConstraints() {
        scrollView.frame = view.bounds
        imageView.frame = scrollView.bounds
        countlbl.frame = CGRect(x: 20,
                                y: view.frame.height - 50,
                                width: view.frame.width - 40,
                                height: 21)
        closeBtn.frame = CGRect(x: 20,
                                y: 80,
                                width: 25,
                                height: 25)
    }

    func loadImage() {
        imageView.image = images[selectedImage]
        countlbl.text = String(format: "%ld / %ld",
                               selectedImage + 1,
                               images.count)
    }

}

// MARK: - скроллинг и увеличение двойным нажатием
extension PhotoViewController: UIScrollViewDelegate, UIGestureRecognizerDelegate {

    func setupGesture() {
        let singleTapGesture = UITapGestureRecognizer(target: self,
                                                      action:
                                                        #selector(handleSingleTapOnScrollView(recognizer:)))
        singleTapGesture.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTapGesture)
        let doubleTapGesture = UITapGestureRecognizer(target: self,
                                                      action:
                                                        #selector(handleDoubleTapOnScrollView(recognizer:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        singleTapGesture.require(toFail: doubleTapGesture)
        let rightSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                                                                            action:
                                                                                #selector(handleSwipeFrom(recognizer:)))
        let leftSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                                                                           action:
                                                                            #selector(handleSwipeFrom(recognizer:)))
        rightSwipe.direction = .right
        leftSwipe.direction = .left
        scrollView.addGestureRecognizer(rightSwipe)
        scrollView.addGestureRecognizer(leftSwipe)
    }

    @objc func handleSingleTapOnScrollView (recognizer: UITapGestureRecognizer) {
        if closeBtn.isHidden {
            closeBtn.isHidden = false
            countlbl.isHidden = false
        } else {
            closeBtn.isHidden = true
            countlbl.isHidden = true
        }
    }

    @objc func handleDoubleTapOnScrollView (recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale,
                                                 center: recognizer.location(in: recognizer.view)),
                            animated: true)
            closeBtn.isHidden = true
            countlbl.isHidden = true
        } else {
            scrollView.setZoomScale(1, animated: true)
            closeBtn.isHidden = false
            countlbl.isHidden = false
        }
    }

    @objc func handleSwipeFrom(recognizer: UISwipeGestureRecognizer) {
        let direction: UISwipeGestureRecognizer.Direction = recognizer.direction
        switch direction {
        case UISwipeGestureRecognizer.Direction.right:
            self.selectedImage -= 1
        case UISwipeGestureRecognizer.Direction.left:
            self.selectedImage += 1
        default:
            break
        }
        self.selectedImage = (self.selectedImage < 0) ? (self.images.count - 1):
        self.selectedImage % self.images.count
        loadImage()
    }

    @objc func handlePinch(recognizer: UIPinchGestureRecognizer) {
        print(recognizer)
        recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale))!
        recognizer.scale = 1
        imageView.contentMode = .scaleAspectFit
    }

    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width  / scale
        let newCenter = imageView.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = imageView.image {
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height
                let ratio = ratioW < ratioH ? ratioW:ratioH
                let newWidth = image.size.width*ratio
                let newHeight = image.size.height*ratio
                let left = 0.5 * (newWidth * scrollView.zoomScale > imageView.frame.width ?
                                  (newWidth - imageView.frame.width) :
                                    (scrollView.frame.width - scrollView.contentSize.width))
                let top = 0.5 * (newHeight * scrollView.zoomScale > imageView.frame.height ?
                                 (newHeight - imageView.frame.height) :
                                    (scrollView.frame.height - scrollView.contentSize.height))
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = UIEdgeInsets.zero
        }
    }

}
