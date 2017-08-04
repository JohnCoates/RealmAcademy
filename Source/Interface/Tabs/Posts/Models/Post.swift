//
//  Post.swift
//  Realm Academy
//
//  Created by John Coates on 8/3/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation

struct Post {
    let headline: String
    let url: URL
    let imageURL: URL
}

struct PostDetails {
    var speakers: [Speaker]
    let jsonpURL: URL
}

struct Speaker {
    let name: String
    let description: String
    var avatarURL: URL?
    let twitterUsername: String?
}

struct VideoDetails {
    let duration: Double
    let createdAt: Int
    let seoDescription: String?
    let mediaAssets: [MediaAsset]
}

struct MediaAsset {
    let type: String
    let slug: String
    let display_name: String
    let container: String?
    let ext: String
    let width: Int
    let height: Int
    let url: URL
}
