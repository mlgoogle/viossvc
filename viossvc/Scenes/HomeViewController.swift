//
//  HomeViewController.swift
//  viossvc
//
//  Created by yaowang on 2016/10/27.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import Foundation


class HomeViewController: BaseRefreshTableViewController {
    
    // 自定义导航条、左右按钮和title
    var topView:UIView?
    var leftBtn:UIButton?
    var rightBtn:UIButton?
    var topTitle:UILabel?
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clearColor();
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewDidLoad() {
        
        addTopView()
    }
    
    func addTopView() {
        // 设置顶部 topView
        topView = UIView.init(frame: CGRectMake(0, 0, ScreenWidth, 64))
        topView?.backgroundColor = UIColor.redColor()
        view.addSubview(topView!)
        
        leftBtn = UIButton.init(frame: CGRectMake(15, 27, 30, 30))
        leftBtn!.layer.masksToBounds = true
        leftBtn!.layer.cornerRadius = 15.0
//        leftBtn!.setImage(UIImage.init(named: "nav-back"), forState: .Normal)
        leftBtn?.setTitle("消", forState: .Normal)
        topView?.addSubview(leftBtn!)
        leftBtn!.addTarget(self, action: #selector(HomeViewController.messageList), forControlEvents: .TouchUpInside)
        
        rightBtn = UIButton.init(frame: CGRectMake(ScreenWidth - 45, 27, 30, 30))
        rightBtn!.layer.masksToBounds = true
        rightBtn!.layer.cornerRadius = 15.0
//        rightBtn!.setImage(UIImage.init(named: "nav-jb"), forState: .Normal)
        rightBtn?.setTitle("+", forState: .Normal)
        topView?.addSubview(rightBtn!)
        rightBtn!.addTarget(self, action: #selector(HomeViewController.addDymicList), forControlEvents: .TouchUpInside)
        
        topTitle = UILabel.init(frame: CGRectMake((leftBtn?.Right)! + 10 , (leftBtn?.Top)!, (rightBtn?.Left)! - leftBtn!.Right - 20, (leftBtn?.Height)!))
        topView?.addSubview(topTitle!)
        topTitle?.font = UIFont.systemFontOfSize(17)
        topTitle?.textAlignment = .Center
        topTitle?.textColor = UIColor.init(decR: 51, decG: 51, decB: 51, a: 1)
    }
    
    // 消息列表
    func messageList() {
        
    }
    // 添加动态
    func addDymicList() {
        
    }
    
    // MARK:---tableView
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ServantPersonalCell", forIndexPath: indexPath) as! ServantPersonalCell
        
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header:ServantHeaderView = ServantHeaderView.init(frame: CGRectMake(0, 0, ScreenWidth, 379))
//        header.didAddNewUI(personalInfo!)
        return header
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 379
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        //        let footer:ServantFooterView = ServantFooterView.init(frame:CGRectMake(0, 0, ScreenWidth, 55),detail: "Ta很神秘，还未发布任何动态")
        let footer:ServantFooterView = ServantFooterView.init(frame:CGRectMake(0, 0, ScreenWidth, 55),detail: "暂无更多动态")
        return footer
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 55
    }
    
    // 滑动的时候改变顶部 topView
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let color:UIColor = UIColor.whiteColor()
        let offsetY:CGFloat = scrollView.contentOffset.y
        
        if offsetY < 1 {
            topView?.backgroundColor = color.colorWithAlphaComponent(0)
            topTitle?.text = ""
            leftBtn?.setImage(UIImage.init(named: "nav-back"), forState:.Normal)
            rightBtn?.setImage(UIImage.init(named: "nav-jb"), forState: .Normal)
        }else {
            let alpha:CGFloat = 1 - ((64 - offsetY) / 64)
            topView?.backgroundColor = color.colorWithAlphaComponent(alpha)
            topTitle?.text = "导航标题~~"
            leftBtn?.setImage(UIImage.init(named: "nav-back-select"), forState:.Normal)
            rightBtn?.setImage(UIImage.init(named: "nav-jb-select"), forState: .Normal)
        }
    }
    
    override func didRequest() {
        didRequestComplete(nil);
    }
    
}
