//
//  AuthUserViewController.swift
//  viossvc
//
//  Created by 木柳 on 2016/11/27.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD
class AuthUserViewController: BaseTableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var frontPic: UIImageView!
    @IBOutlet weak var backPic: UIImageView!
    var imagePicker:UIImagePickerController? = nil
    var frontPicUrl: String?
    var backPicUrl: String?
    var index:NSInteger = 0
    //MARK: --LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initImagePick()
    }
    //MARK: --DATA
    func initData() {
        
    }
    @IBAction func authUser(sender: AnyObject) {
        MobClick.event(AppConst.Event.user_anthuser)
        if frontPicUrl == nil {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请上传正面图片", ForDuration: 1, completion: nil)
            return
        }
        
        if backPicUrl == nil {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请上传背面图片", ForDuration: 1, completion: nil)
            return
        }
        
        AppAPIHelper.userAPI().authUser(CurrentUserHelper.shared.userInfo.uid, frontPic: frontPicUrl!, backPic: backPicUrl!, complete: { [weak self](result) in
            self?.checkAuthStatus()
            SVProgressHUD.showSuccessMessage(SuccessMessage: "上传图片成功，请静待人工审核", ForDuration: 1, completion: nil)
            self?.navigationController?.popToRootViewControllerAnimated(true)
        }, error: errorBlockFunc())
    }
    //MARK: --UI
    func initUI() {
        frontPic.userInteractionEnabled = true
        backPic.userInteractionEnabled = true
    }
    //MARK: --imagePicker
    //MARK: -- imagePicker
    func initImagePick() {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.allowsEditing = true
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker?.dismissViewControllerAnimated(true, completion: nil)
        let imageRotation = index == 0 ? "front" : "back"
        let imageName = "\(CurrentUserHelper.shared.userInfo.uid)" + imageRotation
        SVProgressHUD.showProgressMessage(ProgressMessage: "图片上传中...")
        qiniuUploadImage(image, imageName: imageName) { [weak self](imageUrl) in
            if imageUrl == nil{
                SVProgressHUD.showErrorMessage(ErrorMessage: "图片上传出错，请稍后再试", ForDuration: 1, completion: nil)
                return
            }
            SVProgressHUD.dismiss()
            if self?.index == 0{
                self?.frontPic.image = image
                self?.frontPicUrl = imageUrl as? String
                self?.frontPic.contentMode = .ScaleAspectFill
            }else{
                self?.backPic.image = image
                self?.backPicUrl = imageUrl as? String
                self?.backPic.contentMode = .ScaleAspectFill
            }
        }
    }
    //MARK: --tableView
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            return
        }
        
        index = indexPath.section
        let sheetController = UIAlertController.init(title: "选择图片", message: nil, preferredStyle: .ActionSheet)
        let cancelAction:UIAlertAction! = UIAlertAction.init(title: "取消", style: .Cancel) { action in
            
        }
        let cameraAction:UIAlertAction! = UIAlertAction.init(title: "相机", style: .Default) { action in
            self.imagePicker?.sourceType = .Camera
            self.presentViewController(self.imagePicker!, animated: true, completion: nil)
        }
        let labAction:UIAlertAction! = UIAlertAction.init(title: "从系统相册中选择", style: .Default) { action in
            self.imagePicker?.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker!, animated: true, completion: nil)
        }
        sheetController.addAction(cancelAction)
        sheetController.addAction(cameraAction)
        sheetController.addAction(labAction)
        presentViewController(sheetController, animated: true, completion: nil)
    }

}
