//
//  BGImagePickerController.swift
//  BGPhotoPickerControllerDemo
//
//  Created by user on 15/10/14.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit
import Photos

//swift中支持可选协议，需要在协议声明时加上@objc
protocol BGImagePickerControllerDelegate : NSObjectProtocol {
    func imagePickerController(picker: BGImagePickerController, didFinishPickingPhotoAssets assets:[BGPhotoAsset])
    func imagePickerControllerDidCancel(picker: BGImagePickerController)
}

class BGImagePickerController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: public property
    /// 图片选择代理
    var pickerDelegate: BGImagePickerControllerDelegate?
    /// 获取图片大小，默认是获取原图
    var tagetSize: CGSize = PHImageManagerMaximumSize
    /// 内容mode
    var contentMode: PHImageContentMode = PHImageContentMode.Default
    /// 是否打开侧滑
    var isEnabelSideslipping = true
    
    // MARK: private property
    /// 第一次是否显示
    private var firstShow = true
    /// 是否可以pop
    private var isEnablePop = true
    
    //定制控制器的构造器，默认构造器不能再用，需要子类再覆写；如果需要带有默认构造器，则可以使用extension
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        let ctrl = BGPhotoListViewController()
        self.init(rootViewController: ctrl)
        self.delegate = self
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    //这个为啥要实现这么一个必要控制器？
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //为何控制器不能下面这样调用？
    /*
    override init() {
        let ctrl = BGPhotoGrideController()
        super.init(rootViewController: ctrl)
    }
    */

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
        // Do any additional setup after loading the view.
    }
    
    // MARK: - UINavigationControllerDelegate method
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        self.isEnablePop = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if !self.isEnabelSideslipping {
            return false
        }
        if self.viewControllers.count <= 1 {
            return false
        }
        return self.isEnablePop
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        self.isEnablePop = false
        super.pushViewController(viewController, animated: animated)
        //第一次时，会自动push到BGPhotoGrideController控制器
        if self.firstShow && self.viewControllers.count == 1 {
            self.firstShow = false
            let ctrl = BGPhotoGrideController()
            self.pushViewController(ctrl, animated: false)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    // MARK: - public method
    func finishPickingImages(assets: [PHAsset]) {
        if let letDelegate = self.pickerDelegate {
            //组装成BGPhotoAsset对象
            var resultArr = [BGPhotoAsset]()
            for asset in assets {
                let photoAsset = BGPhotoAsset(asset, size: self.tagetSize, contentMode: self.contentMode)
                resultArr.append(photoAsset)
            }
            letDelegate.imagePickerController(self, didFinishPickingPhotoAssets: resultArr)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelPickImage() {
        self.dismissViewControllerAnimated(true, completion: nil)
        if let letDelegate = self.pickerDelegate {
            letDelegate.imagePickerControllerDidCancel(self)
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
