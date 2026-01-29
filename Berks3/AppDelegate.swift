//
//  AppDelegate.swift
//  Berks3
//
//  Created by Jason Foster on 15/10/2020.
//  Copyright © 2020 Jason Foster. All rights reserved.
//


import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    @IBAction func openHelp(_ sender: Any) {
        if let url = URL(string: "https://designspin.github.io/berks3/") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
}
