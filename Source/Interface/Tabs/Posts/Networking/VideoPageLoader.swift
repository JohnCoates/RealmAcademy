//
//  VideoPageLoader.swift
//  Realm Academy
//
//  Created by John Coates on 8/4/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation
import Ji

enum VideoPageResult {
    case success(post: PostDetails)
    case error(message: String)
}

protocol VideoPageLoaderDelegate: class {
    func videoPageLoader(_ loader: VideoPageLoader, result: VideoPageResult)
}

class VideoPageLoader: VideoDetailsLoaderDelegate {
    
    var delegate: VideoPageLoaderDelegate?
    
    private let url: URL
    
    init(url: URL, delegate: VideoPageLoaderDelegate) {
        self.url = url
        self.delegate = delegate
    }
    
    var videoDetailsLoader: VideoDetailsLoader?
    
    var document: Ji?
    
    func load() {
        DispatchQueue.global(qos: .background).async {
            self.loadInBackground()
        }
    }
    
    private func loadInBackground() {
        guard let document = Ji(htmlURL: url) else {
            delegate?.videoPageLoader(self,
                                      result: .error(message: "Couldn't retrieve page document for url: \(url)"))
            return
        }
        
        self.document = document
        
        let jsonpURL = jsonp(document: document)
        
        let detailsLoader = VideoDetailsLoader(jsonp: jsonpURL, delegate: self)
        detailsLoader.load()
        videoDetailsLoader = detailsLoader
    }
    
    private func speakers(document: Ji) -> [Speaker] {
        let speakersPath = XPathItem(element: "div",
                                     id: "author-block")
        guard let speakerNodes = document.xPath(speakersPath.xPath) else {
            print("No author-block nodes")
            return []
        }
        
        var speakers = [Speaker]()
        
        for speakerNode in speakerNodes {
            guard let speaker = self.speaker(node: speakerNode) else {
                continue
            }
            
            speakers.append(speaker)
        }
        
        return speakers
    }
    
    private func speaker(node: JiNode) -> Speaker? {
        let avatarPath = XPathItem(element: "div", hasClass: "avatar")
        var avatarURL: URL? = nil
        
        if let avatarNode = node.xPath("." + avatarPath.xPath).first,
            let style = avatarNode.attributes["style"],
            let url = style.detectedURLS.first?.secured
        {
            avatarURL = url
        }
        
        let namePath = XPathItem(element: "*", hasClass: "name")
        guard let nameNode = node.xPath("." + namePath.xPath).first,
            let name = nameNode.content?.trimmed else {
                print("Couldn't read speaker name from: \(node)")
            return nil
        }
        
        var description: String = ""
        let descriptionPath = XPathItem(element: "p").withContentLength(atLeast: 10).relative
        if let descriptionNode = node.xPath(descriptionPath).first,
            let descriptionContent = descriptionNode.content?.trimmed {
                description = descriptionContent
        } else {
            print("Couldn't read speaker description from: \(node)")
        }
        
        var twitterUsername: String? = nil
        let twitterPath = XPathItem(element: "a").withContent(equals: "Twitter").relative
        if let twitterNode = node.xPath(twitterPath).first,
           let href = twitterNode.attributes["href"],
           let lastSlash = href.range(of: "/", options: .backwards, range: nil, locale: nil)?.lowerBound {
            let afterSlash = href.index(after: lastSlash)
            twitterUsername = href.substring(from: afterSlash)
            
        }
        
        return Speaker(name: name,
                       description: description,
                       avatarURL: avatarURL,
                       twitterUsername: twitterUsername)
    }
    
    private func jsonp(document: Ji) -> URL {
        let path = XPathItem(element: "script").with(attribute: "src", containing: ".jsonp").relative
        
        guard let node = document.xPath(path)?.first,
              let src = node.attributes["src"],
              let url = URL(string: src)
        else {
            fatalError("Failed to find jsonp in document: \(document)")
        }
        
        return url
    }
    
    // MARK: - Video Details Loader Delegate
    
    func videoDetailsLoader(_ loader: VideoDetailsLoader, result: VideoDetailsResult) {
        guard let document = document else {
            delegate?.videoPageLoader(self,
                                      result: .error(message: "Missing document"))
            return
        }
        
        let speakers = self.speakers(document: document)
        
        switch result {
        case let .success(videoDetails):
            let details = PostDetails(speakers: speakers,
                                      jsonpURL: loader.url,
                                      videoDetails: videoDetails)
            delegate?.videoPageLoader(self, result: .success(post: details))
        case let .error(message):
            delegate?.videoPageLoader(self, result: .error(message: message))
        }
    }
    
}
