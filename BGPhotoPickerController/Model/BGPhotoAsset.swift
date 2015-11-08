//
//  BGPhotoAsset.swift
//  BGPhotoPickerControllerDemo
//
//  Created by user on 15/10/25.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit
import Photos

typealias BGSelectImageBlock = (image:UIImage?) -> Void

struct BGPhotoAsset  {
    private var asset: PHAsset
    private var tagetSize: CGSize = PHImageManagerMaximumSize
    private var contentMode: PHImageContentMode = PHImageContentMode.Default
    var photoAsset: PHAsset {
        get {
            return self.asset
        }
    }
    init(_ asset: PHAsset, size tagetSize:CGSize, contentMode: PHImageContentMode) {
        self.asset = asset
        self.tagetSize = tagetSize
        self.contentMode = contentMode
    }
    /**
     此方法block会回调多次，首先会立刻回调一个不清晰的图片，之后异步回调一个清晰的图片
     */
    func image(block: BGSelectImageBlock?) {
        PHCachingImageManager.defaultManager().requestImageForAsset(self.asset, targetSize: self.tagetSize, contentMode: self.contentMode, options: nil) { (image, info) -> Void in
            if let imageBlock = block {
                imageBlock(image:image)
            }
        }
    }
}

