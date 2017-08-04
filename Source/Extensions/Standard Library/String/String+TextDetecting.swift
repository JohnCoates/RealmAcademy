//
//  String+TextDetecting.swift
//  Realm Academy
//
//  Created by John Coates on 8/4/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation

extension String {
    
    var detectedURLS: [URL] {
        let detector: NSDataDetector
        do {
            detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)

        } catch let error {
            print("URL Detection error: \(error)")
            return []
        }
        
        let matches = detector.matches(in: self,
                                       options: [], range: NSMakeRange(0, characters.count))
        
        var urls: [URL] = []
        for match in matches {
            guard let url = match.url else{
                continue
            }
            
            urls.append(url)
        }
        
        return urls
    }
    
}
