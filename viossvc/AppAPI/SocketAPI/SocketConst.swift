//
//  SockOpcode.swift
//  viossvc
//
//  Created by yaowang on 2016/11/22.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import Foundation

class SocketConst: NSObject {
    enum OPCode:UInt16 {
        // 心跳包
        case Heart = 1000
        // 请求登录
        case Login = 1001
        //请求手机短信
        case SMSVerify = 1019
        //验证手机验证码
        case VerifyCode = 1101
        
        case CheckInviteCode = 1113
        //注册
        case Register = 1021
        //重置密码
        case NodifyPasswrod = 1011
        //修改用户信息
        case NodifyUserInfo = 1023
        //获取图片token
        case GetImageToken = 1047
        //获取用户余额
        case UserCash = 1067
        //认证用户头像
        case AuthUserHeader = 1091
        //获取用户的银行卡信息
        case UserBankCards = 1097
        //校验提现密码
        case CheckDrawCashPassword = 1087
        //提现
        case DrawCash = 1103
        //提现详情
        case DrawCashDetail = 0004
        //提现记录
        case DrawCashRecord = 1105
        //设置默认银行卡
        case DefaultBankCard = 1099
        //添加新的银行卡
        case NewBankCard = 1095
        //获取所有技能标签
        case AllSkills = 1041
        //获取身份认证进度
        case AuthStatus = 1057
        //上传身份认证信息
        case AuthUser = 1055
        //设置/修改支付密码
        case DrawCashPassword = 1089
        //V领队服务
        case ServiceList = 1501
        //更新V领队服务
        case UpdateServiceList = 1503
        //技能分享列表
        case SkillShareList = 1071
        //技能分享详情
        case SkillShareDetail = 1073
        //技能分享评论列表
        case SkillShareComment = 1075
        //技能分享预约
        case SkillShareEnroll = 1077
        /**
         订单列表
         */
        case OrderList = 1505

        //订单详情
        case OrderDetail = 1507
        
        /**
         操作技能标签
         */
        case HandleSkills = 1509
        //商务分享类别
        case TourShareType = 1059
        //商务分享列表
        case TourShareList = 1061
        //商务分享详情
        case TourShareDetail = 1065
        //上传照片到照片墙
        case UploadPhoto2Wall = 1107
        //获取照片墙
        case PhotoWall = 1109
        /**
         修改订单状态
         */
        case ModfyOrderStatus = 2011
        
        case UploadContact = 1111
        case LoginRet = 1002
        case UserInfo = 1013
        //发送chat消息
        case ChatSendMessage = 2003
        //收到chat消息
        case ChatReceiveMessage = 2004
        //获取chat离线消息
        case ChatOfflineRequestMessage = 2025
        case ChatOfflineReceiveMessage = 2006
        case UpdateDeviceToken = 1031
        
        case VersionInfo = 1115
        
        case IDVerifyRequest = 1121
        
        case PriceList = 1123
        
        case FollowCount = 1129
        
        case PriceSetting = 1131
        
        case ContactAndPrice = 1133
        // 发布动态
        case SendDynamic = 1135
        // 动态列表
        case DynamicList = 1139
        // 动态点赞
        case ThumbUp = 1137
    }
    enum type:UInt8 {
        case Error = 0
        case User = 1
        case Chat = 2
    }
    
    class Key {
        static let last_id = "last_id_"
        static let count = "count_"
        static let share_id = "share_id_"
        static let page_type = "page_type_"
        static let uid = "uid_"
        static let from_uid = "from_uid_"
        static let to_uid = "to_uid_"
        static let order_id = "order_id_"
        static let order_status = "order_status_"
        static let change_type = "change_type_"
        static let skills = "skills_"
        static let phoneNum = "phoneNum_"
        static let invitationCode = "invitationCode_"
    }
}
