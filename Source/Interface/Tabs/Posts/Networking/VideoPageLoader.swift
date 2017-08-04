//
//  VideoPageLoader.swift
//  Realm Academy
//
//  Created by John Coates on 8/4/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation
import Ji

class VideoPageLoader {
    
    private let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func load() -> Bool {
        guard let document = Ji(htmlURL: url) else {
            return false
        }
        
        guard let details = postDetails(fromDocument: document) else {
            return false
        }
        
        postDetails = details
        
        return true
    }
    
    var postDetails: PostDetails?
    
    private func postDetails(fromDocument document: Ji) -> PostDetails? {
        let speakers = self.speakers(document: document)
        print("speakers: \(speakers)")
        
        let jsonpURL = jsonp(document: document)
        
        return PostDetails(speakers: speakers, jsonpURL: jsonpURL)
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
    
}
