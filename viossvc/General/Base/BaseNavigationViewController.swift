//
//  BaseNavigationViewController.swift
//  viossvc
//
//  Created by 千山暮雪 on 2017/3/17.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

class BaseNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        
        if viewControllers.count > 0 {
            
            viewController.hidesBottomBarWhenPushed = true
            
            let backBtn:UIButton = UIButton.init(type: .Custom)
            backBtn.setBackgroundImage(UIImage.init(named: "nav-back-select"), forState: .Normal)
            backBtn.addTarget(self, action: #selector(self.backAction), forControlEvents: .TouchUpInside)
            backBtn.sizeToFit()
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    func backAction() {
        self.popViewControllerAnimated(true)
    }
}