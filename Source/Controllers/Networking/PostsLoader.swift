//
//  PostsLoader.swift
//  Realm Academy
//
//  Created by John Coates on 8/3/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation

class PostsLoader: ListingsPageLoaderDelegate {
    weak var delegate: ListingsPageLoaderDelegate?
    
    init(delegate: ListingsPageLoaderDelegate) {
        self.delegate = delegate
    }
    
    private var page = 1
    
    var loader: ListingsPageLoader?
    
    func load() {
        let loadPage = page
        page += 1
        
        let loader = ListingsPageLoader(delegate: self, page: loadPage)
        loader.load()
        self.loader = loader
    }
    
    func listingPageLoader(_ loader: ListingsPageLoader, result: ListingsPageResult) {
        delegate?.listingPageLoader(loader, result: result)
        self.loader = nil
        
        switch result {
        case let .success(posts):
            if posts.count > 0 {
                let unsupportedHeadline = "Realm Adventure Calendar 2016"
                if posts.index(where: { $0.headline == unsupportedHeadline }) != nil {
                    break
                } else {
                    load()
                }
            }
        default:
            break
        }
    }
    
}
