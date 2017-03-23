//
//  CitysSelectViewController.swift
//  viossvc
//
//  Created by 木柳 on 2016/11/25.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit

class CitySelectedCell: OEZTableViewCell {
    @IBOutlet weak var cityNameLabeL: UILabel!
    @IBOutlet weak var citySelectBtn: UIButton!
}

class CitysSelectViewController: BaseTableViewController {
    lazy var citys: NSMutableDictionary = {
        let path = NSBundle.mainBundle().pathForResource("city", ofType: "plist")
        let cityDic = NSMutableDictionary.init(contentsOfFile: path!)
        return cityDic!
    }()
    typealias selectCityBlock = (cityName: String) ->Void
    var keys: [AnyObject]?
    var selectIndex: NSIndexPath?
    var cityName: String?
    var selectCity = selectCityBlock?()
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initNav()
        initIndexView()
    }
    //MARK: --Data
    func initData() {
        keys = citys.allKeys.sort({ (obj1: AnyObject, obj2: AnyObject) -> Bool in
            let str1 = obj1 as? String
            let str2 = obj2 as? String
            return str1?.compare(str2!).rawValue < 0
        })
        
        for (section,key) in keys!.enumerate() {
            let values = citys.valueForKey(key as! String) as! NSMutableArray
            for (row,value) in values.enumerate() {
                if value as? String ==  cityName{
                    selectIndex = NSIndexPath.init(forRow: row, inSection: section)
                    break
                }
            }
            if selectIndex != nil {
                break
            }
        }
        
        if selectIndex == nil {
            selectIndex = NSIndexPath.init(forRow: 0, inSection: 0)
        }
    }
    //MARK: --索引
    func initIndexView() {
        tableView.sectionIndexColor = UIColor(RGBHex: 0x666666)
        
    
    }
    
    //MARK: --nav
    func initNav() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "确定", style: .Plain, target: self, action: #selector(rightItemTapped))
    }
    func rightItemTapped() {
        let values = citys.valueForKey(keys![selectIndex!.section] as! String) as! NSMutableArray
        cityName = values[selectIndex!.row] as? String
        if selectCity != nil {
            selectCity!(cityName: cityName!)
        }
    
        navigationController?.popViewControllerAnimated(true)
    }
    //Mark: --table's delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return keys == nil ? 0 : keys!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let values = citys.valueForKey(keys![section] as! String) as! NSMutableArray
        return values.count
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keys![section] as? String
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let values = citys.valueForKey(keys![indexPath.section] as! String) as! NSMutableArray
        let cell: CitySelectedCell = tableView.dequeueReusableCellWithIdentifier("CitySelectedCell") as! CitySelectedCell
        cell.cityNameLabeL.text = values[indexPath.row] as? String
        cell.citySelectBtn.selected = (selectIndex != nil) && (selectIndex == indexPath)
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let lastIndex:NSIndexPath = selectIndex == nil ? indexPath : selectIndex!
        selectIndex = indexPath
        tableView.reloadRowsAtIndexPaths([lastIndex,selectIndex!], withRowAnimation: .Automatic)
    }
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return keys as? [String]
    }
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        let indexPath = NSIndexPath.init(forRow: 0, inSection: index)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        return index
    }
}
