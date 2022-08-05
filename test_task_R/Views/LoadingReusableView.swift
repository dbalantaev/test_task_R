//
//  LoadingReusableView.swift
//  test_task_R
//
//  Created by Дмитрий Балантаев on 04.08.2022.
//

import UIKit

final class LoadingReusableView: UICollectionReusableView {

    let identifier = "spinner"

    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = .systemBackground
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(activityIndicator)

        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
