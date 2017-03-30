//
//  AttentionUsController.swift
//  wp
//
//  Created by macbook air on 16/12/23.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit

class ActivityVC: UIViewController,UIWebViewDelegate {
    
    let webView = UIWebView()
    var urlString: String?
    
    var isRefresh: (()->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        webView.frame = view.frame
        webView.delegate = self
        webView.backgroundColor = UIColor.whiteColor()
        view.backgroundColor = UIColor.whiteColor()
        let url = NSURL(string: "http://www.yundiantrip.com/")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
        
        let leftBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        leftBtn.setImage(UIImage.init(named: "return"), forState: UIControlState.Normal)
        leftBtn.addTarget(self, action: #selector(didBack), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
    }
    //自定义导航栏返回按钮
    func didBack() {
        isRefresh!()
        navigationController?.popViewControllerAnimated(true)
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
}
