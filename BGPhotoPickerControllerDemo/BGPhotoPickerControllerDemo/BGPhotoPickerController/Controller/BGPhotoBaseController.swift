//
//  BGPhotoBaseController.swift
//  BGPhotoPickerControllerDemo
//
//  Created by user on 15/10/25.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit

class BGPhotoBaseController: BGBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.buttonItem("取消", action: Selector("rightBarButtonItemAction"), titleColor: RGB(0, 122, 255))
        // Do any additional setup after loading the view.
    }
    
    func rightBarButtonItemAction() {
        if let navigationCtrl = self.navigationController as? BGImagePickerController {
            navigationCtrl.cancelPickImage()
        }
    }
    
    var imagePickerController: BGImagePickerController {
        get {
            return self.navigationController as! BGImagePickerController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
