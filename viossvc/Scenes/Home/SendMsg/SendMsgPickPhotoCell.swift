//
//  SendMsgPickPhotoCell.swift
//  viossvc
//
//  Created by 巩婧奕 on 2017/3/6.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import UIKit

class SendMsgPickPhotoCell: UICollectionViewCell {
    
    var imageView:UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.whiteColor()
        imageView = UIImageView.init(frame: self.bounds)
        contentView.addSubview(imageView!)
    }
    
}
