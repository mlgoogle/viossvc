//
//  PriceAndContactSettingVC.swift
//  viossvc
//
//  Created by 陈奕涛 on 17/3/3.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD


class PriceAndContactSettingVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ContactCellDelegate, PriceSelectionCellDelegate {
    
    lazy var tips:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor.init(hexString: "#333333")
        label.text = "选择显示你的微信号售卖金额"
        return label
    }()
    
    lazy var submit:UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 22
        button.backgroundColor = UIColor.init(hexString: "#eeeeee")
        button.setTitle("完成", forState: .Normal)
        button.setTitleColor(UIColor.init(hexString: "#cccccc"), forState: .Normal)
        button.setTitleColor(UIColor.init(hexString: "#ffffff"), forState: .Normal)
        button.addTarget(self, action: #selector(submit(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    var table:UITableView?
    
    var wxAccount:String?
    var wxQRCodeUrl:String?
    
    var priceList:[PriceModel] = []
    var selectedPrice = -1
    
    var qrCodeImage:UIImage?
    
    lazy var imagePicker:UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(hexString: "#ffffff")
        
        getPriceList()
        initTableView()
        hideKeyboard()
        
    }
    
    func registerNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func getPriceList() {
        AppAPIHelper.userAPI().priceList({ [weak self](response) in
            if let models = response as? [PriceModel] {
                self?.priceList = models
                self?.table?.reloadSections(NSIndexSet.init(index: 2), withRowAnimation: .Fade)
                self?.getContactAndPrice()
            }
            }, error: { (error) in
                
        })
    }
    
    func getContactAndPrice() {
        let req = ContactAndPriceRequestModel()
        req.uid_form = CurrentUserHelper.shared.uid
        req.uid_to = CurrentUserHelper.shared.uid
        AppAPIHelper.userAPI().contactAndPrice(req, complete: { [weak self](response) in
            if let model = response as? ContactAndPriceModel {
                self?.wxQRCodeUrl = model.wx_url
                self?.wxAccount = model.wx_num
                self?.selectedPrice = model.service_price
                self?.table?.reloadData()
            }
            }, error: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotify()
        initNav()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: -- Nav
    func initNav()  {
        title = "金额设置"
        
    }
    
    //MARK: -- tableView
    func initTableView() {
        table = UITableView.init(frame: CGRectZero, style: .Plain)
        table?.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 80
        table?.rowHeight = UITableViewAutomaticDimension
        table?.tableFooterView = UIView()
        table?.separatorStyle = .None
        table?.registerClass(ContactCell.self, forCellReuseIdentifier: "ContactCell")
        table?.registerClass(PriceSelectionCell.self, forCellReuseIdentifier: "PriceSelectionCell")
        view.addSubview(table!)
        table?.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return priceList.count / 3 + (priceList.count % 3 > 0 ? 1 : 0)
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! ContactCell
            cell.delegate = self
            cell.update(wxAccount, qrCodeImgae: qrCodeImage, qrCodeURL: wxQRCodeUrl)
            return cell
        } else if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("PriceSelectionTipsCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .None
                cell?.selectionStyle = .None
                cell?.contentView.addSubview(tips)
                tips.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(15)
                    make.top.equalTo(8)
                    make.right.equalTo(-15)
                    make.height.equalTo(18)
                    make.bottom.equalTo(-7.5)
                })
            }
            return cell!
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("PriceSelectionCell", forIndexPath: indexPath) as! PriceSelectionCell
            cell.delegate = self
            var infos = [PriceModel]()
            for i in (indexPath.row*3)..<(indexPath.row*3+3) {
                if i < priceList.count {
                    infos.append(priceList[i])
                } else { break }
            }
            cell.update(infos, selectedPrice: selectedPrice)
            return cell
        } else if indexPath.section == 3 {
            var cell = tableView.dequeueReusableCellWithIdentifier("SubmitCell")
            if cell == nil {
                cell = UITableViewCell()
                cell?.accessoryType = .None
                cell?.selectionStyle = .None
                cell?.contentView.addSubview(submit)
                submit.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(15)
                    make.right.equalTo(-15)
                    make.top.equalTo(20)
                    make.bottom.equalTo(-20)
                    make.height.equalTo(45)
                })
            }
            
            return cell!
        }
        var cell = tableView.dequeueReusableCellWithIdentifier("IDVerifyCell")
        if cell == nil {
            cell = UITableViewCell()
            cell?.accessoryType = .None
            cell?.selectionStyle = .None
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        qrCodeImage = image
        imagePicker.dismissViewControllerAnimated(true, completion: { () in
            self.table?.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: .Fade)
            self.submitCheck()
        })
        
        let data = UIImageJPEGRepresentation(image, 0.5)
        let homeDirectory = NSHomeDirectory()
        let documentPath = homeDirectory + "/Documents"
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        do {
            try fileManager.createDirectoryAtPath(documentPath, withIntermediateDirectories: true, attributes: nil)
            
        } catch _ {
        }
        let timestemp:Int = Int(NSDate().timeIntervalSince1970)
        let key = "/\(CurrentUserHelper.shared.uid)\(timestemp)\(index).png"
        fileManager.createFileAtPath(documentPath.stringByAppendingString(key), contents: data, attributes: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification?) {
        let frame = notification!.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let inset = UIEdgeInsetsMake(0, 0, frame.size.height, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
        table?.contentInset = inset
        table?.scrollIndicatorInsets = inset
    }
    
    override func hideKeyboard() {
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(touchWhiteSpace))
        touch.numberOfTapsRequired = 1
        touch.cancelsTouchesInView = false
        table?.addGestureRecognizer(touch)
    }
    
    func touchWhiteSpace() {
        view.endEditing(true)
    }
    
    func selectedPrice(price: Int) {
        selectedPrice = price
        table?.reloadSections(NSIndexSet.init(index: 2), withRowAnimation: .None)
        submitCheck()
    }
    
    func qrCodeSelecte() {
        let sheetController = UIAlertController.init(title: "选择二维码图片", message: nil, preferredStyle: .ActionSheet)
        let cancelAction:UIAlertAction! = UIAlertAction.init(title: "取消", style: .Cancel) { action in
            
        }
        
        let labAction:UIAlertAction! = UIAlertAction.init(title: "相册", style: .Default) { action in
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        sheetController.addAction(cancelAction)
        sheetController.addAction(labAction)
        presentViewController(sheetController, animated: true, completion: nil)
    }
    
    func accountDidChange(account: String?) {
        wxAccount = account
        
        submitCheck()
    }
    
    func submitCheck() {
        if (wxAccount != nil && wxAccount != "") && (qrCodeImage != nil || wxQRCodeUrl != nil) && selectedPrice != -1 {
            submit.backgroundColor = UIColor.init(hexString: "#fca311")
            submit.enabled = true
        } else {
            submit.backgroundColor = UIColor.init(hexString: "#eeeeee")
            submit.enabled = false
        }
    }
    
    func submit(sender: UIButton) {
        
        if wxAccount?.characters.count == 0  && wxQRCodeUrl?.characters.count == 0{
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入微信号或者上传微信二维码", ForDuration: 1, completion: {
            })
            return
        }
        if selectedPrice < 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请选择价格", ForDuration: 1, completion: {
            })
        }
        
        if qrCodeImage != nil {
            let imageName = "qrcode"
            qiniuUploadImage(qrCodeImage!, imageName: imageName, complete: { [weak self](imageUrl) in
                if let url = imageUrl as? String {
                    self?.wxQRCodeUrl = url
                    self?.changeContactAndPrice()
                }
            })
        } else {
            changeContactAndPrice()
        }
    }
    
    func changeContactAndPrice() {
        let req = PriceSettingRequestModel()
        req.uid = CurrentUserHelper.shared.uid
        req.wx_num = wxAccount
        req.wx_url = wxQRCodeUrl
        req.service_price = selectedPrice
        AppAPIHelper.userAPI().priceSetting(req, complete: { (response) in
            if let model = response as? PriceSettingModel {
                let msg = model.result == 0 ? "设置成功" : "设置失败"
                SVProgressHUD.showWithStatus(msg)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64 (1.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    SVProgressHUD.dismiss()
                })
            }
            }, error: { (err) in
                
        })
    }
}
