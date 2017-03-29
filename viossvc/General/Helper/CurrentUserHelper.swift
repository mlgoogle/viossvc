//
//  CurrentUserHelper.swift
//  viossvc
//
//  Created by yaowang on 2016/11/24.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD


class CurrentUserHelper: NSObject {
    static let shared = CurrentUserHelper()
    private let keychainItem:OEZKeychainItemWrapper = OEZKeychainItemWrapper(identifier: "com.yundian.viossvc.account", accessGroup:nil)
    private var _userInfo:UserInfoModel?
    private var _password:String!
    private var _deviceToken:String? = NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken") as? String
    private var _firstLanuch = true
    
    var deviceToken:String! {
        get {
            return _deviceToken ?? ""
        }
        set {
            _deviceToken = newValue
            updateDeviceToken()
        }
    }
    
    var userInfo:UserInfoModel! {
        get {
            return _userInfo ?? UserInfoModel()
        }
    }
    
    var isLogin : Bool {
        return _userInfo != nil
    }
    
    var uid : Int {
        return _userInfo!.uid
    }
    
    
    func userLogin(phone:String,password:String,complete:CompleteBlock,error:ErrorBlock) {
        
        let loginModel = LoginModel()
        loginModel.phone_num = phone
        loginModel.passwd = password
        _password = password
        
        AppAPIHelper.userAPI().login(loginModel, complete: {  [weak self] (model) in
                self?.loginComplete(model)
                complete(model)
            }, error:error)
    }
    
    func autoLogin(complete:CompleteBlock,error:ErrorBlock) -> Bool {
        let account = lastLoginAccount()
        if !NSString.isEmpty(account.phone) &&  !NSString.isEmpty(account.password)  {
            userLogin(account.phone!, password:account.password!, complete: complete, error: error)
            return true
        }
        return false
    }
    
    private func loginComplete(model:AnyObject?) {
        self._userInfo = model as? UserInfoModel
        keychainItem.resetKeychainItem()
        keychainItem.setObject(_userInfo!.phone_num, forKey: kSecAttrAccount)
        keychainItem.setObject(_password, forKey: kSecValueData)
        updateDeviceToken()
        if _firstLanuch {
            versionCheck()
            _firstLanuch = false
        }
        requestUserCash()
        checkAuthStatus()
    }
    
    //查询用户余额
    func requestUserCash() {
        AppAPIHelper.userAPI().userCash(CurrentUserHelper.shared.userInfo.uid, complete: { (result) in
            if result == nil{
                return
            }
            let resultDic = result as? Dictionary<String, AnyObject>
            
            if let hasPassword = resultDic!["has_passwd_"] as? Int{
                CurrentUserHelper.shared.userInfo.has_passwd_ = hasPassword
            }
            if let userCash = resultDic!["user_cash_"] as? Int{
                CurrentUserHelper.shared.userInfo.user_cash_ =  userCash
            }
            
            }, error: { (err) in
            
            })
    }
    /**
     查询认证状态
     */
    func checkAuthStatus() {
        AppAPIHelper.userAPI().anthStatus(CurrentUserHelper.shared.userInfo.uid, complete: { (result) in
            if let errorReason = result?.valueForKey("failed_reason_") as? String {
                if  errorReason.characters.count != 0 {
                    SVProgressHUD.showErrorMessage(ErrorMessage: errorReason, ForDuration: 1,
                        completion: nil)
                }
            }
            
            if let status = result?.valueForKey("review_status_") as? Int {
                CurrentUserHelper.shared.userInfo.auth_status_ = status
            }
            
            }, error: { (err) in
            
            })
    }
    
    func versionCheck() {
        AppAPIHelper.commenAPI().version({ (model) in
            if let verInfo = model as? [String:AnyObject] {
                UpdateManager.checking4Update(verInfo["newVersion"] as! String, buildVer: verInfo["buildVersion"] as! String, forced: verInfo["mustUpdate"] as! Bool, result: { (gotoUpdate) in
                    if gotoUpdate {
                        UIApplication.sharedApplication().openURL(NSURL.init(string: verInfo["DetailedInfo"] as! String)!)
                        if (verInfo["mustUpdate"] as? Bool)! {
                            exit(0)
                        }
                    }
                })
            }
            }, error: { (err) in
                
        })
    }
    
    func logout() {
        AppAPIHelper.userAPI().logout(_userInfo!.uid)
        nodifyPassword("")
        self._userInfo = nil
    }
    
    func nodifyPassword(password:String) {
        keychainItem.setObject(password, forKey: kSecValueData)
    }
    
    func lastLoginAccount()->(phone:String?,password:String?){
        return (keychainItem.objectForKey(kSecAttrAccount) as? String,keychainItem.objectForKey(kSecValueData) as? String)
    }
    
    private func updateDeviceToken() {
        if isLogin && _deviceToken != nil {
            AppAPIHelper.userAPI().updateDeviceToken(uid, deviceToken: _deviceToken!, complete: nil, error: nil)
        }
    }
}
