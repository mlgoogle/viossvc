//
//  GuidView.swift
//  viossvc
//
//  Created by 千山暮雪 on 2017/3/20.
//  Copyright © 2017年 com.yundian. All rights reserved.
//


protocol GuideViewDelegate {
    func guideDidDismissed()
}

class GuidView: UIView {
    
    var bgImageView:UIImageView?
    var scrollView:UIScrollView?
    var delegate:GuideViewDelegate?
    var enterBtn:UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.cyanColor()
        
        addViews()
    }
    
    
    func addViews() {
        
        bgImageView = UIImageView.init(frame: self.bounds)
        bgImageView?.image = UIImage.init(named: "guideViewBottom")
        self.addSubview(bgImageView!)
        
        scrollView = UIScrollView.init(frame: self.bounds)
        self.addSubview(scrollView!)
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.contentSize = CGSizeMake(ScreenWidth * 2, ScreenHeight)
        for i in 0..<2 {
            
            let imgV = UIImageView.init(frame: CGRectMake(ScreenWidth * CGFloat(i), 0 , ScreenWidth, ScreenHeight))
            scrollView?.addSubview(imgV)
            let imageName:String = "guideView" + String(i)
            imgV.image = UIImage.init(named: imageName)
            
            if i == 1 {
                imgV.userInteractionEnabled = true
                
                let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.imageViewAction))
                imgV.addGestureRecognizer(tap)
            }
        }
        
        enterBtn = UIButton.init(type: .Custom)
        enterBtn?.layer.masksToBounds = true
        enterBtn?.layer.cornerRadius = 12
        enterBtn?.layer.borderWidth = 1
        enterBtn?.layer.borderColor = UIColor.init(decR: 252, decG: 163, decB: 17, a: 1).CGColor
        enterBtn?.backgroundColor = UIColor.clearColor()
        enterBtn!.titleLabel?.font = UIFont.systemFontOfSize(15)
        enterBtn!.setTitleColor(UIColor.init(decR: 252, decG: 163, decB: 17, a: 1), forState: .Normal)
        enterBtn?.setTitle("进入", forState: .Normal)
        self.addSubview(enterBtn!)
        enterBtn?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(self.snp_top).offset(36)
            make.right.equalTo(self.snp_right).offset(-16)
            make.width.equalTo(44)
            make.height.equalTo(24)
        })
        enterBtn?.addTarget(self, action: #selector(self.imageViewAction), forControlEvents: .TouchUpInside)
    }
    
    func imageViewAction() {
        
        self.delegate?.guideDidDismissed()
        UIView.animateWithDuration(1, animations: {
            self.alpha = 0
            }) { (complete) in
                self.removeFromSuperview()
        }
    }
    
}
