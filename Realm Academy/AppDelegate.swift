//
//  AppDelegate.swift
//  Realm Academy
//
//  Created by John Coates on 8/3/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import UIKit
import TVMLKitchen

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var loader: VideoPageLoader?
    var videoDetailsLoader: VideoDetailsLoader?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Kitchen.prepare(Cookbook(launchOptions: launchOptions))
        DispatchQueue.main.async {
            Kitchen.window.alpha = 1
            Kitchen.serve(xmlString: self.xml, redirectWindow: self.window!, animatedWindowTransition: true)
        }
        
        loader = VideoPageLoader(url: URL(string: "https://academy.realm.io/posts/360-andev-2017-huyen-tue-dao-christina-lee-kotlintown/")!)
        
        if let loaded = loader?.load(), loaded, let details = loader?.postDetails {
            videoDetailsLoader = VideoDetailsLoader(jsonp: details.jsonpURL)
            videoDetailsLoader?.load()
            
        }
        
        return true
    }
    
    var xml: String {
        let path = Bundle.main.path(forResource: "Products", ofType: "xml")!
        return try! String(contentsOfFile: path)
//        return try! NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

