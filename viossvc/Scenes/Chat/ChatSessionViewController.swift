//
//  ChatSessionViewController.swift
//  viossvc
//
//  Created by yaowang on 2016/10/28.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import Foundation

class ChatSessionViewController: BaseTableViewController,ChatSessionsProtocol {
    internal var dataSource = [ChatSessionModel]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ChatSessionHelper.shared.chatSessionsDelegate = self
        updateChatSessions(ChatSessionHelper.shared.chatSessions)
    }

    
    func updateChatSessions(chatSession:[ChatSessionModel]) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = ChatSessionHelper.shared.noReadingNumber()
        dataSource = chatSession
        tableView.reloadData()
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    
    override func tableView(tableView: UITableView, cellDataForRowAtIndexPath indexPath: NSIndexPath) -> AnyObject? {
        return dataSource[indexPath.row]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        let model =  self.tableView(tableView, cellDataForRowAtIndexPath: indexPath) as! ChatSessionModel
        if model.type == ChatSessionType.Chat.rawValue {
            let viewController:ChatInteractionViewController = storyboardViewController()
            viewController.chatUid = model.sessionId
            viewController.chatName = model.title
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    deinit {
        ChatSessionHelper.shared.chatSessionsDelegate = nil
    }

}
