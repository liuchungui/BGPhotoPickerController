//
//  BGPhotoPreviewCell.swift
//  BGPhotoPickerControllerDemo
//
//  Created by user on 15/10/14.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit

class BGPhotoPreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
