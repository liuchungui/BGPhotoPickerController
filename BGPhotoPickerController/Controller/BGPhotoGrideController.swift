//
//  BGPhotoPickerController.swift
//  BGPhotoPickerControllerDemo
//
//  Created by user on 15/10/13.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit
import Photos

extension NSIndexSet {
    private func bg_indexPathsFromIndexsWithSection(section: Int) -> [NSIndexPath]{
        var indexPathArr = [NSIndexPath]()
        self.enumerateIndexesUsingBlock { (index, stop) -> Void in
            indexPathArr.append(NSIndexPath(forItem: index, inSection: section))
        }
        return indexPathArr
    }
}

private let BGPhotoGrideControllerRowCount = 4
class BGPhotoGrideController: BGPhotoBaseController, UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver {
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    private var collectionView: UICollectionView?
    /** 选中的数组 **/
    var selectAssetArr = [PHAsset]()
    /// 相册
    var ablum: BGPhotoAblum?
    //回调
    var selectImageBlock: BGSelectImageBlock?

    override func viewDidLoad() {
        super.viewDidLoad()
        //布局视图
        self.setupViews()
        self.setupData()
        //监听相册变化
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        // Do any additional setup after loading the view.
    }
    
    func setupData() {
        //如果没有结果数据，则获取所有照片
        if self.ablum?.fetchResult == nil {
            //获取所有相册的照片
            let options = PHFetchOptions()
            //按照时间排序
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            self.ablum = BGPhotoAblum(name: "相册资源", fetchResult: PHAsset.fetchAssetsWithOptions(options), collection: nil)
        }
    }
    
    // MARK: - view life
    func setupViews(){
        if let title = self.ablum?.name {
            self.title = title
        }
        else{
            self.title = "相册资源"
        }
        self.automaticallyAdjustsScrollViewInsets = false
        
        //创建collectionView
        let rowCount = CGFloat(BGPhotoGrideControllerRowCount)
        let spacing:CGFloat = 1.0
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.headerReferenceSize = CGSizeMake(BGMainScreenWidth, 74)
        flowLayout.footerReferenceSize = CGSizeMake(BGMainScreenWidth, 10)
        flowLayout.itemSize = CGSizeMake((BGMainScreenWidth-(rowCount-1)*spacing)/rowCount, (BGMainScreenWidth-(rowCount-1)*spacing)/rowCount)
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(collectionView)
        
        //赋值
        self.collectionView = collectionView
        
        collectionView.registerNib(UINib(nibName: BGPhotoGrideCell.reuseIdentify(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: BGPhotoGrideCell.reuseIdentify())
        collectionView.registerClass(UIView.self, forSupplementaryViewOfKind: UIView.reuseIdentify(), withReuseIdentifier: UIView.reuseIdentify())
        
        //设置collectionView的约束
        collectionView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view.snp_left)
            make.right.equalTo(self.view.snp_right)
            make.top.equalTo(self.view.snp_top)
            make.bottom.equalTo(self.view.snp_bottom).offset(-60)
        }
        
        //配置底部视图
        self.configureBotttomViews()
        
    }
    
    //MARK: - bottom views
    func configureBotttomViews() {
        //数量
        self.numLabel.hidden = true
        self.numLabel.layer.cornerRadius = 10
        self.numLabel.layer.masksToBounds = true
        self.numLabel.textColor = UIColor.whiteColor()
        self.numLabel.font = UIFont.systemFontOfSize(14)
        self.numLabel.backgroundColor = RGB(100, 100, 255)
        
        //预览按钮
        self.previewButton.setTitleColor(RGB(170, 170, 170), forState: UIControlState.Normal)
        self.previewButton.setTitleColor(RGB(60, 60, 60), forState: UIControlState.Selected)
        
        //发送按钮
        self.sendButton.setTitleColor(RGB(170, 170, 170), forState: UIControlState.Normal)
        self.sendButton.setTitleColor(RGB(60, 60, 60), forState: UIControlState.Selected)
        
    }
    func updateBottomViews() {
        if self.selectAssetArr.count > 0 {
            self.numLabel.text = String(self.selectAssetArr.count)
            self.numLabel.hidden = false
            self.sendButton.selected = true
            self.previewButton.selected = true
        }
        else {
            self.numLabel.hidden = true
            self.sendButton.selected = false
            self.previewButton.selected = false
        }
    }
    
    // MARK: - Button action
    @IBAction func previewButtonAction(sender: UIButton) {
        let ctrl = BGPhotoPreviewViewController()
        ctrl.assetsArr = self.selectAssetArr
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @IBAction func sendButtonAction(sender: UIButton) {
        self.imagePickerController.finishPickingImages(self.selectAssetArr)
    }
    
    
    // MARK: - UICollectionViewDataSource method
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.ablum?.fetchResult.count {
            return count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: BGPhotoGrideCell = collectionView.dequeueReusableCellWithReuseIdentifier(BGPhotoGrideCell.reuseIdentify(), forIndexPath: indexPath) as! BGPhotoGrideCell
        // Increment the cell's tag
        let currentTag = cell.tag + 1;
        cell.tag = currentTag;

        if let fetchResult = self.ablum?.fetchResult {
            let asset: PHAsset = fetchResult[indexPath.item] as! PHAsset
            PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(BGMainScreenWidth/CGFloat(BGPhotoGrideControllerRowCount), BGMainScreenWidth/CGFloat(BGPhotoGrideControllerRowCount)), contentMode:PHImageContentMode.AspectFit, options: nil, resultHandler: { (image, info) -> Void in
                // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                if (cell.tag == currentTag) {
                    cell.image = image;
                    if self.selectAssetArr.count > 0 && self.selectAssetArr.contains(asset) {
                        cell.isSelect = true
                    }
                    else{
                        cell.isSelect = false
                    }
                }
            })
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate method
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let fetchResult = self.ablum?.fetchResult {
            let asset: PHAsset = fetchResult[indexPath.item] as! PHAsset
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! BGPhotoGrideCell
            if cell.isSelect {
                //缓存图片
                self.startCachingImageWithAsset(asset)
                if let index = self.selectAssetArr.indexOf(asset) {
                    self.selectAssetArr.removeAtIndex(index)
                }
            }
            else {
                //取消缓存图片
                self.stopCachingImageWithAsset(asset)
                self.selectAssetArr.append(asset)
            }
            cell.isSelect = !cell.isSelect
        }
        //更新视图
        self.updateBottomViews()
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange) {
        //回调时也许在后台队列，这个时候我们要回到主线程
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //检查assets是否有改变，例如插入、删除、更新
            if let collectionChanges = changeInstance.changeDetailsForFetchResult((self.ablum?.fetchResult)!) {
                //获取新的fetch result
                self.ablum?.fetchResult = collectionChanges.fetchResultAfterChanges
                
                //hasIncrementalChanges 当它为true时，这些变化详情可以通过插入/删除/改变等操作来描述，这时，就可以调用对应的方法来更新UI界面；当它为false时，说明这种改变不可以被描述，这个时候只能通过刷新整个界面来处理
                //hasMoves 标记着照片的获取结果是否重新排列了，若是重新排列，也需要整个刷新
                if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                    self.collectionView?.reloadData()
                }
                else {
                    //动态插入或删除
                    self.collectionView?.performBatchUpdates({ () -> Void in
                        if let removeIndexes = collectionChanges.removedIndexes {
                            self.collectionView?.deleteItemsAtIndexPaths(removeIndexes.bg_indexPathsFromIndexsWithSection(0))
                        }
                        if let insertIndexes = collectionChanges.insertedIndexes {
                            self.collectionView?.insertItemsAtIndexPaths(insertIndexes.bg_indexPathsFromIndexsWithSection(0))
                        }
                        if let changeIndexes = collectionChanges.changedIndexes {
                            self.collectionView?.reloadItemsAtIndexPaths(changeIndexes.bg_indexPathsFromIndexsWithSection(0))
                        }
                        
                        }, completion: nil)
                }
                
            }
        }
    }
    
    // MARK: private method
    func startCachingImageWithAsset(asset: PHAsset) {
        let manager = PHCachingImageManager.defaultManager() as! PHCachingImageManager
        manager.startCachingImagesForAssets([asset], targetSize: self.imagePickerController.tagetSize, contentMode: self.imagePickerController.contentMode, options: nil)
    }
    
    func stopCachingImageWithAsset(asset: PHAsset) {
        let manager = PHCachingImageManager.defaultManager() as! PHCachingImageManager
        manager.stopCachingImagesForAssets([asset], targetSize: self.imagePickerController.tagetSize, contentMode: self.imagePickerController.contentMode, options: nil)
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
