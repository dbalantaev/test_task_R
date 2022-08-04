//
//  ImagesModel.swift
//  test_task_R
//
//  Created by Дмитрий Балантаев on 27.07.2022.
//

//import Foundation
//
//// MARK: - ImagesModel
//struct ImagesModel: Codable {
//
//    let imagesResults: [ImagesResult]
//
//    enum CodingKeys: String, CodingKey {
//        case imagesResults = "images_results"
//    }
//}
//
//// MARK: - ImagesResult
//struct ImagesResult: Codable {
//
//    let thumbnail: String
//    let original: String
//
//    enum CodingKeys: String, CodingKey {
//        case thumbnail
//        case original
//    }
//}

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
