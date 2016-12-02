//
//  SkillLayoutView.swift
//  TestLayoutView
//
//  Created by J-bb on 16/12/1.
//  Copyright © 2016年 J-BB. All rights reserved.
//

import UIKit

/**
 *  layout 结束后回调高度 修改容器高度
 */
protocol LayoutStopDelegate:NSObjectProtocol {
    
    func layoutStopWithHeight(height:CGFloat)
}

class SkillLayoutView: UIView, UICollectionViewDataSource,UICollectionViewDelegate, SkillWidthLayoutDelegate {
    
    var collectionView: UICollectionView?
    
    
    var layout: SkillWidthLayout?
    
    weak var delegate:LayoutStopDelegate?
    
    var dataSouce:Array<SkillsModel>? {
    
        didSet {
            collectionView!.reloadData()
        }
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout = SkillWidthLayout.init()
        layout?.itemHeight = 30
        collectionView  = UICollectionView(frame: CGRectMake(0, 0, frame.size.width, 100), collectionViewLayout: layout!)
        layout!.delegate = self
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView!.registerClass(SingleSkillCell.classForCoder(), forCellWithReuseIdentifier: "singleCell")
        addSubview(collectionView!)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SkillLayoutView.layoutStop), name: "LayoutStop", object: nil)
    }
    
    /**
     layout结束回调。传出最终高度，修改collectionView高度
     */
    func layoutStop() {
        if delegate != nil {
            delegate?.layoutStopWithHeight(CGFloat((layout?.finalHeight)!))
            collectionView!.frame = CGRectMake(0, 0,  UIScreen.mainScreen().bounds.size.width, CGFloat(layout!.finalHeight))
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layout = SkillWidthLayout.init()
        collectionView  = UICollectionView(frame: CGRectMake(0, 0, frame.size.width, 100), collectionViewLayout: layout!)
        layout!.delegate = self
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView!.registerClass(SingleSkillCell.classForCoder(), forCellWithReuseIdentifier: "singleCell")
        addSubview(collectionView!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SkillLayoutView.layoutStop), name: "LayoutStop", object: nil)

    }
    

    /**
     SkillWidthLayoutDelegate
     宽度自适应回调
     - parameter layout:
     - parameter atIndexPath: item所在的indexPath
     
     - returns: item 所占宽度
     */
    func autoLayout(layout:SkillWidthLayout, atIndexPath:NSIndexPath)->Float {
        
        let skill = dataSouce![atIndexPath.row]
        
        
        let size = skill.skill_name!.boundingRectWithSize(CGSizeMake(0, 21), font: UIFont.systemFontOfSize(15), lineSpacing: 0)
        
        
        return Float(size.width + 30)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("singleCell", forIndexPath: indexPath) as! SingleSkillCell
        
        let skill = dataSouce![indexPath.row]
        cell.setupTitle(skill.skill_name!)

        return cell
        
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataSouce == nil ? 0 : (dataSouce?.count)!
    }

}
