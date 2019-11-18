//
//  MyViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/2/16.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class MyViewController: BaseTableViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(createContentUI), name: kNotificationCenterFreshMyPage as NSNotification.Name, object: nil)
        
        createContentUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc public func createContentUI () {
        
//        guard let tab = kAppDelegate.slider.tabBarController, tab.selectedViewController == self else {
//            return
//        }
        
        var y = kNavbarHeight
        
        self.view.viewWithTag(1777)?.removeFromSuperview()
        
        if (LocalStoreData.getApplicense()!.compare("NO") == .orderedSame) {
            
            let tipStrOne = ("当前版本为试用版，剩余".appending((LocalStoreData.getIsUse() ?? "") as String)).appending("天，请及时联系我们！")
            let tipStrTwo = ("        当前版本为使用版，剩余".appending((LocalStoreData.getIsUse() ?? "") as String)).appending("天，请及时联系我们！")
            
            let cFaTextCarouselView = CFaTextCarouselView(frame: CGRect(x: 0.0, y: 0, width: kScreenWidth, height: 40), textArray: [tipStrOne,tipStrTwo], carouselDirection: .horizontally, carouselType: .flowing)
            cFaTextCarouselView?.tag = 1777
            cFaTextCarouselView?.scrollDelay = 6
            cFaTextCarouselView?.isCanUserScroll = true
            cFaTextCarouselView?.isCanUserTap = true
            cFaTextCarouselView?.textFont = UIFont.systemFont(ofSize: 15.0)
            cFaTextCarouselView?.textColor = UIColor.red
            cFaTextCarouselView?.backgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 214/255.0, alpha: 1.0)
            self.view.addSubview(cFaTextCarouselView!)
            
            y = kNavbarHeight + 40
            
        }
        
        self.setTitleView(titles: ["我的"])
        contentTableView?.delegate = self
        contentTableView?.dataSource = self
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: y, width: kScreenWidth, height: kScreenHeight - kNavbarHeight), hasHeader: false, hasFooter: false)
    }
    
    @objc func refreshContent() {
        self.setTitleView(titles: ["我的"])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: kNotificationCenterFreshMyPage as NSNotification.Name, object: nil)
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 70.0
        }
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let cellIdentifier = "CellIdentifier"
            var myTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            
            if myTableViewCell == nil {
                
                myTableViewCell = Bundle.main.loadNibNamed("MyTableViewCell", owner: nil, options: nil)?.first as! MyTableViewCell
                myTableViewCell?.selectionStyle = .none
                
            }
            
            let userInfo = LocalStoreData.getUserInfo()
            
            let tempMyTableViewCell: MyTableViewCell = (myTableViewCell as! MyTableViewCell)
            tempMyTableViewCell.nameLabel.text = userInfo?.name
            tempMyTableViewCell.companyNameLabel.text = LocalStoreData.getCompanyName() as String?
            
            if (userInfo?.type?.compare("1") == .orderedSame) {
                tempMyTableViewCell.roleLabel.text = "普通用户"
            }else {
                tempMyTableViewCell.roleLabel.text = "管理员"
            }
            
            return myTableViewCell!
        }
        
        let cellIdentifier = "CellID"
        var myNormalTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if myNormalTableViewCell == nil {
            
            myNormalTableViewCell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            myNormalTableViewCell?.accessoryType = .disclosureIndicator
            myNormalTableViewCell?.imageView?.image = UIImage(named: "icon_setting")
            myNormalTableViewCell?.textLabel?.text = "设置"
        }
        
        return myNormalTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 1) {
            
            let set:SetViewController = SetViewController()
            self.push(viewController: set)
            
        }
    }

}
