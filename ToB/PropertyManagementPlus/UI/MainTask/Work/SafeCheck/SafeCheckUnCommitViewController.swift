//
//  SafeCheckUnCommitViewController.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/16.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON
import SSZipArchive
import Alamofire

class SafeCheckUnCommitViewController: BaseTableViewController,DatePickerDelegate {
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    fileprivate var myAlarmListTopView = MyAlarmListTopView()
    fileprivate var lSDatePicker = LSDatePicker()
    
    var todayTime = ""
    var dataSource: [SafeCheckResultModel] = []
    var sortDataSource: [[SafeCheckResultModel]] = [[]]
    fileprivate var equipmentPatrolSelectNumber = -1
    fileprivate var equipmentIsLoaded = false
    fileprivate var equipTitles = ["删除当前",
                                   "删除所有未提交",
                                   "删除所有数据"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //去掉NavigationBar的背景和横线
        if navigationController?.navigationBar.subviews.count != 0 {
            navigationController?.navigationBar.subviews[0].isHidden = true
        }
        navigationController?.navigationBar.setBackgroundImage(BaseTool.createImage(with: UIColor.clear), for: .default)
        buttonAction(titles: ["返回","提交"], actions: [#selector(pop),#selector(commit)], target: self)
        
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sortDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: SafeCheckUnCommitListTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "SafeCheckUnCommitListTableViewCell") as? SafeCheckUnCommitListTableViewCell
        cell = (SafeCheckUnCommitListTableViewCell.reuseNib.instantiate(withOwner: self, options: nil)).first as? SafeCheckUnCommitListTableViewCell
        cell?.tag = indexPath.section * 1000 + indexPath.row
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(equipmentPatrolLongPress(longPress:)))
        cell?.contentView.isUserInteractionEnabled = true
        cell?.contentView.addGestureRecognizer(longPress)
        
        let result = self.sortDataSource[indexPath.section][indexPath.row]
        cell?.nameLabel.text = result.Name
        cell?.subNameLabel.text = "有\(self.sortDataSource[indexPath.section].count)条检查记录未提交"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func createUI() {
        
        self.setTitleView(titles: ["未提交" as NSString])
        
        myAlarmListTopView = Bundle.main.loadNibNamed("MyAlarmListTopView", owner: self, options: nil)?.first as! MyAlarmListTopView
        myAlarmListTopView.tag = 7777
        myAlarmListTopView.isUserInteractionEnabled = true
        myAlarmListTopView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 50 + 64)
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: myAlarmListTopView.frame.size.height, width: kScreenWidth, height: kScreenHeight - myAlarmListTopView.height - 50), hasHeader: false, hasFooter: false)
        
        self.view.addSubview(myAlarmListTopView)
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(selectTime))
        myAlarmListTopView.timeLabel.isUserInteractionEnabled = true
        myAlarmListTopView.timeLabel.addGestureRecognizer(tapGes)
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = dateFmt.string(from: Date())
        let dateForeStr = (dateStr.components(separatedBy: " ") as NSArray)[0]
        todayTime = dateForeStr as! String;
        myAlarmListTopView.timeLabel.text = (dateForeStr as AnyObject).appending(",星期") + getWeekDay(dateTime: dateStr)
        
        let actionTapGes = UITapGestureRecognizer(target: self, action: #selector(actionSelectTime(tap:)))
        
        myAlarmListTopView.foreImageView.isUserInteractionEnabled = true
        myAlarmListTopView.foreImageView.tag = 123
        myAlarmListTopView.foreImageView.addGestureRecognizer(actionTapGes)
        
        let backActionTapGes = UITapGestureRecognizer(target: self, action: #selector(actionSelectTime(tap:)))
        myAlarmListTopView.backImageView.isUserInteractionEnabled = true
        myAlarmListTopView.backImageView.tag = 125
        myAlarmListTopView.backImageView.addGestureRecognizer(backActionTapGes)
        
        self.contentTableView?.register(SafeCheckUnCommitListTableViewCell.self, forCellReuseIdentifier: "SafeCheckUnCommitListTableViewCell")
        
    }
    
    func datePickerDelegateEnterAction(withDataPicker picker: LSDatePicker!) {
        
        let value = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue) + " " + String(picker.hourValue) + ":" + String(picker.minuteValue) + ":" + String(picker.secondValue)
        
        todayTime = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue);
        lSDatePicker.tempHintsLabel.text = todayTime + ",星期" + getWeekDay(dateTime: value)
        
        myAlarmListTopView.timeLabel.text = lSDatePicker.tempHintsLabel.text
        
        //reloadAlrmData()
    }
    
    func selectItemPickerDelegate(_ picker: LSDatePicker!) {
        
        let value = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue) + " " + String(picker.hourValue) + ":" + String(picker.minuteValue) + ":" + String(picker.secondValue)
        
        todayTime = String(picker.yearValue) + "-" + String(picker.monthValue) + "-" + String(picker.dayValue);
        
        lSDatePicker.tempHintsLabel.text = todayTime + ",星期" + getWeekDay(dateTime: value)
    }
    
    @objc func selectTime() {
        //时间选择器
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        lSDatePicker = LSDatePicker(frame: self.view.bounds, array: ["年","月","日"], scrollDate: nil)
        
        lSDatePicker.delegate = self
        lSDatePicker.setHintsText("")
        let frame = lSDatePicker.tempHintsLabel.frame
        lSDatePicker.tempHintsLabel.frame = CGRect(x: (frame.origin.x), y: (frame.origin.y), width: (frame.size.width) + 70, height: (frame.size.height))
        lSDatePicker.cancelBtn.isHidden = true
        lSDatePicker.resetBtn.isHidden = true
        lSDatePicker.showView(inSelect: appDelegate.window)
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateStr = dateFmt.string(from: Date())
        let dateForeStr = (dateStr.components(separatedBy: " ") as NSArray)[0]
        lSDatePicker.tempHintsLabel.text = (dateForeStr as AnyObject).appending(",星期") + getWeekDay(dateTime: dateStr)
        
    }
    
    @objc func actionSelectTime(tap: UITapGestureRecognizer) {
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd"
        let time = ((myAlarmListTopView.timeLabel.text?.components(separatedBy: ",星期"))! as [String])[0]
        let date = dateFmt.date(from: time)
        
        let yesterday = Date(timeInterval: -60 * 60 * 24, since: date!)
        let tomorrow = Date(timeInterval: 60 * 60 * 24, since: date!)
        
        if (tap.view?.tag == 123) {
            
            let dateForeStr = dateFmt.string(from: yesterday)
            todayTime = dateForeStr ;
            
            myAlarmListTopView.timeLabel.text = (dateForeStr as AnyObject).appending(",星期") + getWeekDay(dateTime: dateForeStr + " 00:00:00")
            
        }else {
            
            let dateForeStr = dateFmt.string(from: tomorrow)
            todayTime = dateForeStr ;
            
            myAlarmListTopView.timeLabel.text = (dateForeStr as AnyObject).appending(",星期") + getWeekDay(dateTime: dateForeStr + " 00:00:00")
            
        }
        self.loadData()
    }
    
    @objc func commit() {
        //数据提交
        
        let hud: MBProgressHUD? = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.mode = .indeterminate
        hud?.label.text = "正在上传附件"
        
        for (index, item) in self.dataSource.enumerated() {
            if let file = item.FilePaths {
                var imagePaths = file.components(separatedBy: ",")
                imagePaths.removeLast()
                if imagePaths.count != 0 {
                    self.fileUpload(item: item, imagePaths: imagePaths, index: index)
                } else {
                    self.dataUpload(item: item)
                }
            }
        }
        
        hud?.hide(animated: true)
    }
    
    fileprivate func fileUpload(item: SafeCheckResultModel, imagePaths: [String], index: Int) {
        let caches = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last
        // 创建一个zip文件
        let zipFile = caches?.appendingFormat("/images\(index).zip")
        
        let names = item.FileNames?.components(separatedBy: ",")
        var dealImagePaths: [String] = []
        for (index, path) in imagePaths.enumerated() {
            dealImagePaths.append(DiskCache().cachePath(proName: path)+"\(names![index])")
        }
        
        let result = SSZipArchive.createZipFile(atPath: zipFile!, withFilesAtPaths: dealImagePaths)
        if result {
            // 非文件参数
            
            let parameters = [
                "AccountCode" : loginInfo?.accountCode ?? "",
                "upk": userInfo?.upk ?? "",
                "isZip": "1",
                "zipPwd": "",
                "objectType": "2",
                "smallType": "1"
            ]
            
            let mimeType = "application/x-gzip"
            let data = NSData(contentsOfFile: zipFile!)
            
            let hud: MBProgressHUD? = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud?.mode = .indeterminate
            hud?.label.text = "正在上传附件"
            
            //上传
            Alamofire.upload(multipartFormData:
                { multipartFormData in
                    
                    for (key, value) in parameters {
                        multipartFormData.append((value.data(using: String.Encoding.utf8)!), withName: key)
                    }
                    multipartFormData.append(data! as Data, withName: "temp.zip", fileName: "temp.zip", mimeType: mimeType)
                    // 这里就是绑定参数的地方 param 是需要上传的参数，我这里是封装了一个方法从外面传过来的参数，你可以根据自己的需求用NSDictionary封装一个param
            },
             to: LocalStoreData.getPMSAddress().PMSAddress! + kSafeCheckUploadFile,
             encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let value = response.result.value as? [String: AnyObject]{
                            let json = JSON(value)
                            print(json)
                        }
                        DispatchQueue.main.async(execute: {
                            hud?.hide(animated: true)
                        })
                        DiskCache().deleteCachePath(proName: zipFile!)
                        self.dataUpload(item: item)
                    }
                case .failure(let encodingError):
                    hud?.hide(animated: true)
                    print(encodingError)
                }
            }
            )
        }
    }
    
    fileprivate func dataUpload(item: SafeCheckResultModel) {
        
        let infos = NSMutableArray(capacity: 20)
        
        let infoItem = NSMutableDictionary(dictionary: item.yy_modelToJSONObject() as! NSDictionary)
        infoItem.removeObject(forKey: "jsonContent")
        infoItem.removeObject(forKey: "isCommit")
        infoItem.removeObject(forKey: "pk")
        infoItem.removeObject(forKey: "Name")
        infoItem.removeObject(forKey: "FilePaths")
        infoItem["Contents"] = BaseTool.dictionary(withJsonString: item.jsonContent)
        
        infos.add(infoItem)
        
        let addSafeCheckResultAPICmd = AddSafeCheckResultAPICmd()
        addSafeCheckResultAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        addSafeCheckResultAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "", "infos": BaseTool.toJson(infos)]
        addSafeCheckResultAPICmd.transactionWithSuccess({ [weak self] (response) in
            guard let `self` = self else { return }
            
            let dict = JSON(response)
            print(dict)
            let resultStatus = dict["result"].string
            
            if resultStatus == "success"  {
                
                item.deleteObject()
                //图片删除
                var images = item.FilePaths?.components(separatedBy: ",")
                images?.removeLast()
                
                for path in images! {
                    let pathF = NSHomeDirectory() + path
                    DiskCache().deleteCachePath(proName: pathF)
                }
                self.loadData()
                
            } else {
                LocalToastView.toast(text: dict["msg"].string!)
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
        }
        
    }
    
    func getWeekDay(dateTime:String) -> String{
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFmt.date(from: dateTime)
        let interval = Int(date!.timeIntervalSince1970) + NSTimeZone.local.secondsFromGMT()
        let days = Int(interval/86400) // 24*60*60
        let weekday = ((days + 4)%7+7)%7
        
        var week = "一"
        
        if (weekday == 0) {
            week = "日"
        }else if (weekday == 1) {
            week = "一"
        }else if (weekday == 2) {
            week = "二"
        }else if (weekday == 3) {
            week = "三"
        }else if (weekday == 4) {
            week = "四"
        }else if (weekday == 5) {
            week = "五"
        }else if (weekday == 6) {
            week = "六"
        }
        
        return week
    }
    
    func fetchSortDatas() -> [[SafeCheckResultModel]] {
        
        self.dataSource.removeAll()
        let sources = SafeCheckResultModel.findAllExceptions(["Contents"]).filter { (model) -> Bool in
            let resultModel = model as! SafeCheckResultModel
            return (resultModel.CheckTime?.hasPrefix(todayTime))!
        }
        
        //排序
        var itemSource: [SafeCheckResultModel] = []
        for item in sources {
            let resultModel = item as! SafeCheckResultModel
            itemSource.append(resultModel)
        }
        itemSource.sort { (modelF, modelS) -> Bool in
            if (modelF.CheckTime?.compare(modelS.CheckTime!)) == ComparisonResult.orderedAscending {
                return true
            }
            return false
        }
        
        for resultModel in itemSource {
            let array = BaseTool.dictionary(withJsonString: resultModel.jsonContent) as! NSArray
            var resultContents: [Any] = [Any]()
            for dict in array {
                let dictionary = dict as! NSDictionary
                let subModel = EquipmentPatrolGroupConentModel()
                subModel.TaskPK = dictionary["TaskPK"] as? String
                subModel.Value = dictionary["Value"] as? String
                resultContents.append(subModel)
            }
            resultModel.Contents = resultContents
            
            if resultModel.isCommit == "0" {
                //未提交
                self.dataSource.append(resultModel)
            }
        }
        
        self.sortDataSource.removeAll()
        //分组
        var firstGroup: [SafeCheckResultModel] = []
        var firstItem: SafeCheckResultModel?
        for item in self.dataSource {
            if let tempFirstItem = firstItem {
                if tempFirstItem.Name == item.Name
                    && tempFirstItem.pRoomCode == item.pRoomCode {
                    //同一店铺进行分组展示
                    firstGroup.append(tempFirstItem)
                } else {
                    self.sortDataSource.append(firstGroup)
                    firstItem = item
                    firstGroup = [firstItem!]
                }
            } else {
                firstItem = item
                firstGroup = [firstItem!]
            }
        }
        
        if firstGroup.count != 0 {
            self.sortDataSource.append(firstGroup)
        }
        
        return self.sortDataSource
    }
    
    func loadData() {
        
        let _ = fetchSortDatas()
        
        if self.sortDataSource.count == 0 {
            self.setTitleView(titles: ["未提交" as NSString])
        } else {
            self.setTitleView(titles: ["未提交,共\(self.sortDataSource.count)组" as NSString])
        }
        
        self.contentTableView?.reloadData()
        
    }
    
    //MARK: ActionSheetDelegate
    
    func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            return
        }
        
        if tag == "SafeCheckHandleDeleteStyle" {
            if buttonIndex == 1 {
                let item = self.sortDataSource[equipmentPatrolSelectNumber/1000][equipmentPatrolSelectNumber%1000]
                item.deleteObject()
            } else if buttonIndex == 2 {
                for item in self.sortDataSource[equipmentPatrolSelectNumber/1000] {
                    item.deleteObject()
                }
            } else {
                SafeCheckResultModel.clearTable()
            }
            loadData()
        }
    }
}

extension SafeCheckUnCommitViewController {
    
    @objc func equipmentPatrolLongPress(longPress: UILongPressGestureRecognizer) {
        equipmentPatrolSelectNumber = (longPress.view?.tag)!
        showActionSheet(title: "选择操作对象", cancelTitle: "取消", titles: equipTitles, tag: "SafeCheckHandleDeleteStyle")
    }
}

extension SafeCheckUnCommitViewController: SafePatrolDetailViewDelegate {
    func selectSafePatrolDetailViewItem(_ tag: Int) {
    }
}

