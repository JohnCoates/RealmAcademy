//
//  VideosScreenController.swift
//  Realm Academy
//
//  Created by John Coates on 8/4/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import UIKit
import TVMLKitchen

class VideosScreenController: VideoPageLoaderDelegate {
    
    var javascript: String {
        let path = Bundle.main.path(forResource: "Video", ofType: "js")!
        return try! String(contentsOfFile: path)
    }
    
    var xml: String {
        let path = Bundle.main.path(forResource: "Video", ofType: "xml")!
        return try! String(contentsOfFile: path)
    }
    
    init() {
        
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
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { 
            Kitchen.appController.evaluate(inJavaScriptContext: self.addVideo,
                                           completion: nil)
        }
        loadPage()
    }
    
    
    lazy var pageLoader: VideoPageLoader = {
        let url = URL(string: "https://academy.realm.io/posts/360-andev-2017-huyen-tue-dao-christina-lee-kotlintown/")!
        return VideoPageLoader(url: url, delegate: self)
    }()
    
    var videoDetailsLoader: VideoDetailsLoader?
    
    func loadPage() {
        pageLoader.load()
    }
    
    private func executeIntialJavascript(controller: TVApplicationController,
                                         context: JSContext) {
        print("evaluating initial javascript")
        let consoleLog: @convention(block) (String) -> Void = { message in
            print("native console logging!")
            print(message)
        }
        let block = unsafeBitCast(consoleLog, to: AnyObject.self)
        context.setObject(block,
                          forKeyedSubscript: "debug" as NSString)
        
        
        context.evaluateScript(javascript)
    }
    
    private func addVideo(context: JSContext) {
        print("adding video!")
        context.evaluateScript("addVideo()")
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
            print("adding speaker: \(speaker.name)")
        }
        
        bridge.set(id: "heroImage", attribute: "src", value: viewModel.heroImage)
        bridge.callFunction(name: "clearEvent")
        
        if let general = viewModel.generalEvent, let specific = viewModel.specificEvent {
//            print("setting event to: \(general)")
            bridge.setEvent(general: general, specific: specific)
        }
        print("image: \(viewModel.heroImage)")
        
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
        viewModel = VideoViewModel(post: post)
        Kitchen.appController.evaluate(inJavaScriptContext: self.hydrateView,
                                       completion: nil)
        
        print("loaded: \(post)")
        posts.append(post)
    }

}

private struct ContextBridge {
    
    let context: JSContext
    
    init(context: JSContext) {
        self.context = context
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
