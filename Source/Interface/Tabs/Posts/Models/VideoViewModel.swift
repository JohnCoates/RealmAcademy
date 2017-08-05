//
//  VideoViewModel.swift
//  Realm Academy
//
//  Created by John Coates on 8/4/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation

struct VideoViewModel {
    
    let post: PostDetails
    
    init(post: PostDetails) {
        self.post = post
    }
    
    var headerTime: String {
        let now = Date()
        let seconds = post.videoDetails.duration as TimeInterval
        let calendar = Calendar.current
        let left = calendar.dateComponents([.hour, .minute],
                                           from: now,
                                           to: Date(timeIntervalSinceNow: seconds))
        
        var time = ""
        if let hour = left.hour, hour > 0 {
            time += String(hour) + "hr "
        }
        
        if let minute = left.minute, minute > 0 {
            time += String(minute) + " min"
        }
        
        return time
    }
    
    var runtime: String {
        let now = Date()
        let seconds = post.videoDetails.duration as TimeInterval
        let calendar = Calendar.current
        let left = calendar.dateComponents([.hour, .minute, .second],
                                           from: now,
                                           to: Date(timeIntervalSinceNow: seconds))
        
        var time = ""
        if let hour = left.hour, hour > 0 {
            time += String(hour) + ":"
        }
        
        if let minute = left.minute, minute > 0 {
            time += String(minute) + ":"
        }
        
        if let second = left.second, second > 0 {
            time += String(second)
        }
        
        return time
    }
    
    var created: Date {
        return Date(timeIntervalSince1970: Double(post.videoDetails.createdAt))
    }
    
    var year: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: created)
        
        let year = components.year!
        return String(describing: year)
    }
    
    static let dateFormatter = makeDateFormatter()
    private static func makeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
    
    var released: String {
        return VideoViewModel.dateFormatter.string(from: created)
    }
    
    var title: String {
        return post.title
    }
    
    var description: String {
        return post.description
    }
    
    var speakers: [Speaker] {
        return post.speakers
    }
    
    var heroImage: String {
        return post.imageURL.absoluteString
    }
    
    var specificEvent: String? {
        guard let seo = post.videoDetails.seoDescription else {
            return nil
        }
        
        var cleaned = seo.replacingOccurrences(of: "at ", with: "")
        if cleaned.hasPrefix("a ") {
            let index = cleaned.index(cleaned.startIndex, offsetBy: "a ".characters.count)
            cleaned = cleaned.substring(from: index)
        }
        if cleaned.hasSuffix(" video") {
            let suffix = " video"
            let index = cleaned.index(cleaned.endIndex, offsetBy: -suffix.characters.count)
            cleaned = cleaned.substring(to: index)
        }
        return cleaned.trimmed.whitespaceCleaned
    }
    
    var generalEvent: String? {
        guard let specificEvent = specificEvent else {
            return nil
        }
        
        let cleaned = specificEvent.replacingRegexMatches(pattern: "20[0-9]{2}",
                                                          replaceWith: "")
        return cleaned.trimmed.whitespaceCleaned
    }
    
}
