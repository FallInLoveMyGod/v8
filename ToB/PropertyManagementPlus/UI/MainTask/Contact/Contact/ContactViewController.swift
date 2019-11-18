//
//  ContactViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/6.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

enum ContactType {
    case Colleague
    case Customer
    case Out
}

class ContactViewController: LinkBaseViewController,UITableViewDelegate,UITableViewDataSource,SeperaterContentLinkViewDelegate {

    var seperaterContentLinkView:SeperaterContentLinkView?
    var contactType:ContactType = .Colleague
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    var colleagueSuperiorpkDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var colleagueLinkPersonsDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var colleagueOrganizepkDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var customerDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var outsourcingDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        NotificationCenter.default.addObserver(self, selector: #selector(refreshContent), name: kNotificationCenterChangeState as NSNotification.Name, object: nil)
        
        let rect = CGRect(x: 0, y: kNavbarHeight + 10, width: kScreenWidth, height: kScreenHeight - kNavbarHeight - kTabBarHeight - 10)
        contentTableView?.frame = rect;
        contentTableView?.estimatedRowHeight = 0
        contentTableView?.estimatedSectionHeaderHeight = 0
        contentTableView?.estimatedSectionFooterHeight = 0
        contentTableView?.separatorStyle = .singleLine
        contentTableView?.delegate = self
        contentTableView?.dataSource = self
        
        seperaterContentLinkView = Bundle.main.loadNibNamed("SeperaterContentLinkView", owner: self, options: nil)?.first as! SeperaterContentLinkView?
        seperaterContentLinkView?.frame = self.view.bounds
        seperaterContentLinkView?.delegate = self
        self.view.addSubview(seperaterContentLinkView!)
        
        refreshContent()
        
    }
    
    override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(animated)
        
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.slider.tabbarShow()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: kNotificationCenterChangeState as NSNotification.Name, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.contactType == .Colleague) {
            return self.colleagueSuperiorpkDataSource.count
        }
        return self.customerDataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
//        let backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
//        let titleLable = UILabel(frame: CGRect(x: 10, y: 5, width: kScreenWidth, height: 30))
//        titleLable.font = UIFont.boldSystemFont(ofSize: 16)
//        if (self.contactType == .Colleague) {
//            titleLable.text = "组织架构"
//        }else if (self.contactType == .Customer) {
//            titleLable.text = "房产架构"
//        }
//        backView.addSubview(titleLable)
//        
//        backView.isHidden = false
//        
//        if (self.contactType == .Colleague && self.colleagueSuperiorpkDataSource.count == 0) {
//            backView.isHidden = true
//        }else {
//            if (self.customerDataSource.count == 0) {
//                backView.isHidden = true
//            }
//        }
//        return backView
        return nil;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if tableViewCell == nil {
            
            tableViewCell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            tableViewCell?.accessoryType = .disclosureIndicator
            tableViewCell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        
        if (self.contactType == .Colleague) {
            let model: OrganizeDataModel = self.colleagueSuperiorpkDataSource[indexPath.row] as! OrganizeDataModel
            
            tableViewCell?.textLabel?.text = model.organizename
        }else if (self.contactType == .Customer) {
            let model: HouseStructureModel = self.customerDataSource[indexPath.row] as! HouseStructureModel
            
            tableViewCell?.textLabel?.text = model.Name
        }

        return tableViewCell!
    }
    
    //MARK: SeperaterContentLinkView
    
    public func jumpWithObject(object: AnyObject) {
        
        let infoDetail = MaterialDataInfoDetailViewController()
        
        if (object.isKind(of: WorkerDataModel.self)) {
            infoDetail.materialDataInfoType = .dataInfoUnit
        }else {
            infoDetail.materialDataInfoType = .dataInfoColleague
        }
        infoDetail.model = object
        self.push(viewController: infoDetail)
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (self.contactType == .Customer) {
            let customerInfoVC = CustomerInfoViewController()
            customerInfoVC.levelHouseStructureModel = self.customerDataSource[indexPath.row] as! HouseStructureModel
            self.push(viewController: customerInfoVC)
        }else if (self.contactType == .Colleague) {
            let colleagueVC = ColleagueDetailViewController()
            colleagueVC.colleagueOrganizepkDataSource = self.colleagueOrganizepkDataSource
            colleagueVC.colleagueLinkPersonsDataSource = self.colleagueLinkPersonsDataSource
            self.push(viewController: colleagueVC)
        }
        
    }
    
    // SMSegment selector for .ValueChanged
    open override func selectSegmentInSegmentView(segmentView: SMSegmentView) {
        /*
         Replace the following line to implement what you want the app to do after the segment gets tapped.
         */
        print("Select segment at index: \(segmentView.selectedSegmentIndex)")
        
        switch segmentView.selectedSegmentIndex {
            case 0:
                self.contactType = .Colleague
            case 1:
                self.contactType = .Customer
            case 2:
                self.contactType = .Out
            default:
                break
        }
        requestData()
    }
    
    @objc func refreshContent() {
        
        guard let tab = kAppDelegate.slider.tabBarController, tab.selectedViewController == self else {
            return
        }
        
        self.isOnline = LocalStoreData.getOnLine()
        self.setTitleView(titles: ["同事","客户","外协"])
        
    }
    
    override func requestData() {
        
        if (!LocalStoreData.getOnLine()) {
            return
        }
        
        super.requestData()
        
        self.contentTableView?.isHidden = false
        seperaterContentLinkView?.isHidden = true
        
        if (self.contactType == .Colleague) {
            
            self.colleagueSuperiorpkDataSource.removeAllObjects()
            self.colleagueOrganizepkDataSource.removeAllObjects()
            
            for organizeDataModel in OrganizeDataModel.findAll() {
                if ((organizeDataModel as! OrganizeDataModel).superiorpk?.caseInsensitiveCompare("") == .orderedSame) {
                    self.colleagueSuperiorpkDataSource.add(organizeDataModel)
                }else {
                    self.colleagueOrganizepkDataSource.add(organizeDataModel)
                }

            }
            
            self.colleagueLinkPersonsDataSource.removeAllObjects()
            self.colleagueLinkPersonsDataSource.addObjects(from: WorkerDataModel.findAll())
            self.contentTableView?.reloadData()
            
        }else if (self.contactType == .Customer) {
            
            self.customerDataSource.removeAllObjects()
            //self.customerDataSource.addObjects(from: HouseStructureModel.findAll())
            
            let response = UserDefaults.standard.object(forKey: HouseStructureDataSynchronization)
            
            let dict = JSON(response ?? {})

            for (_,tempDict) in dict["PProjects"] {
                
                if let houseStructureModel:HouseStructureModel = HouseStructureModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                    self.customerDataSource.add(houseStructureModel)
                }
                
            }
            
            self.contentTableView?.reloadData()
            
        }else {
            
            //外协
            
            self.contentTableView?.isHidden = true
            seperaterContentLinkView?.isHidden = false
            
            self.outsourcingDataSource.removeAllObjects()
            self.outsourcingDataSource.addObjects(from: OutsourcingDataModel.findAll())
            
            if (self.outsourcingDataSource.count != 0) {
                self.seperaterContentLinkView?.refresh(content: self.outsourcingDataSource,type: 0)
            }
            
        }
        
    }
}
