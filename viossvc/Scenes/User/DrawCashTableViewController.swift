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
        drawCashBtn.backgroundColor = drawCashBtn.enabled ? UIColor(RGBHex: 0x141f33) : UIColor(RGBHex: 0xaaaaaa)
        
        drawCashLabel.text =  "\(drawCash)元"
    }
    //MARK: --DATA
    
    
    //MARK: --Function
    @IBAction func drawCashBtnTapped(sender: UIButton) {
        
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
    
    func checkPassword(password: String) {
        SVProgressHUD.showProgressMessage(ProgressMessage: "")
        AppAPIHelper.userAPI().checkDrawCashPassword(0, password: password, type: 1,complete: { [weak self](result) in
            self?.drawCashRequest(password)
        }, error: errorBlockFunc())
    }
    
    func drawCashRequest(password: String) {
        let model = DrawCashModel()
        AppAPIHelper.userAPI().drawCash(model, complete: { [weak self](result) in
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
        if resultText == "0" {
            return false
        }
        
        let userCash = CurrentUserHelper.shared.userInfo.user_cash_ / 100
        if (resultText.characters.count != 0 && Int(resultText)! > userCash ){
            showErrorWithStatus("提现金额超限")
            return false
        }
        updateView(resultText)
        return true
    }
}
