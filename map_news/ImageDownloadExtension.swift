//
//  ImageDownloadExtension.swift
//  map_news
//
//  Created by Carolyn Hampe on 3/30/18.
//  Copyright © 2018 Carolyn Hampe. All rights reserved.
//

import UIKit

extension UIImage {
    static func downloadFromRemoteURL(_ url: URL, completion: @escaping (UIImage?,Error?)->()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async{
                    completion(nil,error)
                }
                return
            }
            DispatchQueue.main.async() {
                completion(image,nil)
            }
            }.resume()
    }
}
