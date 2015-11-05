//
//  ViewController.swift
//  BGPhotoPickerControllerDemo
//
//  Created by user on 15/10/13.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,BGImagePickerControllerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    var assetsArr:[BGPhotoAsset]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupViews() {
        self.title = "查看相片"
        
        //设置分页
        self.collectionView.pagingEnabled = true
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsHorizontalScrollIndicator = false
        //设置layout中的Item大小
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: BGMainScreenWidth, height: BGMainScreenHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        //register
        self.collectionView.registerNib(UINib(nibName: BGPhotoPreviewCell.reuseIdentify(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: BGPhotoPreviewCell.reuseIdentify())
    }
    
    // MARK: - button action
    @IBAction func systemButtonAction(sender: AnyObject) {
        let ctrl = UIImagePickerController()
        ctrl.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.navigationController?.presentViewController(ctrl, animated: true, completion: nil)
    }

    @IBAction func buttonAction(sender: AnyObject) {
        let ctrl = BGImagePickerController()
        ctrl.pickerDelegate = self
        ctrl.tagetSize = CGSize(width: 300, height: 500)
        self.navigationController?.presentViewController(ctrl, animated: true, completion: nil)
    }
    
    //MARK: - BGImagePickerControllerDelegate
    func imagePickerController(picker: BGImagePickerController, didFinishPickingPhotoAssets assets: [BGPhotoAsset]) {
        self.assetsArr = assets
        self.collectionView.reloadData()
    }
    
    func imagePickerControllerDidCancel(picker: BGImagePickerController) {
        
    }
    
    // MARK: - UICollectionViewDataSource method
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.assetsArr?.count {
            return count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: BGPhotoPreviewCell = collectionView.dequeueReusableCellWithReuseIdentifier(BGPhotoPreviewCell.reuseIdentify(), forIndexPath: indexPath) as! BGPhotoPreviewCell
        
        // Increment the cell's tag
        let currentTag = cell.tag + 1;
        cell.tag = currentTag;
        
        let asset = self.assetsArr![indexPath.row]
        PHCachingImageManager.defaultManager().requestImageForAsset(asset.asset, targetSize: asset.tagetSize, contentMode: asset.contentMode, options: nil) { (image, info) -> Void in
            if cell.tag == currentTag {
                cell.imageView.image = image
            }
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

