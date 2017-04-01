//
//  MainViewController.swift
//  viossvc
//
//  Created by yaowang on 2016/10/27.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD
class MainViewController: UIViewController {
    var childViewControllerIdentifier:String?
    var childViewControllerData:AnyObject?
    static var childViewControllerIdentifierKey = "childViewControllerIdentifier"
    static var childViewControllerDataKey = "childViewControllerData"
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initChildViewController()
        
        autoLogin();
    }
    
    
    private func autoLogin() {
        if childViewControllerIdentifier != nil {
            return
        }
        
        if  CurrentUserHelper.shared.autoLogin({ [weak self] (model) in
            self?.didAutoLoginComplete(model as? UserInfoModel)
            }, error: errorBlockFunc()) {
            SVProgressHUD.showProgressMessage(ProgressMessage: "登录中...")
        }
    }
    
    func didAutoLoginComplete(userInfo:UserInfoModel?) {
        SVProgressHUD.dismiss()
        UIApplication.sharedApplication().keyWindow!.rootViewController = self.storyboardViewController() as MainTabBarController
        
    }
    
    private func initChildViewController() {
        if childViewControllerIdentifier != nil {
            let childViewController:UIViewController! = storyboard!.instantiateViewControllerWithIdentifier(childViewControllerIdentifier!)
            if childViewControllerData != nil {
                childViewController.setValue(childViewControllerData, forKey: MainViewController.childViewControllerDataKey)
            }
            
            addChildViewController(childViewController)
            view.addSubview(childViewController.view)
            visualEffectView.hidden = false
            loginButton.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func didActionLogin(sender: AnyObject) {
       
//        navigationController?.pushViewControllerWithIdentifier(MainViewController.className(), animated: true, valuesForKeys: [MainViewController.childViewControllerIdentifierKey:LoginViewController.className()])
        
       let loginVC = LoginVC()
        loginVC.title = "登录"
        navigationController?.pushViewController(loginVC, animated: true)
        
    }
    
    @IBAction func didActionRegister(sender: AnyObject) {
        MobClick.event(AppConst.Event.sign_btn)
//        navigationController?.pushViewControllerWithIdentifier(MainViewController.className(), animated: true, valuesForKeys: [MainViewController.childViewControllerIdentifierKey:RegisterViewController.className()])
        let vc = LoginWithMSGVC()
        vc.title = "注册"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
