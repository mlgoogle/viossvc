//
//  PersionalIntroductionController.swift
//  viossvc
//
//  Created by 千山暮雪 on 2017/3/17.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD

class PersionalIntroductionController: UIViewController,UITextViewDelegate {
    
    var textView:UITextView?
    var placeholder:UILabel?
    var textNumLabel:UILabel?
    
    
    override func viewDidLoad() {
        
        view.backgroundColor = UIColor.whiteColor()
        
        title = "个人简介"
        
        addNavBtn()
        addViews()
        addData()
    }
    
    func addNavBtn() {
        let rightBtn:UIButton = UIButton.init(frame: CGRectMake(ScreenWidth - 65, 27, 50, 30))
        rightBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        rightBtn.setTitleColor(UIColor.init(decR: 51, decG: 51, decB: 51, a: 1), forState: .Normal)
        rightBtn.setTitle("完成", forState: .Normal)
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
        
        let req:PersionalIntroductionMode = PersionalIntroductionMode()
        req.uid = CurrentUserHelper.shared.uid
        req.introduce = textView?.text
        req.type = 2
        
        AppAPIHelper.userAPI().persionalIntroduct(req, complete: { [weak self](response) in
            
            let model = response as! PersionalIntroductResultModel
            if model.result == "success"{
                
                SVProgressHUD.showSuccessMessage(SuccessMessage: "简介更新成功", ForDuration: 1.5 , completion: {
                    self?.navigationController?.popViewControllerAnimated(true)
                })
            }else {
                SVProgressHUD.showErrorMessage(ErrorMessage: "简介更新失败，请稍后再试", ForDuration: 1.5, completion: {
                })
            }
            
        }) { (error) in
        }
    }
    
    func addData() {
        let req:PersionalIntroductionMode = PersionalIntroductionMode()
        req.uid = CurrentUserHelper.shared.uid
        req.introduce = ""
        req.type = 1
        
        AppAPIHelper.userAPI().persionalIntroduct(req, complete: { [weak self](response) in
            if response == nil {
                
            }
            else{
                let model = response as! PersionalIntroductResultModel
                if model.result?.length() != 0 {
                    
                    self!.textView?.text = model.result
                    self!.placeholder?.removeFromSuperview()
                }
            }
           
            
        }) { (error) in
        }
    }
    
    //MARK: delegate
    
    func textViewDidChange(textView: UITextView) {
        
        if textView.text.length() > 0 {
            placeholder?.removeFromSuperview()
        }else {
            textView.addSubview(placeholder!)
        }
        
        if textView.text.length() > 200 {
            
            let text:String = textView.text
            let index = text.startIndex.advancedBy(200)
            textView.text = text.substringToIndex(index)
        }
    }
    
    override func didReceiveMemoryWarning() {
    }
}
