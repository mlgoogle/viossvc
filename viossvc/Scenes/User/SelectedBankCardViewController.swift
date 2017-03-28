//
//  SelectedBankCardViewController.swift
//  viossvc
//
//  Created by 木柳 on 2016/11/27.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD
class BankCardCell: OEZTableViewCell {
    @IBOutlet weak var bankCardNumLabel: UILabel!
    @IBOutlet weak var bankSelectBtn: UIButton!
    override func update(data: AnyObject!) {
        let bankCardModel = data as! BankCardModel
        let cardNum = bankCardModel.account! as NSString
        var cardName = String.bankCardName(cardNum as String) as NSString
        bankSelectBtn.selected = bankCardModel.is_default == 1 ? true : false
        if cardNum == "" {
            return
        }
        if cardName.length <= 0 {
            cardName = "未知银行"
        }
        bankCardNumLabel.text = "\(cardName.substringToIndex(4))(\(cardNum.substringFromIndex(cardNum.length-4)))"
        print(bankCardNumLabel)
    }
}

class SelectedBankCardViewController: BaseListTableViewController{
    var model: BankCardModel?
    
    var selectIndex:Int = 0
    
    //Data
    override func didRequest() {
        let model = BankCardModel()
        AppAPIHelper.userAPI().bankCards(model, complete: completeBlockFunc(), error: errorBlockFunc())
    }
    
    override func didRequestComplete(data: AnyObject?) {
        dataSource = data as? Array<AnyObject>
        super.didRequestComplete(data)
        if model != nil {
            CurrentUserHelper.shared.userInfo.currentBankCardNumber = model!.account
            CurrentUserHelper.shared.userInfo.currentBanckCardName = String.bankCardName(model!.account!)
            SVProgressHUD.showSuccessMessage(SuccessMessage: "切换成功", ForDuration: 1, completion: nil)
        }
    }
    //MARK: --LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(BankCardCell.self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        didRequest()
    }

    //MARK: --UI
    @IBAction func addNewBankCard() {
        MobClick.event(AppConst.Event.bank_add)
        performSegueWithIdentifier("bankCardToAddNew", sender: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != selectIndex {
            
            MobClick.event(AppConst.Event.bank_select)
            model = dataSource![indexPath.row] as? BankCardModel
            SVProgressHUD.showProgressMessage(ProgressMessage:"切换中...")
            AppAPIHelper.userAPI().defaultBanKCard(model!.account!, complete: { [weak self](result) in
                self!.selectIndex = indexPath.row
                self?.didRequest()
                }, error: errorBlockFunc())
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        for i in 0..<(dataSource?.count)! {
            
            let bankModel:BankCardModel = dataSource![i] as! BankCardModel
            if bankModel.is_default == 1 {
                selectIndex = i
            }
        }
    }
}
