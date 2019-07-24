//
//  ImgDownloader.swift
//  DesktopPapers
//
//  Created by 虫子星球 on 2019/7/14.
//  Copyright © 2019 虫子星球. All rights reserved.
//

import Foundation
import AppKit

class ImgDownloader {
    
    let bingUrl = "https://cn.bing.com"
    private var notifier: IDownloadStatusNotifable?
    
    init() { }
    
    func setDownloadStatusNotifier(notifier: IDownloadStatusNotifable) {
        self.notifier = notifier
    }
    
    func downloadImgAndSetWallpaper() {
        notifier?.updateStatus(status: "Analysing html...")
        let url = URL(string: bingUrl + "/?FORM=BEHPTB&ensearch=1")
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else {
                self.notifier?.updateStatus(status: "Error in downloading html")
                return
            }
            let html: NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
            print(html)
            
            let firstImgUrl: NSString = self.getImgUrl(html: html)
            self.downloadFileAndSetWallpaper(url: firstImgUrl)
        }
        task.resume()
    }
    
    func setWallPaper(filePath: String) throws {
        let image = URL(string: "file://" + filePath)!
        var options = [NSWorkspace.DesktopImageOptionKey: Any]()
        options[.imageScaling] = NSImageScaling.scaleProportionallyUpOrDown.rawValue
        options[.allowClipping] = true
        try NSWorkspace.shared.setDesktopImageURL(image, for: NSScreen.main!, options: options)
    }
    
    func getImgUrl(html: NSString) -> NSString {
        var firstImgUrl: NSString = ""
        
        /// 正则规则字符串
        let pattern = "(?<=\\<link id=\"bgLink\" rel=\"preload\" href=\").*?(?=\"\\sas=\"image\")"
        /// 正则规则
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        /// 进行正则匹配
        if let results = regex?.matches(in: html as String, options: [], range: NSRange(location: 0, length: html.length)), results.count != 0 {
            print("图片url匹配成功")
            //for result in results{
            firstImgUrl = bingUrl + html.substring(with: results[0].range) as NSString
            print("对应图片:",firstImgUrl)
            //}
        }
        
        return firstImgUrl
    }
    
    func getFileName(imgUrl: NSString) -> NSString {
        var fileName: NSString = ""
        
        /// 正则规则字符串
        let pattern = "(?<=th\\?id=).*?.jpg"
        /// 正则规则
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        /// 进行正则匹配
        if let results = regex?.matches(in: imgUrl as String, options: [], range: NSRange(location: 0, length: imgUrl.length)), results.count != 0 {
            //for result in results{
            fileName = imgUrl.substring(with: results[0].range) as NSString
        }
        
        return fileName
    }
    
    func downloadFileAndSetWallpaper(url: NSString) {
        
        //下载地址
        let urlObj = URL(string: url as String)
        //请求
        let request = URLRequest(url: urlObj!)
        
        let session = URLSession.shared
        let fileName: String = self.getFileName(imgUrl: url) as String
        
        notifier?.updateStatus(status: "Downloading...")
        
        //下载任务
        let downloadTask = session.downloadTask(with: request,
                                                completionHandler: { (location:URL?, response:URLResponse?, error:Error?)
                                                    -> Void in
                                                    //输出下载文件原来的存放目录
                                                    print("location:\(String(describing: location))")
                                                    //location位置转换
                                                    let locationPath = location!.path
                                                    //拷贝到用户目录
                                                    let fileManager = FileManager.default
                                                    let dir = NSHomeDirectory() + "/Pictures/BingWallpaper/"
                                                    if !fileManager.fileExists(atPath: dir) {
                                                        try! fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
                                                    }
                                                    
                                                    let documnets:String = dir + fileName
                                                    //创建文件管理器
                                                    
                                                    if !fileManager.fileExists(atPath: documnets) {
                                                        try! fileManager.moveItem(atPath: locationPath, toPath: documnets)
                                                        print("new location:\(documnets)")
                                                        
                                                        self.notifier?.updateStatus(status: "New wallpaper donwloaded")
                                                        
                                                    } else {
                                                        try! fileManager.removeItem(atPath: locationPath)
                                                        print("file already exists:\(documnets)")
                                                        
                                                        self.notifier?.updateStatus(status: "Wallpaper already exists")
                                                        
                                                    }
                                                    
                                                    try! self.setWallPaper(filePath: documnets)
                                                    
                                                    self.notifier?.updateStatus(status: "Wallpaper set successfully")
                                                    
        })
        
        //使用resume方法启动任务
        downloadTask.resume()
    }
    
}
