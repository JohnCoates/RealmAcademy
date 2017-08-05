//
//  VideosScreenController.swift
//  Realm Academy
//
//  Created by John Coates on 8/4/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import UIKit
import TVMLKitchen
import AVKit

class VideosScreenController: VideoPageLoaderDelegate, ListingsPageLoaderDelegate {
    
    var javascript: String {
        let path = Bundle.main.path(forResource: "Video", ofType: "js")!
        return try! String(contentsOfFile: path)
    }
    
    var xml: String {
        let path = Bundle.main.path(forResource: "Video", ofType: "xml")!
        return try! String(contentsOfFile: path)
    }
    
    lazy var listingsLoader: PostsLoader = {
        let loader = PostsLoader(delegate: self)
        return loader
    }()
    
    init() {
        listingsLoader.load()
    }
    
    func show() {
        let cookbook = Cookbook(launchOptions: [:])
        cookbook.evaluateAppJavaScriptInContext = self.executeIntialJavascript
        Kitchen.prepare(cookbook)
        showLoading()
    }
    
    
    private func showLoading() {
        Kitchen.serve(recipe: LoadingRecipe(message: "Loading Content"))
    }
    
    private func showVideoScreen() {
        
        let show: (JSContext) -> Void =  { context in
            context.evaluateScript("navigationDocument.clear()")

            DispatchQueue.main.async {
                self.isShowingLoadingScreen = false
                Kitchen.dismissModal()
                Kitchen.serve(xmlString: self.xml)
                DispatchQueue.main.async {
                    self.canAddVideos = true
                    self.addQueuedVideosToShelf()
                }
                
            }
        }
        Kitchen.appController.evaluate(inJavaScriptContext: show, completion: nil)
    }
    
    private func executeIntialJavascript(controller: TVApplicationController,
                                         context: JSContext) {
        let selectVideo: @convention(block) (String) -> Void = { videoID in
            self.selectedPost(id: Int(videoID)!)
        }
        context.setObject(selectVideo,
                          forKeyedSubscript: "selectVideo" as NSString)
        
        let playVideo: @convention(block) () -> Void = {
            self.playVideo()
            
        }
        context.setObject(playVideo, forKeyedSubscript: "playVideo" as NSString)
        
        let viewDescription: @convention(block) () -> Void = {
            print("view description!")
            self.viewDescription()
        }
        context.setObject(viewDescription,
                          forKeyedSubscript: "viewDescription" as NSString)
        
        context.evaluateScript(javascript)
    }
    
    private func playVideo() {
        guard let videoURL = viewModel?.videoURL else {
            return
        }
        
        let vc = AVPlayerViewController()
        vc.player = AVPlayer(url: videoURL)
        vc.player?.play()
        DispatchQueue.main.async {
            Kitchen.navigationController.pushViewController(vc, animated: true)
        }
    }
    
    private func viewDescription() {
        guard let viewModel = viewModel else {
            return
        }
        
        Kitchen.serve(recipe: AlertRecipe(
            title: viewModel.title,
            description: viewModel.description)
        )
    }
    
    var viewModel: VideoViewModel?
    
    private func hydrateView(context: JSContext) {
        let bridge = ContextBridge(context: context)
        bridge.set(id: "title", content: "Update Test")
        
        guard let viewModel = viewModel else {
            return
        }
        bridge.set(id: "headerTime", content: viewModel.headerTime)
        bridge.set(id: "headerYear", content: viewModel.year)
        bridge.set(id: "title", content: viewModel.title)
        bridge.set(id: "description", content: viewModel.description)
        bridge.set(id: "infoRuntime", content: viewModel.runtime)
        bridge.set(id: "infoReleased", content: viewModel.released)
        
        bridge.removeSpeakers()
        
        for speaker in viewModel.speakers {
            bridge.addSpeaker(name: speaker.name,
                              imageURL: speaker.avatarURL?.absoluteString)
        }
        
        bridge.set(id: "heroImage", attribute: "src", value: viewModel.heroImage)
        bridge.callFunction(name: "clearEvent")
        
        if let general = viewModel.generalEvent, let specific = viewModel.specificEvent {
            bridge.setEvent(general: general, specific: specific)
        }
    }
    
    // MARK: - Page Loader Delegate
    
    var posts = [PostDetails]()
    var canAddVideos = false
    var isShowingLoadingScreen = true
    var addQueue = [PostDetails]()
    
    func videoPageLoader(_ loader: VideoPageLoader, result: VideoPageResult) {
        switch result {
        case let .success(post):
            DispatchQueue.main.async {
                self.add(post: post)
            }
            
        case let .error(message):
            print("error loading: \(message)")
        }
    }
    
    private func add(post: PostDetails) {
        posts.append(post)
        if (!canAddVideos) {
            addQueue.append(post)
            
        } else {
            addVideoToShelf(post: post)
        }
        
        if isShowingLoadingScreen {
            showVideoScreen()
        }
    }
    
    private func addQueuedVideosToShelf() {
        for post in addQueue {
            addVideoToShelf(post: post)
        }
        addQueue.removeAll()
        
        if posts.count > 0 {
            selectedPost(id: 0)
        }
    }
    
    private func addVideoToShelf(post: PostDetails) {
        guard let id = posts.index(where: { $0.title == post.title }) else {
            fatalError("Couldn't find video ID")
        }
        
        let evaluate: (JSContext) -> Void = { context in
            let bridge = ContextBridge(context: context)
            bridge.addVideo(id: id, imageURL: post.imageURL, title: post.title)
        }
        
        Kitchen.appController.evaluate(inJavaScriptContext: evaluate,
                                       completion: nil)
    }
    
    private func selectedPost(id: Int) {
        let post = posts[id]
        viewModel = VideoViewModel(post: post)
        Kitchen.appController.evaluate(inJavaScriptContext: self.hydrateView,
                                       completion: nil)
    }
    
    // MARK: - Listings Delegate
    
    func listingPageLoader(_ loader: ListingsPageLoader, result: ListingsPageResult) {
        switch result {
        case let .success(posts):
            print("loaded posts: \(posts)")
            loadVideoDetails(for: posts)
        case let .error(message):
            print("error : \(message)")
        }
    }
    
    private var detailsLoaders = [VideoPageLoader]()
    private func loadVideoDetails(for posts: [Post]) {
        for post in posts {
            let loader = VideoPageLoader(url: post.url, delegate: self)
            detailsLoaders.append(loader)
            loader.load()
        }
    }

}

private struct ContextBridge {
    
    let context: JSContext
    
    init(context: JSContext) {
        self.context = context
    }
    
    func addVideo(id: Int, imageURL: URL, title: String) {
        let url = imageURL.absoluteString
        let evaluate = "addVideo(\(id), \"\(url)\", \"\(title)\")"
        context.evaluateScript(evaluate)
    }
    
    func set(id: String, content: String) {
        context.evaluateScript("setContent(\"\(id)\", \"\(content)\")")
    }
    
    func set(id: String, attribute: String, value: String) {
        context.evaluateScript("setAttributeFor(\"\(id)\", \"\(attribute)\", \"\(value)\")")
    }
    
    func removeChildren(forID id: String) {
        context.evaluateScript("removeChildrenForId(\"\(id)\")")
    }
    
    func addSpeaker(name: String, imageURL: String?) {
        var script = "addSpeaker(\"\(name)\""
        if let imageURL = imageURL {
            script += ", \"\(imageURL)\""
        }
        script += ")"
        context.evaluateScript(script)
    }
    
    func setEvent(general: String, specific: String) {
        context.evaluateScript("setEvent(\"\(general)\", \"\(specific)\")")
    }
    
    func removeSpeakers() {
        context.evaluateScript("removeSpeakers()")
    }
    
    func callFunction(name: String) {
        context.evaluateScript("\(name)()")
    }
    
}
