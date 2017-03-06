//
//  SendMsgViewController.swift
//  viossvc
//
//  Created by 巩婧奕 on 2017/3/6.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import UIKit

class SendMsgViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    var topView:UIView?
    var textView:UITextView?
    var placeHolderLabel:UILabel?
    var collection:UICollectionView?
    var imageArray:NSMutableArray?
    // 选择图片
    let imagePickerController: UIImagePickerController = UIImagePickerController()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.hidesBottomBarWhenPushed = true
        view.backgroundColor = UIColor.cyanColor()
        
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
        
        let rightBtn:UIButton = UIButton.init(frame: CGRectMake(ScreenWidth - 65, 27, 50, 30))
        rightBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        rightBtn.setTitleColor(UIColor.init(decR: 252, decG: 163, decB: 17, a: 1), forState: .Normal)
        rightBtn.setTitle("发布", forState: .Normal)
        topView?.addSubview(rightBtn)
        rightBtn.addTarget(self, action: #selector(SendMsgViewController.sendMessage), forControlEvents: .TouchUpInside)
        
        let topTitle:UILabel = UILabel.init(frame: CGRectMake((leftBtn.Right) + 10 , (leftBtn.Top), (rightBtn.Left) - leftBtn.Right - 20, (leftBtn.Height)))
        topView?.addSubview(topTitle)
        topTitle.font = UIFont.systemFontOfSize(17)
        topTitle.textAlignment = .Center
        topTitle.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
        topTitle.text = "发布动态"
    }
    
    func addViews() {
        
        
        //定义collectionView的布局类型，流布局
        let layout = UICollectionViewFlowLayout()
        //设置cell的大小
        layout.itemSize = CGSize(width: (ScreenWidth - 60)/4.0, height: (ScreenWidth - 60)/4.0)
        //滑动方向 默认方向是垂直
        layout.scrollDirection = .Vertical
        //每个Item之间最小的间距
        layout.minimumInteritemSpacing = 10
        //每行之间最小的间距
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10) ;
//        let layout:UICollectionViewLayout = UICollectionViewFlowLayout()
        collection = UICollectionView.init(frame: CGRectMake(0, 64, ScreenWidth, view.Height - 64), collectionViewLayout: layout)
        collection?.backgroundColor = UIColor.whiteColor()
        collection?.showsVerticalScrollIndicator = false
        collection?.showsHorizontalScrollIndicator = false
        collection?.delegate = self
        collection?.dataSource = self
        view.addSubview(collection!)
        collection?.registerClass(SendMsgPickPhotoCell.self, forCellWithReuseIdentifier: "SendMsgPickPhotoCell")
    }
    
    func backAction() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // 先上传图片
    func sendMessage() {
        
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
        return (imageArray?.count)! + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:SendMsgPickPhotoCell = collection?.dequeueReusableCellWithReuseIdentifier("SendMsgPickPhotoCell", forIndexPath: indexPath) as! SendMsgPickPhotoCell
        
        if indexPath.row == imageArray?.count {
            cell.contentView.backgroundColor = UIColor.cyanColor()
        }else {
            cell.imageView?.image = imageArray![indexPath.row] as? UIImage
        }
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (ScreenWidth - 60)/4.0, height: (ScreenWidth - 60)/4.0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // 点击进入相册选取图片
        if imageArray?.count != 9 {
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
                let alertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                
                let cameraAction: UIAlertAction = UIAlertAction(title: "拍摄照片", style: .Default) { (action: UIAlertAction!) -> Void in
                    // 设置类型
                    self.imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                    self.presentViewController(self.imagePickerController, animated: true, completion: nil)
                }
                alertController.addAction(cameraAction)
                let photoLibraryAction: UIAlertAction = UIAlertAction(title: "从相册选择图片", style: .Default) { (action: UIAlertAction!) -> Void in
                    // 设置类型
                    self.imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
                    self.imagePickerController.navigationBar.barTintColor = UIColor(red: 171/255, green: 202/255, blue: 41/255, alpha: 1.0)
                    self.imagePickerController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
                    self.imagePickerController.navigationBar.tintColor = UIColor.whiteColor()
                    self.presentViewController(self.imagePickerController, animated: true, completion: nil)
                }
                alertController.addAction(photoLibraryAction)
                let cancelAction: UIAlertAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                presentViewController(alertController, animated: true, completion: nil)
            }else{
                let alertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                let photoLibraryAction: UIAlertAction = UIAlertAction(title: "从相册选择图片", style: .Default) { (action: UIAlertAction!) -> Void in
                    self.imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
                    self.imagePickerController.navigationBar.barTintColor = UIColor(red: 171/255, green: 202/255, blue: 41/255, alpha: 1.0)
                    self.imagePickerController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
                    self.imagePickerController.navigationBar.tintColor = UIColor.whiteColor()
                    self.presentViewController(self.imagePickerController, animated: true, completion: nil)
                }
                alertController.addAction(photoLibraryAction)
                let cancelAction: UIAlertAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        imagePickerController.dismissController()
        
        let image:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        if imageArray?.count == 0 {
            imageArray?.addObject(image)
        }else {
            imageArray?.insertObject(image, atIndex: (imageArray?.count)! - 1)
        }
        collection?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
