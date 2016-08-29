//
//  Extension.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/28/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit

let imageCache = NSCache()

extension UIImageView {
    
    
    
    //download image from url
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil 
        //check cache first
        if let cachedImage = imageCache.objectForKey( urlString) as? UIImage{
            
            self.image = cachedImage
            return
        }
        
        let url = NSURL(string: urlString)
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response:NSURLResponse?, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let downloadImage = UIImage(data: data!) {
                    
                    imageCache.setObject(downloadImage, forKey: urlString)
                    self.image = downloadImage
                }
                
                
             })
            
            
        }).resume()
    }
    
}
