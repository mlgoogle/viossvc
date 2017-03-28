//
//  UIViewController+Extension.swift
//  viossvc
//
//  Created by yaowang on 2016/10/31.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD
import Qiniu
extension UIViewController {
    
    static func storyboardViewController<T:UIViewController>(storyboard:UIStoryboard) ->T {
        return storyboard.instantiateViewControllerWithIdentifier(T.className()) as! T;
    }
    
    func storyboardViewController<T:UIViewController>() ->T {
        
        return storyboard!.instantiateViewControllerWithIdentifier(T.className()) as! T;
    }
    
    
    func errorBlockFunc()->ErrorBlock {
        return { [weak self] (error) in
            XCGLogger.error("\(error) \(self)")
            self?.didRequestError(error)
        }
    }
    
    func didRequestError(error:NSError) {
        self.showErrorWithStatus(error.localizedDescription)
    }
   
    func showErrorWithStatus(status: String!) {
        SVProgressHUD.showErrorWithStatus(status)
    }
    
    func showWithStatus(status: String!) {
        SVProgressHUD.showWithStatus(status)
    }
    
    //MARK: -Common function
    func checkTextFieldEmpty(array:[UITextField]) -> Bool {
        for  textField in array {
            if NSString.isEmpty(textField.text)  {
                showErrorWithStatus(textField.placeholder);
                return false
            }
        }
        return true
    }
    
    func dismissController() {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //查询用户余额
    func requestUserCash(complete: CompleteBlock) {
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
                complete(userCash)
            }

        }, error: errorBlockFunc())
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

        }, error: errorBlockFunc())
    }
    
    /**
     七牛上传图片
     - parameter image:     图片
     - parameter imageName: 图片名
     - parameter complete:  图片完成Block
     */
    func qiniuUploadImage(image: UIImage, imageName: String, complete:CompleteBlock) {
        //1,请求token
        AppAPIHelper.commenAPI().imageToken({ (result) in
            let token = result?.valueForKey("img_token_") as! String
            //2,上传图片
            let timestamp = NSDate().timeIntervalSince1970
            let key = "\(imageName)\(timestamp).png"
            let qiniuManager:QNUploadManager = QNUploadManager()
            qiniuManager.putData(UIImagePNGRepresentation(image), key: key, token: token, complete: { (info, key, resp) in
                
                if resp == nil{
                    complete(nil)
                    return
                }
                //3,返回URL
                let respDic: NSDictionary? = resp
                let value:String? = respDic!.valueForKey("key") as? String
                let imageUrl = AppConst.Network.qiniuHost+value!
                complete(imageUrl)
                
                }, option: nil)
        }, error: errorBlockFunc())
    }
    
    /**
     七牛上传图片
     - parameter image:     图片
     - parameter imagePath: 图片服务器路径
     - parameter imageName: 图片名
     - parameter tags: 图片标记
     - parameter complete:  图片完成Block
     */
    func qiniuUploadImage(image: UIImage, imagePath: String, imageName:String, tags:[String: AnyObject], complete:CompleteBlock) {
        let timestemp = NSDate().timeIntervalSince1970
        let timeStr = String.init(timestemp).stringByReplacingOccurrencesOfString(".", withString: "")
        //0,将图片存到沙盒中
        let filePath = cacheImage(image, imageName: "/tmp_" + timeStr)
        //1,请求token
        AppAPIHelper.commenAPI().imageToken({ (result) in
            let token = result?.valueForKey("img_token_") as! String
            //2,上传图片
            let qiniuManager = QNUploadManager()
            qiniuManager.putFile(filePath, key: imagePath + imageName + "_\(timeStr)", token: token, complete: { (info, key, resp) in
                try! NSFileManager.defaultManager().removeItemAtPath(filePath)
                if resp == nil{
                    NSLog(info.debugDescription)
                    complete([tags, "failed"])
                    return
                }
                //3,返回URL
                let respDic: NSDictionary? = resp
                let value:String? = respDic!.valueForKey("key") as? String
                let imageUrl = AppConst.Network.qiniuHost+value!
                complete([tags, imageUrl])
            }, option: nil)
        }, error: errorBlockFunc())
    }
    
    /**
     缓存图片
     - parameter image:     图片
     - parameter imageName: 图片名
     - returns: 图片沙盒路径
     */
    func cacheImage(image: UIImage ,imageName: String) -> String {
        let data = UIImageJPEGRepresentation(image, 0.5)
        let homeDirectory = NSHomeDirectory()
        let documentPath = homeDirectory + "/Documents/"
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        do {
            try fileManager.createDirectoryAtPath(documentPath, withIntermediateDirectories: true, attributes: nil)
        }
        catch _ {
        }
        let key = "\(imageName).png"
        fileManager.createFileAtPath(documentPath.stringByAppendingString(key), contents: data, attributes: nil)
        //得到选择后沙盒中图片的完整路径
        let filePath: String = String(format: "%@%@", documentPath, key)
        return filePath
    }
    
    func didActionTel(telPhone:String) {
        let alert = UIAlertController.init(title: "呼叫", message: telPhone, preferredStyle: .Alert)
        let ensure = UIAlertAction.init(title: "确定", style: .Default, handler: { (action: UIAlertAction) in
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(telPhone)")!)
        })
        let cancel = UIAlertAction.init(title: "取消", style: .Cancel, handler: { (action: UIAlertAction) in
            
        })
        alert.addAction(ensure)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
        
    }
}