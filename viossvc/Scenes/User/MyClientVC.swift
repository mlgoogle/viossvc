//
//  MyClientVC.swift
//  viossvc
//
//  Created by macbook air on 17/3/15.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import Foundation
import XCGLogger
import SVProgressHUD
import MJRefresh

class MyClientVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var table:UITableView?
    var timer:NSTimer?
    //订单消息列表单个消息
    var orders = [OrderListCellModel]()
    var isFirstTime = true
    //请求行数
    var pageCount = 0
    //视图是否刷新
    var isRefresh:Bool = false
    
    var allDataDict:[String : Array<OrderListCellModel>] = Dictionary()
    var dateArray:[String] = Array()
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(hexString: "#ffffff")
        initTableView()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if isRefresh {
            
        }else{
            header.performSelector(#selector(MJRefreshHeader.beginRefreshing), withObject: nil, afterDelay: 0.5)
        }
    }
    
    //MARK: -- tableView
    func initTableView() {
        table = UITableView(frame: CGRectZero, style: .Grouped)
        table?.backgroundColor = UIColor.init(decR: 241, decG: 242, decB: 243, a: 1)
        table?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        table?.delegate = self
        table?.dataSource = self
        table?.estimatedRowHeight = 80
        table?.rowHeight = UITableViewAutomaticDimension
        table?.separatorStyle = .SingleLine
        table?.registerClass(MyClientCell.self, forCellReuseIdentifier: "MyClientCell")
        view.addSubview(table!)
        table?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        })
        
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        table?.mj_header = header
        footer.hidden = true
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        table?.mj_footer = footer
    }
    
    //上拉刷新
    func headerRefresh() {
        footer.state = .Idle
        pageCount = 0
        let req = OrderListRequestModel()
//        req.uid_ = CurrentUser.uid_
        AppAPIHelper.userAPI().orderList(req, complete: { [weak self](response) in
            if response != nil {
                self!.footer.hidden = false
            }
            if let models = response as? [OrderListCellModel]{
                self!.allDataDict.removeAll()
                self!.dateArray.removeAll()
                self!.setupDataWithModels(models)
                
                self?.orders = models
                self?.endRefresh()
            }
            if self?.orders.count < 10{
                 self?.noMoreData()
            }
            
            }) { [weak self](error) in
                self?.endRefresh()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(endRefresh), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    //下拉刷新
    func footerRefresh() {
        pageCount += 1
        let req = OrderListRequestModel()
        req.page_num = pageCount
        AppAPIHelper.userAPI().orderList(req, complete: { [weak self](response) in
            if let models = response as? [OrderListCellModel]{
                self!.setupDataWithModels(models)
                self?.orders += models
                self?.endRefresh()
            }
            else{
                self?.noMoreData()
            }
            }) { [weak self](error) in
                self?.endRefresh()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(endRefresh), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        
    }
    //结束刷新
    func endRefresh() {
        isFirstTime = false
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
        table?.reloadData()
    }
    func noMoreData() {
        endRefresh()
        footer.state = .NoMoreData
        footer.setTitle("没有更多信息", forState: .NoMoreData)
    }

    
    //数据分组处理
    func setupDataWithModels(models:[OrderListCellModel]){
        let dateFormatter = NSDateFormatter()
        var dateString: String?
        for model in models{
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateFormatter.dateFromString(model.order_time!)
            if date == nil {
                continue
            }
            else{
                dateFormatter.dateFormat = "MM"
                dateString = dateFormatter.stringFromDate(date!)
            }
            
            /*
             - 判断 model 对应的分组 是否已经有当天数据信息
             - 如果已经有信息则直接将model 插入当天信息array
             - 反之，创建当天分组array 插入数据
             */
            if dateArray.contains(dateString!){
                allDataDict[dateString!]?.append(model)
            }
            else{
                var list:[OrderListCellModel] = Array()
                list.append(model)
                dateArray.append(dateString!)
                allDataDict[dateString!] = list
            }
        }
    }

    
    
    //tableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dateArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = allDataDict[dateArray[section]]
        return array == nil ? 0 : array!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyClientCell", forIndexPath: indexPath) as! MyClientCell
        let array = allDataDict[dateArray[indexPath.section]]
        cell.updeat(array![indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    //MARK: -- 返回组标题索引
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        let date = NSDate()
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "MM'at' HH:mm:ss.SSS"
        let strNowTime = timeFormatter.stringFromDate(date) as String
        let timeArray = strNowTime.componentsSeparatedByString(".")
        let NYR = timeArray[0].componentsSeparatedByString("at")
        
        if NYR[0] == dateArray[0] {
            label.text = "最近30天内的订单消息"
        }else{
            label.text = dateArray[section] + "月"
        }
        label.textColor = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        label.font = UIFont.systemFontOfSize(13)
        let sumView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 34))
        sumView.addSubview(label)
        label.snp_makeConstraints { (make) in
            make.centerX.equalTo(sumView)
            make.height.equalTo(13)
            make.top.equalTo(sumView).offset(10)
            make.bottom.equalTo(sumView.snp_bottom).offset(-10)
        }
        return sumView
    }
    //组头高
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    //组尾高
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
            let array = allDataDict[dateArray[indexPath.section]]
            let req = GetRelationRequestModel()
            req.order_id = array![indexPath.row].order_id
            req.uid_form = array![indexPath.row].to_uid
            req.uid_to = array![indexPath.row].to_uid
            AppAPIHelper.userAPI().getRelation(req, complete: { [weak self](response) in
                let model = response as? GetRelationStatusModel
                if model?.result == 4{
                    let clientWeiXinVC = ClientWeiXinVC()
                    clientWeiXinVC.weiXinNumber = model?.wx_num
                    clientWeiXinVC.weiXinName = array![indexPath.row].to_uid_nickename
                    clientWeiXinVC.isRefresh = { ()->() in
                        self!.isRefresh = true
                    }
                    self!.navigationController?.pushViewController(clientWeiXinVC, animated: true)
                }
            }) { (error) in
            }
 
//        APIHelper.consumeAPI().getRelation(getModel, complete: { [weak self](response) in
//            
//            if let model = response as? GetRelationStatusModel{
//                let aidWeiXin = AidWenXinVC()
//                aidWeiXin.getRelation = model
//                aidWeiXin.nickname = array![indexPath.row].to_uid_nickename_
//                aidWeiXin.toUid = array![indexPath.row].to_uid_
//                aidWeiXin.orderId = array![indexPath.row].order_id_
//                aidWeiXin.isEvaluate = array![indexPath.row].is_evaluate_ == 0 ? false : true
//                aidWeiXin.bool = false
//                aidWeiXin.toUidUrl =  array![indexPath.row].to_uid_url_
//                aidWeiXin.isRefresh = { ()->() in
//                    self!.isRefresh = true
//                }
//                self!.navigationController?.pushViewController(aidWeiXin, animated: true)
//            }
        
    }

    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    
}
