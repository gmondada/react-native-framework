//
//  RNXViewController.swift
//  swi mit
//
//  Created by Gabriele Mondada on January 8, 2018.
//  Copyright © 2018 Switcher Inc.
//  This software is part of the SWIRL project. See the COPYRIGHT-SWIRL file.
//

import Foundation
import UIKit
import React

public class RNXViewController: UIViewController {

    private let reactView: RCTRootView
    private var didAppearOnce = false
    private var layoutInfo = LayoutInfo()
    private var temporary = true
    private var visible = false

    var hideTopSafeAreaToReactNative = false

    public var backgroundColor: UIColor? {
        didSet {
            if isViewLoaded {
                reactView.backgroundColor = backgroundColor
            }
        }
    }

    public init(bridge: RCTBridge, moduleName: String, props: [String: Any]? = nil) {
        var initialProperties: [String: Any] = props ?? [:]
        initialProperties["rnx"] = layoutInfo.asProperties(temporary: temporary)
        reactView = RCTRootView(bridge: bridge, moduleName: moduleName, initialProperties: initialProperties)
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bridgeDidLoad),
                                               name: NSNotification.Name.RCTJavaScriptDidLoad,
                                               object: bridge)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        reactView.translatesAutoresizingMaskIntoConstraints = false
        reactView.backgroundColor = backgroundColor
        view.addSubview(reactView)

        if hideTopSafeAreaToReactNative {
            reactView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            reactView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        reactView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        reactView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        reactView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayoutInfo()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didAppearOnce = true
        visible = true
        updateLayoutInfo()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visible = false
        updateLayoutInfo()
    }

    @objc private func bridgeDidLoad() {
        assert(Thread.isMainThread)
        updateLayoutInfo()
    }

    private func updateLayoutInfo() {
        if didAppearOnce && reactView.subviews.count > 0 && !reactView.bridge.isLoading {
            var safeAreaInsets = view.safeAreaInsets
            if hideTopSafeAreaToReactNative {
                safeAreaInsets.top = 0
            }
            let newLayoutInfo = LayoutInfo(size: view.bounds.size,
                                           safeAreaInsets: safeAreaInsets,
                                           visible: visible)
            if newLayoutInfo != layoutInfo || temporary {
                layoutInfo = newLayoutInfo
                temporary = false
                // be sure to finish current layout pass before inform JS
                DispatchQueue.main.async {
                    // be sure layoutInfo hasn't changed since this closure has been enqueued
                    if self.layoutInfo == newLayoutInfo {
                        self.sendLayoutInfoToJS(layoutInfo: newLayoutInfo)
                    }
                }
            }
        }
    }

    private func sendLayoutInfoToJS(layoutInfo: LayoutInfo) {
        var props = self.reactView.appProperties ?? [:]
        props["rnx"] = layoutInfo.asProperties(temporary: false)
        self.reactView.appProperties = props
    }
}

struct LayoutInfo : Equatable {

    var size: CGSize = .zero
    var safeAreaInsets: UIEdgeInsets = .zero
    var visible = false

    func asProperties(temporary: Bool) -> [String : Any] {
        return [
            "layout" : [
                "size" : [
                    "width" : size.width,
                    "height" : size.height,
                ],
                "safeArea" : [
                    "insets" : [
                        "top" : safeAreaInsets.top,
                        "bottom" : safeAreaInsets.bottom,
                        "left" : safeAreaInsets.left,
                        "right" : safeAreaInsets.right,
                    ]
                ],
                "temporary": temporary,
                "visible": visible
            ] as [String : Any]
        ]
    }
}
