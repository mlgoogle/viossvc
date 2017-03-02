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
                return "认证中"
            case 1:
                return "认证通过"
            case 2:
                return "认证失败"
            default:
                return ""
            }
        }
    }
    @IBOutlet weak var priceSettingCell: UITableViewCell!
    
    //MARK: --LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initData()
        initUI()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    //MARK: --DATA
    func initData() {
        checkAuthStatus()
        requsetCommonBankCard()
        SVProgressHUD.showProgressMessage(ProgressMessage: "初始化用户数据")
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
            for i in 100...104 {
                if i <= 100 + CurrentUserHelper.shared.userInfo.praise_lv {
                    let starImage: UIImageView = userContentView.viewWithTag(i) as! UIImageView
                    starImage.image = UIImage.init(named: "my_star_fill")
                }
            }
        }
        
        let askTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(askTapGestureTapped))
        qustionContent.addGestureRecognizer(askTapGesture)
        
        authStatusLabel.text = authStatus
        authCell.accessoryType = authStatus == "未认证" || authStatus == "认证失败" ? .DisclosureIndicator : .None
    }
    func askTapGestureTapped() {
        MobClick.event(AppConst.Event.user_question)
        let serviceTel = "0571-87611687"
        let alert = UIAlertController.init(title: "呼叫", message: serviceTel, preferredStyle: .Alert)
        let ensure = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(serviceTel)")!)
        })
        let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: { (action: UIAlertAction) in
            
        })
        alert.addAction(ensure)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
//        UIApplication.sharedApplication().openURL(NSURL.init(string: "telprompt:0571-87611687")!)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell == authCell && (authStatus == "未认证" || authStatus == "认证失败"){
            let vc = IDVerifyVC()
            navigationController?.pushViewController(vc, animated: true)
            return
//        } else if cell == priceSettingCell && authStatus == "认证通过" {
        } else if cell == priceSettingCell {
            NSLog("金额设置")
            updateFollowCount()
            priceList()
            priceSetting()
            return
        }

    }
    
    func updateFollowCount() {
        let req = FollowCountRequestModel()
        req.uid = CurrentUserHelper.shared.uid
        req.type = 2
        AppAPIHelper.userAPI().followCount(req, complete: { (response) in
            if let model = response as? FollowCountModel {
                NSLog("\(model.follow_count)")
            }
            }, error: nil)
    }
    
    func priceList() {
        AppAPIHelper.userAPI().priceList({ (response) in
            if let models = response as? [PriceModel] {
                NSLog("\(models)")
            }
            }, error: { (error) in
        
        })
    }
    
    func priceSetting() {
        let req = PriceSettingRequestModel()
        req.uid = CurrentUserHelper.shared.uid
        req.wx_num = "12345asdfg"
        req.wx_url = "http://xxx.xxx.com/xxx.png"
        req.service_price = 88
        AppAPIHelper.userAPI().priceSetting(req, complete: { (response) in
            if let model = response as? PriceSettingModel {
                let msg = model.result == 0 ? "设置成功" : "设置失败"
                SVProgressHUD.showWithStatus(msg)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64 (1.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    SVProgressHUD.dismiss()
                })
            }
            }, error: { (err) in
                
        })
    }
    
}
