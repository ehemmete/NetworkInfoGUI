//
//  AppDelegate.swift
//  NetworkInfoGUI
//
//  Created by Eric.Hemmeter on 7/24/19.
//  Copyright © 2019 Sneakypockets. All rights reserved.
//

import Cocoa
import Network

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var aboutWindow: NSWindow!
    @IBOutlet weak var outputLabel: NSTextField!
    
    @IBAction func showAboutWindow(_ sender: NSMenuItem) {
        aboutWindow.setIsVisible(true)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        window.isOpaque = false
        window.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.4)
        window.setIsVisible(true)
        
        let networkInfo = try? NetworkFunctions.updateNetworkInfo()?.joined(separator: "\n")
        outputLabel.stringValue = networkInfo!
        
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                let networkInfo = try? NetworkFunctions.updateNetworkInfo()?.joined(separator: "\n")
                DispatchQueue.main.async {
                    self.outputLabel.stringValue = networkInfo!
                    
                }
            }
            
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
    }
    
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    

}

