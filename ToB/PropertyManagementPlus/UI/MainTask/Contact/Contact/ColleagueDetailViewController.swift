//
//  ColleagueDetailViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/20.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

//TODO:
public protocol ColleagueDetailDelegate {
    func colleagueconfirmWithObject(object: AnyObject)
}


class ColleagueDetailViewController: BaseViewController,SeperaterContentLinkViewDelegate {

    
    var delegate : ColleagueDetailDelegate?
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var isTopLevelShow: Bool = false
    var seperaterContentLinkView:SeperaterContentLinkView?
    
    var model: WorkerDataModel?
    
    //同事信息
    var colleagueOrganizeSuperpkDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var colleagueOrganizepkDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var colleagueLinkPersonsDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        if (isTopLevelShow) {
            self.setTitleView(titles: ["选择员工"])
            
        }else {
            self.setTitleView(titles: ["同事列表"])
        }
        seperaterContentLinkView = Bundle.main.loadNibNamed("SeperaterContentLinkView", owner: self, options: nil)?.first as! SeperaterContentLinkView?
        seperaterContentLinkView?.frame = self.view.bounds
        self.view.addSubview(seperaterContentLinkView!)
        
        seperaterContentLinkView?.topTitleTextLabel.text = "组织架构";
        seperaterContentLinkView?.nextTitleTextLabel.text = "联系人";
        
        self.refreshData(type: isTopLevelShow ? 0 : 1)
        self.seperaterContentLinkView?.topContrains.constant = 0;
        if (isTopLevelShow) {
            buttonAction(titles: ["返回","确定"], actions: [#selector(pop),#selector(commit)], target: self)
            requestDatas()
        }else {
            buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func refreshData(type: NSInteger) {
        
        seperaterContentLinkView?.isTopLevelShow = isTopLevelShow
        
        seperaterContentLinkView?.colleagueOrganizeSuperpkDataSource = self.colleagueOrganizeSuperpkDataSource
        seperaterContentLinkView?.colleagueOrganizepkDataSource = self.colleagueOrganizepkDataSource
        
        seperaterContentLinkView?.colleagueLinkPersonsDataSource = self.colleagueLinkPersonsDataSource
        seperaterContentLinkView?.delegate = self
        
        seperaterContentLinkView?.refresh(content: self.colleagueOrganizepkDataSource, type: 1)
        
    }
    
    func requestDatas() {
        
        if (isTopLevelShow) {
            
            LoadView.storeLabelText = "正在加载组织架构信息"
            
            let getOrganizeDataAPICmd = GetOrganizeDataAPICmd()
            getOrganizeDataAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getOrganizeDataAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
            getOrganizeDataAPICmd.loadView = LoadView()
            getOrganizeDataAPICmd.loadParentView = self.view
            getOrganizeDataAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    self.colleagueOrganizepkDataSource.removeAllObjects()
                    self.colleagueOrganizeSuperpkDataSource.removeAllObjects()
                    for (_,tempDict) in dict["organizeInfo"] {
                        
                        if let organizeDataModel:OrganizeDataModel = OrganizeDataModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            
                            if (organizeDataModel.superiorpk?.caseInsensitiveCompare("") == .orderedSame) {
                                self.colleagueOrganizeSuperpkDataSource.add(organizeDataModel)
                            }else {
                                self.colleagueOrganizepkDataSource.add(organizeDataModel)
                            }
                            
                        }
                        
                    }
                    
                    self.refreshData(type: 1)
                    //self.refreshData(type: self.isTopLevelShow ? 0 : 1)
                    
                }else {
                    LocalToastView.toast(text: "获取组织架构信息失败！")
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
            
            
            let getWorkerDataAPICmd = GetWorkerDataAPICmd()
            getWorkerDataAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getWorkerDataAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
            getWorkerDataAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    self.colleagueLinkPersonsDataSource.removeAllObjects()
                    for (_,tempDict) in dict["workerinfo"] {
                        
                        if let workerDataModel:WorkerDataModel = WorkerDataModel.yy_model(withJSON: tempDict.rawString() ?? {}) {
                            self.colleagueLinkPersonsDataSource.add(workerDataModel)
                        }
                        
                    }
                    
                    self.refreshData(type: 1)
                    //self.refreshData(type: self.isTopLevelShow ? 0 : 1)
                    
                }else {
                    LocalToastView.toast(text: "获取联系人信息失败！")
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
            
        }
        
    }
    
    //MARK: SeperaterContentLinkView
    
    public func jumpWithObject(object: AnyObject) {
        
        if (isTopLevelShow) {
            
            model = object as? WorkerDataModel
            
            let name = "选择了员工：" + (model?.workername)!
            
            self.setTitleView(titles: [name as NSString])
            
        }else {
            
            let infoDetail = MaterialDataInfoDetailViewController()
            
            if (object.isKind(of: WorkerDataModel.self)) {
                infoDetail.materialDataInfoType = .dataInfoUnit
            }else {
                infoDetail.materialDataInfoType = .dataInfoColleague
            }
            infoDetail.model = object
            self.push(viewController: infoDetail)
        }
        
    }
    
    @objc func commit() {
        delegate?.colleagueconfirmWithObject(object: model!)
        pop()
    }
    
}
