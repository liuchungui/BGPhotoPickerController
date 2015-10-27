//
//  BGPhotoListCell.swift
//  BGPhotoPickerControllerDemo
//
//  Created by user on 15/10/17.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit

class BGPhotoListCell: UITableViewCell {

    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var ablumLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func rowHeight(object: AnyObject?) -> CGFloat {
        return 80.0
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
