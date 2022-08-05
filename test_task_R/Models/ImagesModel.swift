//
//  ImagesModel.swift
//  test_task_R
//
//  Created by Дмитрий Балантаев on 27.07.2022.
//

import Foundation
import UIKit

struct APIResponse: Codable {
    let total: Int
    let total_pages: Int
    let results: [Result]
}

struct Result: Codable {
    let id: String
    let description: String?
    let urls: URLS
}

struct URLS: Codable {
    let full: String
    let regular: String
    let thumb: String
}
