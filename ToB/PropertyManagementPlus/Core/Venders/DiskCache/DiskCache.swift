//
//  DiskCache.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/1/8.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

open class DiskCache: NSObject {
    var cacheTerminatePath = "/Library/Caches/proData/"
    /**
     *  获取沙盒路径
     */
    open func cachePath(proName: String)->String
    {
        let cachePath = NSHomeDirectory() + cacheTerminatePath + proName+"/"
        let fileManager: FileManager = FileManager.default
        //判断当前路径是否存在
        if !fileManager.fileExists(atPath: cachePath, isDirectory: nil)
        {
            do {
                try fileManager.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError
            {
                print("存储路径错误-->\(error)")
            }
        }
        return cachePath
    }
    
    open func deleteCachePath(proName: String) -> Bool {
        let cachePath = NSHomeDirectory() + cacheTerminatePath + proName+"/"
        let fileManager: FileManager = FileManager.default
        //判断当前路径是否存在
        if !fileManager.fileExists(atPath: cachePath, isDirectory: nil) {
            do {
                try fileManager.removeItem(atPath: cachePath)
            } catch let error as NSError
            {
                print("删除文件路径错误-->\(error)")
            }
        }
        return false
    }
    //存储缓存
    open func saveDataToCache(proName:String,Data:NSData) -> ()
    {
        let pathStr = self.cachePath(proName: proName)+"\(proName).png"
        print("存路径--->\(pathStr)")
        Data.write(toFile: pathStr, atomically: true)
    }
    
    //存储缓存
    open func saveDataToCache(proName: String, fileName: String, Data: NSData) -> ()
    {
        let pathStr = self.cachePath(proName: proName)+"\(fileName).png"
        print("存路径--->\(pathStr)")
        Data.write(toFile: pathStr, atomically: true)
    }
    
    //取缓存
    open func getDataFromCache(proName:String) -> UIImage
    {
        let pathStr = self.cachePath(proName: proName)+"\(proName).png"
        print("路径--->\(pathStr)")
        let data:NSData = NSData(contentsOfFile: pathStr)!
        
        return UIImage(data: data as Data)!
    }
}
