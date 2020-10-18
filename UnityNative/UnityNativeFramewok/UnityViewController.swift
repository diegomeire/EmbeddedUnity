//
//  ViewController.swift
//  native_app
//
//  Created by NSWell on 2019/12/19.
//  Copyright © 2019 WEACW. All rights reserved.
//

import UIKit
import UnityFramework

open class UnityViewController: UIViewController {

    public var header: MachHeader?
    
    public func initializeUnity(){
        UnityEmbeddedSwift.header = header!
        UnityEmbeddedSwift.initUnity()
    }
    
    public func startUnityWindow(){
        UnityEmbeddedSwift.showUnity()
        let gameVC = UnityEmbeddedSwift.getUnityRootview()
        self.present(gameVC!, animated: true, completion: nil)
    }

    public func unloadUnity(){
        UnityEmbeddedSwift.unloadUnity()
    }
 
    public func changeScene(){
        UnityEmbeddedSwift.sendUnityMessage("Controller", methodName: "CallScene", message: "Scene2")
    }
}

