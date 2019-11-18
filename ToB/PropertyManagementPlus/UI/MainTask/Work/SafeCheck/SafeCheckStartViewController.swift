//
//  SafeCheckStartViewController.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/15.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit
import SSZipArchive
import Alamofire
import HandyJSON
import SwiftyJSON

class SafeCheckStartViewController: BaseViewController,UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let selectImageShowView = SelectImageShowView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 95.0))
    
    fileprivate let loginInfo = LocalStoreData.getLoginInfo()
    fileprivate let userInfo = LocalStoreData.getUserInfo()
    
    var isModify = false
    var name = ""
    var pRoomCode: String = ""
    var itemAssociateCode: String = ""
    
    fileprivate var fileMemo = ""
    fileprivate var fileNames = ""
    fileprivate var filePaths = ""
    fileprivate var picPrints: [UIImage] = []
    
    var saveSuccess = false
    var items: [SafeCheckItemModel]?
    var pinfos: [SafeCheckPInfosModel]?
    var tuples: (SafeCheckHouseModel?, SafeCheckBuildHouseModel?, SafeCheckFloorHouseModel?, SafeCheckHouseRoomModel?)?
    var dataSource: [(SafeCheckPInfosModel, [SafeCheckItemModel], String)] = []
    var contents: Array<SafeCheckResultModel> = Array<SafeCheckResultModel>()
    var textView:UITextView?
    var textMedo:NSString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createUI()
        self.initData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func initData() {
        dataSource.removeAll()
        if let infos = pinfos {
            for info in infos {
                var data = (info, [SafeCheckItemModel](), "")
                var subContents: [EquipmentPatrolGroupConentModel] = []
                if let items = items {
                    for item in items {
                        if info.ProjectPK == item.ProjectPK {
                            data.1.append(item)
                            data.2 = info.ProjectPK
                            
                            let contentModel = EquipmentPatrolGroupConentModel()
                            contentModel.TaskPK = item.TaskPK
                            let types = item.TypeDescription.components(separatedBy: ";")
                            for value in types {
                                let values = value.components(separatedBy: "|")
                                if values.count < 4 {
                                    break;
                                }
                                
                                if values[3] == "1" {
                                    //默认值
                                    contentModel.Caption = values[1]
                                    contentModel.Value = values[2]
                                    contentModel.IsException = values[4]
                                    break
                                }
                            }
                            subContents.append(contentModel)
                        }
                    }
                    print(data.1.count);
                }
                
                if data.1.count != 0 {
                    let resultModel = SafeCheckResultModel()
                    resultModel.ProjectPK = data.2
                    resultModel.pRoomCode = self.pRoomCode
                    resultModel.Contents = subContents
                    contents.append(resultModel)
                    dataSource.append(data)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    fileprivate func createUI() {
        
        self.setTitleView(titles: ["执行安全检查"])
        
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.backgroundColor = UIColor.groupTableViewBackground
        tableView?.separatorStyle = .none
        tableView.register(EquipmentPatrolStartSelectTableViewCell.self, forCellReuseIdentifier: "EquipmentPatrolStartSelectTableViewCell")
        tableView.register(SafeCheckListPhotoTableViewCell.self, forCellReuseIdentifier: "SafeCheckListPhotoTableViewCell")
        tableView.register(SafeCheckMemoTableViewCell.self, forCellReuseIdentifier: "SafeCheckMemoTableViewCell")
        
        if isModify {
            buttonAction(titles: ["返回","修改"], actions: [#selector(pop),#selector(modify)], target: self)
        } else {
            buttonAction(titles: ["返回","提交结果"], actions: [#selector(pop),#selector(save)], target: self)
        }
    }
    
    @objc fileprivate func modify() {
        
    }
    
    @objc fileprivate func save() {
        var indexSection = 0
        var indexRow = 0
        for groupModel in contents {
            for model in groupModel.Contents {
                let contentModel = model as! EquipmentPatrolGroupConentModel
                if contentModel.TaskPK == ""
                    || contentModel.Value == "" {
                    if indexRow != 10 {
                        self.saveDisturbe(indexSection: indexSection, indexRow: indexRow)
                        return
                    }
                    else {
                        if self.textView?.text == "" || self.textView?.text == nil {
                            LocalToastView.toast(text:"备注不能为空")
                            return
                        }
                        else {
                            contentModel.Value = self.textView?.text!;
                        }
//                        contentModel.Value = self.textView?.text ?? "";
//                        contentModel.Value = "";
                    }
                    
                }
                indexRow += 1
            }
            indexSection += 1
        }
        
        //水印->处理图片
        dealPics()
        
        if self.fileNames == "" {
            self.saveDisturbe(indexSection: self.dataSource.count, indexRow: 0)
            return
        }
        
        for (index, groupModel) in contents.enumerated() {
            
            let changeArray = NSMutableArray(capacity: 20)
            
            for model in groupModel.Contents {
                let contentModel = model as! EquipmentPatrolGroupConentModel
                let resultDict = ["TaskPK": contentModel.TaskPK ?? "", "Value": contentModel.Value ?? ""]
                changeArray.add(resultDict)
            }
            
            
            
            groupModel.jsonContent = changeArray.yy_modelToJSONString()
            groupModel.isCommit = "0"
            
            let dateFmt = DateFormatter()
            dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let endTime = dateFmt.string(from: Date())
            
            groupModel.CheckTime = endTime
            groupModel.pRoomCode = pRoomCode
            groupModel.ProjectPK = self.dataSource[index].2
            groupModel.Name = self.name
            groupModel.FileMemo = self.fileMemo
            groupModel.CheckMan = loginInfo?.accountCode ?? ""
            groupModel.CheckResult = "1"
//            if index == contents.count - 1 {
                groupModel.FileNames = self.fileNames
                groupModel.FilePaths = self.filePaths
//            }
            groupModel.saveOrUpdate()
        }
        //数据上传
        dataUpload()
    }
    
    fileprivate func fileUpload() {
        let caches = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last
        // 创建一个zip文件
        let zipFile = caches?.appendingFormat("/images.zip")
        
        var imagePaths = self.filePaths.components(separatedBy: ",")
        imagePaths.removeLast()
        
        let names = self.fileNames.components(separatedBy: ",")
        var dealImages: [String] = []
        for (index, path) in imagePaths.enumerated() {
            dealImages.append(DiskCache().cachePath(proName: path)+"\(names[index])")
        }
        
        let result = SSZipArchive.createZipFile(atPath: zipFile!, withFilesAtPaths: dealImages)
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
                                if json["result"] == "success" {
                                    DiskCache().deleteCachePath(proName: zipFile!)
                                    self.clearDatas()
                                }
                            }
                            self.popStack()
                            DispatchQueue.main.async(execute: {
                                hud?.hide(animated: true)
                            })
                        }
                    case .failure(let encodingError):
                        hud?.hide(animated: true)
                        print(encodingError)
                        self.popStack()
                    }
                }
            )
        }
    }
    
    fileprivate func dataUpload() {
        
        let infos = NSMutableArray(capacity: 20)
        print(contents);
        for groupModel in contents {
            
            if groupModel.isCommit == "1" {
                continue
            }
            
            let infoItem = NSMutableDictionary(dictionary: groupModel.yy_modelToJSONObject() as! NSDictionary)
            infoItem.removeObject(forKey: "jsonContent")
            infoItem.removeObject(forKey: "isCommit")
            infoItem.removeObject(forKey: "pk")
            infoItem.removeObject(forKey: "Name")
            infoItem.removeObject(forKey: "FilePaths")
            infoItem["Contents"] = BaseTool.dictionary(withJsonString: groupModel.jsonContent)
            
            infos.add(infoItem)
        }
        
        LoadView.storeLabelText = "上传安全巡检结果"

        let addSafeCheckResultAPICmd = AddSafeCheckResultAPICmd()
        addSafeCheckResultAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
        addSafeCheckResultAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "", "infos":BaseTool.toJson(infos)!]
//        BaseTool.toJson(infos)
        print("infos == \(["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "", "infos":infos]) , infoJson == \(BaseTool.toJson(infos)!)")
        addSafeCheckResultAPICmd.loadView = LoadView()
        addSafeCheckResultAPICmd.loadParentView = self.view
        addSafeCheckResultAPICmd.transactionWithSuccess({ [weak self] (response) in
            guard let `self` = self else { return }
            let dict = JSON(response)
            print(dict)
            let resultStatus = dict["result"].string

            if resultStatus == "success"  {
                self.fileUpload()
            } else {
                LocalToastView.toast(text: dict["msg"].string!)
                self.popStack()
            }
            
        }) { (response) in
            LocalToastView.toast(text: DisNetWork)
            self.popStack()
        }
        
    }
    
    fileprivate func popStack() {
        super.pop()
    }
    
    fileprivate func clearDatas() {
        //删除数据库数据
        for groupModel in contents {
            var images = groupModel.FilePaths?.components(separatedBy: ",")
            images?.removeLast()
            
            let names = self.fileNames.components(separatedBy: ",")
            for (index, path) in images!.enumerated() {
                let pathF = DiskCache().cachePath(proName: path)+"\(names[index])"
                DiskCache().deleteCachePath(proName: pathF)
            }
            groupModel.deleteObject()
        }
    }
    
    @objc fileprivate func saveDisturbe(indexSection: Int, indexRow: Int) {
        let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: "有选项未完成", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "查看", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            self.tableView.scrollToRow(at: IndexPath(row: indexRow, section: indexSection), at: .middle, animated: true)
        })
        let confirmAction = UIAlertAction(title: "返回", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            
        })
        tipAlertView.addAction(cancelAction)
        tipAlertView.addAction(confirmAction)
        self.present(tipAlertView, animated: true, completion: {})
    }
    
    override func pop() {
        if saveSuccess {
            super.pop()
        } else {
            
            let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: "安全检查结果尚未保存，是否退出？", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "确认", style: .default, handler: {
                (action: UIAlertAction) -> Void in
                super.pop()
            })
            let confirmAction = UIAlertAction(title: "返回", style: .default, handler: {
                (action: UIAlertAction) -> Void in
                
            })
            tipAlertView.addAction(cancelAction)
            tipAlertView.addAction(confirmAction)
            self.present(tipAlertView, animated: true, completion: {})
        }
    }
    
}

extension SafeCheckStartViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == self.dataSource.count {
            return 3;
        }
        return self.dataSource[section].1.count * 2 - 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == self.dataSource.count {
            switch indexPath.row {
            case 0:
                return 35.0
            case 1:
                return 95.0
            default:
                break
            }
            return 44.0
        }
        
        if indexPath.row % 2 == 1 {
            return 10.0
        }
        return 175
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
        
        let contentLabel = UILabel(frame: backView.bounds)
        contentLabel.textColor = UIColor.black
        contentLabel.backgroundColor = UIColor(red: 0.0/255.0, green: 160.0/255.0, blue: 234.0/255.0, alpha: 0.8)
        
        if section == self.dataSource.count {
            contentLabel.text = "  现场照片"
        } else {
            let item = self.dataSource[section].0
            contentLabel.text = "  \(item.ProjectName)"
        }
        
        backView.addSubview(contentLabel)
        return backView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if  indexPath.section == 0 && indexPath.row == self.dataSource[0].1.count*2 - 2{
            let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "UITableView");
            let lab = UILabel.init(frame: CGRect(x: 0, y: 5, width: kScreenWidth, height: 35));
            lab.text = "备注";
            lab.font = UIFont.systemFont(ofSize: 18);
            let textView = UITextView.init(frame: CGRect(x: 10, y: 35, width: kScreenWidth - 20, height: 135));
            textView.backgroundColor = UIColor.init(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1);
            textView.delegate = self;
            textView.text = textMedo as String ;
            cell.selectionStyle = UITableViewCellSelectionStyle.none;
            cell.contentView.addSubview(textView);
            cell.contentView.addSubview(lab);
            self.textView = textView;
//            textView.backgroundColor = UIColor.red
            return cell;
        }
        else {
            if indexPath.section == self.dataSource.count {
                
                switch indexPath.row {
                case 0:
                    var cell: SafeCheckListPhotoTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "SafeCheckListPhotoTableViewCell") as? SafeCheckListPhotoTableViewCell
                    cell = (SafeCheckListPhotoTableViewCell.reuseNib.instantiate(withOwner: self, options: nil))[0] as? SafeCheckListPhotoTableViewCell
                    cell?.selectionStyle = .none
                    return cell!
                case 2:
                    var cell: SafeCheckMemoTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "SafeCheckMemoTableViewCell") as? SafeCheckMemoTableViewCell
                    cell = (SafeCheckMemoTableViewCell.reuseNib.instantiate(withOwner: self, options: nil))[0] as? SafeCheckMemoTableViewCell
                    cell?.selectionStyle = .none
                    cell?.loadData()
                    cell?.textFiledDelegate = self
                    if self.fileMemo != "" {
                        cell?.memoTextField.text = self.fileMemo
                    }
                    return cell!
                default:
                    break
                }
                
                let cell: UITableViewCell = UITableViewCell()
                selectImageShowView.allowSelectLocalPhoto = false
                selectImageShowView.delegate = self
                cell.contentView.addSubview(selectImageShowView)
                return cell
            }
            
            if indexPath.row % 2 == 1 {
                let cell: UITableViewCell = UITableViewCell.init(style: .default, reuseIdentifier: "UITableViewCell100000")
                cell.backgroundColor = UIColor.groupTableViewBackground
                return cell
            }
            else {
                let rows = self.dataSource[indexPath.section].1
                let item = rows[indexPath.row / 2]
                print(" ---------------- \(item.Type) ------------------")
                if NSString.init(string: item.Type).boolValue == false {
                    let cell:UITableViewCell = UITableViewCell.init(style: .default, reuseIdentifier: "UITableViewCell1");
                    for view1 in cell.contentView.subviews {
                        view1 .removeFromSuperview();
                    }
                    let textView = UITextView.init(frame: CGRect(x: 0, y: 5, width: kScreenWidth - 20, height: 170));
                    cell.contentView.addSubview(textView);
                    textView.backgroundColor = UIColor.red
                    return cell;
                }
                else {
                    let cell = (EquipmentPatrolStartSelectTableViewCell.reuseNib.instantiate(withOwner: self, options: nil))[0] as? EquipmentPatrolStartSelectTableViewCell
                    cell?.tag = indexPath.row / 2 + 1000 * indexPath.section;
                    let contentModel = contents[indexPath.section].Contents[indexPath.row / 2] as! EquipmentPatrolGroupConentModel
                    cell?.delegate = self;
                    cell?.safeCheckRefresh(model: item, selectItemHeight: height(typeDescription: item.TypeDescription),tempModel:contentModel)
                    return cell!;
                }
                /*
                //            tableView.register(UINib.init(nibName: "EquipmentPatrolStartSelectTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "EquipmentPatrolStartSelectTableViewCell\(indexPath.row)")
                //            let cell: EquipmentPatrolStartSelectTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "EquipmentPatrolStartSelectTableViewCell\(indexPath.row)") as? EquipmentPatrolStartSelectTableViewCell
                let cell = (EquipmentPatrolStartSelectTableViewCell.reuseNib.instantiate(withOwner: self, options: nil))[0] as? EquipmentPatrolStartSelectTableViewCell
                
                
                //            if  indexPath.section == 0 && indexPath.row == self.dataSource[0].1.count*2 - 3 {
                //                let textView = UITextView.init(frame: CGRect(x: 0, y: 5, width: kScreenWidth - 20, height: 170));
                //                cell?.contentView.addSubview(textView);
                //            }
                let contentModel = contents[indexPath.section].Contents[indexPath.row / 2] as! EquipmentPatrolGroupConentModel
                cell?.delegate = self;
                cell?.safeCheckRefresh(model: item, selectItemHeight: height(typeDescription: item.TypeDescription),tempModel:contentModel)
                
                //            if  indexPath.section == 0 && indexPath.row == self.dataSource[0].1.count*2 - 3 {
                ////                cell?.constructTextField.isHidden = false;
                ////                cell?.bottomTextFiledLineView.isHidden = false;
                //                let textView = UITextView.init(frame: CGRect(x: 0, y: 5, width: kScreenWidth - 20, height: 170));
                //                cell?.contentView.addSubview(textView);
                //                cell?.backgroundColor = UIColor.red
                //            }
 
                return cell!
                */
            }
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textMedo = textView.text as! NSString;
    }
}

extension SafeCheckStartViewController: EquipmentPatrolStartSelectDelegate {
    func selectedValue(tag: Int, descriptions: [String]) {
        let contentModel = contents[tag/1000].Contents[tag%1000] as! EquipmentPatrolGroupConentModel
        contentModel.Caption = descriptions[1]
        contentModel.Value = descriptions[2]
        contentModel.IsException = descriptions[4]
//        let contentModel = contents[tag/1000].Contents[tag%1000] as! EquipmentPatrolGroupConentModel
//        self.dataSource[tag/1000].1.[tag%1000];
//        let rows = self.dataSource[tag/1000].1
//        let item = rows[tag%1000]
//        item.TypeDescription = descriptions.joined(separator: "|");
////        let model = EquipmentPatrolGroupConentModel();
////        model.TaskPK = contentModel.TaskPK;
////        model.IMemo = contentModel.IMemo;
////        model.Caption = descriptions[1]
////        model.Value = descriptions[2]
////        model.IsException = descriptions[4]
////        contents[tag/1000].Contents[tag%1000] = model;
////        self.tableView.reloadData()
//        changeContentModelState(section: tag/1000, row: tag%1000, index: tag%1000, content: descriptions.joined(separator: "|"));
    }
    
    func valueChangeSelect(tag: Int, index: Int, content: String) {
        changeContentModelState(section: tag/1000, row: tag%1000, index: index, content: content)
    }
}

extension SafeCheckStartViewController {
    
    func changeContentModelState(section: Int, row: Int, index: Int, content: String) {
        let contentModel = contents[section].Contents[row] as! EquipmentPatrolGroupConentModel
        
        if index == 0 {
            //巡检值
            contentModel.Caption = content
            contentModel.Value = content
        } else {
            contentModel.IMemo = content
        }
    }
    
    //高度计算
    func height(typeDescription: String?) -> CGFloat {
        if let typeDescription = typeDescription {
            let types = (typeDescription).components(separatedBy: ";")
            if types.count % 4 == 0 {
                return CGFloat(types.count / 4 * 30)
            } else {
                return CGFloat((types.count / 4 + 1) * 30)
            }
        }
        return 0.0
    }
    
    //图片处理
    func dealPics() {
        self.fileNames = ""
        self.filePaths = ""
        for (index, image) in self.selectImageShowView.selectedPhotos.enumerated() {
            
            let printTime = "\(Date().timeIntervalSince1970 * 1000)"
            
            let imageName = "\(String(describing: printTime))\(String(index))"
            //上传服务器图片名称
            let path = "\(self.itemAssociateCode)\(imageName)"
            
            let diskCache = DiskCache()
            //let pathStr = diskCache.cachePath(proName: path)+"\(imageName).png"
            self.filePaths.append(path + ",")
            self.fileNames.append("\(imageName).png" + ",")
            
            picPrints.append(image as! UIImage)
            
            let data = CompressionImage.compressionImage(image as! UIImage)
            //文件存储
            diskCache.saveDataToCache(proName: path, fileName: imageName, Data: data! as NSData)
            
        }
    }
    
    //图片存储
    
    //base64
    func base64(string: String) -> String? {
        let utf8EncodeData = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        // 将NSData进行Base64编码
        let base64String = utf8EncodeData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: UInt(0)))
        return base64String
    }
    
    //unbase64
    func unBase64(base64String: String) -> String? {
        // 将base64字符串转换成NSData
        let base64Data = NSData(base64Encoded:base64String, options: NSData.Base64DecodingOptions(rawValue: 0))
        // 对NSData数据进行UTF8解码
        let stringWithDecode = NSString(data:base64Data! as Data, encoding:String.Encoding.utf8.rawValue)
        return stringWithDecode as String?
    }
}

extension SafeCheckStartViewController: SelectImageShowViewDelegate {
    func presentMyViewController(_ viewController: UIViewController!, animated: Bool) {
        self.present(viewController, animated: animated, completion: nil)
    }
    
    func terminateDealPictures(_ picture: UIImage!) -> UIImage! {
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let printTime = dateFmt.string(from: Date())
        
        let resultImage = picture.waterMarkedImage(waterMarkText: printTime, waterMarkTextColor: UIColor.red, waterMarkTextFont: UIFont.systemFont(ofSize: 80))
        return resultImage
    }
}

extension SafeCheckStartViewController: SafeCheckMemoTextFieldDelegate {
    
    func safeCheckMemoTextFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            self.fileMemo = text
        }
    }
    
    func safeCheckMemoTextFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func safeCheckMemoTextFieldDidEndEditing(_ textField: UITextField) {
        
    }
}

extension SafeCheckUnCommitViewController {
}




