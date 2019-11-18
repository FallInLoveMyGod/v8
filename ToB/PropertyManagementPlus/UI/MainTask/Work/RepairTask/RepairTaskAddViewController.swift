//
//  RepairTaskAddViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/27.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
//import HandyJSON
import Alamofire
import Eureka

class RepairTaskAddViewController: FormBaseTableViewController,SelectImageShowViewDelegate,CustomerInfoDelegate,RepairChooseSenderResultDelegate,UITextViewDelegate,DatePickerDelegate,UITextFieldDelegate,LVRecordViewDelegate {

    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var isModify = false
    
    var getContactsDataModel: GetContactsDataModel?
    var houseStructureModel: HouseStructureModel?
    
    var isHomePage = false
    //新建维修
    var createRepareBillModel: GetRepaireListModel? = GetRepaireListModel()
    
    var newGetRepaireListModel: GetRepaireListModel = GetRepaireListModel()
    
    var rangeTextAreaRow: ComplaintHandlingAddLabelImageTableViewRow!
    var typeTextAreaRow: ComplaintHandlingAddLabelImageTableViewRow!
    
    var textAreaRow = TextAreaRow("")
    let selectImageShowView = SelectImageShowView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 95.0))
    
    var actionSheetNext: UIActionSheet!
//    var checkTypeArray = ["选择派单人","选择派单人+离线","选择维修人","选择维修人+离线","发起抢单","发起抢单+离线"]
    var checkTypeArray = ["选择派单人","选择维修人","发起抢单"]
    
    var billCode = ""
    var auto = ""
    
    var isTextCommit: Bool = false
    var isMaterialCommit: Bool = false
    var isRecordCommit:Bool = false
    
    var localButtonIndex = 0
    
    let personTag = 1111
    let linkTag = 1112
    
    //报修内容标签
    var repairContentCell: ComplaintHandleContentInputTableViewCell? = ComplaintHandleContentInputTableViewCell()
    
    //录音视图
    var recordView: LVRecordView?
    //录音文件
    var recordData: NSData?
    
    //控制提交操作
    var commitActionSelect = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(UIApplication.shared.keyWindow)
        
        self.view.backgroundColor = UIColor.white
        
        if (isModify) {
            self.setTitleView(titles: ["修改维修单"])
        }else {
            self.setTitleView(titles: ["新增维修"])
        }
        
        if (!isModify) {
            
            let range = UserDefaults.standard.object(forKey: "Range")
            
            createRepareBillModel?.Range = "客户区域"
            
            if (range != nil) {
                createRepareBillModel?.Range = range as! String?
            }
            createRepareBillModel?.Type = "有偿维修"
        }else {
            if (createRepareBillModel?.IsTextCommit?.compare("1") == .orderedSame) {
                isTextCommit = true
            }
            
            selectImageShowView.allowDealWithPhoto = true
            
            if (createRepareBillModel?.IsMaterialCommit?.compare("1") == .orderedSame) {
                isMaterialCommit = true
                selectImageShowView.allowDealWithPhoto = false
            }
        }
        
        self.loadForm()
        
        self.tableView?.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kTabBarHeight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if navigationController?.navigationBar.subviews.count != 0 {
            navigationController?.navigationBar.subviews[0].isHidden = false
        }
        navigationController?.navigationBar.barTintColor = kThemeColor
        
        if (isModify) {
            buttonAction(titles: ["返回","提交"], actions: [#selector(pop),#selector(saveAction(isPop:))], target: self)
        }else {
            buttonAction(titles: ["返回","保存"], actions: [#selector(pop),#selector(saveAction(isPop:))], target: self)
        }
        
        
        self.tableView?.sectionFooterHeight = 0.001
        self.tableView?.sectionHeaderHeight = 0.001
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    deinit {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private interface
    
    fileprivate func loadForm() {
        
//        let datePicker = UUDatePicker(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 250), delegate: self, pickerStyle: DateStyle(rawValue: 0))
//        datePicker?.delegate = self
//        datePicker?.scrollToDate = NSDate() as Date!
        
        let sectionNormalLine = setSelfSection(title: "", headerHeight: 10, footerHeight: 0.001)
        
        rangeTextAreaRow = ComplaintHandlingAddLabelImageTableViewRow("range"){
            
            let tempCell = $0.cell as ComplaintHandlingAddLabelImageTableViewCell
            tempCell.nameLabel.text = "维修范围"
            
            }.cellUpdate({ (cell, row) in
                cell.contentLabel.text = self.createRepareBillModel?.Range
        })
        
        typeTextAreaRow = ComplaintHandlingAddLabelImageTableViewRow(){
            
            let tempCell = $0.cell as ComplaintHandlingAddLabelImageTableViewCell
            tempCell.nameLabel.text = "维修类型"
            
            }.cellUpdate({ (cell, row) in
                cell.contentLabel.text = self.createRepareBillModel?.Type
            })
        
        let functionRange = Condition.function(["range"], { form -> Bool in
            
            //let subCell = (form.rowBy(tag: "range") as? ComplaintHandlingAddLabelImageTableViewRow)?.cell
            
            if (self.createRepareBillModel?.Range?.compare("公共区域") == .orderedSame) {
                return true
            }
            
            return false
        })
        
        sectionNormalLine
            <<< rangeTextAreaRow
            <<< typeTextAreaRow
            <<< ComplaintHandlingAddLabelImageTableViewRow(){
                
                let tempCell = $0.cell as ComplaintHandlingAddLabelImageTableViewCell
                tempCell.nameLabel.text = "报修地址"

            }.cellUpdate({ (cell, row) in
                
                cell.contentLabel.text = self.createRepareBillModel?.Location
            })
            <<< ComplaintHandleAddTextFiledTableViewRow(){
                
                $0.hidden = functionRange
                
                let tempCell = $0.cell as ComplaintHandleAddTextFiledTableViewCell
                tempCell.singleTextFiledNameLabel.text = "报修人"
                tempCell.singleTextFiled.tag = personTag
                tempCell.singleTextFiled.delegate = self
                
            }.cellUpdate({ (cell, row) in
                
                cell.singleTextFiled.text = self.createRepareBillModel?.Proposer
                
            })
            <<< ComplaintHandleAddTextFiledTableViewRow(){
                
                $0.hidden = functionRange
                
                let tempCell = $0.cell as ComplaintHandleAddTextFiledTableViewCell
                tempCell.singleTextFiledNameLabel.text = "联系电话"
                tempCell.singleTextFiled.tag = linkTag
                tempCell.singleTextFiled.delegate = self
                
            }.cellUpdate({ (cell, row) in
                cell.singleTextFiled.text = self.createRepareBillModel?.TelNum
            })
            <<< ComplaintHandlingAddLabelTableViewRow(){
                
                let tempCell = $0.cell as ComplaintHandlingAddLabelTableViewCell
                tempCell.singleShowLabel.text = "预约维修时间"
                //tempCell.singleTextFiled.inputView = datePicker
                
            }.cellUpdate({ (cell, row) in
                cell.singleShowContentLabel.text = self.createRepareBillModel?.SubscribeTime
            })
        
        form.append(sectionNormalLine)
        
        textAreaRow = TextAreaRow("报修内容") {
 
            $0.textAreaHeight = .dynamic(initialTextViewHeight: 80)
        }.cellUpdate({ (cell, row) in
            
            if (self.createRepareBillModel?.Content?.compare("") == .orderedSame) {
                cell.placeholderLabel?.text = "报修内容"
            }else {
                cell.placeholderLabel?.text = ""
                cell.textView.text = self.createRepareBillModel?.Content
            }
            cell.textView.isScrollEnabled = true
            cell.textView.delegate = self
            cell.textView.tag = 1113
            
            if (self.isModify && self.isTextCommit) {
                //如果文本提交，则不允许修改
                cell.textView.isUserInteractionEnabled = false
            }
            
        })
        
        let contentSection = setSelfSection(title: "", headerHeight: 0.001, footerHeight: 0.001)
        
        contentSection
            <<< textAreaRow
            <<< ComplaintHandleContentInputTableViewRow() {
                
                let tempCell = $0.cell as ComplaintHandleContentInputTableViewCell
                tempCell.nameLabel.text = "报修内容"
        }.cellUpdate({ (cell, row) in
            self.repairContentCell = cell
        })
        
        form.append(contentSection)
        
        let noOverSection = setSelfSection(title: "", headerHeight: 10, footerHeight: 0.001)
        
        
        noOverSection
            <<< TakePhotoTableViewRow(){
                let tempCell = $0.cell as TakePhotoTableViewCell
                selectImageShowView.delegate = self
                tempCell.contentView.addSubview(selectImageShowView)
        }.cellUpdate({ (cell, row) in
            self.fetchLocalImages()
        })
        
        form.append(noOverSection)
        
        
        let audioSection = setSelfSection(title: "", headerHeight: 10, footerHeight: 0.001)
        
        
        let topView = Bundle.main.loadNibNamed("RecordRelateView", owner: self, options: nil)?.first as! RecordRelateView
        topView.isUserInteractionEnabled = true
        
        let view = Bundle.main.loadNibNamed("LVRecordView", owner: self, options: nil)?.first as! LVRecordView
        view.setup()
        view.relateRelationShip(with: topView)
        
        recordView = view
        recordView?.delegate = self
        
        if (createRepareBillModel?.IsMaterialCommit?.compare("1") == .orderedSame) {
            
            topView.isUserInteractionEnabled = false
            recordView?.isUserInteractionEnabled = false
            
        }
        
        if (createRepareBillModel?.RecordName?.compare("") != .orderedSame) {
            //存在录音文件
            recordView?.fileName = createRepareBillModel?.RecordName
            topView.leadingImageView.image = UIImage(named: "icon_record_layout_nor")
            recordData = recordView?.recordData(withName: createRepareBillModel?.RecordName!) as NSData?
        }
        
        audioSection
            <<< AudioTableViewRow(){
                let tempCell = $0.cell as AudioTableViewCell
                
                topView.frame = CGRect(x: 0, y: 0, width: tempCell.frame.size.width, height: 40.0)
                
                tempCell.contentView.addSubview(topView)
                
                view.frame = CGRect(x: 0, y: topView.frame.size.height, width: tempCell.frame.size.width, height: 160.0)
                
                if (self.createRepareBillModel?.IsMaterialCommit?.compare("1") == .orderedSame) {
                    topView.closeImageView.isUserInteractionEnabled = false
                    view.isUserInteractionEnabled = false
                    
                }
                
                let lineView = UIView(frame: CGRect(x: 0, y: topView.frame.size.height - 0.5, width: kScreenWidth, height: 0.5))
                lineView.backgroundColor = UIColor.groupTableViewBackground
                tempCell.contentView.addSubview(lineView)
                tempCell.contentView.addSubview(view)
        }
        
        form.append(audioSection)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (isModify && isTextCommit) {
            //如果文本提交，则不允许修改
            return
        }
        
        if (indexPath.section != 0) {
            return
        }
        
        if (self.createRepareBillModel?.Range?.compare("公共区域") == .orderedSame) {
            
            if (indexPath.row == 3) {
                
                let dateStr = createRepareBillModel?.SubscribeTime?.components(separatedBy: "T").joined(separator: " ")
                
                let lSDatePicker = LSDatePicker(frame: self.view.bounds, array: ["年","月","日","时","分","秒"], scrollDate: dateStr)
                lSDatePicker?.delegate = self
                lSDatePicker?.setHintsText("选择日期/时间")
                lSDatePicker?.showView(inSelect: self.view)
                
                return;
            }
            
        }
        
        if (indexPath.row == 0) {

            showActionSheet(title: "选择维修范围", cancelTitle: "取消", titles: ["客户区域","公共区域"], tag: "Score")
        }else if (indexPath.row == 1) {

            showActionSheet(title: "选择维修类型", cancelTitle: "取消", titles: ["有偿维修","无偿维修"], tag: "Style")
        }else if (indexPath.row == 2) {
            //跳转
            
            let customerInfoVC = CustomerInfoViewController()
            customerInfoVC.isTopLevelShow = true
            customerInfoVC.range = createRepareBillModel?.Range
            if (createRepareBillModel?.Range?.compare("公共区域") == .orderedSame) {
                customerInfoVC.customerInfoType = .commonArea
            }else {
                customerInfoVC.customerInfoType = .customerArea;
            }
            customerInfoVC.delegate = self
            self.navigationController?.pushViewController(customerInfoVC, animated: true)
            
        }else if (indexPath.row == 5) {
            
            let dateStr = createRepareBillModel?.SubscribeTime?.components(separatedBy: "T").joined(separator: " ")
            
            let lSDatePicker = LSDatePicker(frame: self.view.bounds, array: ["年","月","日","时","分","秒"], scrollDate: dateStr)
            lSDatePicker?.delegate = self
            lSDatePicker?.setHintsText("选择日期/时间")
            lSDatePicker?.showView(inSelect: self.view)
            
        }
    }
    
    
    //MARK: CustomerInfoDelegate
    
    func confirmWithObject(object: AnyObject) {
        
        //GetContactsDataModel
        //HouseStructureModel
        
        if (object.isKind(of: GetContactsDataModel.self)) {
            //联系人model
            getContactsDataModel = object as? GetContactsDataModel
            
            createRepareBillModel?.Proposer = getContactsDataModel?.Name
            createRepareBillModel?.TelNum = getContactsDataModel?.MobileNum
            
        }else {
            houseStructureModel = object as? HouseStructureModel
        }
        
        self.tableView?.reloadData()
    }
    
    func confirmWithAddress(address: NSString, pcode: NSString, bcode: NSString, fname: NSString, rcode: NSString, ownerCode: NSString) {
        
        createRepareBillModel?.PProjectCode = pcode as String
        createRepareBillModel?.PBuildingCode = bcode as String
        createRepareBillModel?.PFloorName = fname as String
        createRepareBillModel?.PRoomCode = rcode as String
        createRepareBillModel?.PUnitIndex = "-1"
        createRepareBillModel?.Location = address as String
        
        self.tableView?.reloadData()
    }
    
    //MARK: UUDatePickerDelegate
    
//    func uuDatePicker(_ datePicker: UUDatePicker!, year: String!, month: String!, day: String!, hour: String!, minute: String!, weekDay: String!) {
//        createRepareBillModel?.CreateTime = year + "-" + month + "-" + day + " " + hour + ":" + minute + ":00"
//        
//    }
    
    //MARK: DatePickerDelegate
    
    //取消
    func cancelButtonClick() {
        
    }
    
    //重置
    func resetButtonClick(withDataPicker picker: LSDatePicker!) {
        createRepareBillModel?.SubscribeTime = ""
        self.tableView?.reloadData()
    }
    
    func datePickerDelegateEnterAction(withDataPicker picker: LSDatePicker!) {
        
        let value = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue) + " " + String(picker.hourValue) + ":" + String(picker.minuteValue) + ":" + String(picker.secondValue)
        
        createRepareBillModel?.SubscribeTime = value
        self.tableView?.reloadData()
        
    }
    
    //RepairChooseSenderResultDelegate
    
    func popAction(_ result: String!) {
        
        if (result.compare("success") == .orderedSame) {
            //成功
            
            deleteLocalData()
            
            if (self.localButtonIndex == 1
                || self.localButtonIndex == 2) {
                //派单中
                saveLocalData(category: "MyCreate", subCategory: "OnSend")
            }else {
                //进行中
                saveLocalData(category: "MyCreate", subCategory: "OnMarch")
            }
            
        }else {
            //失败
            //未分派任务(未提交)
            saveLocalData(category: "MyCreate", subCategory: "NoSend")
            saveLocalData(category: "NoCommit", subCategory: "NoSend")
        }
        
        if (isHomePage) {
            popToRoot()
            return
        }
        
        super.pop()
    }
    
    func chooseCheck(type: String) {
        
        if (type.compare("7") == .orderedSame) {
            
            if (!isModify) {
                if (isTextCommit && isMaterialCommit) {
                    //未分派任务(未提交)
                    saveLocalData(category: "MyCreate", subCategory: "NoSend")
                    saveLocalData(category: "NoCommit", subCategory: "NoSend")
                }else if (isTextCommit && !isMaterialCommit) {
                    saveLocalData(category: "NoCommit", subCategory: "CreateSuccessNoMaterial")
                }
            }
            
            return
        }
            
        self.localButtonIndex = Int(type)!
        
        let choose = RepairChooseSenderViewController()
        choose.delegate = self
        choose.billCode = billCode
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
        }
 */
        //choose.chooseTitle = actionSheet.buttonTitle(at: buttonIndex)
        choose.chooseTitle = checkTypeArray[self.localButtonIndex - 1]
        self.navigationController?.pushViewController(choose, animated: true)
        
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if (textView.tag == 1113) {
            
            self.createRepareBillModel?.Content = textView.text
            textAreaRow.placeholder = ""
            
            repairContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: repairContentCell!,content: (self.createRepareBillModel?.Content!)!) + "字"
            
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if (textView.tag == 1113) {
            if (textView.text.compare("") == .orderedSame) {
                textAreaRow.cell.placeholderLabel?.text = "报修内容"
            }else {
                textAreaRow.cell.placeholderLabel?.text = ""
            }
            
            repairContentCell?.valueLabel.text = "最大字数200，还可输入" + numberCharacterLeft(cell: repairContentCell!,content: (self.createRepareBillModel?.Content!)!) + "字"
        }
        
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.tag == personTag) {
            self.createRepareBillModel?.Proposer = textField.text
        }else if (textField.tag == linkTag) {
            self.createRepareBillModel?.TelNum = textField.text
        }
    }
    
    //MARK: LVRecordViewDelegate
    
    func finishedRecord() {
        
        self.recordData = recordView?.recordData(withName: recordView?.fileName) as NSData?
        
    }
    
    func setSelfSection(title: String, headerHeight: CGFloat , footerHeight: CGFloat) -> Section {
        let section = Section(header: title, footer: "")
        section.header?.height = { return headerHeight }
        section.footer?.height = { return footerHeight }
        
        return section
    }
    
    
    @objc func saveAction(isPop: Bool) {
        
        let processTextView = (textAreaRow.cell as TextAreaCell).textView
        if (processTextView?.text.compare("") == .orderedSame) {
            LocalToastView.toast(text: "没有填写报修内容")
            return;
        }
        
        if (createRepareBillModel?.Location?.compare("") == .orderedSame) {
            LocalToastView.toast(text: "没有选择报修地址")
            return;
        }
        
        createRepareBillModel?.Content = processTextView?.text
        
        if (!isPop) {
            //保存成功为本地保存
            
            buttonAction(titles: ["返回","提交"], actions: [#selector(pop),#selector(saveAction(isPop:))], target: self)
            
            if (!self.isTextCommit) {
                showAlertChoose(title: "提示", message: "保存成功，是否提交？", placeHolder: "", titles: ["提交","返回"], selector: #selector(RepairTaskAddViewController.commitData(type:)), target: self)
            }else {
                if (isTextCommit && isMaterialCommit) {
                    self.auto = "false"
                    actionNext()
                }else {
                    if (isTextCommit && !isMaterialCommit) {
                        DispatchQueue.main.async(execute: {
                            self.uploadFile(type: 0)
                        })
                    }else {
                        commitData(type: "0")
                    }
                }
                
            }
            
        }else {
            
            if (isTextCommit || isMaterialCommit) {
                //提交
                if (isTextCommit && !isMaterialCommit) {
                    //创建附件未提交
                    saveLocalData(category: "NoCommit",subCategory: "CreateSuccessNoMaterial")
                }
            }else {
                saveLocalData(category: "NoCommit",subCategory: "CreateNew")
            }
        }
        
    }
    
    @objc func commitData(type: String) {
        
        if (type.compare("1") == .orderedSame) {
            
            saveAction(isPop: true)
            
            if (isHomePage) {
                popToRoot()
                return
            }
            
            popToRepairTaskHome()
            
        }else {
            //提交(保存文本)
            
            if (commitActionSelect) {
                return
            }
            
            commitActionSelect = true
            
            if (createRepareBillModel?.CreateTime?.compare("") == .orderedSame) {
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                createRepareBillModel?.CreateTime = formatter.string(from: NSDate() as Date)
            }
            
            let json = createRepareBillModel?.yy_modelToJSONString()
            
            let data = json?.data(using: .utf8)
            let dictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            let jsonCreateModel = CreateRepareBillModel()
            jsonCreateModel.setValuesForKeys(dictionary as! [String : Any])
            
            let finalJson = jsonCreateModel.yy_modelToJSONString()
            
            LoadView.storeLabelText = "正在提交任务信息"
            
            let createRepareBillAPICmd = CreateRepareBillAPICmd()
            createRepareBillAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
            createRepareBillAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","BillInfo":finalJson ?? ""]
            createRepareBillAPICmd.loadView = LoadView()
            createRepareBillAPICmd.loadParentView = self.view
            createRepareBillAPICmd.transactionWithSuccess({ (response) in
                
                self.commitActionSelect = false
                
                let dict = JSON(response)
                
                //print(dict)
                
                let resultStatus = dict["result"].string
                
                if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                    //成功
                    
                    //文本数据提交
                    self.isTextCommit = true

                    self.billCode = dict["BillCode"].string!
                    self.auto = dict["Auto"].string!
                    
                    if (self.createRepareBillModel?.BillCode != nil
                        && self.billCode.compare((self.createRepareBillModel?.BillCode)!) == .orderedSame) {
                        //如果不是同一个billcode，表示和表单信息不是同一笔数据，需要针对该表单重新上传附件
                        self.createRepareBillModel?.BillCode = self.billCode
                        if (!self.isMaterialCommit && self.selectImageShowView.selectedPhotos.count != 0) {
                            DispatchQueue.main.async(execute: {
                                self.uploadFile(type: 0)
                            })
                        }else {
                            self.perform(#selector(self.actionNext), with: nil, afterDelay: 1.0)
                        }
                        
                    }else {
                        if self.selectImageShowView.selectedPhotos.count != 0 {
                            DispatchQueue.main.async(execute: {
                                self.uploadFile(type: 0)
                            })
                        }
                        
                    }
                    
                    self.createRepareBillModel?.BillCode = self.billCode
                    self.perform(#selector(self.actionNext), with: nil, afterDelay: 1.0)
                    
                }else {
                    LocalToastView.toast(text: dict["msg"].string!)
                }
                
            }) { (response) in
                self.commitActionSelect = false
                LocalToastView.toast(text: DisNetWork)
            }
            
        }
    }
    
    func uploadFile(type: NSInteger) {
        
        print("upload" + String(type))
        
        let parameters = ["AccountCode":loginInfo?.accountCode ?? "",
                          "upk":userInfo?.upk ?? "",
                          "osType":"0",
                          "type":type == 0 ? "0":"1",
                          "billpk":self.billCode as String,] as [String : String]
    
        
        let hud: MBProgressHUD? = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.mode = .indeterminate
        hud?.label.text = "正在上传附件..."
        
        //上传
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                if (type == 0) {
                    //图片
                    var index = 0
                    for image in self.selectImageShowView.selectedPhotos {
                        //避免图片名称重复，采用时间+索引策略
                        if (BaseTool.isKind(image) == 1) {
                            //filaPath
                            let existImage = UIImage(contentsOfFile: image as! String)
                            //let data = UIImageJPEGRepresentation(existImage!, 0.5)
                            
                            let data = CompressionImage.compressionImage(existImage)
                            
                            let imageName = String(describing: NSDate()) + String(index) + ".png"
                            multipartFormData.append(data!, withName: "uploadFile", fileName: imageName.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: ""), mimeType: "image/png")
                        }else {
                            //let data = UIImageJPEGRepresentation(image as! UIImage, 0.5)
                            
                            let data = CompressionImage.compressionImage(image as! UIImage)
                            
                            let imageName = String(describing: NSDate()) + String(index) + ".png"
                            print(imageName)
                            multipartFormData.append(data!, withName: "uploadFile", fileName: imageName.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: ""), mimeType: "image/png")
                        }
                        
                        index = index + 1
                        
                    }
                }
                
                if (type == 1) {
                    //音频
                    
                    if (self.recordData != nil) {
                        multipartFormData.append(self.recordData as! Data, withName: "recordFile.mp3", fileName: "recordFile.mp3", mimeType: "mp3")
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
                            self.isMaterialCommit = true
                            //self.actionNext()
                            //延迟执行
                            
                            if (self.recordData != nil && !self.isRecordCommit) {
                                self.isRecordCommit = true
                                self.uploadFile(type: 1)
                            }else {
                                self.perform(#selector(self.actionNext), with: nil, afterDelay: 1.0)
                            }
                            
                            
                        })
                        
                    }
                case .failure(let encodingError):
                    hud?.hide(animated: true)
                    print(encodingError)
                }
            }
        )
        
    }
    
    @objc func actionNext() {
        
        if (self.auto.compare("false") == .orderedSame) {
            //弹出对话框选择保修方式
            
            showActionSheet(title: "选择报修方式", cancelTitle: "取消", titles: checkTypeArray, tag: "ChooseCheck")
            
            /*
            showAlertChoose(title: "选择报修方式", message: "", placeHolder: "", titles: checkTypeArray as NSArray, selector: #selector(RepairTaskAddViewController.chooseCheck(type:)), target: self)
            */
            /*
            actionSheetNext = UIActionSheet(title: "选择报修方式", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "选择派单人","选择派单人+离线","选择维修人","选择维修人+离线","发起抢单","发起抢单+离线")
            actionSheetNext.show(in: self.view);
            */
            
        }else {
            
        }
        
    }
    
    internal func presentMyViewController(_ viewController: UIViewController!, animated: Bool) {
        self.present(viewController, animated: animated, completion: nil)
    }
    
    func didFinishChoose() {
        
    }
    
    override func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
        print(buttonIndex)
        
        if (tag.compare("ChooseCheck") == .orderedSame) {
            
            if (buttonIndex == 0) {
                
                if (!isModify) {
                    
                    if (isTextCommit && isMaterialCommit) {
                        //未分派任务(未提交)
                        saveLocalData(category: "MyCreate", subCategory: "NoSend")
                        saveLocalData(category: "NoCommit", subCategory: "NoSend")
                    }else if (isTextCommit && !isMaterialCommit) {
                        saveLocalData(category: "NoCommit", subCategory: "CreateSuccessNoMaterial")
                    }
                    isModify = true
                }else {
                    //修改数据则更新数据
                    self.createRepareBillModel?.update()
                }
                
                return
            }
            
            self.localButtonIndex = buttonIndex
            
            let choose = RepairChooseSenderViewController()
            choose.delegate = self
            choose.billCode = (billCode.compare("") == .orderedSame ? self.createRepareBillModel?.BillCode ?? "": billCode)
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
            choose.chooseTitle = checkTypeArray[self.localButtonIndex - 1]
            
            /*
            if (self.localButtonIndex == 5 || self.localButtonIndex == 6) {
                choose.chooseType = "3"
                choose.requestData()
            }else {
                self.navigationController?.pushViewController(choose, animated: true)
            }*/
            
            if (self.localButtonIndex == 3) {
                choose.chooseType = "3"
                choose.requestData()
            }else {
                self.navigationController?.pushViewController(choose, animated: true)
            }
            
            return
        }
        
        if (tag.compare("HandleStyle") == .orderedSame) {
            
            if (buttonIndex == 0) {
                
            }else {
                
                
                
            }
            
            return;
        }
        
        if (tag.compare("Score") == .orderedSame) {
            
            if (buttonIndex == 1) {
                createRepareBillModel?.Range = "客户区域"
            }else if (buttonIndex == 2) {
                createRepareBillModel?.Range = "公共区域"
            }else {
                
            }
            
            if (buttonIndex != 0) {
                UserDefaults.standard.set(createRepareBillModel?.Range, forKey: "Range")
            }
            
        }else if (tag.compare("Style") == .orderedSame) {
            if (buttonIndex == 1) {
                createRepareBillModel?.Type = "有偿维修"
            }else if (buttonIndex == 2) {
                createRepareBillModel?.Type = "无偿维修"
            }else {
                
            }
        }
        
        rangeTextAreaRow.value = createRepareBillModel?.Range
        
        self.tableView?.reloadData()
    }
    
    override func pop() {
        
        if (isModify) {
            
        }else {
            saveAction(isPop: true)
        }
        
        if (isHomePage) {
            popToRoot()
            return
        }
        
        super.pop()
    }

    func saveLocalData(category: String, subCategory: String) {
        
        //记录文本是否提交
        self.createRepareBillModel?.IsTextCommit = (self.isTextCommit ? "1":"0")
        //记录材料是否提交
        self.createRepareBillModel?.IsMaterialCommit = (self.isMaterialCommit ? "1" :"0")
        
        self.createRepareBillModel?.Category = category
        self.createRepareBillModel?.SubCategory = subCategory
        
        if (isModify) {
            if (self.createRepareBillModel?.BillCode?.compare("") == .orderedSame
                && self.createRepareBillModel?.pk == nil) {
                self.createRepareBillModel?.save()
            }else {
                self.createRepareBillModel?.update()
            }
        }else {
            self.createRepareBillModel?.save()
        }
    
        if (category.compare("NoCommit") == .orderedSame) {
            
            if (createRepareBillModel?.CreateTime?.compare("") == .orderedSame) {
                
                let date = NSDate()
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let createTime = timeFormatter.string(from: date as Date) as String
                createRepareBillModel?.CreateTime = createTime
            }
            
            //未提交
            self.storeRecordData()
            self.storeAddRepairTaskImage()
        }
    }
    
    func storeRecordData() {
        
        if (self.recordData == nil) {
            return
        }
        
        var recordName = (self.createRepareBillModel?.BillCode)! + "Record"
        recordName = recordName.appending((self.createRepareBillModel?.Category)!).appending((self.createRepareBillModel?.SubCategory)!)
        
        let success:Bool = (recordView?.turnRecordFile(withName: recordName))!
        
        if (success) {
            createRepareBillModel?.RecordName = recordName
        }
        
    }
    
    func storeAddRepairTaskImage() {
        
        var index = 0
        let localImages = NSMutableArray(capacity: 20)
        
        //数据初始化
        createRepareBillModel?.LocalImageO = ""
        createRepareBillModel?.LocalImageT = ""
        createRepareBillModel?.LocalImageS = ""
        createRepareBillModel?.LocalImageF = ""
        
        for image in self.selectImageShowView.selectedPhotos {
            
            var data: Any?
            
            if (BaseTool.isKind(image) == 1) {
                //filaPath
                let existImage = UIImage(contentsOfFile: image as! String)
                data = UIImageJPEGRepresentation(existImage!, 0.5)
            }else {
                data = UIImageJPEGRepresentation(image as! UIImage, 0.5)
            }
            
            var imageName = (self.createRepareBillModel?.BillCode)! + String(index)
            imageName = imageName.appending((self.createRepareBillModel?.Category)!).appending((self.createRepareBillModel?.SubCategory)!)
            localImages.add(imageName)
            
            if (index == 0) {
                createRepareBillModel?.LocalImageO = imageName
            }else if (index == 1) {
                createRepareBillModel?.LocalImageT = imageName
            }else if (index == 2) {
                createRepareBillModel?.LocalImageS = imageName
            }else if (index == 3) {
                createRepareBillModel?.LocalImageF = imageName
            }
            
            DiskCache().saveDataToCache(proName: imageName, Data: data! as! NSData)
            
            index = index + 1
        }
        self.createRepareBillModel?.update()
        
    }
    
    func fetchLocalImages() {
        
        self.selectImageShowView.selectedPhotos = []
        self.selectImageShowView.selectedAssets = []
        
        if (createRepareBillModel?.LocalImageO?.compare("") != .orderedSame) {
            writeLocalImage(imageName: createRepareBillModel?.LocalImageO!, type: 0)
        }
        
        if (createRepareBillModel?.LocalImageT?.compare("") != .orderedSame) {
            writeLocalImage(imageName: createRepareBillModel?.LocalImageT!, type: 1)
        }
        
        if (createRepareBillModel?.LocalImageS?.compare("") != .orderedSame) {
            writeLocalImage(imageName: createRepareBillModel?.LocalImageS!, type: 2)
        }
        
        if (createRepareBillModel?.LocalImageF?.compare("") != .orderedSame) {
            writeLocalImage(imageName: createRepareBillModel?.LocalImageF!, type: 3)
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
                createRepareBillModel?.LocalImageO = ""
            }else if (type == 1) {
                createRepareBillModel?.LocalImageT = ""
            }else if (type == 2) {
                createRepareBillModel?.LocalImageS = ""
            }else if (type == 3) {
                createRepareBillModel?.LocalImageF = ""
            }
        }
    }
    
    func deleteLocalData() {
        self.createRepareBillModel?.deleteObject()
    }

}
