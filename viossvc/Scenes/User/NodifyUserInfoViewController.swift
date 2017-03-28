//
//  UserInfoEditViewController.swift
//  viossvc
//
//  Created by yaowang on 2016/11/23.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation
import MapKit
import SVProgressHUD
import Kingfisher

class NodifyUserInfoViewController: BaseTableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var iconImage: UIImageView!
    var imageUrl: String?
    var haveChangeImage: Bool = false
    var locationManager = CLLocationManager()
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController.init()
        picker.allowsEditing = true
        return picker
    }()
    
    var username:String?
    var currentTextField:UITextField?
    //MARK: --LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if navigationItem.rightBarButtonItem == nil {
            let sureBtn = UIButton.init(frame: CGRectMake(0, 0, 40, 30))
            sureBtn.setTitle("完成", forState: .Normal)
            sureBtn.setTitleColor(UIColor(red: 38/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1), forState: .Normal)
            sureBtn.backgroundColor = UIColor.whiteColor()
            sureBtn.addTarget(self, action: #selector(finishItemTapped(_:)), forControlEvents: .TouchUpInside)
            
            let sureItem = UIBarButtonItem.init(customView: sureBtn)
            navigationItem.rightBarButtonItem = sureItem
            
        }
        
        if (CurrentUserHelper.shared.userInfo.head_url != nil){
            let headUrl = NSURL.init(string: CurrentUserHelper.shared.userInfo.head_url!)
            iconImage.kf_setImageWithURL(headUrl, placeholderImage: UIImage.init(named: "head_boy"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        }
        
        if CurrentUserHelper.shared.userInfo.nickname != nil {
            nameText.text = CurrentUserHelper.shared.userInfo.nickname
        }
        
        if CurrentUserHelper.shared.userInfo.address != nil {
            cityLabel.text = CurrentUserHelper.shared.userInfo.address
        }
        
        sexLabel.text = CurrentUserHelper.shared.userInfo.gender == 1 ? "男" : "女"
        nameText.delegate = self
        nameText!.clearButtonMode = .WhileEditing
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        imagePicker.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            creatLocationManager()
        }else{
            openLocation()
        }
    }
    
    //MARK: --上传头像
    func finishItemTapped(sender: AnyObject) {
        let sex = sexLabel.text == "男" ? 1 : 0
        if CurrentUserHelper.shared.userInfo.nickname == nameText.text &&
            CurrentUserHelper.shared.userInfo.address == cityLabel.text && CurrentUserHelper.shared.userInfo.gender == sex &&
            haveChangeImage == false{
            SVProgressHUD.showWainningMessage(WainningMessage: "未做任何修改", ForDuration: 1, completion: nil)
            return
        }
        
        if haveChangeImage && imageUrl == nil  {
            showErrorWithStatus("头像上传失败，请稍后再试")
            return
        }
        if nameText.text?.characters.count == 0 {
            showErrorWithStatus("请输入用户昵称")
            return
        }
        let param = NotifyUserInfoModel()
        param.address = cityLabel.text
        param.gender = sexLabel.text == "男" ? 1 : 0
        if haveChangeImage && imageUrl != nil {
            param.head_url = imageUrl
        }else{
            param.head_url = CurrentUserHelper.shared.userInfo.head_url
        }
        param.nickname = nameText.text
        param.uid = CurrentUserHelper.shared.userInfo.uid
        param.longitude = CurrentUserHelper.shared.userInfo.longitude
        param.latitude = CurrentUserHelper.shared.userInfo.latitude
        AppAPIHelper.userAPI().notifyUsrInfo(param, complete: {[weak self] (result) in
            CurrentUserHelper.shared.userInfo.address = self?.cityLabel.text
            CurrentUserHelper.shared.userInfo.nickname = self?.nameText.text
            CurrentUserHelper.shared.userInfo.gender = self?.sexLabel.text == "男" ? 1 : 0
            //发送通知
            if self?.imageUrl != nil {
                CurrentUserHelper.shared.userInfo.head_url = self?.imageUrl
            }
            NSNotificationCenter.defaultCenter().postNotificationName("updateImageAndName", object: nil, userInfo: nil)
            if self?.haveChangeImage == true {
                SVProgressHUD.showSuccessMessage(SuccessMessage: "设置成功", ForDuration: 1, completion:{
                    self?.navigationController?.popViewControllerAnimated(true)
                })
            }else{
                self?.navigationController?.popViewControllerAnimated(true)
            }
            }, error: errorBlockFunc())
    }
    
    //MARK: --常住地选择
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == CitysSelectViewController.className() {
            MobClick.event(AppConst.Event.user_location)
            let controller: CitysSelectViewController = segue.destinationViewController as! CitysSelectViewController
            controller.cityName = cityLabel.text
            controller.selectCity =  { [weak self](cityName) in
                self?.cityLabel.text = cityName
            }
            return
        }
    }
    
    //MARK: --TABLEVIEW
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        if indexPath.row == 1 || indexPath.row == 4 {
            return
        }
        
        if indexPath.row == 3  {
            
            let push:PersionalIntroductionController = PersionalIntroductionController.init()
            navigationController?.pushViewController(push, animated: true)
            return
        }
        if indexPath.row == 0 {
            MobClick.event(AppConst.Event.user_icon)
        }else{
            MobClick.event(AppConst.Event.user_sex)
        }
        
        let title = indexPath.row == 0 ? "头像" : "性别"
        let firstActionTitle = indexPath.row == 0 ? "相机":"男"
        let secondActionTitle = indexPath.row == 0 ? "从系统相册选择":"女"
        let alterController: UIAlertController = UIAlertController.init(title: title, message: nil, preferredStyle: .ActionSheet)
        let alterActionFirst: UIAlertAction = UIAlertAction.init(title: firstActionTitle, style: .Default) { [weak self](action) in
            if indexPath.row != 0{
                self?.sexLabel.text = firstActionTitle
                return
            }
            
            self?.imagePicker.sourceType = .Camera
            self?.presentViewController((self?.imagePicker)!, animated: true, completion: nil)
        }
        
        let alterActionSecond: UIAlertAction = UIAlertAction.init(title: secondActionTitle, style: .Default) { [weak self](action) in
            if indexPath.row != 0{
                self?.sexLabel.text = secondActionTitle
                return
            }
            self?.imagePicker.sourceType = .PhotoLibrary
            self?.presentViewController((self?.imagePicker)!, animated: true, completion: nil)
        }
        
        let alterActionCancel: UIAlertAction = UIAlertAction.init(title: "取消", style: .Cancel, handler: nil)
        alterController.addAction(alterActionFirst)
        alterController.addAction(alterActionSecond)
        alterController.addAction(alterActionCancel)
        presentViewController(alterController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        haveChangeImage = true
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        iconImage.image = image
        qiniuUploadImage(image, imageName: "\(CurrentUserHelper.shared.userInfo.uid)", complete: { [weak self](imageUrl) in
            if imageUrl == nil || imageUrl?.length == 0 {
                SVProgressHUD.showErrorMessage(ErrorMessage: "头像上传失败，请稍后再试", ForDuration: 1, completion: nil)
                if (CurrentUserHelper.shared.userInfo.head_url != nil){
                    let headUrl = NSURL.init(string: CurrentUserHelper.shared.userInfo.head_url!)
                    self?.iconImage.kf_setImageWithURL(headUrl, placeholderImage: UIImage.init(named: "head_boy"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
                }
                return
            }
            self?.imageUrl = imageUrl as? String
            
            //上传头像图片
            AppAPIHelper.userAPI().authHeaderUrl(CurrentUserHelper.shared.userInfo.uid, head_url_: (self?.imageUrl)! , complete: { (result) in
                }, error: self!.errorBlockFunc())
        })
    }

    //MARK: --CLLocationManagerDelegate
    func creatLocationManager() {
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .Denied {
            openLocation()
            return
        }else if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }else{
            locationManager.startUpdatingLocation()
        }
    }
    func openLocation() {
        
        let alertController = UIAlertController.init(title: "定位失败", message: "定位失败，请前往设置页面打开定位功能", preferredStyle: .Alert)
        let setAction = UIAlertAction.init(title: "前去设置", style: .Default, handler: { [weak self](sender) in
            alertController.dismissController()
            self?.navigationController?.popViewControllerAnimated(false)
            if #available(iOS 10, *) {
                UIApplication.sharedApplication().openURL(NSURL.init(string: UIApplicationOpenSettingsURLString)!)
            } else {
                UIApplication.sharedApplication().openURL(NSURL.init(string: "prefs:root=LOCATION_SERVICES")!)
            }
            
            })
        let cancelAction = UIAlertAction.init(title: "取消", style: .Default, handler: { (sender) in
//            alertController.dismissController()
//            self?.navigationController?.popViewControllerAnimated(true)
            })
        alertController.addAction(cancelAction)
        alertController.addAction(setAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Denied {
            openLocation()
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        openLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        CurrentUserHelper.shared.userInfo.latitude = newLocation.coordinate.latitude
        CurrentUserHelper.shared.userInfo.longitude = newLocation.coordinate.longitude
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        nameText.resignFirstResponder()
    }
    
}

extension NodifyUserInfoViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameText.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        currentTextField = textField
        if range.location > 10 {
            return false
        }
        if textField.tag == 1001 {
            username = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
         }
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        switch textField.tag {
        case 1001:
            username = textField.text
            break
        default:
            break
        }
        return true
    }
}


