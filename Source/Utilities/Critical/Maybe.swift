//
//  Maybe.swift
//  Realm Academy
//
//  Created by John Coates on 8/4/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation

class Maybe {
    
    static func cast<CastType>(_ valueMaybe: Any?) -> CastType? {
        guard let value = valueMaybe else {
            return nil
        }
        
        return value as? CastType
    }
    
}
