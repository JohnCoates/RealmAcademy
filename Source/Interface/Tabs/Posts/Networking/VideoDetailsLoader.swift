//
//  VideoDetailsLoader.swift
//  Realm Academy
//
//  Created by John Coates on 8/4/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation

enum VideoDetailsResult {
    case success(details: VideoDetails)
    case error(message: String)
}

protocol VideoDetailsLoaderDelegate: class {
    func videoDetailsLoader(_ loader: VideoDetailsLoader, result: VideoDetailsResult)
}

class VideoDetailsLoader {
    
    weak var delegate: VideoDetailsLoaderDelegate?
    
    let url: URL
    
    init(jsonp: URL, delegate: VideoDetailsLoaderDelegate) {
        url = jsonp
        self.delegate = delegate
    }
    
    func load() {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Couldn't load url: \(error)")
            }
            
            if let data = data {
                self.ingest(data: data)
            }
        }
        task.resume()
    }
    
    private func ingest(data: Data) {
        let root = object(fromJSONP: data)
        ingest(root: root)
        
    }
    
    private func ingest(root: [String: Any]) {
        let media: [String: Any] = Critical.cast(root["media"])
        
        ingest(media: media)
    }
    
    private func ingest(media: [String: Any]) {
        let assets: [[String: Any]] = Critical.cast(media["assets"])
        let mediaAssets = ingest(assets: assets)
        
        guard
        let duration = media["duration"] as? Double,
        let createdAt = media["createdAt"] as? Int else {
                return
        }
        
        let details = VideoDetails(duration: duration,
                                   createdAt: createdAt,
                                   seoDescription: media["seoDescription"] as? String,
                                   mediaAssets: mediaAssets)
        
        delegate?.videoDetailsLoader(self, result: .success(details: details))
    }
    
    private func ingest(assets: [[String: Any]]) -> [MediaAsset] {
        var mediaAssets = [MediaAsset]()
        for asset in assets {
            if let mediaAsset = self.asset(from: asset) {
                mediaAssets.append(mediaAsset)
            }
        }
        
        return mediaAssets
    }
    
    private func asset(from: [String: Any]) -> MediaAsset? {
        guard
        let type = from["type"] as? String,
        let slug = from["slug"] as? String,
        let display_name = from["display_name"] as? String,
        let ext = from["ext"] as? String,
        let width = from["width"] as? Int,
        let height = from["height"] as? Int,
        let urlString = from["url"] as? String,
        let url = URL(string: urlString) else {
                return nil
        }
        
        return MediaAsset(type: type,
                          slug: slug,
                          display_name: display_name,
                          container: from["container"] as? String,
                          ext: ext,
                          width: width,
                          height: height,
                          url: url)
        
    }
    
    private func object(fromJSONP data: Data) -> [String: Any] {
        let json = self.json(fromJSONP: data)
        
        guard let serialized = try? JSONSerialization.jsonObject(with: json,
                                                                 options: []) else {
            fatalError("Failed to get object from json!")
        }
        
        let dictionary: [String: Any] = Critical.cast(serialized)
        
        return dictionary
    }
    
    private func json(fromJSONP data: Data) -> Data {
        guard let string = String.init(data: data, encoding: .utf8) else {
            fatalError("Couldn't convert JSON data to string")
        }
        
        let start = " = {"
        let end = "};"
        guard let startRange = string.range(of: start),
            let endRange = string.range(of: end) else {
                fatalError("Failed to find start/end ranges in JSONP")
        }
        
        let startIndex = string.index(before: startRange.upperBound)
        let endIndex = string.index(before: endRange.upperBound)
        
        let result = string.substring(with: startIndex..<endIndex)
        
        guard let finalData = result.data(using: .utf8) else {
            fatalError("Failed to convert string \(result) to data")
        }
        
        return finalData
    }
    
}
