//
//  SendMsgViewController.swift
//  viossvc
//
//  Created by 巩婧奕 on 2017/3/6.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol SendMsgViewDelegate {
    func sendMsgViewDidSendMessage()
}

class SendMsgViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextViewDelegate,UIActionSheetDelegate,ZLPhotoPickerViewControllerDelegate {
    
    var topView:UIView?
    var left:UIButton?
    var right:UIButton?
    var textView:UITextView?
    var placeHolderLabel:UILabel?
    var collection:UICollectionView?
    var imageArray:NSMutableArray?
    // 上传图片的Index
    var imgIndex:Int = 0
    // 存放图片链接的数组
    var imgUrlArray:NSMutableArray = NSMutableArray()
    
    var headerView:SendDynamicHeaderView?
    
    var delegate:SendMsgViewDelegate?
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.hidesBottomBarWhenPushed = true
        view.backgroundColor = UIColor.cyanColor()
        automaticallyAdjustsScrollViewInsets = false
        
        imageArray = NSMutableArray()
        addTopView()
        addViews()
    }
    
    func addTopView() {
        topView = UIView.init(frame: CGRectMake(0, 0, ScreenWidth, 64))
        topView?.backgroundColor = UIColor.whiteColor()
        view.addSubview(topView!)
        
        let leftBtn:UIButton = UIButton.init(frame: CGRectMake(15, 27, 50, 30))
        leftBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        leftBtn.setTitleColor(UIColor.init(decR: 51, decG: 51, decB: 51, a: 1), forState: .Normal)
        leftBtn.setTitle("取消", forState: .Normal)
        topView?.addSubview(leftBtn)
        leftBtn.addTarget(self, action: #selector(SendMsgViewController.backAction), forControlEvents: .TouchUpInside)
        self.left = leftBtn
        
        let rightBtn:UIButton = UIButton.init(frame: CGRectMake(ScreenWidth - 65, 27, 50, 30))
        rightBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        rightBtn.setTitleColor(UIColor.init(decR: 252, decG: 163, decB: 17, a: 1), forState: .Normal)
        rightBtn.setTitle("发布", forState: .Normal)
        topView?.addSubview(rightBtn)
        rightBtn.addTarget(self, action: #selector(SendMsgViewController.sendMessage), forControlEvents: .TouchUpInside)
        self.right = rightBtn
        
        let topTitle:UILabel = UILabel.init(frame: CGRectMake((leftBtn.Right) + 10 , (leftBtn.Top), (rightBtn.Left) - leftBtn.Right - 20, (leftBtn.Height)))
        topView?.addSubview(topTitle)
        topTitle.font = UIFont.systemFontOfSize(17)
        topTitle.textAlignment = .Center
        topTitle.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        topTitle.text = "发布动态"
        
        let lineView:UIView = UIView.init(frame: CGRectMake(0, (topView?.Height)! - 1, ScreenWidth, 1))
        lineView.backgroundColor = UIColor.init(decR: 153, decG: 153, decB: 153, a: 1)
        lineView.alpha = 0.35
        topView?.addSubview(lineView)
        
    }
    
    func addViews() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (ScreenWidth - 60)/4.0, height: (ScreenWidth - 60)/4.0)
        layout.scrollDirection = .Vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        collection = UICollectionView.init(frame: CGRectMake(0, 64, ScreenWidth, view.Height - 64), collectionViewLayout: layout)
        collection?.backgroundColor = UIColor.whiteColor()
        collection?.showsVerticalScrollIndicator = false
        collection?.showsHorizontalScrollIndicator = false
        collection?.delegate = self
        collection?.dataSource = self
        view.addSubview(collection!)
        collection?.registerClass(SendMsgPickPhotoCell.self, forCellWithReuseIdentifier: "SendMsgPickPhotoCell")
        collection?.registerClass(SendDynamicHeaderView.self, forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier: "SendDynamicHeaderView")
    }
    
    func backAction() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // 先上传图片
    func sendMessage() {
        
        textView?.resignFirstResponder()
        self.view.endEditing(true)
        
        let message:String = (headerView?.textView?.text)!
        let count:Int = (imageArray?.count)!
        if message.length() == 0 && count == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入发布内容或者图片", ForDuration: 1.5, completion: {
            })
            return
        }
        
        SVProgressHUD.setDefaultMaskType(.Clear)
        SVProgressHUD.showProgressMessage(ProgressMessage: "正在发送")
        self.left?.userInteractionEnabled = false
        self.right?.userInteractionEnabled = false
        
        if imageArray?.count > 0 {
            imgIndex = 0
            self.uploadImages()
          
        } else {
            finallSendDymicMessage()
        }
        
    }
    
    func uploadImages() {
        
        let asset:ZLPhotoAssets = imageArray![imgIndex] as! ZLPhotoAssets
        let image:UIImage = asset.originImage()
        self.qiniuUploadImage(image, imageName: "") { (imageUrl) in
            if imageUrl == nil {
                SVProgressHUD.showErrorMessage(ErrorMessage: "图片上传出错，请稍后再试", ForDuration: 1, completion: nil)
                self.left?.userInteractionEnabled = true
                self.right?.userInteractionEnabled = true
                return
            }
            
            self.imgUrlArray.addObject(imageUrl!)
            
            self.imgIndex += 1
            if self.imgIndex == self.imageArray?.count {
                // 出口
                self.finallSendDymicMessage()
            } else {
                self.uploadImages()
            }
        }
    }
    
    func finallSendDymicMessage() {
        var urlString:String? = ""
        
        if imgUrlArray.count != 0 {
            
            urlString = (imgUrlArray[0] as! String)
            if imgUrlArray.count > 1 {
                
                for i in 1..<imgUrlArray.count {
                    let string = imgUrlArray[i]
                    
                    let finallStr = urlString! + "," + (string as! String)
                    urlString = finallStr
                }
            }
        }
        
        let message:String = (headerView?.textView?.text)!
        let sendModel:SendDynamicMessageModel = SendDynamicMessageModel()
        sendModel.dynamic_text = message
        sendModel.dynamic_url = urlString!
        AppAPIHelper.userAPI().sendDynamicMessage(sendModel, complete: { (response) in
            print(response)
            let resultModel:SendDynamicResultModel = response as! SendDynamicResultModel
            if resultModel.result == 0 {
                SVProgressHUD.showSuccessMessage(SuccessMessage: "发布成功", ForDuration: 1, completion: {
                    self.navigationController?.popViewControllerAnimated(true)
                    self.delegate?.sendMsgViewDidSendMessage()
                })
            }
            }, error: { (error) in
                self.left?.userInteractionEnabled = false
                self.right?.userInteractionEnabled = false
        } )
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.text.length() > 0 {
            placeHolderLabel?.removeFromSuperview()
        }else {
            textView.addSubview(placeHolderLabel!)
        }
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if imageArray?.count == 9 {
            return 9
        }
        
        return (imageArray?.count)! + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:SendMsgPickPhotoCell = collection?.dequeueReusableCellWithReuseIdentifier("SendMsgPickPhotoCell", forIndexPath: indexPath) as! SendMsgPickPhotoCell
        
        if indexPath.row == imageArray?.count {
            cell.imageView?.image = UIImage.init(named: "AddPic")
        } else {
            let asset = imageArray![indexPath.row]
            cell.imageView?.image = asset.originImage()
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (ScreenWidth - 60)/4.0, height: (ScreenWidth - 60)/4.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(ScreenWidth, 116)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            headerView = collection?.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "SendDynamicHeaderView", forIndexPath: indexPath) as? SendDynamicHeaderView
            return headerView!
            
        }
        return UICollectionReusableView.init()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        textView?.resignFirstResponder()
        view.endEditing(true)
        if indexPath.row == imageArray?.count && imageArray?.count != 9 {
            let actionSheet = UIActionSheet.init(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册选择图片")
            
            actionSheet.showInView(self.view)
        } else {
            // 显示图片
            PhotoBroswerVC.show(self, type:PhotoBroswerVCTypePush , index: UInt(indexPath.row), photoModelBlock: { [weak self]() -> [AnyObject]! in
                
                let photoArray:NSMutableArray = NSMutableArray()
                let count:Int = (self!.imageArray?.count)!
               
                for i  in 0..<count {
                    
                    let model:PhotoModel = PhotoModel.init()
                    model.mid = UInt(i) + 1
                    let asset = self!.imageArray![i] as! ZLPhotoAssets
                    model.image = asset.originImage()
                    photoArray.addObject(model)
                }
                
                return photoArray as [AnyObject]
            })
        }
    }
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 1 {
            
            let pickerVC:ZLPhotoPickerViewController = ZLPhotoPickerViewController.init()
            pickerVC.minCount = 9 - (imageArray?.count)!
            pickerVC.status = .CameraRoll
            pickerVC.delegate = self
            pickerVC.show()
        }
    }
    
    // MARK: pickerDelegate
    func pickerViewControllerDoneAsstes(assets: [AnyObject]!) {
        
        imageArray?.addObjectsFromArray(assets)
        collection?.reloadData()
    }
    
    func btnsDisable() {
        topView?.userInteractionEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
