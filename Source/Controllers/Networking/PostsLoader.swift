//
//  PostsLoader.swift
//  Realm Academy
//
//  Created by John Coates on 8/3/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation


protocol PostsLoaderDelegate: class {
//    func postsLoader(_ loader: PostsLoader, )
}

class PostsLoader {
    weak var delegate: PostsLoaderDelegate?
    
    init(delegate: PostsLoaderDelegate) {
        self.delegate = delegate
    }
    
    private var page = 1
    
    func loadPage() {
        let loadPage = self.page
        page += 1
        
        DispatchQueue.global(qos: .background).async {
            self.loadInBackground(page: loadPage)
        }
    }
    
    private func loadInBackground(page: Int) {
//        let loader = ListingsPageLoader(page: page)
//        if loader.load() {
//        }
        
        
    }
}
