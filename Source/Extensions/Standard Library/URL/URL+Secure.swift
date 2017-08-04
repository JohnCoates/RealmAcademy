//
//  URL+Secure.swift
//  Realm Academy
//
//  Created by John Coates on 8/4/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation

extension URL {
    
    var secured: URL {
        guard var components = URLComponents.init(url: self, resolvingAgainstBaseURL: true),
            let scheme = components.scheme, scheme != "https" else {
                return self
        }
        
        components.scheme = "https"
        guard let secureURL = components.url else {
            return self
        }
        
        return secureURL
    }
    
}
