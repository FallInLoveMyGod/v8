//
//  DealComplaintHandleListViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
//import HandyJSON
import Alamofire
import Eureka

class DealComplaintHandleListViewController: FormBaseTableViewController,ColleagueDetailDelegate,UITextViewDelegate {
    
    var complaintHandleModel: ComplaintHandleModel!
    var resultModel: GetComplaintByCodeModel!
    var valuesArray = NSMutableArray(capacity: 20)
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var textAreaRow = TextAreaRow("")
    
    
    let complaintTextViews = NSMutableArray(capacity: 20)
    
    var processCell: ComplaintHandleContentInputTableViewCell = ComplaintHandleContentInputTableViewCell()
    var resultCell: ComplaintHandleContentInputTableViewCell = ComplaintHandleContentInputTableViewCell()
    var suggestCell: ComplaintHandleContentInputTableViewCell = ComplaintHandleContentInputTableViewCell()
    var callBackDealCell: ComplaintHandleContentInputTableViewCell = ComplaintHandleContentInputTableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        if (complaintHandleModel.Type?.compare("1") == .orderedSame) {
            self.setTitleView(titles: ["处理投诉单"])
        }else if (complaintHandleModel.Type?.compare("3") == .orderedSame){
            self.setTitleView(titles: ["投诉回访"])
        }else if (complaintHandleModel.Type?.compare("0") == .orderedSame){
            self.setTitleView(titles: ["投诉分派处理任务"])
        }else if (complaintHandleModel.Type?.compare("2") == .orderedSame){
            self.setTitleView(titles: ["投诉分派回访任务"])
        }
        
        self.tableView?.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight  - 50)
        
        self.loadForm()
        
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if complaintHandleModel.Type == "1" || complaintHandleModel.Type == "3" {
            // -待处理，待回访
            buttonAction(titles: ["返回","提交"], actions: [#selector(pop),#selector(commitAction)], target: self)
        }
        else {
            // 待回访派单，待派单
             buttonAction(titles: ["返回","分派处理任务"], actions: [#selector(pop),#selector(commitAction)], target: self)
        }
        self.tableView?.sectionFooterHeight = 0.001
        self.tableView?.sectionHeaderHeight = 0.001
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private interface
    
    fileprivate func loadForm() {
        
        let sections = [setSelfSection(title: "投诉人信息",headerHeight: 35, footerHeight: 0.001),setSelfSection(title: "被投诉信息",headerHeight: 35, footerHeight: 0.001),setSelfSection(title: "投诉信息",headerHeight: 35, footerHeight: 0.001)]
        let names = [["被诉人地址","投诉人","业户名称","联系方式"],
                     ["类型","被投诉人","联系方式"],
                     ["投诉类别","投诉方式","要求期限","投诉主题","投诉内容"]]
        
        let sctionChoose = setSelfSection(title: " ",headerHeight: 10, footerHeight: 0.001)
        
        sctionChoose
            <<< ComplaintHandlingAddLabelTableViewRow(){
                let tempCell = $0.cell as ComplaintHandlingAddLabelTableViewCell
                tempCell.singleShowLabel.text = "是否立项"
                
                if ((self.resultModel != nil) && self.resultModel.IsCreateProj != nil) {
                    if (self.resultModel.IsCreateProj?.compare("0") == .orderedSame) {
                        tempCell.singleShowContentLabel.text = "否"
                    }else {
                        tempCell.singleShowContentLabel.text = "是"
                    }
                }
                
            }
        
        for (index, section) in sections.enumerated() {
            for (subIndex, name) in (names[index] as NSArray).enumerated() {
                (section as Section).append(
                    ComplaintHandlingAddLabelTableViewRow(){
                        
                        let tempCell = $0.cell as ComplaintHandlingAddLabelTableViewCell
                        tempCell.singleShowLabel.text = name as? String
                        if ((self.resultModel != nil) && valuesArray.count != 0) {
                            tempCell.singleShowContentLabel.text = (valuesArray[index] as! NSArray)[subIndex] as? String
                        }
                        
                })
            }
        }
        
        form = sections[0]
            +++ sections[1]
            +++ sections[2]
            +++ sctionChoose
        
        if (complaintHandleModel.Type?.compare("0") == .orderedSame) {
            // 待派单
        }
        else if (complaintHandleModel.Type?.compare("1") == .orderedSame) {
            //处理投诉单
            
            let complaintHandleSection = Section("投诉处理")
            
            complaintHandleSection
                <<< ComplaintHandlingAddLabelImageTableViewRow(){
                    let tempCell = $0.cell as ComplaintHandlingAddLabelImageTableViewCell
                    tempCell.nameLabel.text = "处理负责人"
                }.cellUpdate({ (cell, row) in
                    cell.contentLabel.text = self.resultModel.HandlePer
                })
                <<< ComplaintHandlingAddLabelImageTableViewRow(){
                    let tempCell = $0.cell as ComplaintHandlingAddLabelImageTableViewCell
                    tempCell.nameLabel.text = "投诉性质"
                }.cellUpdate({ (cell, row) in
                    cell.contentLabel.text = self.resultModel.ComplaintNature
                })
            
            let textViews = ["处理过程","处理结果","客户意见"]
            
            for (subIndex, name) in textViews.enumerated() {
                
                let row = TextAreaRow(name) {
                        $0.placeholder = name
                        $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
                }.cellUpdate({ (cell, row) in
                    cell.textView.isScrollEnabled = true
                    cell.textView.delegate = self
                    
                    if (subIndex == 0 && self.resultModel.HandleProcess?.compare("") != .orderedSame) {
                        cell.textView.text = self.resultModel.HandleProcess
                        cell.placeholderLabel?.text = ""
                    }else if (subIndex == 1 && self.resultModel.HandleResult?.compare("") != .orderedSame) {
                        cell.textView.text = self.resultModel.HandleResult
                        cell.placeholderLabel?.text = ""
                    }else if (subIndex == 2 && self.resultModel.CustomerMemo?.compare("") != .orderedSame) {
                        cell.textView.text = self.resultModel.CustomerMemo
                        cell.placeholderLabel?.text = ""
                    }
                    
                })
                complaintTextViews[subIndex] = row
                complaintHandleSection.append(row)
                complaintHandleSection.append(
                    ComplaintHandleContentInputTableViewRow() {
                        let tempCell = $0.cell as ComplaintHandleContentInputTableViewCell
                        tempCell.nameLabel.text = name
                        tempCell.nameLabel.isHidden = true
                    }.cellUpdate({ (cell, row) in
                        
                        if (subIndex == 0) {
                            self.processCell = cell
                        }else if (subIndex == 1) {
                            self.resultCell = cell
                        }else {
                            self.suggestCell = cell
                        }
                        
                    }))
            }
            
            form.append(complaintHandleSection)
            
            
        }else {
            //回访
            
            if (resultModel != nil) {
                let addNames = ["处理时间","处理负责人","投诉性质","处理过程","处理结果","客户意见"]
                
                let values = [formateTime(time: resultModel.HandleTime!) ,
                              resultModel.HandlePer ?? "",
                              resultModel.Nature ?? "",
                              resultModel.HandleProcess ?? "",
                              resultModel.HandleResult ?? "",
                              resultModel.CustomerMemo ?? ""]
                
                let addSection = Section("投诉处理")
                
                for (subIndex, name) in (addNames as NSArray).enumerated() {
                    addSection.append(
                        ComplaintHandlingAddLabelTableViewRow(){
                            
                            let tempCell = $0.cell as ComplaintHandlingAddLabelTableViewCell
                            tempCell.singleShowLabel.text = name as? String
                            tempCell.singleShowContentLabel.text = values[subIndex]
                            
                    })
                }
                
                form.append(addSection)
                
                textAreaRow = TextAreaRow("回访处理") {
                    $0.placeholder = "回访处理"
                    $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
                }
                textAreaRow.tag = "DealComplaintHandle"
                
                let statusSection = Section("回访处理")
                statusSection
                    <<< textAreaRow
                    <<< ComplaintHandleContentInputTableViewRow() {
                        
                        let tempCell = $0.cell as ComplaintHandleContentInputTableViewCell
                        
                        tempCell.nameLabel.isHidden = true
                    }.cellUpdate({ (cell, row) in
                        self.callBackDealCell = cell
                    })
                
                if (complaintHandleModel.Type?.compare("3") == .orderedSame) {
                    form.append(statusSection)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        if (indexPath.section == 4) {
            
            if (complaintHandleModel.Type?.compare("1") == .orderedSame) {
                
                if (indexPath.row == 1) {
                    
                    showActionSheet(title: "选择投诉性质", cancelTitle: "取消", titles: ["严重","一般"], tag: "Category")
                    
                }else if (indexPath.row == 0) {
                    
                    let customerInfoVC = ColleagueDetailViewController()
                    customerInfoVC.isTopLevelShow = true
                    customerInfoVC.delegate = self
                    self.navigationController?.pushViewController(customerInfoVC, animated: true)
                    
                }
            }else {
                
            }
        }
    }
    
    func setSelfSection(title: String, headerHeight: CGFloat , footerHeight: CGFloat) -> Section {
        
        let section = Section(header: title, footer: "")
        section.header?.height = { return headerHeight }
        section.footer?.height = { return footerHeight }
        
        return section
    }
    
    func requestData() {
        
        LoadView.storeLabelText = "正在加载投诉详情信息"
        
        let getComplaintByCodeAPICmd = GetComplaintByCodeAPICmd()
        getComplaintByCodeAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        getComplaintByCodeAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","Code":complaintHandleModel.Code ?? "","version":"8.2"]
        getComplaintByCodeAPICmd.loadView = LoadView()
        getComplaintByCodeAPICmd.loadParentView = self.view
        getComplaintByCodeAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            //print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
//                self.resultModel = JSONDeserializer<GetComplaintByCodeModel>.deserializeFrom(json: JSON(dict["infos"].object).rawString())
//                let model:GetComplaintByCodeModel = GetComplaintByCodeModel();
                self.resultModel = GetComplaintByCodeModel();
                self.resultModel.initWithJson(json: JSON(dict["infos"].object))
//GetComplaintByCodeModel
//                self.resultModel = GetComplaintByCodeModel.configModelWithJson(json: JSON(dict["infos"].object))
                var respondentType = ""
                
                if (self.resultModel.RespondentType?.compare("0") == .orderedSame) {
                    respondentType = "业户"
                }else if (self.resultModel.RespondentType?.compare("1") == .orderedSame) {
                    respondentType = "员工"
                }else {
                    respondentType = "其他"
                }
                
                let sectionOne = [self.resultModel.ComplainantPsAddress ?? "",
                                  self.resultModel.ComplainantHouseName ?? "",
                                  self.resultModel.Complainant ?? "",
                                  self.resultModel.ComplainantTel ?? ""]
                let sectionTwo = [respondentType,
                                  self.resultModel.uname ?? "",
                                  self.resultModel.RespondentTel ?? ""]
                
                let sectionThree = [self.resultModel.ComplainantType ?? "",
                                    self.resultModel.Way ?? "",
                                    self.resultModel.DateLimit ?? "",
                                    self.resultModel.Title ?? "",
                                    self.resultModel.Content ?? ""]
                
                self.valuesArray = [sectionOne, sectionTwo, sectionThree]
                
                self.form.removeAll()
                self.loadForm()
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }

    }
    
    @objc func commitAction() {
        //提交
        if (complaintHandleModel.Type?.compare("1") == .orderedSame) {
            
            //投诉处理
            
            //print(complaintHandleSection.rowBy(tag: complaintNames[0]) as Any)
            
            //处理过程
            let processTextView = ((complaintTextViews[0] as! TextAreaRow).cell as TextAreaCell).textView
            let resultTextView = ((complaintTextViews[1] as! TextAreaRow).cell as TextAreaCell).textView
            let suggestTextView = ((complaintTextViews[2] as! TextAreaRow).cell as TextAreaCell).textView
            
            let processStr = processTextView?.text ?? ""
            let resultStr = resultTextView?.text ?? ""
            let suggestStr = suggestTextView?.text ?? ""
            
            if (self.resultModel.ComplaintNature?.compare("") == .orderedSame) {
                LocalToastView.toast(text: "没有选择投诉性质")
                return;
            }else {
                
                var tips = NSMutableArray(capacity: 20)
                
                if (self.resultModel.HandlePer?.compare("") == .orderedSame) {
                    //处理责任人
                    tips.add("处理责任人")
                }
                if (processStr.compare("") == .orderedSame) {
                    tips.add("处理过程")
                }
                if (resultStr.compare("") == .orderedSame) {
                    tips.add("处理结果")
                }
                if (suggestStr.compare("") == .orderedSame) {
                    tips.add("客户意见")
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
                    
                    showAlertChoose(title: "提示", message: tipString as NSString, placeHolder: "", titles: ["确认","返回"], selector: #selector(DealComplaintHandleListViewController.commitData(type:)), target: self)
                    
                    return;
                    
                }
                
            }
            
            let complaintNature = self.resultModel.ComplaintNature ?? ""
            
            let infos = ["Code":complaintHandleModel.Code ?? "","HandlePer":self.resultModel.HandlePer ?? "","HandleProcess":processStr,"HandleResult":resultStr,"CustomerMemo":suggestStr,"ComplaintNature":complaintNature]
            
            
            let infojson = (infos as NSDictionary).yy_modelToJSONString()
            
            LoadView.storeLabelText = "正在提交投诉单信息"
            
            let handelComplaintFormAPICmd = HandelComplaintFormAPICmd()
            handelComplaintFormAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            handelComplaintFormAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","Infos":infojson ?? ""]
            handelComplaintFormAPICmd.loadView = LoadView()
            handelComplaintFormAPICmd.loadParentView = self.view
            handelComplaintFormAPICmd.transactionWithSuccess({ (response) in
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    self.pop()
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                LocalToastView.toast(text: DisNetWork)
            }
            
        }else if(complaintHandleModel.Type?.compare("3") == .orderedSame){
            
            //回访
            let textView = (textAreaRow.cell as TextAreaCell).textView
            
            if (textView?.text.compare("") == .orderedSame) {
                LocalToastView.toast(text: "未录入回访情况")
            }else {
                
                LoadView.storeLabelText = "正在提交投诉回访信息"
                
                let returnVisitComplaintAPICmd = ReturnVisitComplaintAPICmd()
                returnVisitComplaintAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
                returnVisitComplaintAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","Feedback":textView?.text ?? "","Code":self.resultModel.Code ?? ""]
                returnVisitComplaintAPICmd.loadView = LoadView()
                returnVisitComplaintAPICmd.loadParentView = self.view
                returnVisitComplaintAPICmd.transactionWithSuccess({ (response) in
                    
                    let dict = JSON(response)
                    
                    //print(dict)
                    
                    let resultStatus = dict["result"].string
                    
                    if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                        //成功
                        self.pop()
                    }else {
                        LocalToastView.toast(text: dict["msg"].string!)
                    }
                    
                }) { (response) in
                    LocalToastView.toast(text: DisNetWork)
                }
                
            }
        } else if (complaintHandleModel.Type?.compare("0") == .orderedSame || complaintHandleModel.Type?.compare("2") == .orderedSame) {
            // 处理派单任务
            
            let choose = RepairChooseSenderViewController();
            choose.chooseType = "1";
            choose.chooseTitle = "投诉派单";
            choose.billCode = complaintHandleModel.Code;
            choose.accountCode = loginInfo?.accountCode ?? ""
            choose.upk = userInfo?.upk ?? ""
            choose.baseUrl = LocalStoreData.getPMSAddress().PMSAddress
            if (complaintHandleModel.Type?.compare("2") == .orderedSame) {
                choose.chooseTitle = "分派回访投诉单";
            }
            self.navigationController?.pushViewController(choose, animated: true)
        }
    }
    
    //MARK: ColleagueDetailDelegate
    
    func colleagueconfirmWithObject(object: AnyObject) {
        let person = object as! WorkerDataModel
        self.resultModel.HandlePer = person.workername
        self.tableView?.reloadData()
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        let processTextView = ((complaintTextViews[0] as! TextAreaRow).cell as TextAreaCell).textView
        let resultTextView = ((complaintTextViews[1] as! TextAreaRow).cell as TextAreaCell).textView
        let suggestTextView = ((complaintTextViews[2] as! TextAreaRow).cell as TextAreaCell).textView
        
        textAreaRow.placeholder = ""
        
        if (textView == processTextView) {
            resultModel.HandleProcess = textView.text
            processCell.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: processCell,content: resultModel.HandleProcess ?? "") + "字"
            
        }else if (textView == resultTextView) {
            resultModel.HandleResult = textView.text
            resultCell.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: resultCell,content: resultModel.HandleResult ?? "") + "字"
        }else if (textView == suggestTextView) {
            resultModel.CustomerMemo = textView.text
            suggestCell.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: suggestCell,content: resultModel.CustomerMemo ?? "") + "字"
        }else if (textView == (textAreaRow.cell as TextAreaCell).textView) {
            
            callBackDealCell.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: callBackDealCell,content: textView.text) + "字"
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        

        let processTextView = ((complaintTextViews[0] as! TextAreaRow).cell as TextAreaCell).textView
        let resultTextView = ((complaintTextViews[1] as! TextAreaRow).cell as TextAreaCell).textView
        let suggestTextView = ((complaintTextViews[2] as! TextAreaRow).cell as TextAreaCell).textView
        
        var placeHolder = "处理过程"
        
        if (textView == processTextView) {
            placeHolder = "处理过程"
            
            setCellValue(cell: processCell, content: resultModel.HandleProcess ?? "", index: 0, changeProcess: true, placeHolder: placeHolder, textView: textView)
            
        }else if (textView == resultTextView) {
            placeHolder = "处理结果"
            
            setCellValue(cell: resultCell, content: resultModel.HandleResult ?? "", index: 1, changeProcess: true, placeHolder: placeHolder, textView: textView)
            
            
        }else if (textView == suggestTextView) {
            placeHolder = "客户意见"
            
            setCellValue(cell: suggestCell, content: resultModel.CustomerMemo ?? "", index: 2, changeProcess: true, placeHolder: placeHolder, textView: textView)
            
        }else if (textView == (textAreaRow.cell as TextAreaCell).textView) {
            placeHolder = "回访处理"
            
            setCellValue(cell: callBackDealCell, content: textView.text, index: -1, changeProcess: true, placeHolder: placeHolder, textView: textView)
        }
        
    }
    
    //MARK: showActionSheet
    
    override func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        if (tag.compare("Category") == .orderedSame) {
            if (buttonIndex == 1) {
                self.resultModel.ComplaintNature = "严重"
            }else if (buttonIndex == 2){
                self.resultModel.ComplaintNature = "一般"
            }else {
                
            }
        }
        
        self.tableView?.reloadData()
    }
    
    @objc func commitData(type: NSString) {
        
        if (type.compare("0") == .orderedSame) {
            
        }else {
            
        }
        
    }
    
    func setCellValue(cell: ComplaintHandleContentInputTableViewCell, content: String, index: NSInteger, changeProcess: Bool, placeHolder: String, textView: UITextView) {
        
        cell.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: processCell,content: content) + "字"
        
        if (index == -1) {

            if (textView.text.compare("") == .orderedSame) {
                self.textAreaRow.cell.placeholderLabel?.text = placeHolder
            }else {
                self.textAreaRow.cell.placeholderLabel?.text = ""
            }
            
        }else {
            let textAreaRow = (complaintTextViews[index] as! TextAreaRow)
            if (textView.text.compare("") == .orderedSame) {
                textAreaRow.cell.placeholderLabel?.text = placeHolder
            }else {
                textAreaRow.cell.placeholderLabel?.text = ""
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
    }
}
