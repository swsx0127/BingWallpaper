//
//  DownloadStatusNotify.swift
//  BingWallpaper
//
//  Created by 虫子星球 on 2019/7/19.
//  Copyright © 2019 虫子星球. All rights reserved.
//

import Foundation
import Cocoa

protocol IDownloadStatusNotifable {
    func updateStatus(status: String)
}

class DownloadStatusNotifier:IDownloadStatusNotifable {
    
    private var menu: NSMenuItem?
    
    init() {}
    
    func setToBeNotify(menu: NSMenuItem) {
        self.menu = menu
    }
    
    func updateStatus(status: String) {
        self.menu!.title = status
    }
    
    
}
