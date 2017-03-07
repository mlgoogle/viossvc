//
//  ServantModels.swift
//  viossvc
//
//  Created by 巩婧奕 on 2017/3/7.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import UIKit

class ServantModels: BaseModel {

}

// 添加动态的 model
class SendDynamicMessageModel: BaseModel {
    dynamic var uid_ = 0
    dynamic var dynamic_text_:String?
    dynamic var dynamic_url_:String?
}
// 添加动态返回结果
class SendDynamicResultModel:BaseModel {
    dynamic var result_ = 0
    dynamic var dynamic_ = 0
}
