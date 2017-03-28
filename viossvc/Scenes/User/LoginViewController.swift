//
//  LoginViewController.swift
//  viossvc
//
//  Created by yaowang on 2016/10/27.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import Foundation
import SVProgressHUD

class BaseLoginViewController: UITableViewController {
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    private let minTopHeight:CGFloat = 175.0;
    private let maxTopHeight:CGFloat = 275.0;
    private let fromHeigth:CGFloat = 206.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldAttributedPlaceholder(textField1);
        setTextFieldAttributedPlaceholder(textField2);
        if textField3 != nil {
            setTextFieldAttributedPlaceholder(textField3)
        }
        self.view.userInteractionEnabled = true;
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(didActionHideKeyboard(_:))))
    }

    private func setTextFieldAttributedPlaceholder(textField:UITextField) {
        let attributes = [NSFontAttributeName:UIFont.systemFontOfSize(15),
                          NSForegroundColorAttributeName:UIColor(white:1,alpha: 0.5)];
        
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: attributes);
        
    }
    
    func didActionHideKeyboard(sender: AnyObject?) {
        hideKeyboard()
    }
    
    
    private func topHeight() -> CGFloat {
        if CGRectGetHeight(self.view.frame) - maxTopHeight - fromHeigth < 50  {
            return minTopHeight;
        }
        return maxTopHeight;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0  {
            return topHeight();
        }
        else if indexPath.row == 2  {
            return CGRectGetHeight(self.view.frame) - topHeight() - fromHeigth;
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath);
    }
    
    
    func checkPhoneFormat(phone:String) -> Bool {
        let predicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", AppConst.Text.PhoneFormat)
        if predicate.evaluateWithObject(phone) == false {
            showErrorWithStatus(AppConst.Text.PhoneFormatErr)
            return false;
        }
        return true;
    }
    
    func didLoginComplete(userInfo:UserInfoModel?) {
        SVProgressHUD.dismiss()
        UIApplication.sharedApplication().keyWindow!.rootViewController = self.storyboardViewController() as MainTabBarController
        
    }
    
    func userLogin(phone:String,password:String) {
        CurrentUserHelper.shared.userLogin(phone, password: password, complete:  {  [weak self] (model) in
            self?.didLoginComplete(model as? UserInfoModel)
            }, error: errorBlockFunc())
    }
}

class LoginViewController: BaseLoginViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let account = CurrentUserHelper.shared.lastLoginAccount()
        textField1.text = account.phone
        textField2.text = account.password
    }

    
    
    @IBAction func didActionLogin(sender: AnyObject) {
        MobClick.event(AppConst.Event.login)
        if checkTextFieldEmpty([textField1,textField2]) && checkPhoneFormat(textField1.text!) {
            hideKeyboard();
            let loginModel = LoginModel();
            loginModel.phone_num = textField1.text
            loginModel.passwd = textField2.text?.trim()
            SVProgressHUD.showProgressMessage(ProgressMessage: "登录中...")
            userLogin(textField1.text!,password:textField2.text!)
        }
    }
    
    @IBAction func didActionRegister(sender: AnyObject) {
        let navController = navigationController;
        navController!.popViewControllerAnimated(false);
        navController?.pushViewControllerWithIdentifier(MainViewController.className(), animated: false, valuesForKeys: [MainViewController.childViewControllerIdentifierKey:RegisterViewController.className(),MainViewController.childViewControllerDataKey:false]);
    }
    

}
