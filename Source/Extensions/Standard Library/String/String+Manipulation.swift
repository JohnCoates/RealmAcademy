//
//  String+Manipulation.swift
//  Realm Academy
//
//  Created by John Coates on 8/3/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation

extension String {
    
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
