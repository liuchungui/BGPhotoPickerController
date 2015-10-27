//
//  BGPhotoManager.swift
//  BGPhotoPickerControllerDemo
//
//  Created by user on 15/10/13.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit
import Photos

class BGPhotoManager: NSObject {
    let assetsFetchResults: PHFetchResult
    let cachingImageManager: PHCachingImageManager
    
    //属性单例
    static let defaultManager: BGPhotoManager = {
        //获取所有相片
        let options = PHFetchOptions()
        //按照时间排序
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return BGPhotoManager(options)
    }()
    
    init(_ options: PHFetchOptions){
        self.assetsFetchResults = PHAsset.fetchAssetsWithOptions(options)
        self.cachingImageManager = PHCachingImageManager()
        super.init()
    }
    
    // MARK: get image
    
}
