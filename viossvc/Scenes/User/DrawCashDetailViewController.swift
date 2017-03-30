//
//  DrawCashDetailViewController.swift
//  viossvc
//
//  Created by 木柳 on 2016/11/27.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD
class DrawCashDetailViewController: BaseTableViewController {
    @IBOutlet weak var bankCardLabel: UILabel!
    @IBOutlet weak var drawCashCount: UILabel!
    @IBOutlet weak var drawCashTime: UILabel!
    @IBOutlet weak var stepIcon1: UIButton!
    @IBOutlet weak var stepIcon2: UIButton!
    @IBOutlet weak var stepIcon3: UIButton!
    var stats: Int?{
        didSet{
            stepIcon1.selected = stats == 0
            stepIcon2.selected = stats == 1
            stepIcon3.selected = stats == 2
        }
    }
    var model: DrawCashRecordModel?
    
    
    //MARK: --LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if model == nil {
            return
        }
        updateUI(model!)
        navigationItem.hidesBackButton = false
        navigationItem.rightBarButtonItem = nil
    }
    
    //MARK: --DATA
    func initData() {
        if model != nil {
            return
        }
        
        let object: DrawCashModel  = DrawCashModel()
        object.uid = CurrentUserHelper.shared.userInfo.uid
        object.account = CurrentUserHelper.shared.userInfo.currentBankCardNumber
        object.num = 1
        object.size = 1
        AppAPIHelper.userAPI().drawCashDetail(object, complete: { [weak self](result) in
            if result == nil{
                SVProgressHUD.showErrorMessage(ErrorMessage: "获取提现详情内容失败，请前往提现记录中查看", ForDuration: 1, completion: {
                    self?.navigationController?.pushViewControllerWithIdentifier(DrawCashRecordViewController.className(), animated: true)
                })
                
                return
            }
            
            let resultModel = result as! DrawCashModel
            if resultModel.withdraw_record.count >= 0{
                
                let model:DrawCashRecordModel =  resultModel.withdraw_record[0]
                self?.updateUI(model)
            }
        }, error: errorBlockFunc())
    }
    
    //MARK: --UI
    func initUI() {
        navigationItem.backBarButtonItem = nil
        navigationItem.hidesBackButton = true
        
        if navigationItem.rightBarButtonItem == nil {
            let sureBtn = UIButton.init(frame: CGRectMake(0, 0, 40, 30))
            sureBtn.setTitle("确定", forState: .Normal)
            sureBtn.titleLabel?.font = UIFont.systemFontOfSize(S18)
            sureBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            sureBtn.backgroundColor = UIColor.clearColor()
            sureBtn.addTarget(self, action: #selector(rightItemTapped), forControlEvents: .TouchUpInside)
            
            let sureItem = UIBarButtonItem.init(customView: sureBtn)
            navigationItem.rightBarButtonItem = sureItem
        }
    }
    
    func updateUI(model: DrawCashRecordModel) {
        let bankNum = ((model.account)! as NSString).substringWithRange(NSRange.init(location: model.account!.length()-4, length: 4))
        let bankName = model.bank_name
        
        bankCardLabel.text =  "\(bankName!)(\(bankNum))"
        
        drawCashCount.text = "￥\(model.cash/100)"
        
        drawCashTime.text = model.request_time
        
        stats = model.status
    }
    
    func rightItemTapped(sender: UIButton) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
