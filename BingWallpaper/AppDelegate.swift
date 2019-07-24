//
//  AppDelegate.swift
//  BingWallpaper
//
//  Created by 虫子星球 on 2019/7/19.
//  Copyright © 2019 虫子星球. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let downloader = ImgDownloader()
    let downloadStatusNotifier = DownloadStatusNotifier()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("hpc26_2x"))
        }
        constructMenu()
        
        _ = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(AppDelegate.downloadWallpaper), userInfo: nil, repeats: false)
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        let menuItem = NSMenuItem(title: "Ready to download", action: nil, keyEquivalent: "")
        downloadStatusNotifier.setToBeNotify(menu: menuItem)
        downloader.setDownloadStatusNotifier(notifier: downloadStatusNotifier)
        
        menu.addItem(menuItem)
        menu.addItem(NSMenuItem(title: "Download Manually", action: #selector(AppDelegate.downloadWallpaper(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Show in finder", action: #selector(AppDelegate.openWallpaperDir(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        
        statusItem.menu = menu
    }
    
    @objc func downloadWallpaper(_ sender: Any) {
        downloader.downloadImgAndSetWallpaper()
    }
    
    @objc func openWallpaperDir(_ sender: Any) {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: NSHomeDirectory() + "/Pictures/BingWallpaper")
    }

}

