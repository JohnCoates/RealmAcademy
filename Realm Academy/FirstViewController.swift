//
//  FirstViewController.swift
//  Realm Academy
//
//  Created by John Coates on 8/3/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import UIKit
import Ji

class FirstViewController: UIViewController, PostsLoaderDelegate {

    lazy var postsLoader: PostsLoader = {
        return PostsLoader(delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        postsLoader.loadPage()
    }
}

