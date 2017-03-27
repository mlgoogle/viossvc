//
//  AddBankCardViewController.swift
//  viossvc
//
//  Created by 木柳 on 2016/11/27.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD
class AddBankCardViewController: BaseTableViewController, UITextFieldDelegate{
    @IBOutlet weak var cardNumberTextfield: UITextField!
    @IBOutlet weak var nameTextfiled: UITextField!
    @IBOutlet weak var bankNameTextfield: UITextField!
    @IBOutlet weak var phoneNumberTextfield: UITextField!
    
    
    
    
    @IBAction func bindBankCard(sender: AnyObject) {
        
        if checkTextFieldEmpty([cardNumberTextfield,nameTextfiled,bankNameTextfield,phoneNumberTextfield]) {
            let predicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", AppConst.Text.PhoneFormat)
            if predicate.evaluateWithObject(phoneNumberTextfield.text) == false {
                showErrorWithStatus(AppConst.Text.PhoneFormatErr)
                return;
            }
            
            SVProgressHUD.showProgressMessage(ProgressMessage: "绑定中...")
            AppAPIHelper.userAPI().newBankCard([
                "uid_":CurrentUserHelper.shared.userInfo.uid,
                "account_": cardNumberTextfield.text!,
                "bank_username_":nameTextfiled.text!,
//                "bank_id_":1,
                "phone_num_":phoneNumberTextfield.text!
                ], complete: { [weak self](response) in
                    if response == nil{
                        SVProgressHUD.showSuccessMessage(SuccessMessage: "绑定成功", ForDuration: 1, completion: {
                            self?.navigationController?.popViewControllerAnimated(true)
                            NSNotificationCenter.defaultCenter().postNotificationName("updateBankCards", object: nil, userInfo: nil)
                        })
                        return
                    }
                    let result: Int = response as! Int
                    if result == 1{
                        SVProgressHUD.showErrorMessage(ErrorMessage: "银行不匹配", ForDuration: 1, completion: nil)
                        return
                    }
                    
            }) { (error) in
                SVProgressHUD.showErrorMessage(ErrorMessage: error.localizedDescription, ForDuration: 1, completion: nil)
            }
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
       
        if textField == cardNumberTextfield {
            if cardNumberTextfield.text?.characters.count > 0 {
                bankNameTextfield.text = String.bankCardName(cardNumberTextfield.text!) as String
  
            }
        }
        return true
    }
}
