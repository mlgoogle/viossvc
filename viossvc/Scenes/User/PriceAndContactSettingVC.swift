//
//  PriceAndContactSettingVC.swift
//  viossvc
//
//  Created by 陈奕涛 on 17/3/3.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD


class PriceAndContactSettingVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PriceSelectionCellDelegate {
    
    lazy var tips:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor.init(hexString: "#333333")
        label.text = "选择显示你的微信号售卖金额"
        return label
    }()
    
    lazy var submit:UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 22
        button.backgroundColor = UIColor.init(hexString: "#eeeeee")
        button.setTitle("完成", forState: .Normal)
        button.setTitleColor(UIColor.init(hexString: "#cccccc"), forState: .Normal)
        button.setTitleColor(UIColor.init(hexString: "#ffffff"), forState: .Normal)
        return button
    }()
    
    var table:UITableView?
    
    var wxAccount:String?
    var wxQRCodeUrl:String?
    
    var priceList:[PriceModel] = []
    var selectedPriceID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(hexString: "#ffffff")
        
        getPriceList()
        initTableView()
        hideKeyboard()
        
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func getPriceList() {
        AppAPIHelper.userAPI().priceList({ [weak self](response) in
            if let models = response as? [PriceModel] {
                self?.priceList = models
                self?.table?.reloadSections(NSIndexSet.init(index: 2), withRowAnimation: .Fade)
            }
            }, error: { (error) in
                
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        initNav()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: -- Nav
    func initNav()  {
        title = "金额设置"
        
    }
    
    func rightItemTapped(item: UIBarButtonItem) {
        view.endEditing(true)
//        guard name != nil && id != nil else {
//            SVProgressHUD.showWainningMessage(WainningMessage: "请完善信息", ForDuration: 1.5, completion: nil)
//            return
//        }
//        if id!.characters.count != 18  {
//            SVProgressHUD.showWainningMessage(WainningMessage: "身份证号长度有误", ForDuration: 1.5, completion: nil)
//            return
//        }
        
        
//        let req = IDverifyRequestModel()
//        req.idcard_urlname = name!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
//        req.uid = CurrentUserHelper.shared.uid
//        req.idcard_name = name
//        req.idcard_num = id
//        AppAPIHelper.userAPI().IDVerify(req, complete: { [weak self](response) in
//            CurrentUserHelper.shared.userInfo.auth_status_ = 0
//            SVProgressHUD.showWainningMessage(WainningMessage: "提交验证信息成功", ForDuration: 1.5, completion: { () in
//                self?.navigationController?.popViewControllerAnimated(true)
//            })
//            }, error: { (err) in
//                SVProgressHUD.showWainningMessage(WainningMessage: "提交验证信息失败，请稍后再试", ForDuration: 1.5, completion: nil)
//        })
    }
    
    //MARK: -- tableView
    func initTableView() {
        table = UITableView.init(frame: CGRectZero, style: .Plain)
        table?.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 80
        table?.rowHeight = UITableViewAutomaticDimension
        table?.tableFooterView = UIView()
        table?.separatorStyle = .None
        table?.registerClass(ContactCell.self, forCellReuseIdentifier: "ContactCell")
        table?.registerClass(PriceSelectionCell.self, forCellReuseIdentifier: "PriceSelectionCell")
        view.addSubview(table!)
        table?.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return priceList.count / 3 + (priceList.count % 3 > 0 ? 1 : 0)
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! ContactCell
            return cell
        } else if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("PriceSelectionTipsCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .None
                cell?.selectionStyle = .None
                cell?.contentView.addSubview(tips)
                tips.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(15)
                    make.top.equalTo(8)
                    make.right.equalTo(-15)
                    make.height.equalTo(18)
                    make.bottom.equalTo(-7.5)
                })
            }
            return cell!
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("PriceSelectionCell", forIndexPath: indexPath) as! PriceSelectionCell
            cell.delegate = self
            var infos = [PriceModel]()
            for i in (indexPath.row*3)..<(indexPath.row*3+3) {
                if i < priceList.count {
                    infos.append(priceList[i])
                } else { break }
            }
            cell.update(infos, selectedID: selectedPriceID)
            return cell
        } else if indexPath.section == 3 {
            var cell = tableView.dequeueReusableCellWithIdentifier("IDVerifyCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .None
                cell?.selectionStyle = .None
                cell?.contentView.addSubview(submit)
                submit.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(15)
                    make.right.equalTo(-15)
                    make.top.equalTo(20)
                    make.bottom.equalTo(-20)
                    make.height.equalTo(45)
                })
            }
            
            return cell!
        }
        var cell = tableView.dequeueReusableCellWithIdentifier("IDVerifyCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.accessoryType = .None
            cell?.selectionStyle = .None
        }
        
        return cell!
    }
    
    func keyboardWillShow(notification: NSNotification?) {
        let frame = notification!.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let inset = UIEdgeInsetsMake(0, 0, frame.size.height, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
    }
    
    override func hideKeyboard() {
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(touchWhiteSpace))
        touch.numberOfTapsRequired = 1
        touch.cancelsTouchesInView = false
        table?.addGestureRecognizer(touch)
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    func selectedPrice(priceID: Int) {
        selectedPriceID = priceID
        table?.reloadSections(NSIndexSet.init(index: 2), withRowAnimation: .None)
    }
    
}
