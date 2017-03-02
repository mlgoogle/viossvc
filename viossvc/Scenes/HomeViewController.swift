//
//  HomeViewController.swift
//  viossvc
//
//  Created by yaowang on 2016/10/27.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import Foundation


class HomeViewController: BaseRefreshTableViewController {
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clearColor();
    }
    
    override func didRequest() {
        didRequestComplete(nil);
        
    }
    
}
