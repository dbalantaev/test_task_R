//
//  MainVC.swift
//  test_task_R
//
//  Created by Дмитрий Балантаев on 27.07.2022.
//

import UIKit

final class MainVC: UIViewController {

    var imagesResults: [Result] = []

    var images = [UIImage]()

    var networkService = NetworkService()

    var loadingView: LoadingReusableView?

    var currentPage = 1

    var isLoading = false

    private var imageURL: [Result]? {
        didSet {
            self.imagesResults = imageURL!
            self.networkService.loadImage(array: self.imagesResults) { [weak self] image in
                self?.image = image
            }
        }
    }

    private var image: UIImage? {
        didSet {
            images.append(image!)
            hideLoadingProcess()
            didRecieveSearchResult()
        }
    }

    private let searchController = UISearchController()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        cv.register(LoadingReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "spinner")

        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        return cv
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = .systemBackground
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        self.dismissKeyboard()
        collectionView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect(x: 10, y: 0, width: view.frame.size.width-20, height: view.frame.size.height)
    }

    private func setupView() {
        self.title = "Photos"
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.backgroundColor = .systemBackground
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
                activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }

    // отображение индикатора загрузки
    private func showLoadingProcess() {
        activityIndicator.startAnimating()
        collectionView.isHidden = true
    }

    // скрытие индикатора загрузки
    private func hideLoadingProcess() {
        activityIndicator.stopAnimating()
        collectionView.isHidden = false
    }

    // перезагрузка данных в таблице
    private func didRecieveSearchResult() {
        collectionView.reloadData()
    }

}

// MARK: - extension для Collection View

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                            for: indexPath) as? CollectionViewCell
        else { return UICollectionViewCell() }
        cell.imageView.image = images[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoVC = PhotoVC()
        photoVC.selectedImage = indexPath.row
        photoVC.images = images
        pushView(viewController: photoVC)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width/4 - 4
        return CGSize(width: width, height: width)
    }

    // MARK: -  пагинация

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if indexPath.row == imagesResults.count - 20, !self.isLoading {
            loadMoreData()
        }
    }

    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(3)) { // сделана зажержка в 3 секунды для демострации пагинации
                self.currentPage += 1
                self.networkService.fetchPhotos(currentPage: self.currentPage) { [weak self] jsonResult in
                    self?.imageURL = jsonResult
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.isLoading = false
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.isLoading {
            return CGSize.zero
        } else {
            return CGSize(width: collectionView.bounds.size.width, height: 55)
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "spinner", for: indexPath) as! LoadingReusableView
            loadingView = aFooterView
            loadingView?.backgroundColor = UIColor.clear
            return aFooterView
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingView?.activityIndicator.startAnimating()
            self.loadingView?.activityIndicator.hidesWhenStopped = false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingView?.activityIndicator.stopAnimating()
            self.loadingView?.activityIndicator.hidesWhenStopped = true
        }
    }

}

// MARK: - extension для SearchBar

extension MainVC: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text?.replacingOccurrences(of: " ", with: "%20") {
            imagesResults = []
            images = []
            networkService.query = text
            networkService.fetchPhotos(currentPage: currentPage) { [weak self] jsonResult in
                self?.imageURL = jsonResult
            }
            didRecieveSearchResult()
            showLoadingProcess()
            self.loadingView?.isHidden = false
        }
    }

}
