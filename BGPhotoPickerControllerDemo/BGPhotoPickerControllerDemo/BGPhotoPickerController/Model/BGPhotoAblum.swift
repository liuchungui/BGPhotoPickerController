//
//  BGPhotoAblum.swift
//  BGPhotoPickerControllerDemo
//
//  Created by user on 15/10/25.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit
import Photos

/**
 *  相册
 */
struct BGPhotoAblum {
    /** 相册名 */
    var name: String
    /** 资源结果，内部有一组PHAsset数据 */
    var fetchResult: PHFetchResult
    /** 对应的实际相册 */
    var assetCollection: PHAssetCollection?
    
    /**
     初始化方法
     
     - parameter name:        相册名
     - parameter fetchResult: PHFetchResult对象，内部存储了一组PHAsset
     - parameter collection:  PHAsset的集合
     
     */
    init(name: String, fetchResult: PHFetchResult, collection: PHAssetCollection?) {
        self.name = name
        self.fetchResult = fetchResult
        self.assetCollection = collection
    }
    
    /**
     获取智能相册当中的图片数据
     
     - parameter type:    collection type
     - parameter subType: 子 collection type
     
     - returns: 返回一组BGPhotoAblum数据
     */
    static func fetchSmartAlbum(type: PHAssetCollectionType, subType: PHAssetCollectionSubtype) -> [BGPhotoAblum] {
        var resultArr = [BGPhotoAblum]()
        let fetchResults = PHAssetCollection.fetchAssetCollectionsWithType(type, subtype: subType, options: nil)
        //遍历，获取PHAssetCollection当中的asset的获取结果
        for var index = 0; index < fetchResults.count; index++ {
            if let collection = fetchResults[index] as? PHAssetCollection {
                //按产生时间升序排序
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let assetsFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
                //相册资源大于0个才展示
                if assetsFetchResult.count > 0 {
                    var albumName = ""
                    if let localizedTitle = collection.localizedTitle {
                        albumName = localizedTitle
                    }
                    let album = BGPhotoAblum(name: albumName, fetchResult: assetsFetchResult, collection: collection)
                    resultArr.append(album)
                }
            }
        }
        return resultArr
    }
    
    /**
     获取一组用户自定义相册
     
     - returns: 返回用户自定义相册组
     */
    static func fetchUserAlbums() -> [BGPhotoAblum] {
        var resultArr = [BGPhotoAblum]()
        //用户自定义相册
        let userCollectionsFetchResult = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
        let count = userCollectionsFetchResult.count
        for var index = 0; index < count; index++ {
            if let assetCollection = userCollectionsFetchResult[index] as? PHAssetCollection {
                var ablumName = "用户自定义相册"
                if let name = assetCollection.localizedTitle {
                    ablumName = name
                }
                let assetFetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
                if assetFetchResult.count > 0 {
                    let userAlubm = BGPhotoAblum(name: ablumName, fetchResult: assetFetchResult, collection: assetCollection)
                    resultArr.append(userAlubm)
                }
                
            }
        }
        return resultArr
    }
    
    /**
     获取经常使用的智能相册中的内容
     
     - returns: 返回一组BGPhotoAblum对象
     */
    static func fetchOftenUseSmartAlbums() -> [BGPhotoAblum] {
        var smartAlbums = [BGPhotoAblum]()
        var tmpAblums = [BGPhotoAblum]()
        //相机胶卷
        tmpAblums = self.fetchSmartAlbum(PHAssetCollectionType.SmartAlbum, subType: PHAssetCollectionSubtype.SmartAlbumUserLibrary)
        smartAlbums.appendContentsOf(tmpAblums)
        
        //我的照片流
        tmpAblums = self.fetchSmartAlbum(PHAssetCollectionType.Album, subType: PHAssetCollectionSubtype.AlbumMyPhotoStream)
        smartAlbums.appendContentsOf(tmpAblums)
        
        //收藏
        tmpAblums = self.fetchSmartAlbum(PHAssetCollectionType.SmartAlbum, subType: PHAssetCollectionSubtype.SmartAlbumFavorites)
        smartAlbums.appendContentsOf(tmpAblums)
        
        //视频
        tmpAblums = self.fetchSmartAlbum(PHAssetCollectionType.SmartAlbum, subType: PHAssetCollectionSubtype.SmartAlbumVideos)
        smartAlbums.appendContentsOf(tmpAblums)
        
        //最近添加
        tmpAblums = self.fetchSmartAlbum(PHAssetCollectionType.SmartAlbum, subType: PHAssetCollectionSubtype.SmartAlbumRecentlyAdded)
        smartAlbums.appendContentsOf(tmpAblums)
        
        return smartAlbums
    }
}
