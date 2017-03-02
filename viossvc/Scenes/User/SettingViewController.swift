//
//  SettingViewController.swift
//  viossvc
//
//  Created by 木柳 on 2016/11/27.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD
class SettingViewController: BaseTableViewController {
    
    @IBOutlet weak var userNumLabel: UILabel!
    @IBOutlet weak var cacheLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var aboutUSCell: UITableViewCell!
    @IBOutlet weak var cacheCell: UITableViewCell!
    @IBOutlet weak var versionCell: UITableViewCell!
    
    
    //MARK: --LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    //MARK: --UI
    func initUI() {
        let userNum = CurrentUserHelper.shared.userInfo.phone_num! as NSString
        userNumLabel.text = userNum.stringByReplacingCharactersInRange(NSRange.init(location: 4, length: 4), withString: "****")
        //缓存
        cacheLabel.text = String(format:"%.2f M",Double(calculateCacle()))
        
    }
    @IBAction func logoutBtnTapped(sender: AnyObject) {
        MobClick.event(AppConst.Event.user_logout)
        CurrentUserHelper.shared.logout()
        let rootController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginNavigationController")
        UIApplication.sharedApplication().keyWindow!.rootViewController = rootController
    }
    
    // 计算缓存
    func calculateCacle() ->Double {
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        let files = NSFileManager.defaultManager().subpathsAtPath(path!)
        var size = 0.00
        for file in files! {
            let filePath = path?.stringByAppendingString("/\(file)")
            let fileAtrributes = try! NSFileManager.defaultManager().attributesOfItemAtPath(filePath!)
            for (attrKey,attrVale) in fileAtrributes {
                if attrKey == NSFileSize {
                    size += attrVale.doubleValue
                }
            }
        }
        let totalSize = size/1024/1024
        return totalSize
    }
    // 清除缓存
    func clearCacleSizeCompletion(completion: (()->Void)?) {
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        let files = NSFileManager.defaultManager().subpathsAtPath(path!)
        for file in files! {
            let filePath = path?.stringByAppendingString("/\(file)")
            if NSFileManager.defaultManager().fileExistsAtPath(filePath!) {
                do{
                    try NSFileManager.defaultManager().removeItemAtPath(filePath!)
                }catch{
                    
                }
            }
        }
        completion!()
        
    }
    //MARK: --TableView
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell == cacheCell{
            MobClick.event(AppConst.Event.user_clearcache)
            clearCacleSizeCompletion({ [weak self] in
                self?.cacheLabel.text = String(format:"%.2f M",Double(self!.calculateCacle()))
                SVProgressHUD.showSuccessMessage(SuccessMessage: "清除成功", ForDuration: 1, completion: nil)
            })
            return
        }
        
//        if cell == authCell && (authStatus == "未认证" || authStatus == "认证失败"){
//            performSegueWithIdentifier("AuthUserViewController", sender: nil)
//            return
//        }
        
        if cell == versionCell {
            MobClick.event(AppConst.Event.user_version)
        }
        
        if cell == aboutUSCell{
            UIApplication.sharedApplication().openURL(NSURL.init(string: "http://www.yundiantrip.com/")!)
            return
        }
    }
}
