//
//  UserHomeViewController.swift
//  viossvc
//
//  Created by yaowang on 2016/10/27.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import Foundation
import SVProgressHUD
import Kingfisher

class UserHomeViewController: BaseTableViewController {
    
    
    @IBOutlet weak var userCashLabel: UILabel!
    @IBOutlet weak var userHeaderImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var qustionContent: UIView!
    @IBOutlet weak var bankCardNumLabel: UILabel!
    @IBOutlet weak var userContentView: UIView!
    @IBOutlet weak var authCell: UITableViewCell!
    @IBOutlet weak var authStatusLabel: UILabel!
    var authStatus: String? {
        get{
            switch CurrentUserHelper.shared.userInfo.auth_status_ {
            case -1:
                return "未认证"
            case 0:
                return "认证通过"
            case 1:
                return "认证中"
            case 2:
                return "认证失败"
            default:
                return ""
            }
        }
    }
    @IBOutlet weak var priceSettingCell: UITableViewCell!
    @IBOutlet weak var myClientCell: UITableViewCell!
    
    var bankCardNum = 0 // 记录一共有几张卡
    
    //MARK: --LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
        initUI()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let key = "isShownFiestTime2"
        let isshownfirsttime = userDefaults.valueForKey(key)
        
        if isshownfirsttime == nil {
            
            let imageView:UIImageView = UIImageView.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64))
            imageView.image = UIImage.init(named: "助理端新手引导2")
            imageView.alpha = 0.5
            view.addSubview(imageView)
            imageView.userInteractionEnabled = true
            let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.imageTapAction(_:)))
            imageView.addGestureRecognizer(tap)
            
            userDefaults.setValue(true, forKey: key)
        }
        
        //接收通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateImageAndName), name: "updateImageAndName", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateBankCards), name: "updateBankCards", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateIDVerify), name: "IDVerifySuccess", object: nil)
    }
    //移除通知
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    //通知实现
    func updateImageAndName(notification: NSNotification?){
        if CurrentUserHelper.shared.userInfo.nickname != nil {
            userNameLabel.text = CurrentUserHelper.shared.userInfo.nickname
        }
        if (CurrentUserHelper.shared.userInfo.head_url != nil){
            let headUrl = NSURL.init(string: CurrentUserHelper.shared.userInfo.head_url!)
            userHeaderImage.kf_setImageWithURL(headUrl, placeholderImage: UIImage.init(named: "head_boy"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        }
        
    }
    // 更新银行卡数量
    func updateBankCards(notification: NSNotification?) {
        let cardCount:Int = bankCardNum + 1
        bankCardNumLabel.text = "\(cardCount)张"
    }
    // 跟新认证状态
    func updateIDVerify() {
        authStatusLabel.text = "认证通过"
    }
    func imageTapAction(tap:UITapGestureRecognizer) {
        
        let imageView:UIImageView = tap.view as! UIImageView
        imageView.removeFromSuperview()
    }
    
    //MARK: --DATA
    func initData() {
        SVProgressHUD.showProgressMessage(ProgressMessage: "初始化用户数据")
        checkAuthStatus()
        requsetCommonBankCard()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        requestUserCash { [weak self](result) in
            SVProgressHUD.dismiss()
            let userCash =  result as! Int
            self?.userCashLabel.text = "\(Double(userCash)/100)元"
        }
    }
    
    func requsetCommonBankCard() {
        let model = BankCardModel()
        unowned let weakSelf = self
        AppAPIHelper.userAPI().bankCards(model, complete: { (response) in
            guard response != nil else {return}
            let banksData = response as! NSArray
            for bank in banksData{
                let model = bank as! BankCardModel
                if model.is_default == 1{
                    CurrentUserHelper.shared.userInfo.currentBankCardNumber = model.account
                    CurrentUserHelper.shared.userInfo.currentBanckCardName = String.bankCardName(model.account!)
                }
            }
            weakSelf.bankCardNumLabel.text = "\(banksData.count)张"
            weakSelf.bankCardNum = banksData.count
        }) { (error) in
        }
    }
    
    //MARK: --UI
    func initUI() {
        if (CurrentUserHelper.shared.userInfo.head_url != nil){
            let headUrl = NSURL.init(string: CurrentUserHelper.shared.userInfo.head_url!)
            userHeaderImage.kf_setImageWithURL(headUrl, placeholderImage: UIImage.init(named: "head_boy"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        }
        
        if CurrentUserHelper.shared.userInfo.nickname != nil {
            userNameLabel.text = CurrentUserHelper.shared.userInfo.nickname
        }
        
        if CurrentUserHelper.shared.userInfo.praise_lv > 0 {
            for i in 0..<CurrentUserHelper.shared.userInfo.praise_lv {
                let starImage: UIImageView = userContentView.viewWithTag(i + 100) as! UIImageView
                starImage.image = UIImage.init(named: "star-select")
            }
        }
        
        let askTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(askTapGestureTapped))
        qustionContent.addGestureRecognizer(askTapGesture)
        
        authStatusLabel.text = authStatus
        authCell.accessoryType = authStatus == "未认证" || authStatus == "认证失败" ? .DisclosureIndicator : .None
    }
    func askTapGestureTapped() {
        MobClick.event(AppConst.Event.user_question)
        let serviceWeChat = "yundian2017"
        let alert = UIAlertController.init(title: "优悦助理客服微信号", message: serviceWeChat, preferredStyle: .Alert)
        let ensure = UIAlertAction.init(title: "复制微信号", style: .Default, handler: { (action: UIAlertAction) in
            UIPasteboard.generalPasteboard().string = serviceWeChat
            SVProgressHUD.showSuccessMessage(SuccessMessage: "复制成功", ForDuration: 1.0, completion: {
                SVProgressHUD.dismiss()
            })
            })
        let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: { (action: UIAlertAction) in
            
        })
        alert.addAction(cancel)
        alert.addAction(ensure)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell == authCell && (authStatus == "认证中" || authStatus == "认证失败"){
            let vc = IDVerifyVC()
            vc.hidesBottomBarWhenPushed = true
           
            vc.subimitFinished = { ()->() in
               self.checkAuthStatus()
               tableView.reloadData()
            }
            
            navigationController?.pushViewController(vc, animated: true)
            return
        } else if cell == priceSettingCell {
            if authStatus == "认证通过" {
                let vc = PriceAndContactSettingVC()
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            } else if authStatus == "认证中" {
                SVProgressHUD.showWainningMessage(WainningMessage: "认证中，请等待认证成功后再试", ForDuration: 1.5, completion: nil)
            } else {
                SVProgressHUD.showWainningMessage(WainningMessage: "未认证或认证未通过，请先进行个人认证", ForDuration: 1.5, completion: nil)
            }
            return
        }
        
        if cell == myClientCell{
            let vc =  MyClientVC()
            vc.title = "我的客户"
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    
    
}
