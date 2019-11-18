//
//  MoreViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/7.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

class MoreViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource ,HomeItemTableViewCellDelegate{
    
    var roleInfoDataSource : NSMutableArray = NSMutableArray(capacity: 20)
    
    @IBOutlet weak var contentTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createUI () {
    
        self.setTitleView(titles: ["更多功能模块"])
        
        contentTableView.estimatedRowHeight = 0
        contentTableView.estimatedSectionHeaderHeight = 0
        contentTableView.estimatedSectionFooterHeight = 0
        contentTableView.delegate = self
        contentTableView.dataSource = self
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
    }
    
    override func netDisconnet() {
        
        DispatchQueue.main.async(execute: {
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
            
            self.view.viewWithTag(kNetDisConnectViewTag)?.removeFromSuperview()
            
            let netDisConnectView = Bundle.main.loadNibNamed("NetDisConnectView", owner: self, options: nil)?.first as! NetDisConnectView
            netDisConnectView.tag = kNetDisConnectViewTag
            self.contentTableView.tableHeaderView = headerView
            
            netDisConnectView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 40)
            
            self.view.addSubview(netDisConnectView)
            
        })
    }
    
    override func netConnect() {
        
        DispatchQueue.main.async(execute: {
            
            self.contentTableView?.tableHeaderView = nil
            self.view.viewWithTag(kNetDisConnectViewTag)?.removeFromSuperview()
            
        })
        
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (roleInfoDataSource.count % 4 == 0) {
            return roleInfoDataSource.count / 4
        }
        return roleInfoDataSource.count / 4 + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var homeItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if homeItemTableViewCell == nil {
            
            homeItemTableViewCell = HomeItemTableViewCell(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 100), lineNumber: indexPath.row, roles: self.roleInfoDataSource, type: -1)
            homeItemTableViewCell?.selectionStyle = .none
            (homeItemTableViewCell as! HomeItemTableViewCell).delegate = self
        }
        
        return homeItemTableViewCell!
    }
    
    
    func clickItem(_ title: String!) {
        self.clickItemExtentsion(title)
    }
}
