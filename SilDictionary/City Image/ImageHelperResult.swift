//
//  ImageHelperResult.swift
//  SilDictionary
//
//  Created by Bartek Jezierski on 12/1/18.
//  Copyright © 2018 Bartek Jezierski. All rights reserved.
//

import Foundation
import UIKit


enum ImageHelperResult {
    case Success(UIImage)
    case Failure(Error)
}

class ImageHelper {
    
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchImage(url: String, completion: @escaping (ImageHelperResult) -> Void) {
        
        if let url = URL(string: url) {
            
            let request = URLRequest(url: url)
            let task = session.dataTask(with: request) { (data, response, error) -> Void in
                guard let imageData = data, let image = UIImage(data: imageData) else {
                    if error != nil {
                        completion(.Failure(error!))
                    }
                    return
                }
                completion(.Success(image))
            }
            task.resume()
        } else {
            completion(.Failure(URLError.BadURL))
        }
    }
}
