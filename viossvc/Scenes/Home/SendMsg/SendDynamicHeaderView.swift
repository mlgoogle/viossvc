//
//  SendDynamicHeaderView.swift
//  viossvc
//
//  Created by 巩婧奕 on 2017/3/7.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import UIKit

class SendDynamicHeaderView: UICollectionReusableView,UITextViewDelegate {
    
    var textView:UITextView?
    var placeholderLabel:UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        
        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func  addViews() {
        textView = UITextView.init(frame: CGRectMake(5, 5, ScreenWidth - 10, self.bounds.size.height - 10))
        textView?.delegate = self
        textView?.font = UIFont.systemFontOfSize(16)
        textView?.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        
        self.addSubview(textView!)
        
        placeholderLabel = UILabel.init(frame: CGRectMake(6, 6, 200, 20))
        placeholderLabel?.textColor = UIColor.init(decR: 153, decG: 153, decB: 153, a: 1)
        placeholderLabel?.font = UIFont.systemFontOfSize(16)
        placeholderLabel?.text = "这一刻的想法..."
        textView?.addSubview(placeholderLabel!)
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.text.length() == 0 {
            textView.addSubview(placeholderLabel!)
        }else {
            placeholderLabel?.removeFromSuperview()
        }
    }
}
