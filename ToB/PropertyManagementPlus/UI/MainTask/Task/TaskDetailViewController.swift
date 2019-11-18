//
//  TaskDetailViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/9.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
//import HandyJSON
import Alamofire
import Eureka

public enum TaskDetailType : Int {
    
    //维修
    case repair
    
    //派单
    case distribute
    
    //未知
    case unknown
    
}

class TaskDetailViewController: FormBaseTableViewController ,SelectImageShowViewDelegate,RepairChooseChargeItemDelegate,RepairChooseSenderResultDelegate,UITextViewDelegate,UITextFieldDelegate {
    
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var taskType: TaskDetailType = .unknown
    //网络图片("BussinessType" : "0")
    var broswerArray = NSMutableArray(capacity: 20)
    //"BussinessType" : "3"/现场照片
    var broswerSceneArray = NSMutableArray(capacity: 20)
    //"BussinessType" : "6"/签字
    var broswerSignArray = NSMutableArray(capacity: 20)
    //"BussinessType" : "1"/报修录音
    var recordUrl: String = ""
    var player: STKAudioPlayer = STKAudioPlayer()
    
    /*
     
     case "未派单":
     contentType = "1"
     case "未完成":
     contentType = "2"
     case "未回访":
     contentType = "5"
     case "未检验":
     contentType = "6"
     
     */
    
    var contentType: String! = ""
    var selectIndex: NSInteger = 0
    
    var peTimeLine: PeTimeLine!
    
    var getRepaireListModel: GetRepaireListModel!
    var getRepaireTypeModel: GetRepaireTypeModel?
    var getModel: GetRepaireListModel!
    
    var valuesArray = NSMutableArray(capacity: 20)
    
    var customerCommondSourceArray = NSMutableArray(capacity: 20)
    var customerCommondTypeArray = NSMutableArray(capacity: 20)
    var checkTypeArray = ["选择派单人","选择维修人","发起抢单"]
    //维修说明
    var textAreaRow = TextAreaRow("")
    var textAreaRowContentCell: ComplaintHandleContentInputTableViewCell? = ComplaintHandleContentInputTableViewCell()
    //检验情况
    var checkConditionRow = TextAreaRow("")
    var checkConditionContentCell: ComplaintHandleContentInputTableViewCell? = ComplaintHandleContentInputTableViewCell()
    //客户评价
    var customerRecommondRow = TextAreaRow("")
    var customerRecommondContentCell: ComplaintHandleContentInputTableViewCell? = ComplaintHandleContentInputTableViewCell()
    //回访情况
    var backConditionRow = TextAreaRow("")
    var backConditionContentCell: ComplaintHandleContentInputTableViewCell? = ComplaintHandleContentInputTableViewCell()
    //客户建议
    var customerSuggestRow = TextAreaRow("")
    var customerSuggestContentCell: ComplaintHandleContentInputTableViewCell? = ComplaintHandleContentInputTableViewCell()
    
    //现场图片
    let selectImageShowView = SelectImageShowView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 95.0))
    //签到
    let signatureViewRow: SignatureViewRow = SignatureViewRow("Sign")
    
    var photoBrowser: PhotoBrowser?
    var imageView: UIImageView!
    
    //本地区分视图类型
    var typeValue: Int = 1
    
    var isExistBillInfo = false
    
    var costTag = 3330
    
    var hege:String = "0"   // 是否合格，临时使用
    var hegeLab:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        fetchLocalDatas()
        requestBillInfoDetail();
//        initContentUI()
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    deinit {
        player.stop()
    }
    
    func fetchLocalDatas() {
//        for model in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '客服_维修_回访客户评价'") {
//            
//            let getDictionaryInfosModel:GetDictionaryInfosModel = model as! GetDictionaryInfosModel
//            self.customerCommondSourceArray.add(getDictionaryInfosModel)
//            self.customerCommondTypeArray.add(getDictionaryInfosModel.Content ?? "")
//        }
//        
//        let numberArray = GetRepaireListModel.find(byCriteria: " WHERE Category = 'NoCommit' AND SubCategory = 'FinishSuccessCase' AND BillCode = '" + getRepaireListModel.BillCode! + "'" )
//        
//        if (numberArray?.count == 0) {
//            isExistBillInfo = false
//        }else {
//            isExistBillInfo = true
//        }
    }
    
    private func initContentUI () {
        
        self.view.backgroundColor = UIColor.white
        
        typeValue = Int(NSString(string: getRepaireListModel.State!).intValue)
        
        var titleStr = ("维修单(" + getRepaireListModel.BillCode! + ")")
        
        if (selectIndex == 0) {
            if (contentType == "12") {
                
                if (getRepaireListModel.Category?.compare("NoCommit") == .orderedSame
                    && getRepaireListModel.SubCategory?.compare("FinishSuccessCase") == .orderedSame) {
                    //创建单据未提交
                    titleStr = ("维修单(" + getRepaireListModel.BillCode! + ")")
                }else {
                    
                    if (getRepaireListModel.Category?.compare("NoReCall") == .orderedSame
                        || getRepaireListModel.Category?.compare("NoCheck") == .orderedSame) {
                        
                        if (getRepaireListModel.Range?.compare("客户区域") == .orderedSame) {
                            titleStr = ("回访任务(" + getRepaireListModel.BillCode! + ")")
                        }else {
                            titleStr = ("检验任务(" + getRepaireListModel.BillCode! + ")")
                        }
                    }else {
                        titleStr = ("维修任务(" + getRepaireListModel.BillCode! + ")")
                    }
                }
                
            }else {
                titleStr = ("维修任务(" + getRepaireListModel.BillCode! + ")")
            }
            
        }
        
        self.setTitleView(titles: [titleStr as NSString])
        
        peTimeLine = PeTimeLine(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 90))
        peTimeLine.allSteps = ["未派单","派单中","进行中","完成","回访/检验"]
        
        // 控制状态
        var currentState:Int?
        if Int(self.getRepaireListModel.State!)! == 0 {
            currentState = 1;
        }
        else {
            currentState = Int(self.getRepaireListModel.State!)!;
            if ((self.getRepaireListModel.IsReview! == "1") || (self.getRepaireListModel.IsReturnCall! == "1")) {
                currentState = currentState! + 1;
            }
        }
        peTimeLine.nowStep = Int32(currentState!);
        
        peTimeLine.backgroundColor = UIColor.groupTableViewBackground
        
        let lineView = UIView(frame: CGRect(x: 0, y: peTimeLine.frame.size.height - 0.5, width: kScreenWidth, height: 0.5))
        lineView.backgroundColor = UIColor.lightGray
        
        peTimeLine.addSubview(lineView)
        
        self.view.addSubview(peTimeLine)
        
        
        switch taskType {
            
        case .repair:
            self.setTitleView(titles: ["维修任务"])
            break
        case .distribute:
            self.setTitleView(titles: ["派送任务"])
            break;
        default:
            break;
        }
        
        self.tableView?.frame = CGRect(x: 0, y: peTimeLine.height, width: kScreenWidth, height: kScreenHeight - kTabBarHeight - peTimeLine.height - 64)
        
        setBottomButton()
        loadForm()
        
    }
    
    func setBottomButton() {
        
        if (selectIndex == 1) {
            buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        }else {
            
            switch contentType {
                
            case "1","0":
                //未派单
                buttonAction(titles: ["返回","派单","发起抢单"], actions: [#selector(singlePopAction),#selector(sendPage),#selector(qPage)], target: self)
                typeValue = 0
                
            case "2","12":
                //未完成
                
                typeValue = 2
                
                if (getRepaireListModel.Category?.compare("NoCommit") == .orderedSame
                    && getRepaireListModel.SubCategory?.compare("FinishSuccessCase") == .orderedSame && isExistBillInfo) {
                    //完成单据未提交
                    
                    buttonAction(titles: ["返回","提交"], actions: [#selector(singlePopAction),#selector(finishCommitBillInfo)], target: self)
                    
                }else {
                    
                    if getRepaireListModel.IsAccept == "0" {
                        bottomButtonAction(titles: ["接单"], images: ["task_break_perssed"], actions: [#selector(arriveAction)], target: self)
                    } else {
                        
                        let isArrive = Int(NSString(string: getRepaireListModel.IsArrive!).intValue)
                        
                        if (isArrive == 1) {
                            //到达
                            
                            let isStart = Int(NSString(string: getRepaireListModel.IsStart!).intValue)
                            let isSuspend = Int(NSString(string: getRepaireListModel.IsSuspend!).intValue)
                            
                            if (isStart == 0) {
                                
                                //尚未开始
                                bottomButtonAction(titles: ["开始","完成"], images: ["task_start_perssed","task_finish_normal"], actions: [#selector(startAction),#selector(finishAction)], target: self)
                                
                            }else {
                                if (isSuspend == 1) {
                                    //开始之后暂停-继续
                                    
                                    //是否是结束状态
                                    let isOver = Int(NSString(string: getRepaireListModel.IsOver!).intValue)
                                    if (isOver == 1) {
                                        
                                        buttonAction(titles: ["返回","提交"], actions: [#selector(singlePopAction),#selector(finishCommitBillInfo)], target: self)
                                        
                                        self.tableView?.frame = CGRect(x: 0, y: peTimeLine.height, width: kScreenWidth, height: kScreenHeight - kTabBarHeight - peTimeLine.height - 94)
                                        
                                    }else {
                                        bottomButtonAction(titles: ["暂停","完成"], images: ["task_stop_perssed","task_finish_perssed"], actions: [#selector(suspendAction),#selector(finishAction)], target: self)
                                    }
                                    
                                }else {
                                    bottomButtonAction(titles: ["继续","完成"], images: ["task_start_perssed","task_finish_normal"], actions: [#selector(suspendAction),#selector(finishAction)], target: self)
                                }
                            }
                            
                        }else {
                            //未到达
                            
                            bottomButtonAction(titles: ["到达"], images: ["task_finish_perssed"], actions: [#selector(arriveAction)], target: self)
                            
                        }
                        
                    }
                    
                    let isOver = Int(NSString(string: getRepaireListModel.IsOver!).intValue)
                    
                    if (isOver != 1) {
                        self.tableView?.frame = CGRect(x: 0, y: peTimeLine.height, width: kScreenWidth, height: kScreenHeight - kTabBarHeight - peTimeLine.height - 94)
                    }
                    
                }
                
                
                
            case "5":
                //未回访
                buttonAction(titles: ["返回","提交"], actions: [#selector(singlePopAction),#selector(visitCommit)], target: self)
                typeValue = 4
                
            case "6":
                //未检验
                buttonAction(titles: ["返回","提交"], actions: [#selector(singlePopAction),#selector(checkCommit)], target: self)
                typeValue = 5
                
            case "7":
                // 未发起回访任务
                if  getModel.Range == "公共区域" {
                    buttonAction(titles: ["返回","分派检验任务"], actions: [#selector(singlePopAction),#selector(sendPage)], target: self)
                }
                else {
                    buttonAction(titles: ["返回","分派回访任务"], actions: [#selector(singlePopAction),#selector(sendPage)], target: self)
                }
                
                
            default:
                //添加默认设置
                buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
                self.tableView.allowsSelection = false;
                
                break
            }
            
        }
        
    }
    
    // MARK: Private interface
    
    fileprivate func loadForm() {
        
        //form.removeAll()
        initDatas()
        
        let bxArray = ["报修单号","报修地址","报修内容","报修时间","报修人","联系电话"]
        let pdArray = ["派单人","派单时间","维修人"]
        var sections = [setSelfSection(title: "报修", headerHeight: 35, footerHeight: 0.001),setSelfSection(title: "派单", headerHeight: 35, footerHeight: 0.001)]
        
        var names = [bxArray,
                     pdArray]
        
        if (typeValue == 0) {
            //未派单
            sections = [setSelfSection(title: "报修", headerHeight: 35, footerHeight: 0.001)]
            names = [bxArray]
        }
        
        if (typeValue == 2 || typeValue == 3 || typeValue == 4 || typeValue == 5) {
            //已完成
            
            var isStopStruct = false
            
            if (selectIndex == 0 && typeValue == 2) {
                let isArrive = Int(NSString(string: getRepaireListModel.IsArrive!).intValue)
                
                if (isArrive == 1) {
                    isStopStruct = true
                }
                
            }else if (selectIndex == 0 && (typeValue == 4 || typeValue == 5)) {
                isStopStruct = true
            }
            
            if (selectIndex == 1) {
                isStopStruct = true
            }
            
            if (isStopStruct) {
                sections.append(setSelfSection(title: "维修", headerHeight: 35, footerHeight: 0.001))
                
                if (selectIndex == 0) {
                    names.append(["到场时间","开始时间","完成时间","维修类别","材料费","人工费","其它费"])
                }else {
                    names.append(["接单人","接单时间","到场时间","开始时间","完成时间","维修类别","材料费","人工费","其它费"])
                }
                
                if (typeValue == 4 || typeValue == 5) {
                    if (self.contentType ==  "7") {
                        
                    }
                    else {
                        if (getRepaireListModel.Range?.compare("客户区域") == .orderedSame) {
                            //已回访
                            sections.append(setSelfSection(title: "回访", headerHeight: 35, footerHeight: 0.001))
                            
                            if (selectIndex == 0) {
                                names.append(["客户评价"])
                            }else {
                                names.append(["回访时间","客户评价"])
                            }
                            
                        }else {
                            //已检验
                            sections.append(setSelfSection(title: "检验", headerHeight: 35, footerHeight: 0.001))
                            
                            if (selectIndex == 0) {
                                names.append(["是否合格"])
                            }else {
                                names.append(["检验时间","是否合格"])
                            }
                            
                        }
                    }
                    
                }
            }
        }
            
        
        for (index, section) in sections.enumerated() {
            for (subIndex, name) in (names[index] as NSArray).enumerated() {
                if (self.contentType == "7") {
                    
                }
                if (selectIndex == 0 && ((name as! String).compare("维修类别") == .orderedSame
                    || (name as! String).compare("是否合格") == .orderedSame
                    || (name as! String).compare("客户评价") == .orderedSame
                    || (name as! String).compare("材料费") == .orderedSame
                    || (name as! String).compare("人工费") == .orderedSame
                    || (name as! String).compare("其它费") == .orderedSame)) {
                    
                    if (((name as! String).compare("材料费") == .orderedSame
                        || (name as! String).compare("人工费") == .orderedSame
                        || (name as! String).compare("其它费") == .orderedSame)) {
                        
                        if (typeValue == 2) {
                            (section as Section).append(
                                ComplaintHandleAddTextFiledTableViewRow(){
                                    
                                    let tempCell = $0.cell as ComplaintHandleAddTextFiledTableViewCell
                                    tempCell.singleTextFiledNameLabel.text = name as? String
                                    tempCell.singleTextFiled.keyboardType = .decimalPad
                                    }.cellUpdate({ (cell, row) in
                                        cell.singleTextFiled.text = (self.valuesArray[index] as! NSArray)[subIndex] as? String
                                        cell.singleTextFiled.tag = 3330 + subIndex
                                        cell.singleTextFiled.delegate = self
                                    }))
                        }else {
                            (section as Section).append(
                                ComplaintHandlingAddLabelTableViewRow(){
                                    
                                    let tempCell = $0.cell as ComplaintHandlingAddLabelTableViewCell
                                    tempCell.singleShowLabel.text = name as? String
                            }.cellUpdate({ (cell, row) in
                                if ((self.getRepaireListModel != nil) && self.valuesArray.count != 0) {
                                    cell.singleShowContentLabel.text = (self.valuesArray[index] as! NSArray)[subIndex] as? String
                                }
                            }))
                        }
                        
                        continue
                    }
                    
                    if (typeValue != 2 || self.contentType != "7" && (name as! String).compare("维修类别") == .orderedSame) {
                        (section as Section).append(
                            ComplaintHandlingAddLabelTableViewRow(){
                                
                                let tempCell = $0.cell as ComplaintHandlingAddLabelTableViewCell
                                tempCell.singleShowLabel.text = name as? String
      
                        }.cellUpdate({ (cell, row) in
                            cell.isUserInteractionEnabled = false
                            if ((self.getRepaireListModel != nil) && self.valuesArray.count != 0) {
                                cell.singleShowContentLabel.text = (self.valuesArray[index] as! NSArray)[subIndex] as? String
                                if (self.contentType == "6" ) {
                                    if (index == 3 && subIndex == 0) {
                                        let btn:UIButton = UIButton.init(type: .custom);
                                        btn.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 44);
//                                        btn.frame = CGRect(x: kScreenWidth - 40, y: 12, width: 20, height: 20);
                                        btn.backgroundColor = UIColor.clear;
                                        btn.addTarget(self, action: #selector(TaskDetailViewController.selectHege), for: .touchUpInside)
                                        cell.contentView.isUserInteractionEnabled = true;
                                        cell.isUserInteractionEnabled = true;
                                        cell.contentView.addSubview(btn);
                                        self.hegeLab = cell.singleShowContentLabel
                                        if ((self.valuesArray[index] as! NSArray)[subIndex] as? String == "0") {
                                            cell.singleShowContentLabel.text = "合格";
                                        }
                                        else {
                                            cell.singleShowContentLabel.text = "合格";
                                        }
                                    }
                                    else {
                                        
                                    }
                                }
                            }
                        }))
                        continue
                    }
                    
                    (section as Section).append(
                        ComplaintHandlingAddLabelImageTableViewRow(){
                            
                            let tempCell = $0.cell as ComplaintHandlingAddLabelImageTableViewCell
                            tempCell.nameLabel.text = name as? String
                            
                    }.cellUpdate({ (cell, row) in
                        
                        if ((name as! String).compare("是否合格") == .orderedSame) {
                            if (self.getRepaireListModel.ReturnCallCheckPass?.compare("1") == .orderedSame) {
                                cell.contentLabel.text = "是"
                            }else {
                                cell.contentLabel.text = "否"
                            }
                            let btn = UIButton(type: .custom);
                            btn.frame = CGRect(x: kScreenWidth - 34, y: 10, width: 23, height: 23)
                            btn.backgroundColor = UIColor.red;
                            cell.contentView.addSubview(btn);
                            cell.contentView.backgroundColor = UIColor.green;
                        }else if ((name as! String).compare("客户评价") == .orderedSame) {
                            cell.contentLabel.text = self.getRepaireListModel.ReturnCallCustEvel
                        }else if ((name as! String).compare("维修类别") == .orderedSame) {
                            
                            if (self.getRepaireListModel != nil) {
                                cell.contentLabel.text = self.getRepaireTypeModel?.repairtypename
                            }else {
                                cell.contentLabel.text = self.getRepaireListModel.Type
                            }
                            
                        }
                        
                    }))
                    
                    
                }else {
                    (section as Section).append(
                        ComplaintHandlingAddLabelTableViewRow(){
                            
                            let tempCell = $0.cell as ComplaintHandlingAddLabelTableViewCell
                            tempCell.singleShowLabel.text = name as? String
                            if ((getRepaireListModel != nil) && valuesArray.count != 0) {
                                tempCell.singleShowContentLabel.text = (valuesArray[index] as! NSArray)[subIndex] as? String
//                                if (self.contentType == "6" ) {
//                                    if (index == 0 && subIndex == 3) {
//                                        if ((valuesArray[index] as! NSArray)[subIndex] as? String == "0") {
//                                             tempCell.singleShowContentLabel.text = "合格";
//                                        }
//                                        else {
//                                             tempCell.singleShowContentLabel.text = "合格";
//                                        }
//                                    }
//                                    else {
//
//                                    }
//                                }
//                                if ((valuesArray[3] as! NSArray)[0] as? String  == "0") {
//                                    tempCell.singleShowContentLabel.text = "合格";
//                                }
//                                else {
//                                    tempCell.singleShowContentLabel.text = "不合格";
//                                }
                            }
                        }.cellUpdate({ (cell, row) in
                            let tempCell = cell as ComplaintHandlingAddLabelTableViewCell
                            if (tempCell.singleShowLabel.text?.compare("报修内容") == .orderedSame) {
                                tempCell.singleShowContentLabel.numberOfLines = 0;
                                cell.height = {BaseTool.calculateHeight(withText: self.getRepaireListModel.Content ?? "  ", textLabel: UIFont.systemFont(ofSize: 14), isCaculateWidth: false, widthOrHeightData: kScreenWidth - 150)};
                            }
                            
                        }))
                }
            }
        }
        
        if (getRepaireListModel.files != nil
            && getRepaireListModel.files?.isKind(of: NSNumber.self) == false
            && getRepaireListModel.files?.count != 0) {
            //存在网络图片
            
            let urlFore = LocalStoreData.getPMSAddress().PMSAddress
            let array = urlFore?.components(separatedBy: "WebAPI")
            let finalURL = array?[0]
            
            broswerArray      = NSMutableArray(capacity: 20)
            broswerSceneArray = NSMutableArray(capacity: 20)
            broswerSignArray  = NSMutableArray(capacity: 20)
            
            for (_,tdict) in getRepaireListModel.files!.enumerated() {
                var url = JSON(tdict).dictionary?["Url"]?.stringValue
                let bussinessType = JSON(tdict).dictionary?["BussinessType"]?.stringValue
                
                if (url?.hasPrefix("http://")) == false {
                    url = finalURL?.appending(url!).replacingOccurrences(of: " ", with: "")
                }
                
                if (Int(bussinessType!)! == 0) {
                    broswerArray.add(url?.replacingOccurrences(of: "\\", with: "/") ?? "")
                }else if (Int(bussinessType!)! == 3) {
                    broswerSceneArray.add(url?.replacingOccurrences(of: "\\", with: "/") ?? "")
                }else if (Int(bussinessType!)! == 6) {
                    broswerSignArray.add(url?.replacingOccurrences(of: "\\", with: "/") ?? "")
                }else if (Int(bussinessType!)! == 1) {
                    recordUrl = (url?.replacingOccurrences(of: "\\", with: "/"))!
                }
                
            }
            
            if (recordUrl.compare("") != .orderedSame) {
                
                let recordContentImageRow = TaskRecordImageContentTableViewRow() {
                    let tempCell = $0.cell as TaskRecordImageContentTableViewCell
                    
                    tempCell.recordImageView.isUserInteractionEnabled = true
                    tempCell.recordImageView.image = UIImage(named: "icon_record_layout_nor")
                    
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(recordPlay(ges:)))
                    tempCell.recordImageView.addGestureRecognizer(gesture)
                    
                }
                
                (sections[0] as Section).append(recordContentImageRow)
            }
            
            
            
            let detailContentImageRow = TaskDetailImageContentTableViewRow(){
                let tempCell = $0.cell as TaskDetailImageContentShowTableViewCell
                
                let contentImageRows = [tempCell.contentImageViewOne,
                                        tempCell.contentImageViewTwo,
                                        tempCell.contentImageViewThree,
                                        tempCell.contentImageViewFour]
                
                for (index, url) in broswerArray.enumerated() {
                    
                    if (index >= 4) {
                        break
                    }
                    let string = url as! NSString;
                    var ss:String! = ""
                    if string.contains("webapi") {
                        ss = string.replacingOccurrences(of:"webapi", with: "")
                    }
                    else {
                        ss = string as String
                    }
                    (contentImageRows[index])?.imageFromURL(ss, placeholder: UIImage())
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(displayPhotoBrowser(ges:)))
                    contentImageRows[index]?.tag = 7771
                    contentImageRows[index]?.isUserInteractionEnabled = true
                    contentImageRows[index]?.addGestureRecognizer(gesture)
                }
                
                }.cellUpdate({ (cell, row) in
                    
                })
            if  broswerArray.count != 0 {
                (sections[0] as Section).append(detailContentImageRow)
            }
        }
        
        if (typeValue == 2 || typeValue == 3 || typeValue == 4 || typeValue == 5) {
            
            
            var isStopStruct = false
            
            if (selectIndex == 0 && typeValue == 2) {
                let isArrive = Int(NSString(string: getRepaireListModel.IsArrive!).intValue)
                
                if (isArrive == 1) {
                    isStopStruct = true
                }
                
            }else if (selectIndex == 0 && (typeValue == 4 || typeValue == 5)) {
                isStopStruct = true
            }
            
            if (selectIndex == 1) {
                isStopStruct = true
            }
            
            if (isStopStruct) {
                
                if (selectIndex == 1 && typeValue == 2) {
                    form.append(sections[0])
                }else {
                    form = sections[0]
                        +++ sections[1]
                        +++ sections[2]
                }
                
                textAreaRow = TextAreaRow("维修说明") {
                    $0.placeholder = "维修说明"
                    $0.textAreaHeight = .dynamic(initialTextViewHeight: 80)
                }.cellUpdate({ (cell, row) in
                    
                    if (self.selectIndex == 1) {
                        cell.textView.isUserInteractionEnabled = false
                    }
                    
                    if (self.getRepaireListModel?.CompleteMemo == nil || self.getRepaireListModel?.CompleteMemo?.compare("") == .orderedSame) {
                        cell.placeholderLabel?.text = "维修说明"
                    }else {
                        cell.placeholderLabel?.text = ""
                    }
                    
                    cell.textView.tag = 3335
                    cell.textView.delegate = self
                    cell.textView.text = self.getRepaireListModel.CompleteMemo
                    
                })
                
                let statusSection = setSelfSection(title: "", headerHeight: 0.001, footerHeight: 0.001)
                
                statusSection
                    <<< textAreaRow
                    <<< ComplaintHandleContentInputTableViewRow() {
                        
                        _ = $0.cell as ComplaintHandleContentInputTableViewCell
                }.cellUpdate({ (cell, row) in
                    self.textAreaRowContentCell = cell
                })
                
                if (self.contentType != "7") {
                    form.append(statusSection)
                }
                
                let textView = (textAreaRow.cell as TextAreaCell).textView
                
                if (selectIndex == 0 && typeValue == 2) {
                    textView?.isUserInteractionEnabled = true
                }else {
                    textView?.isUserInteractionEnabled = false
                }

                if (typeValue == 4 || typeValue == 5) {
                    //回访
                    
                    let checkConditionSection = setSelfSection(title: "", headerHeight: 0.001, footerHeight: 0.001)
                    
                    if (getRepaireListModel.Range?.compare("客户区域") == .orderedSame) {
                        
                        form = sections[0]
                            +++ sections[1]
                            +++ sections[2]

                        sceneAndSignPic()
                        if (self.contentType != "7") {
                            form.append(statusSection)
                             form.append(sections[3])
                        }
                        
                        let commondTitle = "回访情况"
                        let backConditionTitle = "不满意原因"
                        let customerSuggestTitle = "客户建议"
                        
                        //回访情况
                        customerRecommondRow = TextAreaRow(commondTitle) {
                            $0.placeholder = commondTitle
                            $0.textAreaHeight = .dynamic(initialTextViewHeight: 80)
                            }.cellUpdate({ (cell, row) in
                                if (self.selectIndex == 1) {
                                    cell.textView.isUserInteractionEnabled = false
                                }
                                if (self.getRepaireListModel?.ReturnCallMemo == nil || self.getRepaireListModel?.ReturnCallMemo?.compare("") == .orderedSame) {
                                    cell.placeholderLabel?.text = "回访情况"
                                }else {
                                    cell.placeholderLabel?.text = ""
                                }
                                
                                cell.textView.tag = 3330
                                cell.textView.delegate = self
                                cell.textView.text = self.getRepaireListModel?.ReturnCallMemo
                            })
                        //"不满意原因"
                        backConditionRow = TextAreaRow(backConditionTitle) {
                            $0.placeholder = backConditionTitle
                            $0.textAreaHeight = .dynamic(initialTextViewHeight: 80)
                            }.cellUpdate({ (cell, row) in
                                if (self.selectIndex == 1) {
                                    cell.textView.isUserInteractionEnabled = false
                                }
                                if (self.getRepaireListModel?.ReturnCallCustNoSatisCause == nil || self.getRepaireListModel?.ReturnCallCustNoSatisCause?.compare("") == .orderedSame) {
                                    cell.placeholderLabel?.text = "不满意原因"
                                }else {
                                    cell.placeholderLabel?.text = ""
                                }
                                cell.textView.tag = 3331
                                cell.textView.delegate = self
                                cell.textView.text = self.getRepaireListModel?.ReturnCallCustNoSatisCause
                            })
                        //客户建议
                        customerSuggestRow = TextAreaRow(customerSuggestTitle) {
                            $0.placeholder = customerSuggestTitle
                            $0.textAreaHeight = .dynamic(initialTextViewHeight: 80)
                            }.cellUpdate({ (cell, row) in
                                if (self.selectIndex == 1) {
                                    cell.textView.isUserInteractionEnabled = false
                                }
                                if (self.getRepaireListModel?.ReturnCallCustSuggest == nil || self.getRepaireListModel?.ReturnCallCustSuggest?.compare("") == .orderedSame) {
                                    cell.placeholderLabel?.text = "客户建议"
                                }else {
                                    cell.placeholderLabel?.text = ""
                                }
                                cell.textView.tag = 3332
                                cell.textView.delegate = self
                                cell.textView.text = self.getRepaireListModel?.ReturnCallCustSuggest ?? ""
                            })
                        
                        
                        checkConditionSection
                            <<< customerRecommondRow
                            <<< ComplaintHandleContentInputTableViewRow() {
                                
                                let tempCell = $0.cell as ComplaintHandleContentInputTableViewCell
                                tempCell.nameLabel.text = commondTitle
                                
                            }.cellUpdate({ (cell, row) in
                                self.customerRecommondContentCell = cell
                            })
                            <<< backConditionRow
                            <<< ComplaintHandleContentInputTableViewRow() {
                                
                                let tempCell = $0.cell as ComplaintHandleContentInputTableViewCell
                                tempCell.nameLabel.text = backConditionTitle
                                }.cellUpdate({ (cell, row) in
                                    self.backConditionContentCell = cell
                                })
                            <<< customerSuggestRow
                            <<< ComplaintHandleContentInputTableViewRow() {
                                
                                let tempCell = $0.cell as ComplaintHandleContentInputTableViewCell
                                tempCell.nameLabel.text = customerSuggestTitle
                                }.cellUpdate({ (cell, row) in
                                    self.customerSuggestContentCell = cell
                                })
                    }else {
                        
                        form = sections[0]
                            +++ sections[1]
                            +++ sections[2]
                        
                        sceneAndSignPic()
                        
                        if (self.contentType != "7") {
                            form.append(statusSection)
                            form.append(sections[3])
                            
                        }
                        
                        checkConditionRow = TextAreaRow("检验情况") {
                            $0.placeholder = "检验情况"
                            $0.textAreaHeight = .dynamic(initialTextViewHeight: 80)
                            }.cellUpdate({ (cell, row) in
                                
                                if (self.selectIndex == 1) {
                                    cell.textView.isUserInteractionEnabled = false
                                }
                                
                                if (self.getRepaireListModel?.ReturnCallMemo == nil || self.getRepaireListModel?.ReturnCallMemo?.compare("") == .orderedSame) {
                                    cell.placeholderLabel?.text = "检验情况"
                                }else {
                                    cell.placeholderLabel?.text = ""
                                }
                                
                                cell.textView.tag = 3333
                                cell.textView.delegate = self
                                cell.textView.text = self.getRepaireListModel?.ReturnCallMemo
                            })
                        
                        checkConditionSection
                            <<< checkConditionRow
                            <<< ComplaintHandleContentInputTableViewRow() {
                                
                                let tempCell = $0.cell as ComplaintHandleContentInputTableViewCell
                                tempCell.nameLabel.text = "检验情况"
                        }.cellUpdate({ (cell, row) in
                            self.checkConditionContentCell = cell
                        })
                    }
                    if (self.contentType != "7") {
                        form.append(checkConditionSection)
                    }
                    
                }else {
                    if (typeValue == 3) {
                        sceneAndSignPic()
                    }
                }
                
                if (contentType.compare("12") == .orderedSame || (contentType.compare("2") == .orderedSame && self.getRepaireListModel.IsArrive == "1")) {
                    //我的维修 - 未完成
                    
                    let noOverSection = setSelfSection(title: "现场照片", headerHeight: 35, footerHeight: 0.001)
                    
                    noOverSection
                        <<< TakePhotoTableViewRow(){
                            let tempCell = $0.cell as TakePhotoTableViewCell
                            selectImageShowView.delegate = self
                            tempCell.contentView.addSubview(selectImageShowView)
                    }.cellUpdate({ (cell, row) in
                        
                        if (self.getRepaireListModel.IsOver?.compare("1") == .orderedSame) {
                            self.fetchLocalImages()
                        }
                        
                        self.selectImageShowView.allowDealWithPhoto = true
                        
                        if (self.getRepaireListModel.IsOver?.compare("1") == .orderedSame && self.getRepaireListModel.IsMaterialCommit?.compare("1") == .orderedSame) {
                            self.selectImageShowView.allowDealWithPhoto = false
                        }
                        
                    })
                    
                    form.append(noOverSection)
                    
                    let signOverSection = setSelfSection(title: "签到", headerHeight: 35, footerHeight: 0.001)
                    
                    signOverSection.append(signatureViewRow.cellUpdate({ (cell, row) in
                        if (self.getRepaireListModel.IsOver?.compare("1") == .orderedSame) {
                            self.fetchLocalSignImages()
                        }
                        
                        cell.signView.allowDealWithPhoto = true
                        
                        //如果是未完成，且已经是完成状态
                        if (self.getRepaireListModel.IsOver?.compare("1") == .orderedSame && self.getRepaireListModel.IsMaterialCommit?.compare("1") == .orderedSame) {
                            cell.signView.allowDealWithPhoto = false
                        }
                        
                    }))
                    
                    form.append(signOverSection)
                    
                }
            }else {
                form = sections[0]
                    +++ sections[1]
            }
            
        }
        else {
            
            if (typeValue == 0) {
                form.append(sections[0])
            }else {
                form = sections[0]
                    +++ sections[1]
            }
            
            
        }
        
    }
    
    func sceneAndSignPic() {
        
        //判断是否需要显示现场照片和签字
        
        let scenePictureSection = setSelfSection(title: "现场照片", headerHeight: 25, footerHeight: 0.001)
        
        if (broswerSceneArray.count != 0) {
            
            let detailContentImageRow = TaskDetailImageContentTableViewRow(){
                let tempCell = $0.cell as TaskDetailImageContentShowTableViewCell
                
                let contentImageRows = [tempCell.contentImageViewOne,
                                        tempCell.contentImageViewTwo,
                                        tempCell.contentImageViewThree,
                                        tempCell.contentImageViewFour]
                
                for (index, url) in broswerSceneArray.enumerated() {
                    if (index >= 4) {
                        break
                    }
                    let string = url as! NSString;
                    var ss:String! = string as String;
                    if string.contains("webapi") {
                        ss = string.replacingOccurrences(of:"webapi", with: "")
                    }
                    if (ss.hasSuffix(".jpg")) {
                        ss =  ss.components(separatedBy: ".jpg")[0]
                        ss.append(".jpg")
                    }
                    else {
                        ss = ss.components(separatedBy: ".png")[0]
                        ss.append(".png")
                    }
                    NSLog("%@", ss.components(separatedBy: ".jpg"));
                    (contentImageRows[index])?.imageFromURL(ss, placeholder: UIImage())
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(displayPhotoBrowser(ges:)))
                    contentImageRows[index]?.tag = 7773
                    contentImageRows[index]?.isUserInteractionEnabled = true
                    contentImageRows[index]?.addGestureRecognizer(gesture)
                }
                
                }.cellUpdate({ (cell, row) in
                    
                })
            
            scenePictureSection.append(detailContentImageRow)
            form.append(scenePictureSection)
        }
        
        let signPictureSection = setSelfSection(title: "签字", headerHeight: 25, footerHeight: 0.001)
        
        if (broswerSignArray.count != 0) {
            
            let detailContentImageRow = TaskDetailImageContentTableViewRow(){
                let tempCell = $0.cell as TaskDetailImageContentShowTableViewCell
                
                let contentImageRows = [tempCell.contentImageViewOne,
                                        tempCell.contentImageViewTwo,
                                        tempCell.contentImageViewThree,
                                        tempCell.contentImageViewFour]
                
                for (index, url) in broswerSignArray.enumerated() {
                    if (index >= 4) {
                        break
                    }
                    let abc = CFURLCreateStringByAddingPercentEscapes(nil, url as! CFString, nil, "+" as CFString, CFStringBuiltInEncodings.UTF8.rawValue) as! String
                    (contentImageRows[index])?.imageFromURL(url as! String, placeholder: UIImage())
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(displayPhotoBrowser(ges:)))
                    contentImageRows[index]?.tag = 7775
                    contentImageRows[index]?.isUserInteractionEnabled = true
                    contentImageRows[index]?.addGestureRecognizer(gesture)
                }
                
                }.cellUpdate({ (cell, row) in
                    
                })
            
            signPictureSection.append(detailContentImageRow)
            form.append(signPictureSection)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //RepairChooseChargeItemViewController
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 0) {
            
            if (indexPath.row == 5) {
                
                //拨打电话
                if (getRepaireListModel.TelNum?.compare("") != .orderedSame) {
                    dailNumber(phoneNumber: getRepaireListModel.TelNum ?? "")
                }
                
            }
            
        }else if (indexPath.section == 2) {
            
            var isCategory: Bool = false
            
            if (selectIndex == 0) {
                
                if (indexPath.row == 3) {
                    isCategory = true
                }
                
            }else {
                if (indexPath.row == 5) {
                    isCategory = true
                }
            }
            
            if (isCategory && selectIndex == 0) {
                let chooseVC = RepairChooseChargeItemViewController()
                chooseVC.delegate = self
                chooseVC.itemType = 2
                self.navigationController?.pushViewController(chooseVC, animated: true)
            }
            
        }else if ((indexPath.section == 4
            && broswerSceneArray.count == 0
            && broswerSignArray.count == 0)
            || (indexPath.section == 5
                && broswerSceneArray.count != 0
                && broswerSignArray.count == 0)
            || (indexPath.section == 6
                && broswerSceneArray.count != 0
                && broswerSignArray.count != 0)) {
            
            if (selectIndex == 0 && typeValue == 5) {
                //是否合格
                showActionSheet(title: "请选择", cancelTitle: "取消", titles: ["是","否"], tag: "ReturnCallCheckPass")
            }else if (selectIndex == 0 && typeValue == 4) {
                //客户评价
                if (customerCommondTypeArray.count == 0) {
                    customerCommondTypeArray = ["满意","不满意"]
                }
                showActionSheet(title: "请选择", cancelTitle: "取消", titles: (customerCommondTypeArray as NSArray) as! [Any], tag: "ReturnCallCustEvel")
            }
        }
    }
    
    func requestBillInfoDetail(){
        
        let getBillInfoDetailAPICmd = GetBillInfoDetailAPICmd()
        getBillInfoDetailAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getBillInfoDetailAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","type":"3","billcodes":self.getModel?.BillCode]
        getBillInfoDetailAPICmd.loadView = LoadView()
        getBillInfoDetailAPICmd.loadParentView = self.view
        getBillInfoDetailAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                
                let billsArr = dict["Bills"];
                let billDic = billsArr[0];
                let  model:GetRepaireListModel! = GetRepaireListModel.yy_model(withJSON: billDic.rawString() ?? {})!;
                self.getRepaireListModel = model;
                self.initContentUI();
                
            }
        });
    }
    
    func initDatas() {
        
        if (getRepaireListModel.BeginTime?.compare(kEmptyTimeKey) == .orderedSame) {
            getRepaireListModel.IsStart = "0"
            getRepaireListModel.update()
        }
        
        var beginTime = getRepaireListModel.BeginTime ?? ""
        var endTime = getRepaireListModel.EndTime ?? ""
        
        if (beginTime.compare(kEmptyTimeKey) == .orderedSame) {
            beginTime = "尚未开始"
        }
        if (endTime.compare(kEmptyTimeKey) == .orderedSame) {
            endTime = "尚未结束"
        }
        
        
        let sectionOne = [getRepaireListModel.BillCode ?? "",
                          getRepaireListModel.Location ?? "",
                          getRepaireListModel.Content ?? "",
                          formateTime(time: getRepaireListModel.CreateTime!) ,
                          getRepaireListModel.Proposer ?? "",
                          getRepaireListModel.TelNum ?? ""]
        let sectionTwo = [getRepaireListModel.SendPerson ?? "",
                          formateTime(time: getRepaireListModel.SendTime!),
                          getRepaireListModel.AcceptPerson ?? ""]
        
        if (typeValue == 0) {
            valuesArray = [sectionOne]
        }
        
        if (typeValue == 2 || typeValue == 3 || typeValue == 4 || typeValue == 5) {
            
            var materialCost = getRepaireListModel.MaterialCost! + ""
            var laborCost = getRepaireListModel.LaborCost! + ""
            var otherCost = getRepaireListModel.OtherCost! + ""
            
            if (Float(materialCost) == 0.0) {
                materialCost = ""
            }
            
            if (Float(laborCost) == 0.0) {
                laborCost = ""
            }
            
            if (Float(otherCost) == 0.0) {
                otherCost = ""
            }
            
            var sectionThree = [formateTime(time: getRepaireListModel.ArriveTime!),
                                beginTime,
                                endTime,
                                getRepaireListModel.RepareWay ?? "",
                                materialCost,
                                laborCost,
                                otherCost]
            
            if (selectIndex == 1) {
                sectionThree.insert(formateTime(time: getRepaireListModel.AcceptTime!), at: 0)
                if (getRepaireListModel.AcceptPerson != nil) {
                    sectionThree.insert(getRepaireListModel.AcceptPerson!, at: 0)
                }else {
                    sectionThree.insert(" ", at: 0)
                }
                
            }
            
            valuesArray = [sectionOne,sectionTwo,sectionThree]
            
            if (typeValue == 4 || typeValue == 5) {
                
                var sectionFour = [" "," "]
            
                if (getRepaireListModel.Range?.compare("客户区域") == .orderedSame) {
                    if (selectIndex == 0) {
                        sectionFour = [getRepaireListModel.ReturnCallCustEvel ?? ""]
                    }else {
                        sectionFour = [formateTime(time: getRepaireListModel.ReturnCallTime!),
                                       getRepaireListModel.ReturnCallCustEvel ?? ""]
                    }
                    
                }else {
                    
                    if (selectIndex == 0) {
                        sectionFour = [getRepaireListModel.ReturnCallCheckPass ?? ""]
                    }else {
                        sectionFour = [formateTime(time: getRepaireListModel.ReturnCallTime!),
                                       getRepaireListModel.ReturnCallCheckPass ?? ""]
                    }
                    
                }
                
                valuesArray = [sectionOne,sectionTwo,sectionThree,sectionFour]
            }
            
        }else {
            valuesArray = [sectionOne, sectionTwo]
        }
        
    }
    
    func setSelfSection(title: String, headerHeight: CGFloat , footerHeight: CGFloat) -> Section {
        let section = Section(header: title, footer: "")
        section.header?.height = { return headerHeight }
        section.footer?.height = { return footerHeight }
        
        return section
    }
    
    //回访
    @objc func visitCommit() {
        
        let tips = NSMutableArray(capacity: 20)
        
        let processTextView = (customerRecommondRow.cell as TextAreaCell).textView
        let resultTextView = (backConditionRow.cell as TextAreaCell).textView
        let suggestTextView = (customerSuggestRow.cell as TextAreaCell).textView
        
        let processStr = processTextView?.text ?? ""
        let resultStr = resultTextView?.text ?? ""
        let suggestStr = suggestTextView?.text ?? ""
        
        if (processStr.compare("") == .orderedSame) {
            tips.add("回访情况")
        }
        
        if (resultStr.compare("") == .orderedSame) {
            tips.add("不满意原因")
        }
        
        if (suggestStr.compare("") == .orderedSame) {
            tips.add("客户建议")
        }
        
        if (tips.count != 0) {
            
            var tipString = "["
            
            for (index, name) in tips.enumerated() {
                tipString.append(name as! String)
                if (index != tips.count - 1) {
                    tipString.append(",")
                }
                
            }
            
            tipString.append("]没有填写，继续提交？")
            
            showAlertChoose(title: "提示", message: tipString as NSString, placeHolder: "", titles: ["继续提交","返回填写"], selector: #selector(TaskDetailViewController.commitVisitTip(type:)), target: self)
            
            return;
            
        }
        
        visitCommitAction()
        
    }
    
    func visitCommitAction() {
        
        let processTextView = (customerRecommondRow.cell as TextAreaCell).textView
        let resultTextView = (backConditionRow.cell as TextAreaCell).textView
        let suggestTextView = (customerSuggestRow.cell as TextAreaCell).textView
        
        let processStr = processTextView?.text ?? ""
        let resultStr = resultTextView?.text ?? ""
        let suggestStr = suggestTextView?.text ?? ""
        
        let billInfo = ["ReturnCallMemo":processStr,"ReturnCallCustNoSatisCause":resultStr,"ReturnCallCustSuggest":suggestStr,"ReturnCallCustEvel":getRepaireListModel.ReturnCallCustEvel ?? "","ReturnCallWay":"APP"]
        
        let finalJson = (billInfo as NSDictionary).yy_modelToJSONString()
        
        LoadView.storeLabelText = "正在提交回访信息"
        
        let acceptRepareTaskAPICmd = AcceptRepareTaskAPICmd()
        acceptRepareTaskAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","billInfo":finalJson ?? "","taskType":"3","billCode":getRepaireListModel.BillCode ?? ""]
        acceptRepareTaskAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        acceptRepareTaskAPICmd.loadView = LoadView()
        acceptRepareTaskAPICmd.loadParentView = self.view
        acceptRepareTaskAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                self.getRepaireListModel.IsReturnCall = "1"
                self.getRepaireListModel.State = "4"
                LocalToastView.toast(text: "提交回访信息成功！")
                self.saveLocalData(category: "AlreadyCallBack", subCategory: "")
                self.popAction("")
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
        }) { (response) in
            print(response);
            LocalToastView.toast(text: DisNetWork)
        }
        
    }
    
    //检验
    @objc func checkCommit() {
        
        let tips = NSMutableArray(capacity: 20)
        
        let processTextView = (checkConditionRow.cell as TextAreaCell).textView
        let processStr = processTextView?.text ?? ""
        
        if (processStr.compare("") == .orderedSame) {
            tips.add("检验情况")
        }
        
        if (tips.count != 0) {
            
            var tipString = "["
            
            for (index, name) in tips.enumerated() {
                tipString.append(name as! String)
                if (index != tips.count - 1) {
                    tipString.append(",")
                }
            }
            
            tipString.append("]没有填写，继续提交？")
            
            showAlertChoose(title: "提示", message: tipString as NSString, placeHolder: "", titles: ["继续提交","返回填写"], selector: #selector(TaskDetailViewController.commitTip(type:)), target: self)
            
            return;
            
        }
        
        checkCommitAction()
    }
    
    func checkCommitAction() {
        
        let processTextView = (checkConditionRow.cell as TextAreaCell).textView
        let processStr = processTextView?.text ?? ""
        
        var checkStatus = ""
        
        if (getRepaireListModel.ReturnCallCheckPass?.compare("1") == .orderedSame) {
            checkStatus = "true"
        }else {
            checkStatus = "false"
        }
        
        let billInfo = ["ReturnCallMemo":processStr,"ReturnCallCheckPass":checkStatus,"ReturnCallWay":"APP"]
        
        let finalJson = (billInfo as NSDictionary).yy_modelToJSONString()
        
        LoadView.storeLabelText = "正在提交检验信息"
        
        let acceptRepareTaskAPICmd = AcceptRepareTaskAPICmd()
        acceptRepareTaskAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        acceptRepareTaskAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","billInfo":finalJson ?? "","taskType":"4","billCode":getRepaireListModel.BillCode ?? ""]
        acceptRepareTaskAPICmd.loadView = LoadView()
        acceptRepareTaskAPICmd.loadParentView = self.view
        acceptRepareTaskAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                self.getRepaireListModel.IsReturnCall = "1"
                self.getRepaireListModel.State = "4"
                
                LocalToastView.toast(text: "提交检验信息成功！")
                self.saveLocalData(category: "AlreadyCheck", subCategory: "")
                
                self.popAction("")
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
    }
    
    @objc func commitTip(type: NSString) {
        
        if (type.compare("0") == .orderedSame) {
            //继续提交
            checkCommitAction()
        }else {
            
        }
        
    }
    
    @objc func commitVisitTip(type: NSString) {
        if (type.compare("0") == .orderedSame) {
            //继续提交
            visitCommitAction()
        }else {
            
        }
    }
    
    //派单
    
    @objc func sendPage() {
        
        if contentType == "7" {
            self.settedActionSheet(nil, tag: "FQHFStyle", clickedButtonAt: 0)
        }
        else {
            // 派单
            if self.contentType == "0" {
                self.actionNext();
            }
            if self.contentType == "1" {
                self.settedActionSheet(nil, tag: "SendStyle", clickedButtonAt: 0)
            }
        }
        //showActionSheet(title: "选择类型", cancelTitle: "取消", titles: ["在线人员","全部人员"], tag: "SendStyle")
//        let vc = RepairTaskAddViewController();
    }
    
    //到达
    @objc func arriveAction() {
        //更新
        
        if getRepaireListModel.IsAccept == "0" {
            
            let billInfo = [String: Any]()
            
            let finalJson = (billInfo as NSDictionary).yy_modelToJSONString()
            
            LoadView.storeLabelText = "正在接单"
            
            let acceptRepareTaskAPICmd = AcceptRepareTaskAPICmd()
            acceptRepareTaskAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","billInfo":finalJson ?? "","taskType":"1","billCode":getRepaireListModel.BillCode ?? ""]
            acceptRepareTaskAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            acceptRepareTaskAPICmd.loadView = LoadView()
            acceptRepareTaskAPICmd.loadParentView = self.view
            acceptRepareTaskAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    self.getRepaireListModel.IsAccept = "1"
                    self.getRepaireListModel.update()
                    self.setBottomButton()
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
        } else {
            //到达
            let date = NSDate()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let arriveTime = timeFormatter.string(from: date as Date) as String
            
            getRepaireListModel.IsArrive = "1"
            getRepaireListModel.ArriveTime = arriveTime
            getRepaireListModel.update()
            setBottomButton()
            
            loadForm()
            
        }
        
    }
    
    //完成
    @objc func finishAction() {
        
        let isArrive = Int(NSString(string: getRepaireListModel.IsArrive!).intValue)
        let isStart = Int(NSString(string: getRepaireListModel.IsStart!).intValue)
        let isSuspend = Int(NSString(string: getRepaireListModel.IsSuspend!).intValue)
        
        if (isArrive == 1 && isStart == 1 && isSuspend == 1) {
            
            let tips = NSMutableArray(capacity: 20)
            
            if (getRepaireListModel.Type?.compare("") == .orderedSame) {
                tips.add("维修类别")
            }
            
            if (getRepaireListModel.CompleteMemo?.compare("") == .orderedSame) {
                tips.add("维修情况")
            }
            
            if (selectImageShowView.selectedPhotos.count == 0) {
                tips.add("现场照片")
            }
            
            let cell = self.signatureViewRow.cell as SignatureTableViewCell
            
            if (cell.signView.signatureSuccessImage == nil) {
                tips.add("签字")
            }
            
            if (tips.count != 0) {
                
                var tipString = "没有处理["
                
                for (index, name) in tips.enumerated() {
                    tipString.append(name as! String)
                    if (index != tips.count - 1) {
                        tipString.append(",")
                    }
                }
                
                tipString.append("]是否继续，完成后将无法修改现场照片和签字！")
                
                showAlertChoose(title: "提示", message: tipString as NSString, placeHolder: "", titles: ["返回","继续"], selector: #selector(finishImageAction(type:)), target: self)
                
                return;
                
            }
            
            showAlertChoose(title: "消息提示", message: "确认维修完成？", placeHolder: "", titles: ["返回","确定"], selector: #selector(confirmFinishAction(type:)), target: self)
        }

    }
    
    //暂停
    @objc  func suspendAction() {
        
        if (getRepaireListModel.IsSuspend?.compare("1") == .orderedSame) {
            getRepaireListModel.IsSuspend = "0"
        }else {
            getRepaireListModel.IsSuspend = "1"
        }
        getRepaireListModel.update()
        setBottomButton()
        loadForm()
    }
    
    //开始
    @objc  func startAction() {
        
        let date = NSDate()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strNowTime = timeFormatter.string(from: date as Date) as String
        
        getRepaireListModel.IsEdit = "1"
        getRepaireListModel.IsStart = "1"
        getRepaireListModel.IsSuspend = "1"
        getRepaireListModel.BeginTime = strNowTime
        getRepaireListModel.update()
        setBottomButton()
        loadForm()
    }
    
    //抢单
    
    @objc func qPage() {
        
        //抢单不需要选人
        self.settedActionSheet(nil, tag: "QStyle", clickedButtonAt: 0)
        //showActionSheet(title: "选择类型", cancelTitle: "取消", titles: ["在线人员","全部人员"], tag: "QStyle")
        
        
    }
    
    @objc func finishImageAction(type: NSString) {
        
        if (type.compare("0") == .orderedSame) {
            
        }else {
            //继续
            self.perform(#selector(self.tipActionFinish), with: nil, afterDelay: 1.0)
        }
        
    }
    
    @objc func tipActionFinish() {
        showAlertChoose(title: "消息提示", message: "确认维修完成？", placeHolder: "", titles: ["返回","确定"], selector: #selector(confirmFinishAction(type:)), target: self)
    }
    
    @objc func confirmFinishAction(type: NSString) {
        
        if (type.compare("0") == .orderedSame) {
            
        }else {
            
            //确定
            
            //完成 ！= 提交
            
            self.getRepaireListModel.IsOver = "1"
            
            let date = NSDate()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let endTime = timeFormatter.string(from: date as Date) as String
            self.getRepaireListModel.EndTime = endTime
            self.getRepaireListModel.update()
            
            loadForm()
            
            
            self.view.viewWithTag(1178)?.removeFromSuperview()
            
            self.tableView?.frame = CGRect(x: 0, y: peTimeLine.height, width: kScreenWidth, height: kScreenHeight - kTabBarHeight - peTimeLine.height - 94)
            
            //点击完成，存储图片
            storeAddRepairTaskImage()
            signPictureStore()
            
            self.getRepaireListModel.IsMaterialCommit = "1"
            self.getRepaireListModel.update()
            self.tableView?.reloadData()
            
            buttonAction(titles: ["返回","提交"], actions: [#selector(singlePopAction),#selector(finishCommitBillInfo)], target: self)
            
        }
        
    }
    
    @objc func finishCommitBillInfo() {
        //完成任务
        
        let jsonBillInfo: NSMutableDictionary = NSMutableDictionary(capacity: 20)
        
        jsonBillInfo["State"] = "4"
        jsonBillInfo["StateCause"] = getRepaireListModel.CompleteMemo ?? ""
        jsonBillInfo["BeginTime"] = getRepaireListModel.BeginTime ?? ""
        jsonBillInfo["ArriveTime"] = getRepaireListModel.ArriveTime ?? ""
        jsonBillInfo["EndTime"] = getRepaireListModel.EndTime ?? ""
        jsonBillInfo["RepareTime"] = stringToTimeStamp(stringBeginTime: getRepaireListModel.EndTime!, stringEndTime: getRepaireListModel.BeginTime!) ?? ""
        jsonBillInfo["BillCode"] = getRepaireListModel.BillCode ?? ""
        
        jsonBillInfo["LaborCost"] = getRepaireListModel.LaborCost ?? ""
        jsonBillInfo["MaterialCost"] = getRepaireListModel.MaterialCost ?? ""
        jsonBillInfo["OtherCost"] = getRepaireListModel.OtherCost ?? ""
        
        jsonBillInfo["RepareCategoryID"] = getRepaireListModel.RepareCategoryID ?? ""
        jsonBillInfo["Sort"] = getRepaireListModel.sort ?? ""
        
        let laborCost = Float(getRepaireListModel.LaborCost!) ?? 0.0
        let materialCost = Float(getRepaireListModel.MaterialCost!) ?? 0.0
        let otherCost = Float(getRepaireListModel.OtherCost!) ?? 0.0
        let repareFee = laborCost + materialCost + otherCost
        
        
        jsonBillInfo["RepareFee"] = String(repareFee)
        jsonBillInfo["Memo"] = getRepaireListModel.ReturnCallMemo
        
        LoadView.storeLabelText = "正在完成维修任务"
        
        let updateRepareTaskAPICmd = UpdateRepareTaskAPICmd()
        updateRepareTaskAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        updateRepareTaskAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","BillInfo":jsonBillInfo.yy_modelToJSONString() ?? ""]
        updateRepareTaskAPICmd.loadView = LoadView()
        updateRepareTaskAPICmd.loadParentView = self.view
        updateRepareTaskAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                self.getRepaireListModel.IsCommit = "1"
                self.getRepaireListModel.deleteObject()
                
                //同时删除未提交中相关数据
                GetRepaireListModel.deleteObjects(byCriteria: " WHERE Category = 'NoCommit' AND SubCategory = 'FinishSuccessCase' AND BillCode = '" + self.getRepaireListModel.BillCode! + "'")
                
                self.getRepaireListModel.State = "4"
                self.saveLocalData(category: "AlreadyComplete", subCategory: "")
                
                self.uploadFile(type: 3)
                
            }else {
                
            }
            
            LocalToastView.toast(text: dict["msg"].string!)
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
    }
    
    func uploadFile(type: NSInteger) {
        
        var uploadType = "3"
        if (type == 6) {
            uploadType = "6"
        }else if (type == 4) {
            uploadType = "4"
        }
        
        let parameters = ["AccountCode":loginInfo?.accountCode ?? "",
                          "upk":userInfo?.upk ?? "",
                          "osType":"0",
                          "type":uploadType,
                          "billpk":self.getRepaireListModel.BillCode!,] as [String : String]
        
        
        let hud: MBProgressHUD? = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.mode = .indeterminate
        hud?.label.text = "正在上传附件..."
        
        //上传
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                var index = 0
                
                if (type == 3) {
                    //图片
                    
                    for image in self.selectImageShowView.selectedPhotos {
                        //避免图片名称重复，采用时间+索引策略
                        if (BaseTool.isKind(image) == 1) {
                            
                            let existImage = UIImage(contentsOfFile: image as! String)
                            
                            let data = CompressionImage.compressionImage(existImage)
                            let imageName = String(describing: NSDate()) + String(index) + ".png"
                            multipartFormData.append(data!, withName: imageName, fileName: imageName.replacingOccurrences(of: " ", with: ""), mimeType: "image/png")
                        }else {
                            
                            let data = CompressionImage.compressionImage(image as! UIImage)
                            let imageName = String(describing: NSDate()) + String(index) + ".png"
                            print(imageName)
                            multipartFormData.append(data!, withName: imageName, fileName: imageName.replacingOccurrences(of: " ", with: ""), mimeType: "image/png")
                        }
                        
                        index = index + 1
                        
                    }
                    
                }else if (type == 4) {
                    //完成音频
                    
                }else if (type == 6) {
                    //签字
                    let cell = self.signatureViewRow.cell as SignatureTableViewCell
                    
                    if (cell.signView.signatureSuccessImage != nil) {
                        let data = CompressionImage.compressionImage(cell.signView.signatureSuccessImage as UIImage)
                        let imageName = String(describing: NSDate()) + String(index + 11) + ".png"
                        
                        multipartFormData.append(data!, withName: imageName, fileName: imageName.replacingOccurrences(of: " ", with: ""), mimeType: "image/png")
                    }
                    
                }
                
                // 这里就是绑定参数的地方 param 是需要上传的参数，我这里是封装了一个方法从外面传过来的参数，你可以根据自己的需求用NSDictionary封装一个param
                for (key, value) in parameters {
                    multipartFormData.append((value.data(using: String.Encoding.utf8)!), withName: key)
                }
                
        },
            to: LocalStoreData.getPMSAddress().PMSAddress! + kUploadFile,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        print(response)
                        DispatchQueue.main.async(execute: {
                            hud?.hide(animated: true)
                            if (type == 6) {
                                //签名成功
                                self.pop()
                            }else if (type == 3) {
                                //传签名
                                self.uploadFile(type: 6)
                            }
                            //self.actionNext()
                            //延迟执行
                        })
                        
                    }
                case .failure(let encodingError):
                    hud?.hide(animated: true)
                    print(encodingError)
                }
        }
        )
        
    }
    
    //MARK: UITextFieldDelegate
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("-- \(indexPath.section),- \(indexPath.row)")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch contentType {
        case "8","9","10","11":
            return false
        default:
            return true
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        switch contentType {
        case "8","9","10","11":
            return false
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if (textField.tag == costTag + 4) {
            getRepaireListModel.MaterialCost = textField.text
        }else if (textField.tag == costTag + 5) {
            getRepaireListModel.LaborCost = textField.text
        }else if (textField.tag == costTag + 6) {
            getRepaireListModel.OtherCost = textField.text
        }
        
        self.initDatas()
        self.tableView?.reloadData()
    }
    
    open override func textInputShouldBeginEditing<T>(_ textInput: UITextInput, cell: Cell<T>) -> Bool {
        switch contentType {
        case "7","8","9","10","11":
            return false;
        default:
            return true;
        }
    }
    
    //MARK: UITextViewDelegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if (textView.tag == 3330) {
            getRepaireListModel.ReturnCallMemo = textView.text
            
            customerRecommondContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: customerRecommondContentCell!,content: (self.getRepaireListModel.ReturnCallMemo!)) + "字"
            
        }else if (textView.tag == 3331) {
            getRepaireListModel.ReturnCallCustNoSatisCause = textView.text
            
            backConditionContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: backConditionContentCell!,content: (self.getRepaireListModel.ReturnCallCustNoSatisCause!)) + "字"
            
        }else if (textView.tag == 3332) {
            getRepaireListModel.ReturnCallCustSuggest = textView.text
            
            customerSuggestContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: customerSuggestContentCell!,content: (self.getRepaireListModel.ReturnCallCustSuggest!)) + "字"
            
        }else if (textView.tag == 3333) {
            getRepaireListModel.ReturnCallMemo = textView.text
            
            checkConditionContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: checkConditionContentCell!,content: (self.getRepaireListModel.ReturnCallMemo!)) + "字"
        }else if (textView.tag == 3335) {
            getRepaireListModel.CompleteMemo = textView.text
            
            textAreaRowContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: textAreaRowContentCell!,content: (self.getRepaireListModel.CompleteMemo!)) + "字"
        }
        self.tableView?.reloadData()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if (textView.tag == 3330) {
            if (textView.text.compare("") == .orderedSame) {
                customerRecommondRow.cell.placeholderLabel?.text = "回访情况"
            }else {
                customerRecommondRow.cell.placeholderLabel?.text = ""
            }
            
            customerRecommondContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: customerRecommondContentCell!,content: (self.getRepaireListModel.ReturnCallMemo ?? "")) + "字"
            
        }else if (textView.tag == 3331) {
            if (textView.text.compare("") == .orderedSame) {
                backConditionRow.cell.placeholderLabel?.text = "不满意原因"
            }else {
                backConditionRow.cell.placeholderLabel?.text = ""
            }
            
            backConditionContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: backConditionContentCell!,content: (self.getRepaireListModel.ReturnCallCustNoSatisCause ?? "")) + "字"
            
        }else if (textView.tag == 3332) {
            if (textView.text.compare("") == .orderedSame) {
                customerSuggestRow.cell.placeholderLabel?.text = "客户建议"
            }else {
                customerSuggestRow.cell.placeholderLabel?.text = ""
            }
            
            customerSuggestContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: customerSuggestContentCell!,content: (self.getRepaireListModel.ReturnCallCustSuggest ?? "") + "字")
            
        }else if (textView.tag == 3333) {
            if (textView.text.compare("") == .orderedSame) {
                checkConditionRow.cell.placeholderLabel?.text = "检验情况"
            }else {
                checkConditionRow.cell.placeholderLabel?.text = ""
            }
            checkConditionContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: checkConditionContentCell!,content: (self.getRepaireListModel.ReturnCallMemo ?? "") + "字")
        }else if (textView.tag == 3335) {
            if (textView.text.compare("") == .orderedSame) {
                textAreaRow.cell.placeholderLabel?.text = "维修说明"
            }else {
                textAreaRow.cell.placeholderLabel?.text = ""
            }
            textAreaRowContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: textAreaRowContentCell!,content: (self.getRepaireListModel.CompleteMemo ?? "") + "字")
        }
    }
    
    //MARK: ActionSheet
    
    @objc func selectHege() {
        showActionSheet(title: "是否合格", cancelTitle: "取消", titles: ["合格","不合格"], tag: "selectHege")
    }
    
    @objc func actionNext() {
            
            showActionSheet(title: "选择报修方式", cancelTitle: "取消", titles: checkTypeArray, tag: "ChooseCheck")
        
    }
    
    override func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            return
        }
        
        if (tag.compare("selectHege") == .orderedSame) {
            if (buttonIndex == 1) {
                self.hege = "0";
                self.hegeLab?.text = "合格";
                self.getRepaireListModel.ReturnCallCheckPass = "1";
            }
            else {
                self.hege = "1";
                self.hegeLab?.text = "不合格";
                self.getRepaireListModel.ReturnCallCheckPass = "0";
            }
            return;
        }
        
        if (tag.compare("ChooseCheck") == .orderedSame) {
            
            if (buttonIndex == 0) {
                return
            }
            
//            self.localButtonIndex = buttonIndex
            
            let choose = RepairChooseSenderViewController()
            choose.delegate = self
            choose.billCode = self.getModel.BillCode!;
            choose.accountCode = loginInfo?.accountCode ?? ""
            choose.upk = userInfo?.upk ?? ""
            choose.baseUrl = LocalStoreData.getPMSAddress().PMSAddress
            
            if (LocalStoreData.getIsRepairOn()?.compare("YES") == .orderedSame) {
                choose.lineState = "0"
            }else {
                choose.lineState = "1"
            }
            
            /*
             if (self.localButtonIndex == 1 || self.localButtonIndex == 3 || self.localButtonIndex == 5) {
             choose.lineState = "1"
             }else {
             choose.lineState = "0"
             }*/
            
            //choose.chooseTitle = actionSheet.buttonTitle(at: buttonIndex)
            choose.chooseTitle = checkTypeArray[buttonIndex - 1]
            
            /*
             if (self.localButtonIndex == 5 || self.localButtonIndex == 6) {
             choose.chooseType = "3"
             choose.requestData()
             }else {
             self.navigationController?.pushViewController(choose, animated: true)
             }*/
            
            if (buttonIndex == 3) {
                choose.chooseType = "3"
                choose.requestData()
            }else {
                self.navigationController?.pushViewController(choose, animated: true)
            }
            
            return
        }
        // Mark: 分割
        if (tag.compare("ReturnCallCheckPass") == .orderedSame) {
            
            if (buttonIndex == 1) {
                self.getRepaireListModel.ReturnCallCheckPass = "1"
            }else {
                self.getRepaireListModel.ReturnCallCheckPass = "0"
            }
            
            self.tableView?.reloadData()
            
        }else if (tag.compare("ReturnCallCustEvel") == .orderedSame) {
            //ReturnCallCustEvel 客户评价
            
            if (customerCommondSourceArray.count == 0) {
                
                if (buttonIndex == 1) {
                    self.getRepaireListModel.ReturnCallCustEvel = "满意"
                }else {
                    self.getRepaireListModel.ReturnCallCustEvel = "不满意"
                }
                
            }else {
                let model = self.customerCommondSourceArray[buttonIndex - 1] as! GetDictionaryInfosModel
                getRepaireListModel.ReturnCallCustEvel = model.Content
            }
            
            self.tableView?.reloadData()
            
        }
        else {
            
            self.settedActionSheet(actionSheet, tag: tag, clickedButtonAt: buttonIndex)
            
        }
        
        
    }
    
    func settedActionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
//        RepairChooseSenderResultDelegate
        let choose = RepairChooseSenderViewController()
        choose.delegate = self
        choose.billCode = getRepaireListModel.BillCode
        choose.accountCode = loginInfo?.accountCode ?? ""
        choose.upk = userInfo?.upk ?? ""
        choose.baseUrl = LocalStoreData.getPMSAddress().PMSAddress
        
        
        if (tag.compare("SendStyle") == .orderedSame) {
            choose.chooseTitle = "维修"
            choose.chooseType = "2"
        }else if (tag.compare("QStyle") == .orderedSame) {
            choose.chooseTitle = "发起抢单"
            choose.chooseType = "3"
        }
        else if (tag.compare("FQHFStyle") == .orderedSame) {
            if (getModel.Range == "公共区域") {
                choose.chooseTitle = "发起检验"
                choose.chooseType = "4"
            }
            else {
                choose.chooseTitle = "发起回访"
                choose.chooseType = "4"
            }
        }
        
        if (LocalStoreData.getIsRepairOn()?.compare("YES") == .orderedSame) {
            choose.lineState = "0"
        }else {
            choose.lineState = "1"
        }
        
        if (tag.compare("SendStyle") == .orderedSame || tag.compare("FQHFStyle") == .orderedSame) {
            self.navigationController?.pushViewController(choose, animated: true)
        }else {
            choose.requestData()
        }
    }
    
    internal func presentMyViewController(_ viewController: UIViewController!, animated: Bool) {
        self.present(viewController, animated: animated, completion: nil)
    }
    
    //MARK: RepairChooseChargeItemDelegate
    
    func confirmRepairChooseChargeItemWithObject(object: AnyObject){
        getRepaireTypeModel = object as? GetRepaireTypeModel
        getRepaireListModel.RepareCategoryID = getRepaireTypeModel?.repairtypepk
        getRepaireListModel.sort = getRepaireTypeModel?.sort
        self.tableView?.reloadData()
    }
    
    override func pop() {
        storeDataPopAction(needNotification: true)
        super.pop()
    }
    
    @objc  func singlePopAction() {
        storeDataPopAction(needNotification: false)
        super.pop()
    }
    
    @objc func popAction(_ result: String!, message: String!) {
        LocalToastView.toast(text: message);
        super.pop()
    }
//    - (void)popAction:(NSString *)result message:(NSString *)message;
    
    func storeDataPopAction(needNotification: Bool) {
        
        if (getRepaireListModel.IsOver?.compare("1") == .orderedSame) {
            
            storeAddRepairTaskImage()
            signPictureStore()
            
            if (selectIndex == 0
                && getRepaireListModel.Category?.compare("NoComplete") == .orderedSame
                && getRepaireListModel.IsOver?.compare("1") == .orderedSame
                && !isExistBillInfo) {
                
                //如果未提交中存在该单据NoCommit，则不再添加，否则直接更新
                let array = NSMutableArray(array: GetRepaireListModel.find(byCriteria: " WHERE BillCode = '" + getRepaireListModel.BillCode! + "' and Category = 'NoCommit'"))
                if (array.count == 0) {
                    saveLocalData(category: "NoCommit", subCategory: "FinishSuccessCase")
                }else {
                    getRepaireListModel.update()
                }
            }else {
                getRepaireListModel.update()
            }
        }else if (selectIndex != 1 && contentType.compare("1") == .orderedSame) {
            
        }
        
        if (selectIndex == 0 && needNotification) {
            //我的维修返回刷新
//            NotificationCenter.default.post(name: kNotificationCenterFreshRepairTaskDetailList as NSNotification.Name, object: nil)
        }
        
    }
    
    func popAction(_ result: String) {
        
        if (selectIndex != 1 && contentType.compare("1") == .orderedSame) {
            //派单成功 --- 存储本地已派单
//            if (result.compare("success") == .orderedSame) {
//                saveLocalData(category: "AlreadySend", subCategory: "")
//            }
        }
        
//        NotificationCenter.default.post(name: kNotificationCenterFreshRepairTaskDetailList as NSNotification.Name, object: nil)
        super.pop()
    }
    
    
    func saveLocalData(category: String, subCategory: String) {
        self.getRepaireListModel?.Category = category
        self.getRepaireListModel?.SubCategory = subCategory
        self.getRepaireListModel?.save()
    }
    
    
    func stringToTimeStamp(stringBeginTime:String, stringEndTime:String) -> String {
        
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="yyyy-MM-dd HH:mm:ss"
        
        let beginDate = dfmatter.date(from: stringBeginTime)
        let endDate = dfmatter.date(from: stringEndTime)
        
        let dateStartStamp:TimeInterval = beginDate!.timeIntervalSince1970
        let dateEndStamp:TimeInterval = endDate!.timeIntervalSince1970
        
        let dateSt:Int = Int(dateStartStamp)
        let dateEt:Int = Int(dateEndStamp)
        
        return String(dateEt - dateSt)
        
    }
    
    //签到图片存储
    func signPictureStore() {
        
        getRepaireListModel?.LocalSignImage = ""
        
        let cell = signatureViewRow.cell as SignatureTableViewCell
        
        if (cell.signView.signatureSuccessImage != nil) {
            
            let data = UIImageJPEGRepresentation(cell.signView.signatureSuccessImage as UIImage, 0.5)
            
            var imageName = (self.getRepaireListModel?.BillCode)! + "Sign"
            imageName = imageName.appending((self.getRepaireListModel?.Category)!).appending((self.getRepaireListModel?.SubCategory)!)
            getRepaireListModel?.LocalSignImage = imageName
            
            DiskCache().saveDataToCache(proName: imageName, Data: data! as NSData)
        }
        
    }
    
    func fetchLocalSignImages() {
        
        if (getRepaireListModel?.LocalSignImage != nil && getRepaireListModel?.LocalSignImage?.compare("") != .orderedSame) {
            
            let pathStr = DiskCache().cachePath(proName: (getRepaireListModel?.LocalSignImage)!).appending((getRepaireListModel?.LocalSignImage)!).appending(".png")
            let existImage = UIImage(contentsOfFile: pathStr)
            if (existImage != nil) {
                let cell = signatureViewRow.cell as SignatureTableViewCell
                cell.signView.signatureSuccessImage = existImage
                cell.signView.signImageView.image = existImage
            }
        }

    }
    
    //图片存储
    func storeAddRepairTaskImage() {
        
        var index = 0
        let localImages = NSMutableArray(capacity: 20)
        
        for image in self.selectImageShowView.selectedPhotos {
            
            var data: Any?
            
            if (BaseTool.isKind(image) == 1) {
                //filaPath
                let existImage = UIImage(contentsOfFile: image as! String)
                data = UIImageJPEGRepresentation(existImage!, 0.5)
            }else {
                data = UIImageJPEGRepresentation(image as! UIImage, 0.5)
            }
            
            var imageName = (self.getRepaireListModel?.BillCode)! + String(index)
            imageName = imageName.appending((self.getRepaireListModel?.Category)!).appending((self.getRepaireListModel?.SubCategory)!)
            localImages.add(imageName)
            
            if (index == 0) {
                getRepaireListModel?.LocalImageO = imageName
            }else if (index == 1) {
                getRepaireListModel?.LocalImageT = imageName
            }else if (index == 2) {
                getRepaireListModel?.LocalImageS = imageName
            }else if (index == 3) {
                getRepaireListModel?.LocalImageF = imageName
            }
            
            DiskCache().saveDataToCache(proName: imageName, Data: data! as! NSData)
            
            index = index + 1
        }
        self.getRepaireListModel?.update()
        
    }
    
    func fetchLocalImages() {
        
        self.selectImageShowView.selectedPhotos = []
        self.selectImageShowView.selectedAssets = []
        
        if (getRepaireListModel?.LocalImageO?.compare("") != .orderedSame) {
            writeLocalImage(imageName: getRepaireListModel?.LocalImageO!, type: 0)
        }
        
        if (getRepaireListModel?.LocalImageT?.compare("") != .orderedSame) {
            writeLocalImage(imageName: getRepaireListModel?.LocalImageT!, type: 1)
        }
        
        if (getRepaireListModel?.LocalImageS?.compare("") != .orderedSame) {
            writeLocalImage(imageName: getRepaireListModel?.LocalImageS!, type: 2)
        }
        
        if (getRepaireListModel?.LocalImageF?.compare("") != .orderedSame) {
            writeLocalImage(imageName: getRepaireListModel?.LocalImageF!, type: 3)
        }
        
        self.selectImageShowView.collectionView.reloadData()
        
    }
    
    fileprivate func writeLocalImage(imageName: String?, type: NSInteger) {
        let pathStr = DiskCache().cachePath(proName: imageName!).appending(imageName!).appending(".png")
        let existImage = UIImage(contentsOfFile: pathStr)
        if (existImage != nil) {
            self.selectImageShowView.selectedPhotos.add(pathStr)
            self.selectImageShowView.selectedAssets.add(pathStr)
        }else {
            if (type == 0) {
                getRepaireListModel?.LocalImageO = ""
            }else if (type == 1) {
                getRepaireListModel?.LocalImageT = ""
            }else if (type == 2) {
                getRepaireListModel?.LocalImageS = ""
            }else if (type == 3) {
                getRepaireListModel?.LocalImageF = ""
            }
        }
    }
    
    @objc func recordPlay(ges: UITapGestureRecognizer) {
        
        player.play(recordUrl)
        
    }
    
    @objc func displayPhotoBrowser(ges: UITapGestureRecognizer) {
        
        var scanPhotos = NSMutableArray(capacity: 20)
        
        var turnPagePhotos = broswerArray
        
        if (ges.view?.tag == 7771) {
            
        }else if (ges.view?.tag == 7773) {
            turnPagePhotos = broswerSceneArray
        }else if (ges.view?.tag == 7775) {
            turnPagePhotos = broswerSignArray
        }
        for url in turnPagePhotos {
            let string = url as! NSString;
            
            var ss:String! = string as String;
            if string.contains("webapi") {
                ss = string.replacingOccurrences(of:"webapi", with: "")
            }
            if (ss.hasSuffix(".jpg")) {
                ss =  ss.components(separatedBy: ".jpg")[0]
                ss.append(".jpg")
            }
            else {
                ss = ss.components(separatedBy: ".png")[0]
                ss.append(".png")
            }
            NSLog("%@", ss.components(separatedBy: ".jpg"));
//            var ss:String! = string as String
//            if string.contains("webapi") {
//                ss = string.replacingOccurrences(of:"webapi", with: "")
//            }
            let thumbnail1 = UIImage.init(named: "thumbnail1")
            let photoUrl1 = URL.init(string: ss)
            
            let photo = Photo.init(image: nil, title:"查看图片", thumbnailImage: thumbnail1, photoUrl: photoUrl1)
            scanPhotos.add(photo)
            
        }
        
        photoBrowser = PhotoBrowser()
        if let browser = photoBrowser {
            browser.isFromPhotoPicker = true
            browser.photos = scanPhotos as! [Photo]
            browser.photoBrowserDelegate = self
            browser.currentIndex = 0
            presentPhotoBrowser(browser, fromView: ges.view!)
        }
    }

    
}

extension TaskDetailViewController: PhotoBrowserDelegate {
    
    func photoBrowser(_ browser: PhotoBrowser, didShowPhotoAtIndex index: Int) {
        print("photo browser did show at index: \(index)")
    }
    
    func dismissPhotoBrowser(_ photoBrowser: PhotoBrowser) {
        dismissPhotoBrowser(toView: imageView)
    }
    
    func longPressOnImage(_ gesture: UILongPressGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else {
            return
        }
    }
    
    func photoBrowser(_ browser: PhotoBrowser, willSharePhoto photo: Photo) {
        print("Custom share action here")
    }
    
    func photoBrowser(_ browser: PhotoBrowser, canSelectPhotoAtIndex index: Int) -> Bool {
        print("canSelectPhotoAtIndex \(index)")
        if index == 2 {
            return false
        }
        return true
    }
    
    func photoBrowser(_ browser: PhotoBrowser, didSelectPhotoAtIndex index: Int) {
        print("didSelectPhotoAtIndex \(index)")
    }
}
