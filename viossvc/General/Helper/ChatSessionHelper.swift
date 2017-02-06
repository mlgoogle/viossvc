//
//  ChatSessionHelper.swift
//  viossvc
//
//  Created by yaowang on 2016/12/3.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit

protocol ChatSessionsProtocol : NSObjectProtocol {
    func updateChatSessions(chatSession:[ChatSessionModel])
}

protocol ChatSessionProtocol : NSObjectProtocol {
    
    func receiveMsg(chatMsgModel:ChatMsgModel)
    
    func sessionUid() ->Int
}


class ChatSessionHelper: NSObject {
    static let shared = ChatSessionHelper()
    private var _chatSessions:[ChatSessionModel] = []
    var chatSessions:[ChatSessionModel] {
        return _chatSessions
    }
    weak var chatSessionsDelegate:ChatSessionsProtocol?
    weak private var currentChatSessionDelegate:ChatSessionProtocol?
    func noReadingNumber() -> Int {
        var number = 0
        for chatSession in chatSessions {
            let seesion = chatSession 
            number += seesion.noReading
        }
        return number
    }

    func findHistorySession() {
        
        _chatSessions = ChatDataBaseHelper.ChatSession.findHistorySession()
        syncUserInfos()
        chatSessionSort()
        
    }
    
    func openChatSession(chatSessionDelegate:ChatSessionProtocol) {
        currentChatSessionDelegate = chatSessionDelegate
        let chatSession = findChatSession(currentChatSessionDelegate!.sessionUid())
        if chatSession != nil {
            if UIApplication.sharedApplication().applicationIconBadgeNumber < chatSession.noReading {
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            } else {
                UIApplication.sharedApplication().applicationIconBadgeNumber -= chatSession.noReading
            }

            chatSession.noReading = 0
            updateChatSession(chatSession)
        }
    }
    
    
    func  closeChatSession()  {
        currentChatSessionDelegate = nil
    }
    
    func receiveMsg(chatMsgModel:ChatMsgModel)  {
        

        let sessionId = chatMsgModel.from_uid == CurrentUserHelper.shared.uid ? chatMsgModel.to_uid : chatMsgModel.from_uid
        
        var chatSession = findChatSession(sessionId)
        if chatSession == nil {
            chatSession = createChatSession(sessionId)
            chatSession.lastChatMsg = chatMsgModel
        }
        else if chatSession.lastChatMsg == nil
            || chatSession.lastChatMsg.msg_time < chatMsgModel.msg_time {
            chatSession.lastChatMsg = chatMsgModel
            chatSessionSort()
        }
        
        if currentChatSessionDelegate != nil {
            currentChatSessionDelegate?.receiveMsg(chatMsgModel)
        }
        else if chatMsgModel.from_uid != CurrentUserHelper.shared.uid {
            chatSession.noReading += 1
        }
        
        updateChatSession(chatSession)
    }
    
    
    
    func didReqeustUserInfoComplete(userInfo:UserInfoModel!) {
        if userInfo != nil {
            if let chatSession = findChatSession(userInfo.uid) {
                chatSession.title = userInfo.nickname!
                chatSession.icon = userInfo.head_url!
                updateChatSession(chatSession)
            }
            
        }
    }
    
    
    func updateChatSession(chatSession:ChatSessionModel) {
        ChatDataBaseHelper.ChatSession.updateModel(chatSession)
        chatSessionsDelegate?.updateChatSessions(_chatSessions)
    }
    
    private func syncUserInfos() {
        var getInfoIds = [String]()
        for  chatSesion in _chatSessions {
            if chatSesion.type == ChatSessionType.Chat.rawValue && NSString.isEmpty(chatSesion.title) {
                getInfoIds.append("\(chatSesion.sessionId)")
            }
        }
        if getInfoIds.count > 0 {
            AppAPIHelper.userAPI().getUserInfos(getInfoIds, complete: { [weak self] (array) in
                    let userInfos = array as? [UserInfoModel]
                    if userInfos != nil {
                        for userInfo in userInfos! {
                            self?.didReqeustUserInfoComplete(userInfo)
                        }
                    }
                }, error: nil)
        }
    }
    
    private func chatSessionSort() {
        _chatSessions.sortInPlace({ (chatSession1, chatSession2) -> Bool in
            return chatSession1.lastChatMsg?.msg_time > chatSession2.lastChatMsg?.msg_time
        })
    }
    
    private func updateChatSessionUserInfo(uid:Int) {
        AppAPIHelper.userAPI().getUserInfo(uid, complete: { [weak self](model) in
            self?.didReqeustUserInfoComplete(model as? UserInfoModel)
            }, error: {(error) in})
    }
    
    private func createChatSession(uid:Int) -> ChatSessionModel {
        let chatSession = ChatSessionModel()
        chatSession.sessionId = uid
        _chatSessions.insert(chatSession, atIndex: 0)
        if chatSession.type == 0 {
            updateChatSessionUserInfo(uid)
        }
        ChatDataBaseHelper.ChatSession.addModel(chatSession)
        return chatSession

    }
    
    private func findChatSession(uid:Int) ->ChatSessionModel! {
        for  chatSession in _chatSessions {
            if chatSession.sessionId == uid {
                return chatSession
            }
        }
        return nil
    }
}
