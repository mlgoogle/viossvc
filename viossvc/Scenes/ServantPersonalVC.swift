//
//  ServantPersonalVC.swift
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/4.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh
import SVProgressHUD

public class ServantPersonalVC : UIViewController,UITableViewDelegate,UITableViewDataSource,ServantPersonalCellDelegate,SendMsgViewDelegate ,GuideViewDelegate {
    // MARK: - 属性
    var personalInfo:UserInfoModel?
    
    // 自定义导航条、左右按钮和title
    var topView:UIView?
    var leftBtn:UIButton?
    var rightBtn:UIButton?
    var topTitle:UILabel?
    
    var tableView:UITableView?
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    // 头视图
    var headerView:ServantHeaderView?
    // 是否关注状态
    var follow = false
    var fansCount = 0
    
    var pageNum:Int = 0
    var dataArray = [servantDynamicModel]()
    var timer:NSTimer? // 刷新用
    var offsetY:CGFloat = 0.0
    
    // MARK: - 函数方法
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if offsetY < 0 {
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        }
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.floatForKey("guideVersion") < ((NSBundle.mainBundle().infoDictionary! ["CFBundleShortVersionString"])?.floatValue) {
            loadGuide()
        } else {
            initViews()
        }
        //接收通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateImageAndName), name: "updateImageAndName", object: nil)
    }
    
    //移除通知
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //通知实现
    func updateImageAndName(notification: NSNotification?) {
        headerView?.didUpdateUI(CurrentUserHelper.shared.userInfo.head_url!, name: CurrentUserHelper.shared.userInfo.nickname!, star: CurrentUserHelper.shared.userInfo.praise_lv)
    }
    
    func loadGuide() {
        let guidView:GuidView = GuidView.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
        guidView.delegate = self
        UIApplication.sharedApplication().keyWindow?.addSubview(guidView)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setFloat(((NSBundle.mainBundle().infoDictionary! ["CFBundleShortVersionString"])?.floatValue)!, forKey: "guideVersion")
    }
    
    func initViews() {
        personalInfo = CurrentUserHelper.shared.userInfo
        
        addViews()
        header.performSelector(#selector(MJRefreshHeader.beginRefreshing), withObject: nil, afterDelay: 0.5)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let key = "isShownFiestTime1"
        let isshownfirsttime = userDefaults.valueForKey(key)
        
        if isshownfirsttime == nil {
            
            let imageView:UIImageView = UIImageView.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
            imageView.image = UIImage.init(named: "助理端新手引导1")
            imageView.alpha = 0.5
            UIApplication.sharedApplication().keyWindow?.addSubview(imageView)
            
            imageView.userInteractionEnabled = true
            let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.imageTapAction(_:)))
            imageView.addGestureRecognizer(tap)
            
            userDefaults.setValue(true, forKey: key)
        }
    }
    
    // 加载页面
    func addViews() {
        tableView = UITableView.init(frame: CGRectMake(0, -20, ScreenWidth, ScreenHeight + 20), style: .Grouped)
        tableView?.backgroundColor = UIColor.init(decR: 242, decG: 242, decB: 242, a: 1)
        tableView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .None
        tableView?.estimatedRowHeight = 120
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.separatorStyle = .None
        tableView?.showsVerticalScrollIndicator = false
        tableView?.showsHorizontalScrollIndicator = false
        // 只有一条文字的Cell展示
        tableView?.registerClass(ServantOneLabelCell.self, forCellReuseIdentifier: "ServantOneLabelCell")
        // 只有一张图片的Cell展示
        tableView?.registerClass(ServantOnePicCell.self, forCellReuseIdentifier: "ServantOnePicCell")
        // 复合Cell展示
        tableView?.registerClass(ServantPicAndLabelCell.self, forCellReuseIdentifier: "ServantPicAndLabelCell")
        view.addSubview(tableView!)
        
        header.setRefreshingTarget(self, refreshingAction: #selector(ServantPersonalVC.headerRefresh))
        footer.setRefreshingTarget(self, refreshingAction: #selector(ServantPersonalVC.footerRefresh))
        tableView?.mj_header = header
        tableView?.mj_footer = footer
        
        // 设置顶部 topView
        topView = UIView.init(frame: CGRectMake(0, 0, ScreenWidth, 64))
        topView?.backgroundColor = UIColor.clearColor()
        view.addSubview(topView!)
        
        leftBtn = UIButton.init(frame: CGRectMake(15, 27, 30, 30))
        leftBtn!.layer.masksToBounds = true
        leftBtn!.layer.cornerRadius = 15.0
        leftBtn!.setImage(UIImage.init(named: "message-1"), forState: .Normal)
        topView?.addSubview(leftBtn!)
        leftBtn!.addTarget(self, action: #selector(ServantPersonalVC.backAction), forControlEvents: .TouchUpInside)
        
        rightBtn = UIButton.init(frame: CGRectMake(ScreenWidth - 45, 27, 30, 30))
        rightBtn!.layer.masksToBounds = true
        rightBtn!.layer.cornerRadius = 15.0
        rightBtn!.setImage(UIImage.init(named: "sendDynamic-1"), forState: .Normal)
        topView?.addSubview(rightBtn!)
        rightBtn!.addTarget(self, action: #selector(ServantPersonalVC.reportAction), forControlEvents: .TouchUpInside)
        
        topTitle = UILabel.init(frame: CGRectMake((leftBtn?.Right)! + 10 , (leftBtn?.Top)!, (rightBtn?.Left)! - leftBtn!.Right - 20, (leftBtn?.Height)!))
        topView?.addSubview(topTitle!)
        topTitle?.font = UIFont.systemFontOfSize(17)
        topTitle?.textAlignment = .Center
        topTitle?.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
    }
    
    func backAction() {
        let vc =  MyInformationVC()
        vc.title = "我的消息"
        vc.hidesBottomBarWhenPushed = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func reportAction() {
        let sendMsgView:SendMsgViewController = SendMsgViewController()
        sendMsgView.hidesBottomBarWhenPushed = true
        sendMsgView.delegate = self
        navigationController?.pushViewController(sendMsgView, animated: true)
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < dataArray.count {
            
            let model:servantDynamicModel = dataArray[indexPath.row]
            let detailText:String = model.dynamic_text!
            let urlStr = model.dynamic_url
            let urlArray = urlStr!.componentsSeparatedByString(",")
            
            if urlStr?.characters.count == 0 {
                // 只有文字的Cell
                let cell = tableView.dequeueReusableCellWithIdentifier("ServantOneLabelCell", forIndexPath: indexPath) as! ServantOneLabelCell
                cell.delegate = self
                cell.selectionStyle = .None
                cell.updateLabelText(model)
                
                return cell
                
            } else if detailText.characters.count  == 0 && urlArray.count == 1 {
                // 只有一张图片的cell
                let cell = tableView.dequeueReusableCellWithIdentifier("ServantOnePicCell", forIndexPath: indexPath) as! ServantOnePicCell
                cell.delegate = self
                cell.selectionStyle = .None
                
                cell.updateImage(model)
                return cell
                
            } else {
                // 复合cell
                let cell = tableView.dequeueReusableCellWithIdentifier("ServantPicAndLabelCell", forIndexPath: indexPath) as! ServantPicAndLabelCell
                cell.delegate = self
                cell.selectionStyle = .None
                
                cell.updateUI(model)
                
                return cell
            }
            
        }
        
        return UITableViewCell.init()
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView = ServantHeaderView.init(frame: CGRectMake(0, 0, ScreenWidth, 379))
        headerView?.didUpdateUI(CurrentUserHelper.shared.userInfo.head_url!, name: CurrentUserHelper.shared.userInfo.nickname!, star: CurrentUserHelper.shared.userInfo.praise_lv)
        headerView?.updateFansCount(self.fansCount)
        return headerView
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 316
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // 滑动的时候改变顶部 topView
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let color:UIColor = UIColor.whiteColor()
        offsetY = scrollView.contentOffset.y
        
        if offsetY < 0 {
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
            
            topView?.backgroundColor = color.colorWithAlphaComponent(0)
            topTitle?.text = ""
            leftBtn?.setImage(UIImage.init(named: "message-1"), forState:.Normal)
            rightBtn?.setImage(UIImage.init(named: "sendDynamic-1"), forState: .Normal)
        } else {
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
            
            let alpha:CGFloat = 1 - ((128 - offsetY) / 128)
            topView?.backgroundColor = color.colorWithAlphaComponent(alpha)
            
            let titleString = "首页"
            topTitle?.text = titleString
            leftBtn?.setImage(UIImage.init(named: "message-2"), forState:.Normal)
            rightBtn?.setImage(UIImage.init(named: "sendDynamic-2"), forState: .Normal)
        }
    }
    // MARK: 数据
    // 刷新数据
    func headerRefresh() {
        
        footer.state = .Idle
        pageNum = 0
        let servantInfo:ServantInfoModel = ServantInfoModel()
        servantInfo.page_num = pageNum
        AppAPIHelper.userAPI().requestDynamicList(servantInfo, complete: { (response) in

        if let models = response as? [servantDynamicModel] {
            self.dataArray = models
            self.endRefresh()
        }
        if self.dataArray.count < 10 {
            self.noMoreData()
        }
            // 查询粉丝数
            self.updateFollowCount()
            
        }, error: { [weak self](error) in
            self?.endRefresh()
        })
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(endRefresh), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    // 加载数据
    func footerRefresh() {
        
        pageNum += 1
        let servantInfo:ServantInfoModel = ServantInfoModel()
        servantInfo.page_num = pageNum
        
        AppAPIHelper.userAPI().requestDynamicList(servantInfo, complete: { (response) in
            
            let models = response as! [servantDynamicModel]
            self.dataArray += models
            self.endRefresh()
            
            if models.count == 0 {
                self.noMoreData()
            }
            
            }, error: { [weak self](error) in
                self?.endRefresh()
            })
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(endRefresh), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    // 停止刷新
    func endRefresh() {
        if header.state == .Refreshing {
            header.endRefreshing()
        }
        if footer.state == .Refreshing {
            footer.endRefreshing()
        }
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        tableView!.reloadData()
    }
    
    func noMoreData() {
        endRefresh()
        footer.state = .NoMoreData
        if dataArray.count == 0 {
            footer.setTitle("您还未发布任何动态，快去发布吧", forState: .NoMoreData)
        } else {
            footer.setTitle("暂无更多动态", forState: .NoMoreData)
        }
    }
    
    // 查询粉丝数量
    func updateFollowCount() {
        
        let req = FollowCountRequestModel()
        req.uid = CurrentUserHelper.shared.uid
        req.type = 2
        AppAPIHelper.userAPI().followCount(req, complete: { (response) in
            if let model = response as? FollowCountModel {
                self.headerView?.updateFansCount(model.follow_count)
            }
            }, error: nil)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // 点赞
    func servantIsLikedAction(sender: UIButton, model: servantDynamicModel) {
        
        let req = ServantThumbUpModel()
        req.dynamic_id = model.dynamic_id
        
        AppAPIHelper.userAPI().servantThumbup(req, complete: { (response) in
            let result = response as! ServantThumbUpResultModel
            
            let likecount = result.dynamic_like_count
            
            if result.result == 0 {
                sender.selected = true
                sender.setTitle(String(likecount), forState: .Selected)
                model.is_liked = 1
            }else if result.result == 1 {
                sender.selected = false
                sender.setTitle(String(likecount), forState: .Normal)
                model.is_liked = 0
            }
            model.dynamic_like_count = likecount
            
            }, error: nil)
    }
    
    // 图片点击放大
    func servantImageDidClicked(model: servantDynamicModel, index: Int) {
        // 解析图片链接
        let urlString:String = model.dynamic_url!
        let imageUrls:NSArray = urlString.componentsSeparatedByString(",")
        
        // 显示图片
        PhotoBroswerVC.show(self, type: PhotoBroswerVCTypePush , index: UInt(index)) {() -> [AnyObject]! in
            
            let photoArray:NSMutableArray = NSMutableArray()
            let count:Int = imageUrls.count
            
            for i  in 0..<count {
                
                let model: PhotoModel = PhotoModel.init()
                model.mid = UInt(i) + 1
                model.image_HD_U = imageUrls.objectAtIndex(i) as! String
                photoArray.addObject(model)
            }
            
            return photoArray as [AnyObject]
        }
    }
    
    // 刷新界面
    func sendMsgViewDidSendMessage() {
        
        header.performSelector(#selector(MJRefreshHeader.beginRefreshing), withObject: nil, afterDelay: 0.5)
    }
    
    // 新手引导图片点击
    func imageTapAction(tap:UITapGestureRecognizer) {
        
        let imageView:UIImageView = tap.view as! UIImageView
        imageView.removeFromSuperview()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let key = "isShownFiestTime1"
        userDefaults.setValue(true, forKey: key)
    }
    
    // 启动页消失
    func guideDidDismissed() {
        initViews()
    }
}
