//
//  NewsStoriesModel.swift
//  map_news
//
//  Created by Carolyn Hampe on 3/27/18.
//  Copyright © 2018 Carolyn Hampe. All rights reserved.
//

import UIKit
class NewsStoriesModel {
    static func getTopStories(url: URL, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
    
    static func getLatLng(url: URL, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
}
