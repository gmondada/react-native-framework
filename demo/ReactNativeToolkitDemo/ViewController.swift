//
//  ViewController.swift
//  ReactNativeToolkitDemo
//
//  Created by Gabriele Mondada on 29.09.23.
//

import UIKit
import React

class ViewController: RNXViewController {

    init() {
        let url = Bundle.main.url(forResource: "main", withExtension: "jsbundle")
        // let url = URL(string: "http://localhost:8081/index.bundle?platform=ios")!
        let bridge = RCTBridge(bundleURL: url, moduleProvider: nil)
        super.init(bridge: bridge!, moduleName: "dummyapp")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
