//
//  String+Manipulation.swift
//  Realm Academy
//
//  Created by John Coates on 8/3/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var whitespaceCleaned: String {
        let cleared = replacingOccurrences(of: "\n", with: " ")
        return cleared.replacingOccurrences(of: "  ", with: " ")
    }
    
    var strippedHTML: String {
        let data = self.data(using: .utf8)!
        
        let options: [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as NSString,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue as NSNumber]
        
        
        let attributed = try! NSAttributedString(data: data,
                                                 options: options,
                                                 documentAttributes: nil)
        
        return attributed.string
    }
    
}
