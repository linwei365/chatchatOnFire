//
//  Extension.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/28/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    
    
    //download image from url
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        
        self.image = nil 
        //check cache first
        if let cachedImage = imageCache.object( forKey: urlString as AnyObject) as? UIImage{
            
            self.image = cachedImage
            return
        }
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response:URLResponse?, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadImage = UIImage(data: data!) {
                    
                    imageCache.setObject(downloadImage, forKey: urlString as AnyObject)
                    self.image = downloadImage
                }
                
                
             })
            
            
        }).resume()
    }
    
}
