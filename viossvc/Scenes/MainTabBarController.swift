//
//  MainTabBarViewController.swift
//  viossvc
//
//  Created by yaowang on 2016/10/27.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import Foundation

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad();
        //友盟的帐号统计
        MobClick.profileSignInWithPUID("\(CurrentUserHelper.shared.userInfo.uid)")
    }
}
