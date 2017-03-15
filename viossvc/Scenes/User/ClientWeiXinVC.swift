//
//  ClientWeiXinVC.swift
//  viossvc
//
//  Created by macbook air on 17/3/15.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import Foundation
import SVProgressHUD
class ClientWeiXinVC: UIViewController {
    
    var accountLabel: UILabel = UILabel()
    var accountName: UILabel = UILabel()
    var copyBtn: UIButton = UIButton()
    var evaluateBtn: UIButton = UIButton()
    
    var weiXinNumber:String?
    var weiXinName: String?
    
    var isRefresh: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        title = "联系客户"
        
        let leftBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        leftBtn.setImage(UIImage.init(named: "return"), forState: UIControlState.Normal)
        leftBtn.addTarget(self, action: #selector(didBack), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        setupUI()
    }
    //自定义导航栏返回按钮
    func didBack() {
        isRefresh!()
        navigationController?.popViewControllerAnimated(true)
    }
    
    func setupUI(){
        
        view.addSubview(accountLabel)
        view.addSubview(accountName)
        view.addSubview(copyBtn)
        view.addSubview(evaluateBtn)
        accountLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(126)
            make.height.equalTo(18)
        }
        accountLabel.textAlignment = .Center
        accountLabel.font = UIFont.systemFontOfSize(18)
        accountLabel.text = "'" + "'" + weiXinName! + "'" + "' " + "微信账号"
        accountLabel.textColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        
        accountName.snp_makeConstraints { (make) in
            make.centerX.equalTo(accountLabel)
            make.top.equalTo(accountLabel.snp_bottom).offset(10)
        }
        accountName.textAlignment = .Center
        accountName.font = UIFont.systemFontOfSize(14)
        accountName.text = weiXinNumber
        accountName.textColor = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        
        copyBtn.snp_makeConstraints { (make) in
            make.centerX.equalTo(accountName)
            make.top.equalTo(accountName.snp_bottom).offset(30)
            make.right.equalTo(view).offset(-62)
            make.left.equalTo(view).offset(62)
            make.height.equalTo(45)
        }
        copyBtn.setTitle("点击复制助理微信号", forState: UIControlState.Normal)
        copyBtn.setTitleColor(UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1), forState: UIControlState.Normal)
        copyBtn.backgroundColor = UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
        copyBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        copyBtn.addTarget(self, action: #selector(copyBtnDidClick), forControlEvents: UIControlEvents.TouchUpInside)
        
        evaluateBtn.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.left.equalTo(view).offset(15)
            make.right.equalTo(view).offset(-15)
            make.height.equalTo(45)
            make.bottom.equalTo(view).offset(-30)
        }
        evaluateBtn.setTitle("完成", forState: UIControlState.Normal)
        evaluateBtn.setTitleColor(UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1), forState: UIControlState.Normal)
        evaluateBtn.backgroundColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1)
        evaluateBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        evaluateBtn.layer.cornerRadius = 22
        evaluateBtn.layer.masksToBounds = true
        evaluateBtn.addTarget(self, action: #selector(evaluateDidClick), forControlEvents: UIControlEvents.TouchUpInside)
        evaluateBtn.enabled = true
    }
    
    //点击复制助理微信号按钮
    func copyBtnDidClick() {
        let pasteboard = UIPasteboard.generalPasteboard()
        if accountName.text?.characters != nil {
            pasteboard.string = accountName.text
            SVProgressHUD.showSuccessMessage(SuccessMessage: "复制成功", ForDuration: 1.0, completion: {
                SVProgressHUD.dismiss()
            })
        }
    }
    //点击完成按钮
    func evaluateDidClick() {
        didBack()
    }
}
