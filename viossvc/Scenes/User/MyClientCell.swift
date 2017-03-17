//
//  MyClientCell.swift
//  viossvc
//
//  Created by macbook air on 17/3/15.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import Foundation

class MyClientCell: UITableViewCell {
    
    let clientName = UILabel()
    var weiXinNumber = UILabel()
    let timeLabel = UILabel()
    var pointImage = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.clearColor()
        selectionStyle = .None
        setupUI()
        
    }
    func updeat(info: OrderListCellModel){
        //时间戳的转换
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.dateFromString(info.order_time!)
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateString = dateFormatter.stringFromDate(date!)
        timeLabel.text =  dateString
        clientName.text = "客户 " + "'" + "'" + info.to_uid_nickename! + "'" + "'"
        
        let req = GetRelationRequestModel()
        req.order_id = info.order_id
        req.uid_form = info.to_uid
        req.uid_to = info.to_uid
        AppAPIHelper.userAPI().getRelation(req, complete: { [weak self](response) in
            let model = response as? GetRelationStatusModel
            if model?.result == 4{
                self!.weiXinNumber.text = model?.wx_num
            }
            }) { (error) in
        }
    }
     
    func setupUI() {

        
        let paymentSucceed = UILabel()
        
        
        contentView.addSubview(clientName)
        contentView.addSubview(weiXinNumber)
        contentView.addSubview(pointImage)
        contentView.addSubview(timeLabel)
        contentView.addSubview(paymentSucceed)
        
        
        clientName.text = "客户 @你好吗"
        clientName.font = UIFont.systemFontOfSize(16)
        clientName.textColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        clientName.textAlignment = .Center
        clientName.snp_makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.top.equalTo(contentView).offset(14)
            make.height.equalTo(16)
        }
        
//        weiXinNumber.text = "微信号widjk-156841355423"
        weiXinNumber.textColor = UIColor.init(red: 252/255.0, green: 163/255.0, blue: 17/255.0, alpha: 1)
        weiXinNumber.font = UIFont.systemFontOfSize(14)
        weiXinNumber.textAlignment = .Center
        weiXinNumber.snp_makeConstraints { (make) in
            make.left.equalTo(clientName)
            make.top.equalTo(clientName.snp_bottom).offset(8)
        }
        
        pointImage.image = UIImage.init(named: "arror")
        pointImage.snp_makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-15)
            make.top.equalTo(contentView).offset(25)
            make.width.equalTo(8)
            make.height.equalTo(15)
        }
        
        
        timeLabel.text = "2017/02/27"
        timeLabel.textColor = UIColor.init(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        timeLabel.font = UIFont.systemFontOfSize(10)
        timeLabel.textAlignment = .Center
        timeLabel.snp_makeConstraints { (make) in
            make.right.equalTo(pointImage).offset(-20)
            make.top.equalTo(contentView).offset(14)
            make.height.equalTo(9)
        }
        
        paymentSucceed.text = "付款成功"
        paymentSucceed.textColor = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        paymentSucceed.font = UIFont.systemFontOfSize(14)
        paymentSucceed.textAlignment = .Center
        paymentSucceed.snp_makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp_bottom).offset(14)
            make.right.equalTo(timeLabel)
            make.height.equalTo(14)
        }
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
