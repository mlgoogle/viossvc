//
//  PriceSelectionCell.swift
//  viossvc
//
//  Created by 陈奕涛 on 17/3/3.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import Foundation

protocol PriceSelectionCellDelegate: NSObjectProtocol {
    
    func selectedPrice(priceID: Int)
}

class PriceSelectionCell: UITableViewCell {
    
    weak var delegate:PriceSelectionCellDelegate?
    
    var priceInfos:[PriceModel]?
    
    lazy var leftPrice:UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage.init(named: "price_unselecte"), forState: .Normal)
        button.setBackgroundImage(UIImage.init(named: "price_selecte"), forState: .Selected)
        button.setBackgroundImage(UIImage.init(named: "price_selecte"), forState: .Highlighted)
        button.setTitle("8", forState: .Normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 25, 0)
        button.titleLabel?.font = UIFont.systemFontOfSize(20)
        button.setTitleColor(UIColor.init(hexString: "#cccccc"), forState: .Normal)
        button.setTitleColor(UIColor.init(hexString: "#fffefe"), forState: .Selected)
        button.setTitleColor(UIColor.init(hexString: "#fffefe"), forState: .Highlighted)
        button.addTarget(self, action: #selector(selecteAction), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var middlePrice:UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage.init(named: "price_unselecte"), forState: .Normal)
        button.setBackgroundImage(UIImage.init(named: "price_selecte"), forState: .Selected)
        button.setBackgroundImage(UIImage.init(named: "price_selecte"), forState: .Highlighted)
        button.setTitle("88", forState: .Normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 25, 0)
        button.titleLabel?.font = UIFont.systemFontOfSize(20)
        button.setTitleColor(UIColor.init(hexString: "#cccccc"), forState: .Normal)
        button.setTitleColor(UIColor.init(hexString: "#fffefe"), forState: .Selected)
        button.setTitleColor(UIColor.init(hexString: "#fffefe"), forState: .Highlighted)
        button.addTarget(self, action: #selector(selecteAction), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var rightPrice:UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage.init(named: "price_unselecte"), forState: .Normal)
        button.setBackgroundImage(UIImage.init(named: "price_selecte"), forState: .Selected)
        button.setBackgroundImage(UIImage.init(named: "price_selecte"), forState: .Highlighted)
        button.setTitle("888", forState: .Normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 25, 0)
        button.titleLabel?.font = UIFont.systemFontOfSize(20)
        button.setTitleColor(UIColor.init(hexString: "#cccccc"), forState: .Normal)
        button.setTitleColor(UIColor.init(hexString: "#fffefe"), forState: .Selected)
        button.setTitleColor(UIColor.init(hexString: "#fffefe"), forState: .Highlighted)
        button.addTarget(self, action: #selector(selecteAction), forControlEvents: .TouchUpInside)
        return button
    }()
    
    var items = [UIButton]()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(leftPrice)
        leftPrice.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(25)
            make.top.equalTo(7.5)
            make.width.equalTo(75)
            make.height.equalTo(98)
            make.bottom.equalTo(-7.5)
        })
        
        contentView.addSubview(middlePrice)
        middlePrice.snp_makeConstraints(closure: { (make) in
            make.centerX.equalTo(contentView)
            make.centerY.equalTo(leftPrice)
            make.width.equalTo(75)
            make.height.equalTo(98)
        })
        
        contentView.addSubview(rightPrice)
        rightPrice.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(-25)
            make.centerY.equalTo(leftPrice)
            make.width.equalTo(75)
            make.height.equalTo(98)
        })
        
        items.append(leftPrice)
        items.append(middlePrice)
        items.append(rightPrice)
    }
    
    func update(priceInfos: [PriceModel], selectedID: Int) {
        self.priceInfos = priceInfos
        for i in 0..<3 {
            items[i].hidden = i >= priceInfos.count
            guard i < priceInfos.count else { continue }
            items[i].setTitle("\(priceInfos[i].price)", forState: .Normal)
            items[i].selected = selectedID == priceInfos[i].price_id
        }
        
    }
    
    func selecteAction(sender: UIButton) {
        for i in 0..<items.count {
            if items[i] == sender {
                delegate?.selectedPrice(priceInfos![i].price_id)
                break
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
