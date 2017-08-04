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
        
        Kitchen.window.alpha = 1
        Kitchen.serve(xmlString: xml,
                      redirectWindow: window, animatedWindowTransition: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { 
            Kitchen.appController.evaluate(inJavaScriptContext: self.addVideo,
                                           completion: nil)
        }
//        loadPage()
    }
    
    
    lazy var pageLoader: VideoPageLoader = {
        let url = URL(string: "https://academy.realm.io/posts/360-andev-2017-huyen-tue-dao-christina-lee-kotlintown/")!
        return VideoPageLoader(url: url, delegate: self)
    }()
    
    var videoDetailsLoader: VideoDetailsLoader?
    
    func loadPage() {
//        pageLoader.load()
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
        print("loaded: \(post)")
        posts.append(post)
    }

}
