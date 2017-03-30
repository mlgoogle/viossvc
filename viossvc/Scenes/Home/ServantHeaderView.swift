//
//  ServantHeaderView.swift
//  HappyTravel
//
//  Created by 巩婧奕 on 2017/3/3.
//  Copyright © 2017年 陈奕涛. All rights reserved.
//

import UIKit
import Foundation

class ServantHeaderView: UIView {
    
    var headerView:UIImageView?
    var nameLabel:UILabel?
    var attentionNum:UILabel?
    var starsView:UIView?
    var tagView:UIView?// 标签条
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.whiteColor()
        
        topBgImage()
        
        middleView()
        
        let bottomLine = UIView.init()
        bottomLine.backgroundColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1)
        self.addSubview(bottomLine)
        bottomLine.snp_makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(self)
            make.height.equalTo(1)
            make.bottom.equalTo(self)
        }
    }
    
    // 设置顶部图片
    func topBgImage() {
        let bgImgView:UIImageView = UIImageView.init(frame: CGRectMake(0, 0, ScreenWidth, 200))
        self.addSubview(bgImgView)
        bgImgView.snp_makeConstraints { (make) in
            make.left.top.right.equalTo(self)
            make.height.equalTo(200)
        }
        bgImgView.image = UIImage.init(named: "servant-header-bg")
    }
    
    // 设置中间卡片
    func middleView() {
        
        let middleView:UIView = UIView.init(frame: CGRectMake(30, 160, ScreenWidth - 60, 120))
        self.addSubview(middleView)
        
        middleView.snp_makeConstraints { (make) in
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self).offset(-30)
            make.top.equalTo(self).offset(160)
            make.height.equalTo(120)
            make.bottom.equalTo(self).offset(-20)
        }
        
        middleView.backgroundColor = UIColor.whiteColor()
        middleView.layer.borderWidth = 1.0
        middleView.layer.borderColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1).CGColor
        
        headerView = UIImageView.init(frame: CGRectMake(15, 15, 60, 60))
        headerView!.layer.masksToBounds = true
        headerView!.layer.cornerRadius = 30
        middleView.addSubview(headerView!)
        
        nameLabel = UILabel.init()
        nameLabel!.font = UIFont.systemFontOfSize(18)
        nameLabel!.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        middleView.addSubview(nameLabel!)
        nameLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo((headerView?.snp_right)!).offset(10)
            make.right.equalTo(middleView.snp_right).offset(-10)
            make.top.equalTo((headerView?.snp_top)!)
            make.height.equalTo(30)
        })

        tagView = UIView.init(frame: CGRectMake((nameLabel?.Left)!, (nameLabel?.Bottom)! + 3, (nameLabel?.Width)!, (headerView?.Height)! - (nameLabel?.Bottom)! - 3))
        middleView.addSubview(tagView!)
        
        let sw:UIButton = UIButton.init(type: .Custom)
        sw.setBackgroundImage(UIImage.init(named: "attentionList_serviceTag"), forState: .Normal)
        sw.setTitle("商务", forState: .Normal)
        sw.titleLabel?.font = UIFont.systemFontOfSize(S10)
        sw.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 5, -1)
        sw.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        middleView.addSubview(sw)
        
        sw.snp_makeConstraints { (make) in
            make.left.equalTo((nameLabel?.snp_left)!)
            make.top.equalTo((nameLabel?.snp_bottom)!)
            make.width.equalTo(27)
            make.height.equalTo(25)
        }
        
        let xx:UIButton = UIButton.init(type: .Custom)
        xx.setBackgroundImage(UIImage.init(named: "attentionList_serviceTag"), forState: .Normal)
        xx.setTitle("休闲", forState: .Normal)
        xx.titleLabel?.font = UIFont.systemFontOfSize(S10)
        xx.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 5, -1)
        xx.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        middleView.addSubview(xx)
        
        xx.snp_makeConstraints { (make) in
            make.left.equalTo(sw.snp_right).offset(5)
            make.top.equalTo((nameLabel?.snp_bottom)!)
            make.width.equalTo(27)
            make.height.equalTo(25)
        }
        
        attentionNum = UILabel.init()
        attentionNum!.textAlignment = .Center
        attentionNum!.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        attentionNum!.font = UIFont.systemFontOfSize(18)
        attentionNum?.text = "0"
        middleView.addSubview(attentionNum!)
        attentionNum?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(middleView).offset(20)
            make.right.equalTo(middleView).offset(-20)
            make.width.equalTo(40)
            make.height.equalTo(20)
        })
        
        let fansLibel = UILabel.init()
        fansLibel.textAlignment = .Center
        fansLibel.textColor = UIColor.init(decR: 102, decG: 102, decB: 102, a: 1)
        fansLibel.font = UIFont.systemFontOfSize(10)
        fansLibel.text = "粉丝"
        middleView.addSubview(fansLibel)
        fansLibel.snp_makeConstraints { (make) in
            make.left.right.width.equalTo(attentionNum!)
            make.top.equalTo((attentionNum?.snp_bottom)!).offset(5)
        }
        
        let line = UIView.init(frame: CGRectMake(16, (headerView?.Bottom)! + 14, middleView.Width - 32, 1))
        line.backgroundColor = UIColor.init(decR: 235, decG: 235, decB: 235, a: 1)
        middleView.addSubview(line)
        
        starsView = UIView.init(frame: CGRectMake((middleView.Width - 140)/2.0, line.Bottom + 8, 140, 20))
        starsView?.backgroundColor = UIColor.whiteColor()
        middleView.addSubview(starsView!)
    }
    
    // 更新UI数据
    func didUpdateUI(headerUrl:String, name:String, star:Int) {
        
        headerView?.kf_setImageWithURL(NSURL.init(string: headerUrl), placeholderImage: UIImage.init(named: "head_boy"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        nameLabel?.text = name
        
        let count:Int = star > 0 ? star : 0
        for i in 0..<count {
            
            let starImage:UIImageView = UIImageView.init(frame: CGRectMake( CGFloat(Float(i)) * 30.0, 0, 20, 20))
            starsView!.addSubview(starImage)
            starImage.image = UIImage.init(named: "star-select")
        }
        // 空心的星星
        for i in count ..< 5 {
            let starImage:UIImageView = UIImageView.init(frame: CGRectMake( CGFloat(Float(i)) * 30.0, 0, 20, 20))
            starsView!.addSubview(starImage)
            starImage.image = UIImage.init(named: "star-emp")
        }
    }
    
    // 更新粉丝数量
    func updateFansCount(count:Int) {
        attentionNum?.text = String(count)
    }
    
}
