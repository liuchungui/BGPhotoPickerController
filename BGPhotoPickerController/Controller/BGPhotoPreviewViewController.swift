//
//  BGPhotoPreviewViewController.swift
//  BGPhotoPickerControllerDemo
//
//  Created by user on 15/10/14.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit
import Photos

class BGPhotoPreviewViewController: BGPhotoBaseController, UICollectionViewDataSource, UICollectionViewDelegate, BGSelectImageLayoutDelegate {
    
    @IBOutlet weak var bottomBaseView: UIView!
    @IBOutlet weak var scrollIndexLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    @IBOutlet weak var bottomCollectionViewLayout: BGSelectImageLayout!
    //相片资源
    var assetsArr:[PHAsset]?
    /** 是否全屏 */
    var isMainScreen: Bool = false
    var targetSize = CGSizeMake(MainScreenWidth*2, MainScreenHeight*2)
    var currentPage = 0
    //选中的索引
    private var selectIndexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
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
        //register
        self.collectionView.registerNib(UINib(nibName: BGPhotoPreviewCell.reuseIdentify(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: BGPhotoPreviewCell.reuseIdentify())
        
        //底部collectionView
        self.bottomCollectionViewLayout.itemSize = CGSizeMake(30, 50)
        self.bottomCollectionViewLayout.delegate = self
        //设置内容区域
        self.bottomCollectionViewLayout.contentInset = UIEdgeInsetsMake(0, MainScreenWidth/2.0-self.bottomCollectionViewLayout.itemSize.width-self.bottomCollectionViewLayout.interitemSpacing, 0, MainScreenWidth/2.0-self.bottomCollectionViewLayout.itemSize.width-self.bottomCollectionViewLayout.interitemSpacing)
        
        self.bottomCollectionView.dataSource = self
        self.bottomCollectionView.delegate = self
        self.bottomCollectionView.showsHorizontalScrollIndicator = false
        self.bottomCollectionView.showsVerticalScrollIndicator = false
        self.bottomCollectionView.backgroundColor = RGB(250, 250, 250)
        
        self.bottomCollectionView.registerNib(UINib(nibName: BGPhotoPreviewCell.reuseIdentify(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: BGPhotoPreviewCell.reuseIdentify())
        self.bottomCollectionView.registerClass(UIView.self, forSupplementaryViewOfKind: UIView.reuseIdentify(), withReuseIdentifier: UIView.reuseIdentify())
        
        //更新底部视图
//        self.bottomBaseView.layer.backgroundColor = RGB(255, 255, 255, 0.6).CGColor
        self.updateScrollPageIndexLabel(0)
    }
    
    // MARK: - UICollectionViewDataSource method
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if collectionView == self.collectionView {
            if let count = self.assetsArr?.count {
                return count
            }
            return 0
        }
        else {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return 1
        }
        else {
            if let count = self.assetsArr?.count {
                return count
            }
            return 0
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //预览大图设置
        if collectionView == self.collectionView {
            let cell: BGPhotoPreviewCell = collectionView.dequeueReusableCellWithReuseIdentifier(BGPhotoPreviewCell.reuseIdentify(), forIndexPath: indexPath) as! BGPhotoPreviewCell
            
            // Increment the cell's tag
            let currentTag = cell.tag + 1;
            cell.tag = currentTag;
            
            let asset: PHAsset = self.assetsArr![indexPath.section]
            PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.targetSize, contentMode: PHImageContentMode.AspectFit, options: nil) { (image, info) -> Void in
                if(cell.tag == currentTag) {
                    cell.imageView.image = image
                }
            }
            return cell
        }
        //底部collectionView
        else {
            let cell: BGPhotoPreviewCell = collectionView.dequeueReusableCellWithReuseIdentifier(BGPhotoPreviewCell.reuseIdentify(), forIndexPath: indexPath) as! BGPhotoPreviewCell
            cell.imageView.contentMode = .ScaleToFill
            
            // Increment the cell's tag
            let currentTag = cell.tag + 1;
            cell.tag = currentTag;
            
            let asset: PHAsset = self.assetsArr![indexPath.row]
            PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.targetSize, contentMode: PHImageContentMode.AspectFit, options: nil) { (image, info) -> Void in
                if(cell.tag == currentTag) {
                    cell.imageView.image = image
//                    self.imagesDic[indexPath.row] = image
                }
            }
            return cell
        }
    }
    
    // MARK: UICollectionViewDelegate method
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.collectionView == collectionView {
            self.isMainScreen = !self.isMainScreen
            if self.isMainScreen {
                self.hideNaviagtionBarAndBottomViews()
            }
            else {
                self.showNavigationBarAndBottomViews()
            }
        }
        else {
            self.bottomCollectionViewLayout.selectIndexPath = indexPath
        }
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if scrollView == self.collectionView {
                let page = Int(self.collectionView.contentOffset.x / self.collectionView.width)
                self.updateScrollPageIndexLabel(page)
            }
            else {
                self.bottomCollectionViewLayout.configureWhenScrollStop()
            }
        }
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.collectionView {
            let page = Int(self.collectionView.contentOffset.x / self.collectionView.width)
            self.updateScrollPageIndexLabel(page)
        }
        else {
            self.bottomCollectionViewLayout.configureWhenScrollStop()
        }
    }
    
    // MARK: - BGSelectImageLayoutDelegate method
    func selectImageLayout(layout: BGSelectImageLayout, selectIndexPath: NSIndexPath) {
        if self.selectIndexPath == selectIndexPath {
            return
        }
        self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: 0, inSection: selectIndexPath.row), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        //设置页数
        self.updateScrollPageIndexLabel(selectIndexPath.row)
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
    
    func updateScrollPageIndexLabel(page: Int) {
        if let assets = self.assetsArr {
            self.scrollIndexLabel.text = "\(page+1)/\(assets.count)"
        }
        //设置底部视图
        let selectIndexPath = NSIndexPath(forRow: page, inSection: 0)
        if selectIndexPath != self.selectIndexPath {
            self.selectIndexPath = selectIndexPath
            self.bottomCollectionViewLayout.selectIndexPath = selectIndexPath
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
