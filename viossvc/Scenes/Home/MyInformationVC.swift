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

class MyInformationVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var table:UITableView?
    var timer:NSTimer?
    //订单消息列表单个消息
    var orders = [MyMessageListStatusModel]()
    var isFirstTime = true
    //请求行数
    var pageCount = 0
    //视图是否刷新
    var isRefresh:Bool = false
    
    var allDataDict:[String : Array<MyMessageListStatusModel>] = Dictionary()
    var dateArray:[String] = Array()
    
    var activityList = [MyMessageListStatusModel]()
    var activityListDict:[String : Array<MyMessageListStatusModel>] = Dictionary()
    var activityListArray:[String] = Array()
    
    var deleArray = [MyMessageListStatusModel]()
    
    let header:MJRefreshStateHeader = MJRefreshStateHeader()
    let footer:MJRefreshAutoStateFooter = MJRefreshAutoStateFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(hexString: "#ffffff")
        initTableView()
        AppAPIHelper.userAPI().getActivityList({ [weak self](response) in
            if let models = response as? [MyMessageListStatusModel]{
                
                for ele in models{
                    ele.timestamp = ele.campaign_time
                }
                self?.orders += models
            }
        }) { (error) in
        }
        
        
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
        table?.registerClass(MyInformationCell.self, forCellReuseIdentifier: "MyInformationCell")
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
    
    //下拉刷新
    func headerRefresh() {
        footer.state = .Idle
        pageCount = 0
        let req = OrderListRequestModel()
        //        req.uid_ = CurrentUser.uid_
        AppAPIHelper.userAPI().orderListSum(req, complete: { [weak self](response) in
            if response != nil {
                self!.footer.hidden = false
            }
            if let models = response as? [MyMessageListStatusModel]{
                self?.orders.removeAll()
                
                AppAPIHelper.userAPI().getActivityList({ [weak self](response) in
                    if let models = response as? [MyMessageListStatusModel]{
                        
                        for ele in models{
                            ele.timestamp = ele.campaign_time
                        }
                        self?.orders += models
                    }
                }) { (error) in
                }
                
                for ele in models{
                    ele.timestamp = ele.order_time
                }
                self?.orders += models
                
                //进行排序
                self!.setupDataWithModels((self?.orders)!)
                
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
    
    //上拉刷新
    func footerRefresh() {
        pageCount += 1
        let req = OrderListRequestModel()
        req.page_num = pageCount
        AppAPIHelper.userAPI().orderListSum(req, complete: { [weak self](response) in
            if let models = response as? [MyMessageListStatusModel]{
                for ele in models{
                    ele.timestamp = ele.order_time
                }
                self?.orders += models
                self!.setupDataWithModels((self?.orders)!)
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
    func setupDataWithModels(models:[MyMessageListStatusModel]){
        self.allDataDict.removeAll()
        self.dateArray.removeAll()
        //将传入的模型根据timestamp进行降序
        for i in 0...(self.orders.count - 2) {
            for j in 0...(self.orders.count - i - 2){
                //                let str1 = models[j].timestamp! as NSString
                //                let str2 = self.orders[j + 1].timestamp! as NSString
                //                let result = str1.compare(str2 as String, options: NSStringCompareOptions.NumericSearch)
                if self.orders[j].timestamp < self.orders[j + 1].timestamp {
                    //交换位置
                    let temp = self.orders[j]
                    
                    self.orders[j] = self.orders[j + 1]
                    
                    self.orders[j + 1] = temp
                    
                }
            }
            
        }
        
        let dateFormatter = NSDateFormatter()
        var dateString: String?
        for model in self.orders{
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateFormatter.dateFromString(model.timestamp!)
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
                var list:[MyMessageListStatusModel] = Array()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("MyInformationCell", forIndexPath: indexPath) as! MyInformationCell
        let array = allDataDict[dateArray[indexPath.section]]
        if array![indexPath.row].campaign_time != nil {
            cell.activityList(array![indexPath.row])
            return cell
        }
        else{
            cell.updeat(array![indexPath.row])
            return cell
        }
        
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
        if array![indexPath.row].campaign_time != nil {
            let vc = ActivityVC()
            vc.isRefresh = { ()->() in
                self.isRefresh = true
            }
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    
}
