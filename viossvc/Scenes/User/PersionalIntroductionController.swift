//
//  PersionalIntroductionController.swift
//  viossvc
//
//  Created by 千山暮雪 on 2017/3/17.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import UIKit

class PersionalIntroductionController: UIViewController,UITextViewDelegate {
    
    var textView:UITextView?
    var placeholder:UILabel?
    var textNumLabel:UILabel?
    
    
    override func viewDidLoad() {
        
        view.backgroundColor = UIColor.whiteColor()
        
        title = "个人简介"
        
        addNavBtn()
        addViews()
    }
    
    func addNavBtn() {
        let rightBtn:UIButton = UIButton.init(type: .Custom)
        rightBtn.setTitle("完成", forState: .Normal)
        rightBtn.backgroundColor = UIColor.whiteColor()
        rightBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        rightBtn.titleLabel?.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        rightBtn.sizeToFit()
        rightBtn.addTarget(self, action: #selector(self.didEndAction), forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
    }
    
    func addViews() {
        
        textView = UITextView.init()
        textView?.font = UIFont.systemFontOfSize(14)
        textView?.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        textView?.backgroundColor = UIColor.whiteColor()
        textView?.layer.borderWidth = 1
        textView?.layer.borderColor = UIColor.init(decR: 226, decG: 226, decB: 226, a: 1).CGColor
        textView?.delegate = self
        view.addSubview(textView!)
        textView?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(15)
            make.height.equalTo(200)
        })
        
        placeholder = UILabel.init(frame: CGRectMake(5, 7, 200, 20))
        placeholder?.text = "个人简介说明..."
        placeholder?.textColor = UIColor.init(decR: 153, decG: 153, decB: 153, a: 1)
        textView?.addSubview(placeholder!)
        
        textNumLabel = UILabel.init()
        textNumLabel?.font = UIFont.systemFontOfSize(10)
        textNumLabel?.textColor = UIColor.init(decR: 153, decG: 153, decB: 153, a: 1)
        textNumLabel?.text = "200字符以内"
        textNumLabel?.textAlignment = .Right
        view.addSubview(textNumLabel!)
        textNumLabel?.snp_makeConstraints(closure: { (make) in
            make.width.equalTo(80)
            make.height.equalTo(15)
            make.right.equalTo((textView?.snp_right)!).offset(-10)
            make.bottom.equalTo((textView?.snp_bottom)!).offset(-5)
        })
    }
    
    // 完成
    func didEndAction() {
    }
    
    //MARK: delegate
    
    func textViewDidChange(textView: UITextView) {
        
        if textView.text.length() > 0 {
            placeholder?.removeFromSuperview()
        }else {
            textView.addSubview(placeholder!)
        }
        
        if textView.text.length() > 10 {
            
            let text:String = textView.text
            let index = text.startIndex.advancedBy(10)
            textView.text = text.substringToIndex(index)
        }
    }
    
    override func didReceiveMemoryWarning() {
    }
}
