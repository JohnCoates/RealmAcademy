//
//  XPath.swift
//  Realm Academy
//
//  Created by John Coates on 8/3/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation

struct XPathItem {
    
    let selector: String
    
    var xPath: String {
        return "//\(selector)"
    }
    
    var relative: String {
        return "." + xPath
    }
    
    init(element: String, hasClass requiredClass: String) {
        // adapted from https://stackoverflow.com/a/1604480/6896239
        selector = "\(element)[contains(concat(' ', normalize-space(@class), ' '), ' \(requiredClass) ')]"
    }
    
    init(element: String, id: String) {
        selector = "\(element)[@id='\(id)']"
    }
    
    init(element: String) {
        selector = "\(element)"
    }
    
    private init(selector: String) {
        self.selector = selector
    }
    
    func withContentLength(atLeast: Int) -> XPathItem {
        return XPathItem(selector: selector + "[string-length() > \(atLeast)]")
    }
    
    func withContent(equals: String) -> XPathItem {
        return XPathItem(selector: selector + "[text()=\'\(equals)']")
    }
    
    func with(attribute: String, containing: String) -> XPathItem {
        return XPathItem(selector: selector + "[contains(@\(attribute), '\(containing)')]")
    }
}

struct XPath {
    static func selector(_ selector: String, hasAncestor ancestor: String) -> String {
        return "//\(ancestor)//\(selector)"
    }
}
