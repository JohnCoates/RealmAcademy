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
        var hasHours: Bool = false
        if let hour = left.hour, hour > 0 {
            hasHours = true
            time += String(hour) + ":"
        }
        
        if let minute = left.minute, minute > 0 {
            time += self.time(fromInt: minute, padded: hasHours) + ":"
        }
        
        if let second = left.second, second > 0 {
            time += self.time(fromInt: second, padded: true)
        }
        
        return time
    }
    
    private func time(fromInt from: Int?, padded: Bool) -> String {
        if let from = from {
            var padding = ""
            var value = String(from)
            if padded, value.characters.count == 1 {
                padding = "0"
            }
            
            return padding + value
        }
        else {
            return "0"
        }
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
        
        let prefixes = ["an ", "at ", "a "]
        var cleaned = seo
        
        for prefix in prefixes where cleaned.lowercased().hasPrefix(prefix) {
            let index = cleaned.index(cleaned.startIndex, offsetBy: prefix.characters.count)
            cleaned = cleaned.substring(from: index)
        }
        
        let suffixes = [" video", " videos"]
        for suffix in suffixes where cleaned.lowercased().hasSuffix(suffix) {
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
    
    var videoURL: URL? {
        let assets = post.videoDetails.mediaAssets
        let formats = ["4k", "1080p", "720p"]
        for format in formats {
            if let index = assets.index(where: { $0.display_name == format && $0.type == "hls_video" }) {
                return assets[index].url
            }
        }
        
        return nil
    }
}
