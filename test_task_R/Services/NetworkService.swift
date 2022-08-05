//
//  NetworkService.swift
//  test_task_R
//
//  Created by Дмитрий Балантаев on 27.07.2022.
//

import UIKit

final class NetworkService {

    var query = ""
    
    var imageCache = NSCache<AnyObject, AnyObject>()
    
    func fetchPhotos (currentPage: Int, completion: @escaping ([Result]) -> Void) {
        
        let accessKey = "your_key"
        let baseURL = "https://api.unsplash.com/search/photos"
        let count = 20
        let urlString = "\(baseURL)?client_id=\(accessKey)&page=\(currentPage)&per_page=\(count)&query=\(query)"
        
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let jsonResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                print(jsonResponse.results.count)
                DispatchQueue.main.async {
                    completion(jsonResponse.results)
                }
            } catch {
                print(error)
            }

        }
        task.resume()
    }


    func loadImage(array: [Result], completion: @escaping (UIImage?) -> Void) {

        for elem in array {

            if let imageFromCache = imageCache.object(forKey: elem.urls.regular as AnyObject) as? UIImage {

                completion(imageFromCache)
                return

            } else {
                guard let url = URL(string: elem.urls.regular) else { return }

                URLSession.shared.dataTask(with: url) { data, _, error in

                    guard let data = data, error == nil else { return }

                    guard let image = UIImage(data: data) else { return }

                    self.imageCache.setObject(image, forKey: elem.urls.regular as AnyObject )

                    DispatchQueue.main.async {
                        completion(image)
                    }
                }.resume()
            }
        }
    }

}
