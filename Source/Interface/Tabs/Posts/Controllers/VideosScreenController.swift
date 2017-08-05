//
//  VideosScreenController.swift
//  Realm Academy
//
//  Created by John Coates on 8/4/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import UIKit
import TVMLKitchen

class VideosScreenController: VideoPageLoaderDelegate, ListingsPageLoaderDelegate {
    
    var javascript: String {
        let path = Bundle.main.path(forResource: "Video", ofType: "js")!
        return try! String(contentsOfFile: path)
    }
    
    var xml: String {
        let path = Bundle.main.path(forResource: "Video", ofType: "xml")!
        return try! String(contentsOfFile: path)
    }
    
    lazy var listingsLoader: ListingsPageLoader = {
        let loader = ListingsPageLoader(delegate: self, page: 1)
        return loader
    }()
    
    init() {
        listingsLoader.load()
    }
    
    func show(redirectWindow window: UIWindow) {
        let cookbook = Cookbook(launchOptions: [:])
        cookbook.evaluateAppJavaScriptInContext = self.executeIntialJavascript
        Kitchen.prepare(cookbook)
        
        // Stops responding to user input if done immediately
        DispatchQueue.main.async {
            Kitchen.window.alpha = 1
            Kitchen.serve(xmlString: self.xml,
                          redirectWindow: window, animatedWindowTransition: true)
        }
    }
    
    private func executeIntialJavascript(controller: TVApplicationController,
                                         context: JSContext) {
        print("evaluating initial javascript")
        let consoleLog: @convention(block) (String) -> Void = { message in
            print("native console logging!")
            print(message)
        }
        
        context.setObject(consoleLog,
                          forKeyedSubscript: "debug" as NSString)
        
        let selectVideo: @convention(block) (String) -> Void = { videoID in
            print("selected video: \(videoID)")
            self.selectedPost(id: Int(videoID)!)
        }
        context.setObject(selectVideo,
                          forKeyedSubscript: "selectVideo" as NSString)
        
        let playVideo: @convention(block) () -> Void = {
            print("play video!")
        }
        context.setObject(playVideo, forKeyedSubscript: "playVideo" as NSString)
        
        context.evaluateScript(javascript)
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
        let id = posts.count
        posts.append(post)
        
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
