//
//  ListingsPageLoader.swift
//  Realm Academy
//
//  Created by John Coates on 8/4/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation
import Ji

class ListingsPageLoader {
    
    private lazy var url: URL = {
        return URL(string: "https://academy.realm.io/section/apple/page/\(self.page)/")!
    }()
    
    private let page: Int
    
    init(page: Int) {
        self.page = page
    }
    
    func load() -> Bool {
        guard let document = Ji(htmlURL: url) else {
            return false
        }
        
        return hydratePosts(fromDocument: document)
    }
    
    var posts: [Post] = []
    
    private func hydratePosts(fromDocument document: Ji) -> Bool {
        let sectionItem = XPathItem(element: "div",
                                    hasClass: "small-section")
        let articleItem = XPathItem(element: "div",
                                    hasClass: "article")
        
        let xPath = XPath.selector(articleItem.selector,
                                   hasAncestor: sectionItem.selector)
        
        guard let posts = document.xPath(xPath) else {
            return false
        }
        
        for postNode in posts {
            guard let post = self.post(fromPostNode: postNode) else {
                continue
            }
            
            self.posts.append(post)
        }
        
        return true
    }
    
    private func post(fromPostNode postNode: JiNode) -> Post? {
        let linkItem = XPathItem(element: "a", hasClass: "post")
        
        // . prefix is required to select current node
        guard let linkNode = postNode.xPath("." + linkItem.xPath).first,
            let linkString = linkNode.attributes["href"] else {
                print("Couldn't read link from post: \(post)")
                return nil
        }
        
        let imageItem = XPathItem(element: "img", hasClass: "article-img")
        
        guard let imageNode = postNode.xPath("." + imageItem.xPath).first,
            let image = imageNode.attributes["src"],
            let imageURL = URL(string: image, relativeTo: self.url)
            
            else {
                print("Couldn't read image from post: \(post)")
                return nil
        }
        
        let headlineItem = XPathItem(element: "a", hasClass: "news-headline")
        
        guard let headlineNode = postNode.xPath("." + headlineItem.xPath).first,
            let headline = headlineNode.content?.trimmed else {
                print("Couldn't read headline from post: \(post)")
                return nil
        }
        
        guard let url = URL(string: linkString, relativeTo: self.url)else {
            fatalError("Invalid url string!")
        }
        
        return Post(headline: headline, url: url, imageURL: imageURL)
    }
    
}
