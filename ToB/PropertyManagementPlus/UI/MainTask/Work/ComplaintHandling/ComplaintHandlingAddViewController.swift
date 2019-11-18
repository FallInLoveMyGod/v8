//
//  ComplaintHandlingAddViewController.swift
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

class ComplaintHandlingAddViewController: FormBaseTableViewController,CustomerInfoDelegate,ColleagueDetailDelegate,UITextFieldDelegate,UIActionSheetDelegate,RepairChooseSenderResultDelegate,DatePickerDelegate,UITextViewDelegate{

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    //是否是首页
    var isHomePage = false
    
    var textAreaRow = TextAreaRow("")
    
    var addComplaintFormModel: AddComplaintFormModel = AddComplaintFormModel()
    
    //联系单转投诉单
    var contentModel: SearchContactFormModel?
    
    var selectIndex = 0
    
    var complainantTypeSourceArray = NSMutableArray(capacity: 20)
    var waySourceArray = NSMutableArray(capacity: 20)
    
    var complainantTypeArray = NSMutableArray(capacity: 20)
    var wayArray = NSMutableArray(capacity: 20)
    
    var getRepaireListModel: GetRepaireListModel?
    
    var yhItems = ["YhPsCode":"","YhHouseNo":""]
    
    var chooseTypeName = ["客服_投诉_投诉类型","客服_投诉_投诉方式"]
    
    //tag
    let objectTag = 1111
    let linkTag = 1112
    let complaintLinkTag = 1113
    let customerNameTag = 1114
    let complaintContentTag = 1115
    let bComplaintPersonTag = 1116
    
    //投诉内容标签
    var complaintHandleContentCell: ComplaintHandleContentInputTableViewCell? = ComplaintHandleContentInputTableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        if (self.contentModel != nil) {
            self.setTitleView(titles: ["联系单转投诉单"])
        }else {
            if (self.addComplaintFormModel.BillCode?.compare("") != .orderedSame) {
                self.setTitleView(titles: ["处理投诉单"])
            }else {
                self.setTitleView(titles: ["新增投诉单"])
            }
            
        }
        addComplaintFormModel.YhItems = yhItems
        
        self.loadForm()
        
        self.tableView?.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kTabBarHeight)
        
        loadLocalData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buttonAction(titles: ["返回","提交"], actions: [#selector(pop),#selector(commit)], target: self)
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
        
        textAreaRow = TextAreaRow("投诉内容") {
            $0.placeholder = "投诉内容"
            $0.textAreaHeight = .dynamic(initialTextViewHeight: 80)
        }.cellUpdate({ (cell, row) in
            if (self.addComplaintFormModel.Content?.compare("") == .orderedSame) {
                cell.placeholderLabel?.text = "投诉内容"
            }else {
                cell.placeholderLabel?.text = ""
                cell.textView.text = self.addComplaintFormModel.Content
            }
            cell.textView.isScrollEnabled = true
            cell.textView.delegate = self
            cell.textView.tag = self.complaintContentTag
            
        })
        
        let contentSection = setSelfSection(title: "", headerHeight: 0.001, footerHeight: 0.001)
        
        form = setSelfSection(title: "投诉人信息", headerHeight: 35, footerHeight: 0.001)
            <<< ComplaintHandlingAddLabelImageTableViewRow(){
                
                let tempCell = $0.cell as ComplaintHandlingAddLabelImageTableViewCell
                tempCell.nameLabel.text = "投诉人地址"
                
            }.cellUpdate({ (cell, row) in
                if (self.contentModel != nil) {
                    cell.iconImageView.isHidden = true
                }
                cell.contentLabel.text = self.addComplaintFormModel.Location
            })
            <<< ComplaintHandlingAddLabelTableViewRow(){
                
                let tempCell = $0.cell as ComplaintHandlingAddLabelTableViewCell
                tempCell.singleShowLabel.text = "投诉人"
                
            }.cellUpdate({ (cell, row) in
                cell.singleShowContentLabel.text = self.addComplaintFormModel.Complainant
            })
            <<< ComplaintHandleAddTextFiledTableViewRow(){
                
                let tempCell = $0.cell as ComplaintHandleAddTextFiledTableViewCell
                tempCell.singleTextFiledNameLabel.text = "业户名称"
                tempCell.singleTextFiled.tag = self.customerNameTag
                tempCell.singleTextFiled.delegate = self
                
            }.cellUpdate({ (cell, row) in
                if (self.contentModel != nil) {
                    cell.singleTextFiled.isUserInteractionEnabled = false
                    cell.singleTextFiled.text = self.contentModel?.contactName
                }else{
                    cell.singleTextFiled.text = self.addComplaintFormModel.Complainant
//                    cell.singleTextFiled.text = self.addComplaintFormModel.ComplainantHouseName
                }
                
            })
            <<< ComplaintHandleAddTextFiledTableViewRow(){
                
                let tempCell = $0.cell as ComplaintHandleAddTextFiledTableViewCell
                tempCell.singleTextFiledNameLabel.text = "联系方式"
                tempCell.singleTextFiled.tag = self.complaintLinkTag
                tempCell.singleTextFiled.delegate = self
                
            }.cellUpdate({ (cell, row) in
                if (self.contentModel != nil) {
                    cell.singleTextFiled.isUserInteractionEnabled = false
                }
                cell.singleTextFiled.text = self.addComplaintFormModel.ComplainantTel
            })
            +++ setSelfSection(title: "被投诉信息", headerHeight: 35, footerHeight: 0.001)
            <<< ComplaintHandlingAddLabelImageTableViewRow(){
                
                let tempCell = $0.cell as ComplaintHandlingAddLabelImageTableViewCell
                tempCell.nameLabel.text = "类型"
                
            }.cellUpdate({ (cell, row) in
                
                if (self.addComplaintFormModel.RespondentType?.compare("") == .orderedSame) {
                    
                }else if (self.addComplaintFormModel.RespondentType?.compare("0") == .orderedSame) {
                    cell.contentLabel.text = "业户"
                }else if (self.addComplaintFormModel.RespondentType?.compare("1") == .orderedSame) {
                    cell.contentLabel.text = "员工"
                }else if (self.addComplaintFormModel.RespondentType?.compare("2") == .orderedSame) {
                    cell.contentLabel.text = "其他"
                }
                
            })
            <<< ComplaintHandlingAddLabelImageTableViewRow(){
                
                let tempCell = $0.cell as ComplaintHandlingAddLabelImageTableViewCell
                tempCell.nameLabel.text = "被投诉人"
                
            }.cellUpdate({ (cell, row) in
                
                cell.contentLabel.text = self.addComplaintFormModel.uname
                
                if (self.addComplaintFormModel.RespondentType?.compare("2") == .orderedSame){
                    cell.contentLabel.text = ""
                    cell.iconImageView.isHidden = true
                    cell.contentLabel.isUserInteractionEnabled = true
                    
                    if (cell.contentLabel.viewWithTag(self.bComplaintPersonTag) == nil) {
                        let textField = UITextField(frame: cell.contentLabel.bounds)
                        textField.delegate = self
                        textField.tag = self.bComplaintPersonTag
                        cell.contentLabel.addSubview(textField)
                    }
                    
                }else {
                    cell.contentLabel.isUserInteractionEnabled = false
                    (cell.contentLabel.viewWithTag(self.bComplaintPersonTag))?.removeFromSuperview()
                }
            })
            <<< ComplaintHandleAddTextFiledTableViewRow(){
                let tempCell = $0.cell as ComplaintHandleAddTextFiledTableViewCell
                tempCell.singleTextFiledNameLabel.text = "联系方式"
                tempCell.singleTextFiled.tag = self.linkTag
                tempCell.singleTextFiled.delegate = self
            }.cellUpdate({ (cell, row) in
                cell.singleTextFiled.text = self.addComplaintFormModel.RespondentTel
            })
            +++ setSelfSection(title: "投诉信息", headerHeight: 35, footerHeight: 0.001)
            <<< ComplaintHandlingAddLabelImageTableViewRow(){
                let tempCell = $0.cell as ComplaintHandlingAddLabelImageTableViewCell
                tempCell.nameLabel.text = "投诉类别"
            }.cellUpdate({ (cell, row) in
                cell.contentLabel.text = self.addComplaintFormModel.ComplainantType
            })
            <<< ComplaintHandlingAddTextFiledImageTableViewRow(){
                let tempCell = $0.cell as ComplaintHandlingAddTextFiledImageTableViewCell
                tempCell.textFiledImageNameLabel.text = "投诉方式"
            }.cellUpdate({ (cell, row) in
                cell.textFiledImageTextFiled.text = self.addComplaintFormModel.Way
            })
            <<< ComplaintHandlingAddLabelTableViewRow(){
                let tempCell = $0.cell as ComplaintHandlingAddLabelTableViewCell
                tempCell.singleShowLabel.text = "要求期限"
                //tempCell.singleTextFiled.inputView = datePicker
            }.cellUpdate({ (cell, row) in
                    cell.singleShowContentLabel.text = self.addComplaintFormModel.DateLimit
            })
            
            <<< ComplaintHandleAddTextFiledTableViewRow(){
                let tempCell = $0.cell as ComplaintHandleAddTextFiledTableViewCell
                tempCell.singleTextFiledNameLabel.text = "投诉主题"
                tempCell.singleTextFiled.tag = self.objectTag
                tempCell.singleTextFiled.delegate = self
            }.cellUpdate({ (cell, row) in
                cell.singleTextFiled.text = self.addComplaintFormModel.Title
            })
            
        
            +++ contentSection
            <<< textAreaRow
            <<< ComplaintHandleContentInputTableViewRow() {
                
                let tempCell = $0.cell as ComplaintHandleContentInputTableViewCell
                tempCell.nameLabel.text = "投诉内容"
                
            }.cellUpdate({ (cell, row) in
                self.complaintHandleContentCell = cell
            })
            
            +++ setSelfSection(title: "", headerHeight: 10, footerHeight: 0.001)
            <<< ComplaintHandlingAddLabelImageTableViewRow(){
                let tempCell = $0.cell as ComplaintHandlingAddLabelImageTableViewCell
                tempCell.nameLabel.text = "是否立项"
            }.cellUpdate({ (cell, row) in
                
                if (self.addComplaintFormModel.IsCreateProj != nil && self.addComplaintFormModel.IsCreateProj?.compare("") != .orderedSame) {
                    cell.contentLabel.text = (self.addComplaintFormModel.IsCreateProj?.compare("1") == .orderedSame ? "是":"否")
                }else {
                    cell.contentLabel.text = ""
                }
                
            })
        +++ Section()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.view.endEditing(true)
        
        if (indexPath.section == 1) {
            
            if (indexPath.row == 0) {

                showActionSheet(title: "选择投诉类型", cancelTitle: "取消", titles: ["业户","员工","其他"], tag: "Type")
                
            }else if (indexPath.row == 1) {
                
                if (addComplaintFormModel.RespondentType?.compare("") == .orderedSame) {
                    LocalToastView.toast(text: "没有选择被投诉类型")
                    return
                }
                
                selectIndex = indexPath.section
                
                if (addComplaintFormModel.RespondentType?.compare("0") == .orderedSame) {
                    //业户
                    
                    let customerInfoVC = CustomerInfoViewController()
                    customerInfoVC.isTopLevelShow = true
                    customerInfoVC.delegate = self
                    self.navigationController?.pushViewController(customerInfoVC, animated: true)
                    
                }else if (addComplaintFormModel.RespondentType?.compare("1") == .orderedSame) {
                    //员工
                    
                    let customerInfoVC = ColleagueDetailViewController()
                    customerInfoVC.isTopLevelShow = true
                    customerInfoVC.delegate = self
                    self.navigationController?.pushViewController(customerInfoVC, animated: true)
                    
                }else {
                    //更换UI
                }
                
            }
            
            
            
        }else if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                
                if (self.contentModel != nil) {
                    return
                }
                
                selectIndex = indexPath.section
                
                let customerInfoVC = CustomerInfoViewController()
                customerInfoVC.isTopLevelShow = true
                customerInfoVC.delegate = self
                self.navigationController?.pushViewController(customerInfoVC, animated: true)
            }
            
        }else if (indexPath.section == 2) {
            
            if (indexPath.row == 0) {
                showActionSheet(title: "选择投诉类别", cancelTitle: "取消", titles: (complainantTypeArray as NSArray) as! [Any], tag: "ComplainantType")
            }else if (indexPath.row == 1) {
                showActionSheet(title: "选择投诉方式", cancelTitle: "取消", titles: (wayArray as NSArray) as! [Any], tag: "Way")
            }else if (indexPath.row == 2) {
                
                let dateStr = addComplaintFormModel.DateLimit?.components(separatedBy: "T").joined(separator: " ")
                
                let lSDatePicker = LSDatePicker(frame: self.view.bounds, array: ["年","月","日","时","分","秒"], scrollDate: dateStr)
                lSDatePicker?.delegate = self
                lSDatePicker?.setHintsText("选择日期/时间")
                lSDatePicker?.showView(inSelect: self.view)
            }
            
        }
        else if (indexPath.section == 4) {

            showActionSheet(title: "是否立项", cancelTitle: "取消", titles: ["是","否"], tag: "Support")
        }
        
    }
    
    func setSelfSection(title: String, headerHeight: CGFloat , footerHeight: CGFloat) -> Section {
        let section = Section(header: title, footer: "")
        section.header?.height = { return headerHeight }
        section.footer?.height = { return footerHeight }
        
        return section
    }
    
    //MARK: CustomerInfoDelegate
    
    func confirmWithObject(object: AnyObject) {
        
        //GetContactsDataModel
        //HouseStructureModel
        
        if (object.isKind(of: GetContactsDataModel.self)) {
            //联系人model
            let getContactsDataModel = object as? GetContactsDataModel
            addComplaintFormModel.ComplainantTel = getContactsDataModel?.MobileNum
            addComplaintFormModel.Complainant = getContactsDataModel?.Name
            addComplaintFormModel.ComplainantHouseNo = getContactsDataModel?.Code
            
            if (selectIndex == 1) {
                addComplaintFormModel.uname = getContactsDataModel?.Name
                addComplaintFormModel.RespondentTel = getContactsDataModel?.MobileNum
            }
            
        }else {
            
        }
        
        self.tableView?.reloadData()
    }
    
    func confirmWithAddress(address: NSString, pcode: NSString, bcode: NSString, fname: NSString, rcode: NSString, ownerCode: NSString) {
        
        if (selectIndex == 0) {
            addComplaintFormModel.Location = address as String
            addComplaintFormModel.ComplainantPsCode = rcode as String
            addComplaintFormModel.ComplainantHouseNo = ownerCode as String
            self.tableView?.reloadData()
        }else {
            yhItems["YhPsCode"] = rcode as String
            yhItems["YhHouseNo"] = ownerCode as String
            addComplaintFormModel.YhItems = yhItems
        }
        
    }
    
    //MARK: ColleagueDetailDelegate
    
    func colleagueconfirmWithObject(object: AnyObject) {
        let person = object as! WorkerDataModel
        addComplaintFormModel.uname = person.workername
        addComplaintFormModel.RespondentTel = person.tellphone
        addComplaintFormModel.uid = person.workerid
        
        self.tableView?.reloadData()
    }
    
    //MARK: DatePickerDelegate
    
    func cancelButtonClick() {
        
    }
    
    func resetButtonClick(withDataPicker picker: LSDatePicker!) {
        addComplaintFormModel.DateLimit = ""
        self.tableView?.reloadData()
    }
    
    func datePickerDelegateEnterAction(withDataPicker picker: LSDatePicker!) {
        
        let value = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue) + " " + String(picker.hourValue) + ":" + String(picker.minuteValue) + ":" + String(picker.secondValue)
        
        addComplaintFormModel.DateLimit = value
        addComplaintFormModel.CreateDate = value
        
        self.tableView?.reloadData()
        
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.tag == objectTag) {
            addComplaintFormModel.Title = textField.text
        }else if (textField.tag == linkTag) {
            addComplaintFormModel.RespondentTel = textField.text
        }else if (textField.tag == complaintLinkTag) {
            addComplaintFormModel.ComplainantTel = textField.text
        }else if (textField.tag == customerNameTag) {
            addComplaintFormModel.Complainant = textField.text
        }else if (textField.tag == bComplaintPersonTag) {
            self.addComplaintFormModel.uname = textField.text
        }
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.tag == complaintContentTag) {
            
            addComplaintFormModel.Content = textView.text
            textAreaRow.placeholder = ""
            
            complaintHandleContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: complaintHandleContentCell!,content: self.addComplaintFormModel.Content!) + "字"
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if (textView.tag == complaintContentTag) {
            if (textView.text.compare("") == .orderedSame) {
                textAreaRow.cell.placeholderLabel?.text = "投诉内容"
            }else {
                textAreaRow.cell.placeholderLabel?.text = ""
            }
            
            complaintHandleContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: complaintHandleContentCell!,content: self.addComplaintFormModel.Content!) + "字"
        }
        
    }
    
    // MARK: RepairChooseSenderResultDelegate
    
    func popAction(_ result: String!, message: String!) {
        
        if (isHomePage) {
            popToRoot()
            return
        }
        
        if (result.compare("fail") == .orderedSame) {
            LocalToastView.toast(text: message)
        }else {
            NotificationCenter.default.post(name: kNotificationCenterFreshComplaintList as NSNotification.Name, object: nil)
        }
        
        if (contentModel != nil) {
            popToLinksHome()
        }else {
            super.pop()
        }
        
    }
    
    func changeState(_ state: String!, pk: String!) {
        //更新状态
        
        if (state.compare("NoDeal") == .orderedSame) {
            self.addComplaintFormModel.deleteObject()
            NotificationCenter.default.post(name: kNotificationCenterFreshComplaintList as NSNotification.Name, object: nil)
            
            if (isHomePage) {
                popToRoot()
                return
            }
            
            if (contentModel != nil) {
                popToLinksHome()
            }else{
                super.pop()
            }
        }
        
    }
    
    //MARK: ActionSheetDelegate
    
    override func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            if (tag.compare("SendStyle") == .orderedSame) {
                self.addComplaintFormModel.Category = "NoSend"
                return
            }
            return
        }
        
        if (tag.compare("Type") == .orderedSame) {
            
            switch buttonIndex {
            case 0:
                addComplaintFormModel.RespondentType = ""
            case 1:
                addComplaintFormModel.RespondentType = "0"
            case 2:
                addComplaintFormModel.RespondentType = "1"
            case 3:
                addComplaintFormModel.RespondentType = "2"
            default:
                break;
            }
            
        }else if (tag.compare("ComplainantType") == .orderedSame) {
            if (buttonIndex == 0) {
                
            }else {
                
                let model = self.complainantTypeSourceArray[buttonIndex - 1] as! GetDictionaryInfosModel
                
                addComplaintFormModel.ComplainantType = model.Content
                addComplaintFormModel.ComplainantTypeId = model.Id
            }
        }else if (tag.compare("Way") == .orderedSame) {
            if (buttonIndex == 0) {
                
            }else {
                
                let model = self.waySourceArray[buttonIndex - 1] as! GetDictionaryInfosModel
                
                addComplaintFormModel.Way = model.Content
                addComplaintFormModel.WayId = model.Id
                
            }
        }else if (tag.compare("Support") == .orderedSame) {
            if (buttonIndex == 0) {
                
            }else {
                if (buttonIndex == 1) {
                    addComplaintFormModel.IsCreateProj = "1"
                }else {
                    addComplaintFormModel.IsCreateProj = "0"
                }
            }
        }else if (tag.compare("SendStyle") == .orderedSame) {
            
            self.settedActionSheet(actionSheet, tag: "SendStyle", clickedButtonAt: 0)
            return
        }
        
        self.tableView?.reloadData()
    }
    
    func settedActionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
        let choose = RepairChooseSenderViewController()
        choose.delegate = self
        choose.pk = String(self.addComplaintFormModel.pk)
        choose.billCode = self.addComplaintFormModel.BillCode
        choose.accountCode = loginInfo?.accountCode ?? ""
        choose.upk = userInfo?.upk ?? ""
        choose.baseUrl = LocalStoreData.getPMSAddress().PMSAddress
        choose.chooseType = "1"
        
        if (LocalStoreData.getIsRepairOn()?.compare("YES") == .orderedSame) {
            choose.lineState = "0"
        }else {
            choose.lineState = "1"
        }
        
        self.navigationController?.pushViewController(choose, animated: true)
    }
    
    //提交
    @objc func commit() {
        
        if (self.addComplaintFormModel.IsCreateProj == nil
            || self.addComplaintFormModel.IsCreateProj?.compare("") == .orderedSame) {
            LocalToastView.toast(text: "未选择是否立项")
            return
        }
        
        if (self.addComplaintFormModel.RespondentType == nil
            || self.addComplaintFormModel.RespondentType?.compare("") == .orderedSame) {
            LocalToastView.toast(text: "被投诉类型未选择")
            return
        }
        
        if (self.addComplaintFormModel.ComplainantType == nil
            || self.addComplaintFormModel.ComplainantType?.compare("") == .orderedSame) {
            LocalToastView.toast(text: "没有选择投诉类别")
            return
        }
        
        if (self.addComplaintFormModel.Way == nil
            || self.addComplaintFormModel.Way?.compare("") == .orderedSame) {
            LocalToastView.toast(text: "投诉方式不可为空")
            return
        }
        
        let textView = (textAreaRow.cell as TextAreaCell).textView
        addComplaintFormModel.Content = textView?.text
        
        let tips = NSMutableArray(capacity: 20)
        
        if (addComplaintFormModel.Location == nil || addComplaintFormModel.Location?.compare("") == .orderedSame) {
            //处理责任人
            tips.add("投诉人地址")
        }
        if (addComplaintFormModel.ComplainantTel?.compare("") == .orderedSame) {
            tips.add("投诉人联系电话")
        }
        if (addComplaintFormModel.uname?.compare("") == .orderedSame) {
            tips.add("被投诉人")
        }
        if (addComplaintFormModel.RespondentTel?.compare("") == .orderedSame) {
            tips.add("被投诉人联系方式")
        }
        
        if (addComplaintFormModel.DateLimit?.compare("") == .orderedSame) {
            tips.add("要求期限")
        }
        if (addComplaintFormModel.Title?.compare("") == .orderedSame) {
            tips.add("投诉主题")
        }
        if (addComplaintFormModel.Content?.compare("") == .orderedSame) {
            tips.add("投诉内容")
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
            
            showAlertChoose(title: "提示", message: tipString as NSString, placeHolder: "", titles: ["确认","返回"], selector: #selector(ComplaintHandlingAddViewController.commitTip(type:)), target: self)
            
            return;
            
        }
        
        if (self.addComplaintFormModel.BillCode?.compare("") != .orderedSame) {
            dealComplaintList()
        }else {
            commitBaseInfo()
        }
        
        
    }
    
    func dealComplaintList() {
        
//        let action: UIActionSheet = UIActionSheet(title: "选择派送人类型", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "在线","全部")
//        action.show(in: self.view);
        
        //showActionSheet(title: "选择派送人类型", cancelTitle: "取消", titles: ["在线","全部"], tag: "SendStyle")
        self.settedActionSheet(nil, tag: "SendStyle", clickedButtonAt: 0)
    }
    
    func commitBaseInfo() {
        
        addComplaintFormModel.out_trade_no = GUIDGenarate.stringWithUUID()
        
        let json = addComplaintFormModel.yy_modelToJSONString()
        
        let data = json?.data(using: .utf8)
        let dictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        
        let changeDict = NSMutableDictionary(dictionary: dictionary!)
        
        let object = NSMutableArray(object: changeDict)
        
        let parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","Infos":object.yy_modelToJSONString() ?? ""] as [String : Any]
        
        
        LoadView.storeLabelText = "正在提交投诉单信息"
        
        let addComplaintFormAPICmd = AddComplaintFormAPICmd()
        addComplaintFormAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        addComplaintFormAPICmd.parameters = NSMutableDictionary(dictionary: parameters as NSDictionary)
        addComplaintFormAPICmd.loadView = LoadView()
        addComplaintFormAPICmd.loadParentView = self.view
        addComplaintFormAPICmd.transactionWithSuccess({ (response) in
            
            let dict = JSON(response)
            
            //print(dict)
            
            let resultStatus = dict["result"].string
            
            if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                //成功
                
                if (self.addComplaintFormModel.IsCreateProj?.compare("1") == .orderedSame) {
                    //是立项
                    
                    self.addComplaintFormModel.BillCode = dict["infos"][0]["ServerPK"].string!
                    self.addComplaintFormModel.Category = "NoSend"
                    self.addComplaintFormModel.save()
                    
//                    let action: UIActionSheet = UIActionSheet(title: "选择派送人类型", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "在线","全部")
//                    action.show(in: self.view);
                    
                    //self.showActionSheet(title: "选择派送人类型", cancelTitle: "取消", titles: ["在线","全部"], tag: "SendStyle")
                    self.settedActionSheet(nil, tag: "SendStyle", clickedButtonAt: 0)
                    
                    
                }else {
                    self.pop()
                }
                
            }else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
    }
    
    //MARK: UIActionSheetDelegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            self.addComplaintFormModel.Category = "NoSend"
            return
        }
        
        let choose = RepairChooseSenderViewController()
        choose.delegate = self
        choose.pk = String(self.addComplaintFormModel.pk)
        choose.billCode = self.addComplaintFormModel.BillCode
        choose.accountCode = loginInfo?.accountCode ?? ""
        choose.upk = userInfo?.upk ?? ""
        choose.baseUrl = LocalStoreData.getPMSAddress().PMSAddress
        choose.chooseType = "1"
        if (buttonIndex == 1) {
            choose.lineState = "1"
        }else {
            choose.lineState = "0"
        }
        
        self.navigationController?.pushViewController(choose, animated: true)
        
    }
    
    @objc func commitTip(type: NSString) {
        
        if (type.compare("0") == .orderedSame) {
            //确认
            
            if (self.addComplaintFormModel.BillCode?.compare("") != .orderedSame) {
                dealComplaintList()
            }else {
                commitBaseInfo()
            }
            
        }else {
            //
        }
        
    }
    
    func loadLocalData() {
        
        for model in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '客服_投诉_投诉方式'") {
            
            let getDictionaryInfosModel:GetDictionaryInfosModel = model as! GetDictionaryInfosModel
            self.waySourceArray.add(getDictionaryInfosModel)
            self.wayArray.add(getDictionaryInfosModel.Content ?? "")
        }
        
        for model in GetDictionaryInfosModel.find(byCriteria:  " WHERE Type = '客服_投诉_投诉类型'") {
            
            let getDictionaryInfosModel:GetDictionaryInfosModel = model as! GetDictionaryInfosModel
            self.complainantTypeSourceArray.add(getDictionaryInfosModel)
            self.complainantTypeArray.add(getDictionaryInfosModel.Content ?? "")
        }
        
    }
    
    override func pop() {
        if (contentModel != nil) {
            NotificationCenter.default.post(name: kNotificationCenterFreshTurnComplaintList as NSNotification.Name, object: nil)
        }
        if (isHomePage) {
            popToRoot()
            return
        }
        super.pop()
    }
}
