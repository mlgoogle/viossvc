//
//  ContactCell.swift
//  viossvc
//
//  Created by 陈奕涛 on 17/3/3.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import Foundation

protocol ContactCellDelegate: NSObjectProtocol {
    
    func accountDidChange(account: String?)
    
    func qrCodeSelecte()
}

class ContactCell: UITableViewCell, UITextFieldDelegate {
    
    weak var delegate:ContactCellDelegate?
    
    var wxAccount:String?
    
    var wxQRCodeUrl:String?
    
    lazy var icon:UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        bg.layer.masksToBounds = true
        bg.layer.cornerRadius = 3
        
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "price_wx")
        imageView.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        bg.addSubview(imageView)
        imageView.snp_makeConstraints(closure: { (make) in
            make.center.equalTo(bg)
            make.width.equalTo(25)
            make.height.equalTo(24)
        })
        
        let vLine = UIView()
//        vLine.backgroundColor = UIColor.init(hexString: "#e5e5e5")
        bg.addSubview(vLine)
        vLine.snp_makeConstraints(closure: { (make) in
            make.centerY.equalTo(bg)
            make.width.equalTo(1)
            make.height.equalTo(51)
            make.right.equalTo(bg).offset(-3)
        })
        return bg
    }()
    
    lazy var wxAccountField:UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "输入你真实有效的微信号码"
        textField.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        textField.layer.cornerRadius = 3
        textField.layer.masksToBounds = true
        return textField
    }()
    
    lazy var wxQRBGView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        view.layer.borderColor = UIColor.init(hexString: "#f2f2f2").CGColor
        view.layer.borderWidth = 1
        return view
    }()
    
    lazy var wxQRCodeSettingTips:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        button.setTitle("点此上传二维码", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(12)
        button.addTarget(self, action: #selector(uploadQRCode), forControlEvents: .TouchUpInside)
        button.setTitleColor(UIColor.init(hexString: "#999999"), forState: .Normal)
        return button
    }()
    
    lazy var wxQRCodeResetTips:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        button.setTitle("点击修改", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(9)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(self, action: #selector(uploadQRCode), forControlEvents: .TouchUpInside)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    lazy var bigQRCodeResetTips:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clearColor()
        button.addTarget(self, action: #selector(uploadQRCode), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var wxQRCodeView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "690·220_placeholder")
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        
        contentView.addSubview(icon)
        icon.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(15)
            make.top.equalTo(20)
            make.width.equalTo(51)
            make.height.equalTo(51)
        })
        
        contentView.addSubview(wxAccountField)
        wxAccountField.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(icon.snp_right).offset(-3)
            make.top.equalTo(icon)
            make.bottom.equalTo(icon)
            make.right.equalTo(-15)
        })
        
        contentView.addSubview(wxQRBGView)
        wxQRBGView.snp_makeConstraints(closure: { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(icon.snp_bottom).offset(36)
            make.width.equalTo(141)
            make.height.equalTo(141)
            make.bottom.equalTo(-45)
        })
        
        contentView.addSubview(wxQRCodeSettingTips)
        wxQRCodeSettingTips.snp_makeConstraints(closure: { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(wxQRBGView).offset(5.5)
            make.width.equalTo(130)
            make.height.equalTo(130)
            make.bottom.equalTo(wxQRBGView).offset(-5.5)
        })
        
        contentView.addSubview(wxQRCodeView)
        wxQRCodeView.snp_makeConstraints(closure: { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(wxQRBGView).offset(5.5)
            make.width.equalTo(130)
            make.height.equalTo(130)
            make.bottom.equalTo(wxQRBGView).offset(-5.5)
        })
        
        contentView.addSubview(wxQRCodeResetTips)
        wxQRCodeResetTips.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(wxQRCodeView).offset(-1)
            make.bottom.equalTo(wxQRCodeView).offset(-1)
            make.width.equalTo(46)
            make.height.equalTo(16)
        })
        contentView.addSubview(bigQRCodeResetTips)
        bigQRCodeResetTips.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(wxQRCodeView)
        })
    }
    
    func update(account:String? ,qrCodeImgae:UIImage?, qrCodeURL:String?) {
        wxAccount = account
        wxAccountField.text = account
        
        if qrCodeImgae != nil {
            wxQRCodeView.image = qrCodeImgae
        } else if qrCodeURL != nil {
            wxQRCodeView.kf_setImageWithURL(NSURL.init(string: qrCodeURL!))
        }
        
        wxQRCodeSettingTips.hidden = qrCodeURL != nil || qrCodeImgae != nil
        wxQRCodeResetTips.hidden = !wxQRCodeSettingTips.hidden
        wxQRCodeView.hidden = wxQRCodeResetTips.hidden
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UITextField
    func textFieldDidEndEditing(textField: UITextField) {
        wxAccount = textField.text
        delegate?.accountDidChange(wxAccount)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location > 18 {
            return false
        }
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        wxAccount = nil
        return true
    }
    
    func uploadQRCode(sender: UIButton) {
        delegate?.qrCodeSelecte()
    }
    
}