//
//  BGPhotoListViewController.swift
//  BGPhotoPickerControllerDemo
//
//  Created by user on 15/10/16.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit
import Photos

class BGPhotoListViewController: BGPhotoBaseController, UITableViewDataSource, UITableViewDelegate, PHPhotoLibraryChangeObserver {
    let cachingImageManager: PHCachingImageManager = PHCachingImageManager()
    var dataArr = [BGPhotoAblum]()
    //析构
    deinit {
        //注销对相册的监听
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //布局视图
        self.setupViews()
        //加载数据
        self.setupData()
        //监听相册变化
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        // Do any additional setup after loading the view.
    }
    
    func setupData() {
        var ablums = BGPhotoAblum.fetchOftenUseSmartAlbums()
        self.dataArr.appendContentsOf(ablums)
        ablums = BGPhotoAblum.fetchUserAlbums()
        self.dataArr.appendContentsOf(ablums)
    }
    
    // MARK: - view life
    func setupViews(){
        self.title = "相薄"
        
        //创建UITableView
        let tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.tag = 1990
        self.view.addSubview(tableView)
        
        //设置头
        tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, MainScreenWidth, 64))
        
        //注册cell
        tableView.registerNib(UINib(nibName: BGPhotoListCell.reuseIdentify(), bundle: NSBundle.mainBundle()), forCellReuseIdentifier: BGPhotoListCell.reuseIdentify())
        
        //添加约束
        tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view.snp_edges)
        }
    }
    
    // MARK: - UITableViewDataSource method
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return BGPhotoListCell.rowHeight(nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(BGPhotoListCell.reuseIdentify(), forIndexPath: indexPath) as! BGPhotoListCell
        let ablum: BGPhotoAblum = self.dataArr[indexPath.row]
        cell.ablumLabel.text = ablum.name
        cell.numLabel.text = "(\(ablum.fetchResult.count))"
        //取资源图片的最后一张显示
        if let asset = ablum.fetchResult.lastObject as? PHAsset {
            self.cachingImageManager.requestImageForAsset(asset, targetSize: CGSizeMake(54, 54), contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
                cell.headImageView.image = image
            }
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate method
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let ctrl = BGPhotoGrideController()
        let ablum: BGPhotoAblum = self.dataArr[indexPath.row]
        ctrl.ablum = ablum
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    // MARK: - PHPhotoLibraryChangeObserver method
    func photoLibraryDidChange(changeInstance: PHChange) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //重新获取数据
            self.dataArr.removeAll()
            self.setupData()
            if let tableview = self.view.viewWithTag(1990) as? UITableView {
                tableview.reloadData()
            }
        }
    }
    
}
