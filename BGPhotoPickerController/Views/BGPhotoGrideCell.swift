//
//  BGPhotoGrideCell.swift
//  BGPhotoPickerControllerDemo
//
//  Created by user on 15/10/13.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit

class BGPhotoGrideCell: UICollectionViewCell {
    private var isDidSelect = false
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 0.3
        self.layer.masksToBounds = true
        self.isSelect = false
        self.selectImageView.hidden = false
    }
    
    //MARK: var value
    var image: UIImage? {
        get {
            return self.imageView.image
        }
        set(newImage) {
            self.imageView.image = newImage
        }
    }
    var isSelect: Bool {
        get {
            return self.isDidSelect
        }
        set(newValue) {
            self.isDidSelect = newValue
            if newValue {
                self.selectImageView.image = UIImage(named: "ImageSelectedOn.png")
            }
            else {
                self.selectImageView.image = UIImage(named: "ImageSelectedOff.png")
            }
        }
    }
}
