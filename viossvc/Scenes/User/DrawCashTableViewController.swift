//
//  DrawCashTableViewController.swift
//  viossvc
//
//  Created by 木柳 on 2016/11/26.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD
class DrawCashTableViewController: BaseTableViewController, UITextFieldDelegate {
    //MARK: 属性
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var cashNumLabel: UILabel!
    @IBOutlet weak var drawCashText: UITextField!
    @IBOutlet weak var drawCashLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var drawCashBtn: UIButton!
    
    
    //MARK: lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if CurrentUserHelper.shared.userInfo.has_passwd_  != 1 {
            let alertController = UIAlertController.init(title: "提现密码", message: "还未设置提现密码，前往设置", preferredStyle: .Alert)
            let setAction = UIAlertAction.init(title: "前去设置", style: .Default, handler: { [weak self](sender) in
                alertController.dismissController()
                self?.navigationController?.pushViewControllerWithIdentifier("SetDrawCashPassworController", animated: true)
                })
            let cancelAction = UIAlertAction.init(title: "取消", style: .Default, handler: { (sender) in
                alertController.dismissController()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(setAction)
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        //bankName
        if CurrentUserHelper.shared.userInfo.currentBanckCardName != nil{
            let bankNum = CurrentUserHelper.shared.userInfo.currentBankCardNumber! as NSString
            let bankName = CurrentUserHelper.shared.userInfo.currentBanckCardName! as NSString
            if bankNum == "" || bankName == ""{
                bankNameLabel.text = "银行卡格式错误"
                return
            }
            
            bankNameLabel.text = bankName.substringToIndex(4) + "(\(bankNum.substringFromIndex(bankNum.length-4)))"
        }else{
            bankNameLabel.text = "暂无默认银行卡"
        }
    }
    //MARK: --View
    func initView() {
        //contentView
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        //drawCashBtn
        drawCashBtn.layer.cornerRadius = 5
        drawCashBtn.layer.masksToBounds = true
        drawCashBtn.enabled = false
        //cashNum
        cashNumLabel.text = "\(Double(CurrentUserHelper.shared.userInfo.user_cash_) / 100)"
        //drawCashText
        drawCashText.becomeFirstResponder()
        
    }
    
    func updateView(drawCash: String) {
        drawCashBtn.enabled = drawCash.characters.count != 0
        drawCashBtn.backgroundColor = drawCashBtn.enabled ? UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1) : UIColor.init(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
    }
    
    //MARK: --DrawCash
    @IBAction func drawCashBtnTapped(sender: UIButton) {
        MobClick.event(AppConst.Event.drawcash)
        if CurrentUserHelper.shared.userInfo.currentBanckCardName == nil {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请选择提现银行卡", ForDuration: 1, completion: nil)
            return
        }
        
        if bankNameLabel.text == "银行卡格式错误"{
            SVProgressHUD.showErrorMessage(ErrorMessage: "银行卡格式错误", ForDuration: 1, completion: nil)
            return
        }
        
        if checkTextFieldEmpty([drawCashText]) {
            view.endEditing(true)
            let passwordController: EnterPasswordViewController =  storyboard?.instantiateViewControllerWithIdentifier("EnterPasswordViewController") as! EnterPasswordViewController
            passwordController.modalPresentationStyle = .Custom
            passwordController.Password = { [weak self](password) in
                self?.checkPassword(password)
            }
            presentViewController(passwordController, animated: true, completion: { [weak self] in
                if let strongSelf = self{
                    passwordController.valueLabel.text = "￥\(strongSelf.drawCashText.text!)"
                }
            })
        }
    }
    @IBAction func allDrawBtnTapped(sender: AnyObject) {
        MobClick.event(AppConst.Event.drawcash_total)
        drawCashText.text = cashNumLabel.text
        updateView(drawCashText.text!)
    }
    //检查密码
    func checkPassword(password: String) {
        SVProgressHUD.showProgressMessage(ProgressMessage: "")
        AppAPIHelper.userAPI().checkDrawCashPassword(CurrentUserHelper.shared.userInfo.uid, password: password, type: 1,complete: { [weak self](result) in
            self?.drawCashRequest(password)
        }, error: errorBlockFunc())
    }
    //提现
    func drawCashRequest(password: String) {
        let model = DrawCashModel()
        model.uid = CurrentUserHelper.shared.userInfo.uid
        model.account = CurrentUserHelper.shared.userInfo.currentBankCardNumber
        model.cash = Int(Double(drawCashText.text!)!) * 100
        AppAPIHelper.userAPI().drawCash(model, complete: { [weak self](result) in
            SVProgressHUD.dismiss()
            let controller: DrawCashDetailViewController = self?.storyboard?.instantiateViewControllerWithIdentifier("DrawCashDetailViewController") as! DrawCashDetailViewController
            self?.navigationController?.pushViewController(controller, animated: true)
        }, error: errorBlockFunc())
    }
    //textField's Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let resultText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
//        if resultText == "0" {
//            return false
//        }
        let userCash = Double(CurrentUserHelper.shared.userInfo.user_cash_) / 100
        if (resultText.characters.count != 0 && Double(resultText)! > userCash ){
            showErrorWithStatus("提现金额超限")
            return false
        }
        updateView(resultText)
        return true
    }
}
