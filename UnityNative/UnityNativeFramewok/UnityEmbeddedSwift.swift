//
//  UnityEmbeddedSwift.swift
//  native_app
//
//  Created by NSWell on 2019/12/19.
//  Copyright © 2019 WEACW. All rights reserved.
//

//
//  Created by Simon Tysland on 19/08/2019.
//  Copyright © 2019 Simon Tysland. All rights reserved.
//

import Foundation
import UnityFramework

public class UnityEmbeddedSwift: UIResponder, UIApplicationDelegate, UnityFrameworkListener {
    
    public struct UnityMessage {
        let objectName : String?
        let methodName : String?
        let messageBody : String?
    }
    
    public static var instance : UnityEmbeddedSwift!
    public var ufw : UnityFramework!
    public static var hostMainWindow : UIWindow! //Window to return to when exitting Unity window
    public static var launchOpts : [UIApplication.LaunchOptionsKey: Any]?
    
    public static var cachedMessages = [UnityMessage]()
    public static var header: MachHeader!
    
    //Static functions that can be called from other scripts
    
    //Add this func to push and display unity view -- Sorry my englsih no good
    public static func getUnityRootview()->UIViewController!{
        return instance.ufw.appController()?.rootViewController
    }
    
    
    public static func setHostMainWindow(_ hostMainWindow : UIWindow?) {
        UnityEmbeddedSwift.hostMainWindow = hostMainWindow
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
    }
    
    public static func setLaunchinOptions(_ launchingOptions :  [UIApplication.LaunchOptionsKey: Any]?) {
        UnityEmbeddedSwift.launchOpts = launchingOptions
    }
    
    public static func showUnity() {
        if(UnityEmbeddedSwift.instance == nil || UnityEmbeddedSwift.instance.unityIsInitialized() == false) {
            UnityEmbeddedSwift().initUnityWindow()
        }
        else {
            UnityEmbeddedSwift.instance.showUnityWindow()
        }
    }
    
    public static func initUnity(){
        if(UnityEmbeddedSwift.instance == nil || UnityEmbeddedSwift.instance.unityIsInitialized() == false) {
            UnityEmbeddedSwift().initUnityWindow()
        }
    }
    
    
    public static func hideUnity() {
        UnityEmbeddedSwift.instance?.hideUnityWindow()
    }
    
    public static func unloadUnity() {
        UnityEmbeddedSwift.instance?.unloadUnityWindow()
    }
    
    public static func sendUnityMessage(_ objectName : String, methodName : String, message : String) {
        let msg : UnityMessage = UnityMessage(objectName: objectName, methodName: methodName, messageBody: message)
        
        //Send the message right away if Unity is initialized, else cache it
        if(UnityEmbeddedSwift.instance != nil && UnityEmbeddedSwift.instance.unityIsInitialized()) {
            UnityEmbeddedSwift.instance.ufw.sendMessageToGO(withName: msg.objectName, functionName: msg.methodName, message: msg.messageBody)
        }
        else {
            UnityEmbeddedSwift.cachedMessages.append(msg)
        }
    }
    
    //Callback from UnityFrameworkListener
    public func unityDidUnload(_ notification: Notification!) {
        ufw.appController()?.rootViewController.dismiss(animated: true, completion: nil)
        ufw.unregisterFrameworkListener(self)
        ufw = nil
        // UnityEmbeddedSwift.hostMainWindow?.makeKeyAndVisible()
    }
    
    public func unityDidQuit(_ notification: Notification!) {
        ufw.appController()?.rootViewController.dismiss(animated: true, completion: nil)
        ufw.unregisterFrameworkListener(self)
        ufw = nil
      //  UnityEmbeddedSwift.hostMainWindow?.makeKeyAndVisible()
    }

    
    //Private functions called within the class
    public func unityIsInitialized() -> Bool {
        return ufw != nil && (ufw.appController() != nil)
    }
    
    public func initUnityWindow() {
        if unityIsInitialized() {
            showUnityWindow()
            return
        }
        ufw = UnityFrameworkLoad(header: UnityEmbeddedSwift.header)!
        ufw.setDataBundleId("com.unity3d.framework")
        ufw.register(self)
//        NSClassFromString("FrameworkLibAPI")?.registerAPIforNativeCalls(self)
        
    //    ufw.appController()!.quitHandler = { () in print("test") }
        
      //  [[self ufw] appController].quitHandler = ^(){ NSLog(@"AppController.quitHandler called"); };
        ufw.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts: UnityEmbeddedSwift.launchOpts)
        
        sendUnityMessageToGameObject()
        
        UnityEmbeddedSwift.instance = self
        
        
    }
    
    public func showUnityWindow() {
        if unityIsInitialized() {
            ufw.showUnityWindow()
            sendUnityMessageToGameObject()
        }
    }
    
    public func hideUnityWindow() {
        if(UnityEmbeddedSwift.hostMainWindow == nil) {
            print("WARNING: hostMainWindow is nil! Cannot switch from Unity window to previous window")
        }
        else {
            UnityEmbeddedSwift.hostMainWindow?.makeKeyAndVisible()
        }
    }
    
    public func unloadUnityWindow() {
        if unityIsInitialized() {
            UnityEmbeddedSwift.cachedMessages.removeAll()
            ufw.unloadApplication()
        }
    }
    
    public func sendUnityMessageToGameObject() {
        if(UnityEmbeddedSwift.cachedMessages.count >= 0 && unityIsInitialized())
        {
            for msg in UnityEmbeddedSwift.cachedMessages {
                ufw.sendMessageToGO(withName: msg.objectName, functionName: msg.methodName, message: msg.messageBody)
            }
            
            UnityEmbeddedSwift.cachedMessages.removeAll()
        }
    }
    
    public func UnityFrameworkLoad(header: MachHeader) -> UnityFramework? {
        let bundlePath: String = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
        
        let bundle = Bundle(path: bundlePath )
        if bundle?.isLoaded == false {
            bundle?.load()
        }
        
        //_mh_execute_header
        
        let ufw = bundle?.principalClass?.getInstance()
        if ufw?.appController() == nil {
            // unity is not initialized
            //            ufw?.executeHeader = &mh_execute_header
            
            let machineHeader = UnsafeMutablePointer<MachHeader>.allocate(capacity: 1)
            machineHeader.pointee = header
            
            ufw!.setExecuteHeader(machineHeader)
        }
        return ufw
    }
}
