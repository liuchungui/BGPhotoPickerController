//
//  BGPhotoPreviewViewController.swift
//  BGPhotoPickerControllerDemo
//
//  Created by user on 15/10/14.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit
import Photos

class BGPhotoPreviewViewController: BGPhotoBaseController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var bottomBaseView: UIView!
    @IBOutlet weak var scrollIndexLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    //相片资源
    var assetsArr:[PHAsset]?
    var imagesDic = [Int: UIImage]()
    /** 是否全屏 */
    var isMainScreen: Bool = false
    var targetSize = CGSizeMake(MainScreenWidth*2, MainScreenHeight*2)
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        // Do any additional setup after loading the view.
    }
    
    func setupViews() {
        self.title = "查看相片"
        //设置分页
        self.collectionView.pagingEnabled = true
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        //设置layout中的Item大小
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: MainScreenWidth, height: MainScreenHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.footerReferenceSize = CGSizeMake(20, MainScreenHeight)
        //register
        self.collectionView.registerNib(UINib(nibName: BGPhotoPreviewCell.reuseIdentify(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: BGPhotoPreviewCell.reuseIdentify())
        
        //更新底部视图
        self.updateScrollPageIndexLabel()
    }
    
    // MARK: - UICollectionViewDataSource method
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let count = self.assetsArr?.count {
            return count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: BGPhotoPreviewCell = collectionView.dequeueReusableCellWithReuseIdentifier(BGPhotoPreviewCell.reuseIdentify(), forIndexPath: indexPath) as! BGPhotoPreviewCell
        
        if let image = self.imagesDic[indexPath.section] {
            cell.imageView.image = image
        }
        else{
            // Increment the cell's tag
            let currentTag = cell.tag + 1;
            cell.tag = currentTag;
            
            let asset: PHAsset = self.assetsArr![indexPath.section]
            PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.targetSize, contentMode: PHImageContentMode.AspectFit, options: nil) { (image, info) -> Void in
                if(cell.tag == currentTag) {
                    cell.imageView.image = image
                    self.imagesDic[indexPath.section] = image
                }
            }
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate method
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.isMainScreen = !self.isMainScreen
        if self.isMainScreen {
            self.hideNaviagtionBarAndBottomViews()
        }
        else {
            self.showNavigationBarAndBottomViews()
        }
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.updateScrollPageIndexLabel()
        }
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.updateScrollPageIndexLabel()
    }
    
    // MARK: - button action
    @IBAction func buttonAction(sender: AnyObject) {
        if let assets = self.assetsArr {
            self.imagePickerController.finishPickingImages(assets)
        }
    }
    
    // MARK: - private method
    func showNavigationBarAndBottomViews() {
        if let ctrl = self.navigationController as? BGImagePickerController {
            ctrl.isEnabelSideslipping = true
        }
        UIView.animateWithDuration(0.4) { () -> Void in
            //导航栏
            self.navigationController?.navigationBar.top = 20
            self.navigationController?.navigationBar.alpha = 1.0
            self.collectionView.backgroundColor = UIColor.whiteColor()
            //底部视图
            self.bottomBaseView.top = MainScreenHeight - self.bottomBaseView.height
            self.bottomBaseView.alpha = 1.0
        }
    }
    
    func hideNaviagtionBarAndBottomViews() {
        if let ctrl = self.navigationController as? BGImagePickerController {
            ctrl.isEnabelSideslipping = false
        }
        UIView.animateWithDuration(0.4) { () -> Void in
            self.navigationController?.navigationBar.top = -64
            self.navigationController?.navigationBar.alpha = 0
            self.collectionView.backgroundColor = UIColor.blackColor()
            //底部视图
            self.bottomBaseView.top = MainScreenHeight
            self.bottomBaseView.alpha = 0
        }
    }
    
    func updateScrollPageIndexLabel() {
        let page = Int(self.collectionView.contentOffset.x / self.collectionView.width)
        if let assets = self.assetsArr {
            self.scrollIndexLabel.text = "\(page+1)/\(assets.count)"
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
