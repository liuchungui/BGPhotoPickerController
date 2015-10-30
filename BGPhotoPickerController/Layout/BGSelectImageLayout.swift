//
//  BGSelectImageLayout.swift
//  BGSimpleImageSelectCollectionView
//
//  Created by user on 15/10/27.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit

protocol BGSelectImageLayoutDelegate: NSObjectProtocol {
    /**
     选择了某个索引
     
     - parameter layout:          layout
     - parameter selectIndexPath: 选择的索引
     */
    func selectImageLayout(layout: BGSelectImageLayout, selectIndexPath: NSIndexPath)
}

/// 此布局，只有一组，没有多组
class BGSelectImageLayout: UICollectionViewLayout {
    // MARK: - properties
    /// 内容区域
    var contentInset: UIEdgeInsets = UIEdgeInsetsZero
    /// 每个cell的间距
    var interitemSpacing: CGFloat = 10
    /// 每个cell大小
    var itemSize: CGSize = CGSizeMake(45, 45)
    weak var delegate: BGSelectImageLayoutDelegate? = nil
    
    /// cell布局信息
    private var layoutInfoDic = [NSIndexPath:UICollectionViewLayoutAttributes]()
    /// 需要更新的indexPath集合
    private var updateIndexPathArr = [NSIndexPath]()
    /// 删除的indexPath集合
    private var deleteIndexPathArr = [NSIndexPath]()
    /// 插入的indexPath集合
    private var insertIndexPathArr = [NSIndexPath]()
    /// 上一次选中的indexPath
    private var lastSelectIndexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    /// 当前选中的indexPath
    private var currentSelectIndexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    /// 选中的indexPath
    var selectIndexPath: NSIndexPath {
        get {
            return self.currentSelectIndexPath
        }
        set (indexPath) {
            self.lastSelectIndexPath = self.currentSelectIndexPath
            self.currentSelectIndexPath = indexPath
            self.collectionView?.reloadSections(NSIndexSet(index: 0))
            //调用代理方法
            self.delegate?.selectImageLayout(self, selectIndexPath: indexPath)
        }
    }
    
    // MARK: - must override methods
    override func prepareLayout() {
        super.prepareLayout()
        
        //重置数组
        self.layoutInfoDic = [NSIndexPath:UICollectionViewLayoutAttributes]()
        
        //布局只取第0组的信息
        if let numOfItems = self.collectionView?.numberOfItemsInSection(0) {
            for i in 0 ..< numOfItems {
                let indexPath = NSIndexPath(forItem: i, inSection: 0)
                if let attributes = self.layoutAttributesForItemAtIndexPath(indexPath) {
                    self.layoutInfoDic[indexPath] = attributes
                }
            }
        }
        
    }
    
    override func collectionViewContentSize() -> CGSize {
        if let numOfItems = self.collectionView?.numberOfItemsInSection(0) {
            return CGSizeMake((self.itemSize.width+self.interitemSpacing)*CGFloat(numOfItems+1)+self.interitemSpacing+self.contentInset.left+self.contentInset.right, self.itemSize.height+self.contentInset.top+self.contentInset.bottom)
        }
        else {
            return self.collectionView!.frame.size
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArr = [UICollectionViewLayoutAttributes]()
        //遍历布局信息
        for arttibutes in self.layoutInfoDic.values {
            //判断arttibutes当中的区域与rect是否存在交集
            if CGRectIntersectsRect(arttibutes.frame, rect) {
                attributesArr.append(arttibutes)
            }
        }
        return attributesArr
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.frame = self.currentFrameWithIndexPath(indexPath)
        return attributes
    }
    
    // MARK: - option override method
    //此方法刷新动画的时候会调用
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        let frame = self.currentFrameWithIndexPath(self.currentSelectIndexPath)
        return CGPointMake(frame.centerX-self.collectionView!.width/2.0, 0)
    }
    
    // MARK: animation method
    override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        super.prepareForCollectionViewUpdates(updateItems)
        //数组重置
        self.updateIndexPathArr = [NSIndexPath]()
        self.deleteIndexPathArr = [NSIndexPath]()
        self.insertIndexPathArr = [NSIndexPath]()
        //将更新的内容放入数组当中
        for item in updateItems {
            //reload的时候，才加入
            if item.updateAction == .Reload {
                let indexPath = item.indexPathBeforeUpdate
                self.updateIndexPathArr.append(indexPath)
            }
            else if item.updateAction == .Delete {
                let indexPath = item.indexPathBeforeUpdate
                self.deleteIndexPathArr.append(indexPath)
            }
            else if item.updateAction == .Insert {
                let indexPath = item.indexPathBeforeUpdate
                self.insertIndexPathArr.append(indexPath)
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
    }
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath)
        if attributes == nil {
            attributes = self.layoutAttributesForItemAtIndexPath(itemIndexPath)
        }
        let frame = self.lastFrameWithIndexPath(itemIndexPath)
        attributes?.frame = frame
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes = super.finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath)
        if attributes == nil {
            attributes = self.layoutAttributesForItemAtIndexPath(itemIndexPath)
        }
        let frame = self.currentFrameWithIndexPath(itemIndexPath)
        attributes?.frame = frame
        //注意：不能够让它透明
        attributes?.alpha = 1.0
        return attributes
    }
    
    // MARK: - private method
    func currentFrameWithIndexPath(indexPath: NSIndexPath) -> CGRect {
        return self.frameWithIndexPath(indexPath, selectIndexPath: self.currentSelectIndexPath)
    }
    func lastFrameWithIndexPath(indexPath: NSIndexPath) -> CGRect {
        return self.frameWithIndexPath(indexPath, selectIndexPath: self.lastSelectIndexPath)
    }
    func frameWithIndexPath(indexPath: NSIndexPath, selectIndexPath: NSIndexPath) -> CGRect {
        var left: CGFloat
        var width: CGFloat
        if indexPath.row < selectIndexPath.row {
            left = CGFloat(indexPath.row)*(self.itemSize.width+self.interitemSpacing)
            width = self.itemSize.width
        }
        else if indexPath.row == selectIndexPath.row {
            left = CGFloat(indexPath.row)*(self.itemSize.width+self.interitemSpacing)+self.interitemSpacing
            width = self.itemSize.width*2
        }
        else {
            left = CGFloat(indexPath.row+1)*(self.itemSize.width+self.interitemSpacing)+self.interitemSpacing
            width = self.itemSize.width
        }
        let frame = CGRectMake(left+self.contentInset.left, CGFloat(indexPath.section)*self.itemSize.height+self.contentInset.top, width, self.itemSize.height)
        return frame
    }
    
    func printAttributes(attributes: UICollectionViewLayoutAttributes) {
        print("frame:\(attributes.frame)")
        print("indexPath:\(attributes.indexPath)")
        print("transform:\(attributes.transform)")
        print("alpha:\(attributes.alpha)")
    }
    
    // MARK: public method
    /**
    当滑动停留的时候调用此方法，此方法会在内部确定选择哪个cell
    */
    func configureWhenScrollStop() {
        //判断停留的时候，中心点在哪个cell内部
        let contentOffset = self.collectionView!.contentOffset
        let center = CGPointMake(contentOffset.x+self.collectionView!.width/2.0, self.itemSize.height/2.0)
        for (indexPath, attributes) in self.layoutInfoDic {
            var spacing = self.interitemSpacing
            if self.selectIndexPath == indexPath {
                spacing = self.interitemSpacing*2
            }
            if CGRectContainsPoint(CGRectMake(attributes.frame.left-spacing/2.0, attributes.frame.top, attributes.frame.width+spacing, attributes.frame.height), center) {
                self.selectIndexPath = indexPath
                break
            }
        }
    }
    
    
}
