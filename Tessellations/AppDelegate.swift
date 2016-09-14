//
//  AppDelegate.swift
//  Tessellations
//
//  Created by James Linnell on 6/23/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Singleton.shared.load()
        
        self.generateAllThumbnailImages()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        Singleton.shared.syncProgress()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Generate launch screen bg, for dev purposes
        /*
        for (i, palette) in Singleton.shared.allPalettes.enumerate() {
            Singleton.shared.setAppPalette(i)
            
            let size = CGSize(width: 2048, height: 2048)
            let skView = SKView(frame: CGRect(origin: CGPointZero, size: size))
            let scene = SquareTriangleScene(size: size, boardWidth: 40, boardHeight: 40, margins: false)
            skView.ignoresSiblingOrder = true
            skView.opaque = false
            scene.scaleMode = .AspectFit
            skView.presentScene(scene)
            
            self.window!.addSubview(skView)
            self.window!.sendSubviewToBack(skView)
            
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
            skView.drawViewHierarchyInRect(skView.bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let filePath = paths.first?.stringByAppendingString("Background-\(palette.name).png")
            UIImagePNGRepresentation(image)?.writeToFile(filePath!, atomically: true)
        }
        */
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func generateAllThumbnailImages() {
        let fullPalette = Singleton.shared.palette
        let clear = UIColor.clearColor()
        let piecePalette = ScenePalette(pipeEnabled: clear, pipeDisabled: clear, piece: fullPalette.piece, background: clear, buttonBackground: clear, rootMarker: clear, name: "piecePalette")
        let pipePalette = ScenePalette(pipeEnabled: fullPalette.pipeEnabled, pipeDisabled: clear, piece: clear, background: clear, buttonBackground: clear, rootMarker: clear, name: "pipePalette")
        let rootPalette = ScenePalette(pipeEnabled: clear, pipeDisabled: clear, piece: clear, background: clear, buttonBackground: clear, rootMarker: fullPalette.rootMarker, name: "rootPalette")
        
        // Set and generate each layer
        Singleton.shared.setOverridePalette(piecePalette)
        pieceThumbnailImages = self.generateThumbnails()
        
        Singleton.shared.setOverridePalette(pipePalette)
        pipeThumbnailImages = self.generateThumbnails()
        
        Singleton.shared.setOverridePalette(rootPalette)
        rootThumbnailImages = self.generateThumbnails()
        
        // Reset app-wide palette
        Singleton.shared.setOverridePalette(nil)
        
    }
    
    func generateThumbnails() -> [String: UIImage] {
        let size = CGSize(width: window!.frame.width/2.0, height: window!.frame.width/2.0)
//        let size = CGSize(width: 1024, height: 1024)
        var ret: [String: UIImage] = [:]
        
        let skView = SKView(frame: CGRect(origin: CGPointZero, size: size))
        skView.ignoresSiblingOrder = true
        skView.opaque = false
        
        for classString in sceneClassStrings {
            if let theClass = NSClassFromString(classString) as? AbstractGameBoardScene.Type {
                
                let scene = theClass.thumbnailScene(size)!
                scene.scaleMode = .AspectFit
                skView.presentScene(scene)

                let image = UIImage(CGImage: skView.textureFromNode(scene)!.CGImage())
                
                ret[classString] = image.imageWithRenderingMode(.AlwaysTemplate)
                
                skView.presentScene(nil)
            }
        }
        
        return ret
    }

}

