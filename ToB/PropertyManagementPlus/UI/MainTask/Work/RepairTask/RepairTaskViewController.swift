//
//  RepairTaskViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/10.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

/*
import UIKit
import SwiftyJSON
import HandyJSON

class RepairTaskViewController: BaseTableViewController,FJFloatingViewDelegate {

    var floatingView: FJFloatingView = FJFloatingView(frame: CGRect(x: kScreenWidth - 80, y: kScreenHeight - 190, width: 60, height: 60))
    
    let myCreateTask = Bundle.main.loadNibNamed("TaskNumberImageTableViewCell", owner: nil, options: nil)?.first as! TaskNumberImageTableViewCell
    var backView = UIView()
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var getMyRepareTaskNumModel: GetMyRepareTaskNumModel?
    var getStateNumJsonModel: GetStateNumJsonModel?
    
    var stateNumNames = ["未完成","未派单","已派单","待修中","进行中","已完成","未回访","已回访","已退单"]
    
    var myRepareNames = ["未派单","未完成","未回访","未检验","未提交","已派单","已完成","已回访","已检验","已退回"]
    
    var myRepareCategorys = ["NoSend","NoComplete","NoReCall","NoCheck",
                             "NoCommit","AlreadySend","AlreadyComplete","AlreadyCallBack",
                             "AlreadyCheck","AlreadyBack"]
    
    var stateValues = ["0","0","0","0","0","0","0","0","0","0"]
    
    var myRepareValues = ["0","0","0","0","0","0","0","0","0","0"]
    
    var selectIndex: NSInteger = 0
    
    //MyCreateCount
    var myCreateCount = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.setTitleView(titles: ["维修任务"])
        self.addSegmentView(titles: ["我的维修","所有维修"])
        
        self.localHasFooter = false
        
        refreshUI(frame: CGRect(x: 0, y: 50, width: kScreenWidth, height: kScreenHeight - 165))
        
        buttonAction(titles: ["返回","查看抢单"], actions: [#selector(pop),#selector(viewGrab)], target: self)
        
        backView.frame = CGRect(x: 0, y: segmentView.frame.origin.y + segmentView.frame.size.height + 10, width: kScreenWidth, height: 50)
        backView.backgroundColor = UIColor.groupTableViewBackground
        //self.view.addSubview(backView)
        
        myCreateTask.contentView.frame = CGRect(x: 0, y: segmentView.frame.origin.y + segmentView.frame.size.height + 15, width: kScreenWidth, height: 40)
        myCreateTask.accessoryType = .disclosureIndicator
        myCreateTask.contentView.isUserInteractionEnabled = true
        myCreateTask.contentView.backgroundColor = UIColor.white
        myCreateTask.nameLabel.text = "我创建的维修"
        myCreateTask.nameLabel.textColor = UIColor.black
        myCreateTask.traingConstraint.constant = 30
        //self.view.addSubview(myCreateTask.contentView)
        
        let imageView = UIImageView(frame: CGRect(x: kScreenWidth - 35, y: 8, width: 30, height: 25))
        imageView.image = UIImage(named: "icon_next")
        myCreateTask.contentView.addSubview(imageView)
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(myCreate))
        myCreateTask.contentView.addGestureRecognizer(tapGes)
        
        floatingView.delegate = self
        self.view.addSubview(floatingView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //去掉NavigationBar的背景和横线
        navigationController?.navigationBar.subviews[0].isHidden = true
        reloadLocalData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func netDisconnet() {
        
        DispatchQueue.main.async(execute: {
            
            self.changeTopUIFrame(height: 50)
        })

    }
    
    override func netConnect() {
        
        DispatchQueue.main.async(execute: {
            
            self.changeTopUIFrame(height: 0)
        })
        
    }
    
    func changeTopUIFrame(height: CGFloat) {
        
        self.view.viewWithTag(kSegmentViewTag)?.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 50 + height)
        self.segmentView.frame = CGRect(x: 40, y: height, width: kScreenWidth - 80, height: 40)
        
        self.contentTableView?.frame = CGRect(x: 0, y: 50 + height, width: kScreenWidth, height: kScreenHeight - (101 + height))
        
        self.view.viewWithTag(kNetDisConnectViewTag)?.removeFromSuperview()
        
        let netDisConnectView = Bundle.main.loadNibNamed("NetDisConnectView", owner: self, options: nil)?.first as! NetDisConnectView
        netDisConnectView.tag = kNetDisConnectViewTag
        netDisConnectView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 40)
        if (height == 50) {
            self.view.addSubview(netDisConnectView)
        }else {
            
        }
        
        self.changeUIFrame()
        
    }
    
    override func selectSegmentInSegmentView(segmentView: SMSegmentView) {
        selectIndex = segmentView.selectedSegmentIndex
        
        myCreateTask.contentView.removeFromSuperview()
        backView.removeFromSuperview()
        
        if (selectIndex == 0) {
            floatingView.isHidden = false;
            //self.view.addSubview(backView)
            //self.view.addSubview(myCreateTask.contentView)
        }else {
            floatingView.isHidden = true;
        }
        
        self.requestData()
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (selectIndex == 0) {
            return 1
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selectIndex == 0) {
            return myRepareNames.count
        }
        return stateNumNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
//        if (selectIndex == 0)  {
//            return 50
//        }
        
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var taskTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if taskTableViewCell == nil {
            
            taskTableViewCell = Bundle.main.loadNibNamed("TaskNumberImageTableViewCell", owner: nil, options: nil)?.first as! TaskNumberImageTableViewCell
            taskTableViewCell?.selectionStyle = .none
            taskTableViewCell?.accessoryType = .disclosureIndicator
            
        }
        
        let tempCell: TaskNumberImageTableViewCell = (taskTableViewCell as! TaskNumberImageTableViewCell)
        //tempCell.traingConstraint.constant = -10
        
        if (selectIndex == 0) {
            
            tempCell.nameLabel.text = myRepareNames[indexPath.row]
            
            var content = ""
            
            content = self.myRepareValues[indexPath.row]
            
            if (content.compare("0") == .orderedSame) {
                tempCell.numberLabel.text = ""
                
            }else {
                tempCell.numberLabel.text = content
            }
            
            if (tempCell.nameLabel.text?.compare("未提交") == .orderedSame) {
                tempCell.nameLabel.textColor = UIColor.red
            }else {
                tempCell.nameLabel.textColor = UIColor.black
            }
            
            
        }else {
            
            tempCell.nameLabel.text = stateNumNames[indexPath.row]
            
            var content = ""
            
            if (self.getStateNumJsonModel != nil) {
                
                content = self.stateValues[indexPath.row]
                
                if (content.compare("0") == .orderedSame) {
                    tempCell.numberLabel.text = ""
                }else if (content.compare("") == .orderedSame) {
                    tempCell.numberLabel.text = content
                }else {
                    tempCell.numberLabel.text = "(" + content + ")"
                }
                
                tempCell.leftMarginConstraint.constant = 10
                
                if (tempCell.nameLabel.text?.compare("未完成") == .orderedSame
                    || tempCell.nameLabel.text?.compare("已完成") == .orderedSame
                    || tempCell.nameLabel.text?.compare("已退单") == .orderedSame) {
                    tempCell.nameLabel.textColor = kThemeColor
                    tempCell.leftMarginConstraint.constant = 0
                }else {
                    tempCell.nameLabel.textColor = UIColor.black
                }
            }
            
        }
        
//        let model: GetTaskListModel = self.myRepairTaskDataSource[indexPath.row] as! GetTaskListModel
//        
//        let tempTaskTableViewCell: TaskTableViewCell = (taskTableViewCell as! TaskTableViewCell)
//        
//        if model.Categories?.caseInsensitiveCompare("1") == .orderedSame {
//            //1: 维修任务
//            tempTaskTableViewCell.titleNameLabel.text = "维修任务"
//        }else {
//            tempTaskTableViewCell.titleNameLabel.text = "未知任务"
//        }
//        
//        tempTaskTableViewCell.digestLabel.text = model.Sender?.appending("发来的\"".appending(TaskSettingAction.getKind(kind: model.Kind!))).appending("\"任务")
//        
//        
//        tempTaskTableViewCell.timeLable.text = model.SendTime
//        tempTaskTableViewCell.describeLabel.text = model.Description
        
        
        return taskTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController = RepairTaskDetailViewController()
        var content = ""
        var state = ""
        if (selectIndex == 1) {
        
            state = "All"
            
            if (self.getStateNumJsonModel != nil) {
                content = self.stateValues[indexPath.row]
                
                switch stateNumNames[indexPath.row] {
                case "未完成":
                    state = "0"
                case "未派单":
                    state = "1"
                case "已派单":
                    state = "2"
                case "待修中":
                    state = "3"
                case "进行中":
                    state = "4"
                case "已完成":
                    state = "5"
                case "未回访":
                    state = "6"
                case "已回访":
                    state = "7"
                case "已退单":
                    state = "8"
                default:
                    break
                }
                
            }
            
            
            //+ content + ")条"
            content = stateNumNames[indexPath.row]
            viewController.state = state
            
        }else {
            
            content = self.myRepareValues[indexPath.row]
            
            //+ content + ")条"
            content = "维修任务-" + myRepareNames[indexPath.row]
            
            var contentType = ""
            
            switch myRepareNames[indexPath.row] {
            case "未派单":
                contentType = "1"
            case "未完成":
                contentType = "2"
            case "未回访":
                contentType = "5"
            case "未检验":
                contentType = "6"
            default:
                break
            }
            
            if (indexPath.row == 0
                || indexPath.row == 1
                || indexPath.row == 2
                || indexPath.row == 3) {
                viewController.category = self.myRepareCategorys[indexPath.row]
            }else {
                
                let localDetail = RepairLocalTaskDetailViewController()
                localDetail.titleContent = content as NSString?
                
                //NoCommit\AlreadySend\AlreadyComplete\AlreadyCallBack\AlreadyCheck\AlreadyBack
                
                if (indexPath.row == 4) {
                    localDetail.category = "NoCommit"
                }else if (indexPath.row == 5) {
                    localDetail.category = "AlreadySend"
                }else if (indexPath.row == 6) {
                    localDetail.category = "AlreadyComplete"
                }else if (indexPath.row == 7) {
                    localDetail.category = "AlreadyCallBack"
                }else if (indexPath.row == 8) {
                    localDetail.category = "AlreadyCheck"
                }else if (indexPath.row == 9) {
                    localDetail.category = "AlreadyBack"
                }
                
                self.navigationController?.pushViewController(localDetail, animated: true)
                
                return
            }
            
            viewController.contentType = contentType
        }
        
        viewController.titleContent = content as NSString?
        viewController.selectIndex = selectIndex
        
        push(viewController: viewController)
        
    }
    
    func changeUIFrame() {
        
        backView.frame = CGRect(x: 0, y: segmentView.frame.origin.y + segmentView.frame.size.height + 10, width: kScreenWidth, height: 50)
        backView.backgroundColor = UIColor.groupTableViewBackground
        
        myCreateTask.contentView.frame = CGRect(x: 0, y: segmentView.frame.origin.y + segmentView.frame.size.height + 15, width: kScreenWidth, height: 40)
        
    }
    
    func reloadLocalData() {
        
        let createNumberArray = GetRepaireListModel.find(byCriteria: " WHERE Category = 'MyCreate'")
        if (createNumberArray?.count != 0) {
            myCreateCount = NSString(format: "%d", (createNumberArray?.count)!) as String
            myCreateTask.numberLabel.text = String(myCreateCount)
        }
        
        var index = 0
        for name in myRepareCategorys {
            
            //if (index >= 4) {
                let sql = " WHERE Category = '" + name + "'"
                myRepareValues[index] = String(GetRepaireListModel.find(byCriteria: sql).count)
            //}
            
            index = index + 1
        }
        
        requestData()
        
        self.contentTableView?.reloadData()
    }
    
    override func requestData() {
        
        super.requestData()
        
        if (selectIndex == 0) {
            
            LoadView.storeLabelText = "正在加载我的维修信息"
            
            let getMyRepareTaskNumAPICmd = GetMyRepareTaskNumAPICmd()
            getMyRepareTaskNumAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getMyRepareTaskNumAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
            getMyRepareTaskNumAPICmd.loadView = LoadView()
            getMyRepareTaskNumAPICmd.loadParentView = self.view
            getMyRepareTaskNumAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    self.getMyRepareTaskNumModel = GetMyRepareTaskNumModel()
                    
                    self.getMyRepareTaskNumModel = JSONDeserializer<GetMyRepareTaskNumModel>.deserializeFrom(json: JSON(dict.object).rawString())
                    
                    self.myRepareValues[0] = (self.getMyRepareTaskNumModel?.NoSend)!
                    self.myRepareValues[1] = (self.getMyRepareTaskNumModel?.NoComplete)!
                    self.myRepareValues[2] = (self.getMyRepareTaskNumModel?.NoReCall)!
                    self.myRepareValues[3] = (self.getMyRepareTaskNumModel?.NoCheck)!
                    
                    self.contentTableView?.reloadData()
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
                let checkNumberArray = GetRepaireListModel.find(byCriteria: " WHERE Category = 'AlreadyCheck'")
                let mycheckCount = NSString(format: "%d", (checkNumberArray?.count)!) as String
                self.myRepareValues[8] = mycheckCount
                
                self.stopFresh()
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
                self.stopFresh()
            }
            
        }else {
            
            LoadView.storeLabelText = "正在加载所有维修信息"
            
            let getStateNumJsonAPICmd = GetStateNumJsonAPICmd()
            getStateNumJsonAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getStateNumJsonAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? ""]
            getStateNumJsonAPICmd.loadView = LoadView()
            getStateNumJsonAPICmd.loadParentView = self.view
            getStateNumJsonAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    self.getStateNumJsonModel = JSONDeserializer<GetStateNumJsonModel>.deserializeFrom(json: JSON(dict.object).rawString())
                    
                    
                    self.stateValues[0] = (self.getStateNumJsonModel?.NoComplete)!
                    self.stateValues[1] = (self.getStateNumJsonModel?.NoSend)!
                    self.stateValues[2] = (self.getStateNumJsonModel?.Send)!
                    self.stateValues[3] = (self.getStateNumJsonModel?.WaitRepare)!
                    self.stateValues[4] = (self.getStateNumJsonModel?.Repareing)!
                    self.stateValues[5] = (self.getStateNumJsonModel?.Complete)!
                    self.stateValues[6] = (self.getStateNumJsonModel?.NoRecall)!
                    self.stateValues[7] = (self.getStateNumJsonModel?.Recall)!
                    
                    self.contentTableView?.reloadData()
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
                self.stopFresh()
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
                self.stopFresh()
            }
            
        }
        
    }
    
    //查看抢单
    @objc func viewGrab() {
        
        let viewController = RepairTaskDetailViewController()
        viewController.selectIndex = -1
        viewController.contentType = "4"
        viewController.titleContent = "待抢列表"
        push(viewController: viewController)
        
    }
    
    func floatingViewClick() {
        
        let viewController = RepairTaskAddViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @objc func myCreate() {
        //我创建的维修
        let tempVC = RepairLocalTaskDetailViewController()
        tempVC.titleContent = "维修任务-我的报修" as NSString?
        tempVC.category = "MyCreate"
        push(viewController: tempVC)
        
    }

}
 */

import UIKit
import SwiftyJSON
import HandyJSON

class RepairTaskViewController: BaseTableViewController,FJFloatingViewDelegate,AlertViewDelegate,ChooseAlertDelegate,DataSynchronizationManagerDelegate {
    
    func startSynchronization(synchronizationType: NSInteger) {
//        self.hud.show(animated: true)
    }
    func endSynchronization(synchronizationType: NSInteger, itemNumber: NSString) {
//        self.hud.hide(animated: true)
    }
    
    lazy var hud:MBProgressHUD = {
        let myHud = MBProgressHUD.init(view: self.view);
        myHud.mode = MBProgressHUDMode.indeterminate;
        self.view.addSubview(myHud);
        return myHud;
    }()
    
    var floatingView: FJFloatingView = FJFloatingView(frame: CGRect(x: kScreenWidth - 80, y: kScreenHeight - 190, width: 60, height: 60))
    
    let myCreateTask = Bundle.main.loadNibNamed("TaskNumberImageTableViewCell", owner: nil, options: nil)?.first as! TaskNumberImageTableViewCell
    var backView = UIView()
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var getMyRepareTaskNumModel: GetMyRepareTaskNumModel?
    var getStateNumJsonModel: GetStateNumJsonModel?
    
    var stateNumNames = ["未完成","未派单","已派单","待修中","进行中","已完成","未回访","已回访","已退单"]
    
    //    var myRepareNames = ["未派单","未完成","未回访","未检验","未提交","已派单","已完成","已回访","已检验","已退回"]
    
    var myRepareNames = ["未处理","未派单","未接单","未完成","未发起回访","未回访","未检验","未提交","已派单","已完成","已回访","已检验"]
    
    //    var myRepareCategorys = ["NoSend","NoComplete","NoReCall","NoCheck",
    //                             "NoCommit","AlreadySend","AlreadyComplete","AlreadyCallBack",
    //                             "AlreadyCheck","AlreadyBack"]
    
    var myRepareCategorys = ["NoHandel","NoSend","NoAccept","NoComplete","NoSendToReCall","NoReCall","NoCheck","NoSubmit","Send","Complete","ReCall","Check"]
    
    var stateValues = ["0","0","0","0","0","0","0","0","0","0","0","0"]
    
    var myRepareValues = ["0","0","0","0","0","0","0","0","0","0","0","0"]
    
    var selectIndex: NSInteger = 0
    
    //MyCreateCount
    var myCreateCount = "0"
    
    var chooseTitle:NSString? = "" // 楼盘筛选
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.setTitleView(titles: ["维修任务"])
        self.addSegmentView(titles: ["我的维修","所有维修"])
        
        self.localHasFooter = false
        
        refreshUI(frame: CGRect(x: 0, y: 50, width: kScreenWidth, height: kScreenHeight - 165))
        
        buttonAction(titles: ["返回","查看抢单"], actions: [#selector(pop),#selector(viewGrab)], target: self)
        
        backView.frame = CGRect(x: 0, y: segmentView.frame.origin.y + segmentView.frame.size.height + 10, width: kScreenWidth, height: 50)
        backView.backgroundColor = UIColor.groupTableViewBackground
        //self.view.addSubview(backView)
        
        myCreateTask.contentView.frame = CGRect(x: 0, y: segmentView.frame.origin.y + segmentView.frame.size.height + 15, width: kScreenWidth, height: 40)
        myCreateTask.accessoryType = .disclosureIndicator
        myCreateTask.contentView.isUserInteractionEnabled = true
        myCreateTask.contentView.backgroundColor = UIColor.white
        myCreateTask.nameLabel.text = "我创建的维修"
        myCreateTask.nameLabel.textColor = UIColor.black
        myCreateTask.traingConstraint.constant = 30
        //self.view.addSubview(myCreateTask.contentView)
        
        let imageView = UIImageView(frame: CGRect(x: kScreenWidth - 35, y: 8, width: 30, height: 25))
        imageView.image = UIImage(named: "icon_next")
        myCreateTask.contentView.addSubview(imageView)
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(myCreate))
        myCreateTask.contentView.addGestureRecognizer(tapGes)
        
        floatingView.delegate = self
        self.view.addSubview(floatingView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //去掉NavigationBar的背景和横线
        if navigationController?.navigationBar.subviews.count != 0 {
            navigationController?.navigationBar.subviews[0].isHidden = true
        }
        reloadLocalData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func netDisconnet() {
        
        DispatchQueue.main.async(execute: {
            
            self.changeTopUIFrame(height: 50)
        })
        
    }
    
    override func netConnect() {
        
        DispatchQueue.main.async(execute: {
            
            self.changeTopUIFrame(height: 0)
        })
        
    }
    
    func changeTopUIFrame(height: CGFloat) {
        
        self.view.viewWithTag(kSegmentViewTag)?.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 50 + height)
        self.segmentView.frame = CGRect(x: 40, y: height, width: kScreenWidth - 80, height: 40)
        
        self.contentTableView?.frame = CGRect(x: 0, y: 50 + height, width: kScreenWidth, height: kScreenHeight - (101 + height))
        
        self.view.viewWithTag(kNetDisConnectViewTag)?.removeFromSuperview()
        
        let netDisConnectView = Bundle.main.loadNibNamed("NetDisConnectView", owner: self, options: nil)?.first as! NetDisConnectView
        netDisConnectView.tag = kNetDisConnectViewTag
        netDisConnectView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 40)
        if (height == 50) {
            self.view.addSubview(netDisConnectView)
        }else {
            
        }
        
        self.changeUIFrame()
        
    }
    
    override func selectSegmentInSegmentView(segmentView: SMSegmentView) {
        selectIndex = segmentView.selectedSegmentIndex
        
        myCreateTask.contentView.removeFromSuperview()
        backView.removeFromSuperview()
        
        if (selectIndex == 0) {
            floatingView.isHidden = false;
            self.navigationItem.rightBarButtonItem = nil;
            //self.view.addSubview(backView)
            //self.view.addSubview(myCreateTask.contentView)
        }else {
            floatingView.isHidden = true;
            let rightBarBtn = UIBarButtonItem.init(image: UIImage(named: "SX.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(chooseArea))
            self.navigationItem.rightBarButtonItem = rightBarBtn;
        }
        
        self.requestData()
    }
    
    @objc func chooseArea() {
        
        if  (!HouseStructureModel.isExistInTable())  {
            let alertv = UIAlertController.init(title: "还未同步房产信息", message: "是否同步", preferredStyle: UIAlertControllerStyle.alert)
            let action1 = UIAlertAction.init(title: "立即同步", style: .default) { (action) in
                DataSynchronizationManager.houseStructureDataSynchronization();
                DataSynchronizationManager.delegate = self
            }
            let cancleAction = UIAlertAction.init(title: "取消", style: .default) { (action) in
                
            }
            alertv.addAction(action1);
            alertv.addAction(cancleAction);
            self.present(alertv, animated: true, completion: nil);
            return;
        }
        let arr:NSArray = HouseStructureModel.findAll()! as NSArray;
        let alert = ChooseAlertView.init(frame: CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight));
        appDelegate.window?.addSubview(alert)
        alert.delegate = self;
        alert.dataSource = arr;
        alert.show()
//        let alertView = AlertView.init(frame: CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight))
//        appDelegate.window?.addSubview(alertView)
//        alertView.delegate = self;
//        alertView.dataSource = arr as! [Any];
//        alertView.show()
    }
    
    // MARK:ChooseAlertDelegate
    func tableViewSelectWithHouseModel(model: HouseStructureModel) {
        print(model.Code ?? "");
        self.chooseTitle = model.Code! as NSString;
        self.setTitleView(titles: [("维修任务-" + model.Name! as NSString)])
        self.requestData()
    }
    
    // MARK:AlertViewDelegate
    func tableViewDidSelect(withAreaName areaName: HouseStructureModel!) {
        print(areaName);
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (selectIndex == 0) {
            return 1
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selectIndex == 0) {
            return myRepareNames.count
        }
        return stateNumNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        //        if (selectIndex == 0)  {
        //            return 50
        //        }
        
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var taskTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if taskTableViewCell == nil {
            
            taskTableViewCell = Bundle.main.loadNibNamed("TaskNumberImageTableViewCell", owner: nil, options: nil)?.first as! TaskNumberImageTableViewCell
            taskTableViewCell?.selectionStyle = .none
            taskTableViewCell?.accessoryType = .disclosureIndicator
            
        }
        
        let tempCell: TaskNumberImageTableViewCell = (taskTableViewCell as! TaskNumberImageTableViewCell)
        //tempCell.traingConstraint.constant = -10
        
        if (selectIndex == 0) {
            
            tempCell.nameLabel.text = myRepareNames[indexPath.row]
            
            var content = ""
            
            content = self.myRepareValues[indexPath.row]
            
            if (content.compare("0") == .orderedSame) {
                tempCell.numberLabel.text = ""
                
            }else {
                tempCell.numberLabel.text = content
            }
            
            if (tempCell.nameLabel.text?.compare("未提交") == .orderedSame) {
                tempCell.nameLabel.textColor = UIColor.red
                tempCell.numberLabel.text = self.myRepareValues[7] as String?
            }else {
                tempCell.nameLabel.textColor = UIColor.black
            }
            
            
        }else {
            
            tempCell.nameLabel.text = stateNumNames[indexPath.row]
            
            var content = ""
            
            if (self.getStateNumJsonModel != nil) {
                
                content = self.stateValues[indexPath.row]
                
                if (content.compare("0") == .orderedSame) {
                    tempCell.numberLabel.text = ""
                }else if (content.compare("") == .orderedSame) {
                    tempCell.numberLabel.text = content
                }else {
                    tempCell.numberLabel.text = "(" + content + ")"
                }
                
                tempCell.leftMarginConstraint.constant = 10
                
                if (tempCell.nameLabel.text?.compare("未完成") == .orderedSame
                    || tempCell.nameLabel.text?.compare("已完成") == .orderedSame
                    || tempCell.nameLabel.text?.compare("已退单") == .orderedSame) {
                    tempCell.nameLabel.textColor = kThemeColor
                    tempCell.leftMarginConstraint.constant = 0
                }else {
                    tempCell.nameLabel.textColor = UIColor.black
                }
            }
            
        }
        
        //        let model: GetTaskListModel = self.myRepairTaskDataSource[indexPath.row] as! GetTaskListModel
        //
        //        let tempTaskTableViewCell: TaskTableViewCell = (taskTableViewCell as! TaskTableViewCell)
        //
        //        if model.Categories?.caseInsensitiveCompare("1") == .orderedSame {
        //            //1: 维修任务
        //            tempTaskTableViewCell.titleNameLabel.text = "维修任务"
        //        }else {
        //            tempTaskTableViewCell.titleNameLabel.text = "未知任务"
        //        }
        //
        //        tempTaskTableViewCell.digestLabel.text = model.Sender?.appending("发来的\"".appending(TaskSettingAction.getKind(kind: model.Kind!))).appending("\"任务")
        //
        //
        //        tempTaskTableViewCell.timeLable.text = model.SendTime
        //        tempTaskTableViewCell.describeLabel.text = model.Description
        
        
        return taskTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController = RepairTaskDetailViewController()
        var content = ""
        var state = ""
        if (selectIndex == 1) {
            
            state = "All"
            
            if (self.getStateNumJsonModel != nil) {
                content = self.stateValues[indexPath.row]
                
                switch stateNumNames[indexPath.row] {
                case "未完成":
                    state = "0"
                case "未派单":
                    state = "1"
                case "已派单":
                    state = "2"
                case "待修中":
                    state = "3"
                case "进行中":
                    state = "4"
                case "已完成":
                    state = "5"
                case "未回访":
                    state = "6"
                case "已回访":
                    state = "7"
                case "已退单":
                    state = "8"
                default:
                    break
                }
                
            }
            
            
            //+ content + ")条"
            content = stateNumNames[indexPath.row]
            viewController.state = state
            viewController.chooseTitle = self.chooseTitle;
            
        }else {
            
            content = self.myRepareValues[indexPath.row]
            
            //+ content + ")条"
            content = "维修任务-" + myRepareNames[indexPath.row]
            
            var contentType = ""
            
            switch myRepareNames[indexPath.row] {
            case "未派单":
                contentType = "1"
            case "未完成":
                contentType = "12"
            case "未回访":
                contentType = "5"
            case "未检验":
                contentType = "6"
            case "已派单":
                contentType = "8"
            case "已完成":
                contentType = "9"
            case "已回访":
                contentType = "10"
            case "已检验":
                contentType = "11"
            case "未处理":
                contentType = "0"
            case "未发起回访":
                contentType = "7"
            case "未接单":
                contentType = "2"
            default:
                break
            }
            
            if (indexPath.row != 7) {
                viewController.category = self.myRepareCategorys[indexPath.row]
            }else {
                
                let localDetail = RepairLocalTaskDetailViewController()
                localDetail.titleContent = content as NSString?
                localDetail.category = "NoCommit"
                
                //NoCommit\AlreadySend\AlreadyComplete\AlreadyCallBack\AlreadyCheck\AlreadyBack
                
//                if (indexPath.row == 4) {
//                    localDetail.category = "NoCommit"
//                }else if (indexPath.row == 5) {
//                    localDetail.category = "AlreadySend"
//                }else if (indexPath.row == 6) {
//                    localDetail.category = "AlreadyComplete"
//                }else if (indexPath.row == 7) {
//                    localDetail.category = "AlreadyCallBack"
//                }else if (indexPath.row == 8) {
//                    localDetail.category = "AlreadyCheck"
//                }else if (indexPath.row == 9) {
//                    localDetail.category = "AlreadyBack"
//                }
                
                self.navigationController?.pushViewController(localDetail, animated: true)
                
                return
            }
            
            viewController.contentType = contentType
        }
        
        viewController.titleContent = content as NSString?
        viewController.selectIndex = selectIndex
        
        push(viewController: viewController)
        
    }
    
    func changeUIFrame() {
        
        backView.frame = CGRect(x: 0, y: segmentView.frame.origin.y + segmentView.frame.size.height + 10, width: kScreenWidth, height: 50)
        backView.backgroundColor = UIColor.groupTableViewBackground
        
        myCreateTask.contentView.frame = CGRect(x: 0, y: segmentView.frame.origin.y + segmentView.frame.size.height + 15, width: kScreenWidth, height: 40)
        
    }
    
    func reloadLocalData() {
        
                let createNumberArray = GetRepaireListModel.find(byCriteria: " WHERE Category = 'MyCreate'")
                if (createNumberArray?.count != 0) {
                    myCreateCount = NSString(format: "%d", (createNumberArray?.count)!) as String
                    myCreateTask.numberLabel.text = String(myCreateCount)
                }
        
                var index = 0
                for name in myRepareCategorys {
        
                    //if (index >= 4) {
                        let sql = " WHERE Category = '" + name + "'"
                        myRepareValues[index] = String(GetRepaireListModel.find(byCriteria: sql).count)
                    //}
        
                    index = index + 1
                }
        
        requestData()
        
        self.contentTableView?.reloadData()
    }
    
    override func requestData() {
        
        super.requestData()
        
        if (selectIndex == 0) {
            
            LoadView.storeLabelText = "正在加载我的维修信息"
            
            let getMyRepareTaskNumAPICmd = GetMyRepareTaskNumAPICmd()
            getMyRepareTaskNumAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getMyRepareTaskNumAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","version":"8.2"]
            getMyRepareTaskNumAPICmd.loadView = LoadView()
            getMyRepareTaskNumAPICmd.loadParentView = self.view
            getMyRepareTaskNumAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    self.getMyRepareTaskNumModel = GetMyRepareTaskNumModel()
                    
                    self.getMyRepareTaskNumModel = JSONDeserializer<GetMyRepareTaskNumModel>.deserializeFrom(json: JSON(dict.object).rawString())
                    
                    self.myRepareValues[0] = (self.getMyRepareTaskNumModel?.NoHandel)!
                    self.myRepareValues[1] = (self.getMyRepareTaskNumModel?.NoSend)!
                    self.myRepareValues[2] = (self.getMyRepareTaskNumModel?.NoAccept)!
                    self.myRepareValues[3] = (self.getMyRepareTaskNumModel?.NoComplete)!
                    self.myRepareValues[4] = (self.getMyRepareTaskNumModel?.NoSendToReCall)!
                    self.myRepareValues[5] = (self.getMyRepareTaskNumModel?.NoReCall)!
                    self.myRepareValues[6] = (self.getMyRepareTaskNumModel?.NoCheck)!
                    self.myRepareValues[7] = "0"
                    self.myRepareValues[8] = (self.getMyRepareTaskNumModel?.Send)!
                    self.myRepareValues[9] = (self.getMyRepareTaskNumModel?.Complete)!
                    self.myRepareValues[10] = (self.getMyRepareTaskNumModel?.ReCall)!
                    self.myRepareValues[11] = (self.getMyRepareTaskNumModel?.Check)!
                    
                    self.contentTableView?.reloadData()
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
                let checkNumberArray = GetRepaireListModel.find(byCriteria: " WHERE Category = 'AlreadyCheck'")
                let mycheckCount = NSString(format: "%d", (checkNumberArray?.count)!) as String
                self.myRepareValues[7] = mycheckCount
                
                self.stopFresh()
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
                self.stopFresh()
            }
            
        }else {
            
            LoadView.storeLabelText = "正在加载所有维修信息"
            
            let getStateNumJsonAPICmd = GetStateNumJsonAPICmd()
            getStateNumJsonAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            getStateNumJsonAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","PProjectCode":self.chooseTitle! ]
            getStateNumJsonAPICmd.loadView = LoadView()
            getStateNumJsonAPICmd.loadParentView = self.view
            getStateNumJsonAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    self.getStateNumJsonModel = JSONDeserializer<GetStateNumJsonModel>.deserializeFrom(json: JSON(dict.object).rawString())
                    
                    
                    self.stateValues[0] = (self.getStateNumJsonModel?.NoComplete)!
                    self.stateValues[1] = (self.getStateNumJsonModel?.NoSend)!
                    self.stateValues[2] = (self.getStateNumJsonModel?.Send)!
                    self.stateValues[3] = (self.getStateNumJsonModel?.WaitRepare)!
                    self.stateValues[4] = (self.getStateNumJsonModel?.Repareing)!
                    self.stateValues[5] = (self.getStateNumJsonModel?.Complete)!
                    self.stateValues[6] = (self.getStateNumJsonModel?.NoRecall)!
                    self.stateValues[7] = (self.getStateNumJsonModel?.Recall)!
                    
                    self.contentTableView?.reloadData()
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
                self.stopFresh()
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
                self.stopFresh()
            }
            
        }
        
    }
    
    //查看抢单
    @objc func viewGrab() {
        
        let viewController = RepairTaskDetailViewController()
        viewController.selectIndex = -1
        viewController.contentType = "4"
        viewController.titleContent = "待抢列表"
        push(viewController: viewController)
        
    }
    
    func floatingViewClick() {
        
        let viewController = RepairTaskAddViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @objc func myCreate() {
        //我创建的维修
        let tempVC = RepairLocalTaskDetailViewController()
        tempVC.titleContent = "维修任务-我的报修" as NSString?
        tempVC.category = "MyCreate"
        push(viewController: tempVC)
        
    }
    
}



