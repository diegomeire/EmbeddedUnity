//
//  EmbeddedUnityViewController.swift
//  EmbededUnity
//
//  Created by Diego Meire on 17/10/20.
//

import Foundation
import UnityNative
import UnityFramework

class EmbeddedUnityViewController: UnityViewController{
    
    override func viewDidLoad() {
        header = _mh_execute_header
        super.viewDidLoad()
        
        super.initializeUnity()
    }
    
    @IBAction func startUnity(){
        super.startUnityWindow()
    }

    @IBAction func callEditor(){
        super.changeScene()
    }
}


