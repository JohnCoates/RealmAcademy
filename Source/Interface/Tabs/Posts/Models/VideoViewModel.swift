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
    var created: Date {
        return Date(timeIntervalSince1970: Double(post.videoDetails.createdAt))
    }
    
    var year: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: created)
        
        let year = components.year!
        return String(describing: year)
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
    
}
