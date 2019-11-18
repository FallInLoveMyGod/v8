//
//  EquipmentPatrolGroupStartViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/17.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class EquipmentPatrolGroupStartViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let userInfo = LocalStoreData.getUserInfo()
    
    var saveSuccess = false
    var result: NSArray = NSArray()
    var item: NSArray = NSArray()
    var pInfo: NSArray = NSArray()
    var contents: Array<EquipmentPatrolGroupModel> = Array<EquipmentPatrolGroupModel>()
    
    
    fileprivate var isModify = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.createUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initData() {
        
        if contents.count != 0 {
            isModify = true
            return
        }
        
        var index = 0
        for subItem in item {
            
            var subContents: Array<EquipmentPatrolGroupConentModel> = Array<EquipmentPatrolGroupConentModel>()
            
            
            var groupModel: EquipmentPatrolGroupModel = EquipmentPatrolGroupModel()
            var tuples: (Array<EquipmentPatrolGroupConentModel>, EquipmentPatrolGroupModel)?
            if subItem is NSDictionary {
                tuples = setContent(subItem: subItem, index: index)
            } else if subItem is NSArray{
                tuples = setContent(subItem: (subItem as! NSArray).firstObject!, index: index)
            }
            subContents = (tuples?.0)!
            groupModel = (tuples?.1)!
            
            groupModel.Contents = subContents
            
            contents.append(groupModel)
            
            index = index + 1
        }
    }
    
    func setContent(subItem: Any, index: Int) -> (Array<EquipmentPatrolGroupConentModel>, EquipmentPatrolGroupModel) {
        
        var subContents: Array<EquipmentPatrolGroupConentModel> = Array<EquipmentPatrolGroupConentModel>()
        
        let groupModel: EquipmentPatrolGroupModel = EquipmentPatrolGroupModel()
        
        if let equipDict = subItem as? NSDictionary {
            
            groupModel.out_trade_no = GUIDGenarate.stringWithUUID()
            groupModel.PollingPK = equipDict["PollingPK"] as? String
            groupModel.TypePK = equipDict["TypePK"] as? String
            groupModel.EquipmentPK = equipDict["EquipmentPK"] as? String
            groupModel.Finishman = userInfo?.upk ?? ""
            
            let resultDict = result[index] as! NSDictionary
            groupModel.ProjectPK = resultDict["ProjectPK"] as? String
            
            for subPInfo in pInfo {
                
                
                
                let contentModel = EquipmentPatrolGroupConentModel()
                let subPInfoDict = subPInfo as! NSDictionary
                contentModel.TaskPK = subPInfoDict["TaskPK"] as? String
//                groupModel.ProjectPK = subPInfoDict["ProjectPK"] as? String
                
                if groupModel.ProjectPK != subPInfoDict["ProjectPK"] as? String {
                    continue
                }
                
                if (subPInfoDict["Type"] as! String) == "1" {
                    //选择型
                    if let typeDescription = subPInfoDict["TypeDescription"] {
                        let types = (typeDescription as! String).components(separatedBy: ";")
                        for value in types {
                            let values = value.components(separatedBy: "|")
                            if values[3] == "1" {
                                //默认值
                                contentModel.Caption = values[1]
                                contentModel.Value = values[2]
                                contentModel.IsException = values[4]
                                break
                            }
                        }
                    }
                } else {
                    if let typeDescription = subPInfoDict["TypeDescription"] {
                        let types = (typeDescription as! String).components(separatedBy: "|")
                        contentModel.Caption = types[0]
                        contentModel.Value = types[0]
                        contentModel.IsException = types[4]
                    }
                }
                subContents.append(contentModel)
            }
        }
        
        return (subContents, groupModel)
    }

    func createUI() {
        
        self.setTitleView(titles: ["设备巡检"])
        
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.backgroundColor = UIColor.groupTableViewBackground
        tableView?.separatorStyle = .none
        
        if isModify {
            buttonAction(titles: ["返回","修改"], actions: [#selector(pop),#selector(save)], target: self)
        } else {
            buttonAction(titles: ["返回","保存结果"], actions: [#selector(pop),#selector(save)], target: self)
        }

    }
    
    //type
    func type(model: EquipmentPatrolGroupConentModel) -> Int {
        let models = findModel(content: " WHERE TaskPK = '".appending(model.TaskPK!).appending("'"))
        if models.count == 0 {
            return 0
        }
        return BaseTool.toInt(models[0].Type)
    }
    
    //height type = 1
    func height(model: EquipmentPatrolGroupConentModel) -> CGFloat {
        let models = findModel(content: " WHERE TaskPK = '".appending(model.TaskPK!).appending("'"))
        if models.count == 0 {
            return 0.0
        }
        if let typeDescription = models[0].TypeDescription {
            let types = (typeDescription).components(separatedBy: ";")
            if types.count % 4 == 0 {
                return CGFloat(types.count / 4 * 30)
            } else {
                return CGFloat((types.count / 4 + 1) * 30)
            }
        }
        return 0.0
    }
    
    func findProjectInfo(model: EquipmentPatrolGroupModel) -> (String, String) {
        
        var tuples = ("","")
        
        let dContent = " WHERE EquipmentPK = '"
            .appending(model.EquipmentPK ?? "")
            .appending("'")
            .appending(" AND PollingPK = '")
            .appending(model.PollingPK ?? "")
            .appending("'")
        
        let dinfos = findDInfoModel(content: dContent)
        
        if dinfos.count == 0 {
            return ("", "")
        }
        
        let dinfo = dinfos[0]
        tuples.0 = dinfo.EquipmentName!
        
        let pContent = " WHERE TypePK = '"
            .appending(model.TypePK ?? "")
            .appending("'")
            .appending(" AND ProjectPK = '")
            .appending(model.ProjectPK ?? "")
            .appending("'")
        let pinfos = findPInfoModel(content: pContent)
        if pinfos.count == 0 {
            return ("", "")
        }
        let pinfo = pinfos[0]
        tuples.1 = pinfo.ProjectName!
        
        return tuples
    }
    
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
    
    func findModel(content: String) -> [EquipmentPatrolGroupItemModel] {
        let models = EquipmentPatrolGroupItemModel.find(byCriteria: content)
        return models as! [EquipmentPatrolGroupItemModel]
    }
    
    func findDInfoModel(content: String) -> [EquipmentPatrolGroupDInfosModel] {
        let models = EquipmentPatrolGroupDInfosModel.find(byCriteria: content)
        return models as! [EquipmentPatrolGroupDInfosModel]
    }
    
    func findPInfoModel(content: String) -> [EquipmentPatrolGroupPInfosModel] {
        let models = EquipmentPatrolGroupPInfosModel.find(byCriteria: content)
        return models as! [EquipmentPatrolGroupPInfosModel]
    }
    
    func setTextField(contentTextField: UITextField) {
//        contentTextField.inputAccessoryView = BaseTool.addBar(withTarget: self, action: #selector(EquipmentPatrolGroupStartViewController.tap))
    }
    
    @objc func save() {
        var indexSection = 0
        var indexRow = 0
        for groupModel in contents {
            for model in groupModel.Contents {
                let contentModel = model as! EquipmentPatrolGroupConentModel
                if contentModel.Caption == ""
                    || contentModel.Value == "" {
                    //|| contentModel.IMemo == ""
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
                    
                    return
                }
                indexRow += 1
            }
            indexSection += 1
        }
        
        for groupModel in contents {
            
            let changeArray = NSMutableArray(capacity: 20)
            
            for model in groupModel.Contents {
                let contentModel = model as! EquipmentPatrolGroupConentModel
                let json = contentModel.yy_modelToJSONString()
                
                let data = json?.data(using: .utf8)
                let dictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                changeArray.add(dictionary!)
                
            }
            
            groupModel.jsonContent = changeArray.yy_modelToJSONString()
            groupModel.isCommit = "0"
            
            let dateFmt = DateFormatter()
            dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let endTime = dateFmt.string(from: Date())
            
            groupModel.FinishTime = endTime
            groupModel.saveOrUpdate()
        }
        
        let childs = self.navigationController?.childViewControllers
        if isModify {
            super.pop()
        } else {
            self.navigationController?.popToViewController((childs?[(childs?.count)! - 3])!, animated: true)
        }
        
    }
    
    func tap() {
        self.view.endEditing(true)
    }
    
    override func pop() {
        if saveSuccess {
            super.pop()
        } else {
            
            let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: "巡检结果尚未保存，是否退出？", preferredStyle: .alert)
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

extension EquipmentPatrolGroupStartViewController: EquipmentPatrolStartNormalDelegate {
    func valueChange(tag: Int, index: Int, content: String) {
        changeContentModelState(section: tag/1000, row: tag%1000, index: index, content: content)
    }
}

extension EquipmentPatrolGroupStartViewController: EquipmentPatrolStartSelectDelegate {
    func selectedValue(tag: Int, descriptions: [String]) {
        let contentModel = contents[tag/1000].Contents[tag%1000] as! EquipmentPatrolGroupConentModel
        contentModel.Caption = descriptions[1]
        contentModel.Value = descriptions[2]
        contentModel.IsException = descriptions[4]
    }

    func valueChangeSelect(tag: Int, index: Int, content: String) {
        changeContentModelState(section: tag/1000, row: tag%1000, index: index, content: content)
    }
}

extension EquipmentPatrolGroupStartViewController: UITableViewDataSource,UITableViewDelegate {
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let model: EquipmentPatrolGroupModel = contents[section]
        return model.Contents.count * 2 - 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 1 {
            return 10.0
        }
        let model: EquipmentPatrolGroupModel = contents[indexPath.section]
        let itemModel = model.Contents[indexPath.row / 2] as! EquipmentPatrolGroupConentModel
        
        let item = EquipmentPatrolGroupItemModel.find(byCriteria: " WHERE TaskPK = '".appending(itemModel.TaskPK!).appending("'"))[0] as! EquipmentPatrolGroupItemModel
        
        var methodHeight = BaseTool.calculateHeight(withText: item.CheckMeans, font: UIFont.systemFont(ofSize: 14), isCaculateWidth: false, data: kScreenWidth - 95)
        methodHeight = methodHeight < 35.0 ? 10.0 : methodHeight - 35.0
        var requireHeight = BaseTool.calculateHeight(withText: item.Need, font: UIFont.systemFont(ofSize: 14), isCaculateWidth: false, data: kScreenWidth - 95)
        requireHeight = requireHeight < 35.0 ? 10.0 : requireHeight - 35.0
        
        if type(model: itemModel) == 1 {
            return height(model: itemModel) + 155 + methodHeight + requireHeight
        }
        return 180 + methodHeight + requireHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
        
        let model: EquipmentPatrolGroupModel = contents[section]
        let tuples = findProjectInfo(model: model)
        
        let contentLabel = UILabel(frame: backView.bounds)
        contentLabel.textColor = UIColor.black
        contentLabel.backgroundColor = kThemeColor
        contentLabel.text = "  ".appending((tuples.0).appending("-").appending(tuples.1))
        
        backView.addSubview(contentLabel)
        return backView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "normal"
        let selectCellID = "select"
        
        if indexPath.row % 2 == 1 {
            let cell: UITableViewCell = UITableViewCell()
            cell.backgroundColor = UIColor.groupTableViewBackground
            return cell
        }
        
        let model: EquipmentPatrolGroupModel = contents[indexPath.section]
        
        if type(model: model.Contents[indexPath.row / 2] as! EquipmentPatrolGroupConentModel) == 1 {
            
            var select = tableView.dequeueReusableCell(withIdentifier: selectCellID)
            
            if select == nil {
                
                select = Bundle.main.loadNibNamed("EquipmentPatrolStartSelectTableViewCell", owner: nil, options: nil)?.first as! EquipmentPatrolStartSelectTableViewCell
                select?.accessoryType = .none
            }
            
            let selectCell: EquipmentPatrolStartSelectTableViewCell = select as! EquipmentPatrolStartSelectTableViewCell
            selectCell.tag = indexPath.section * 1000 + indexPath.row/2
            selectCell.delegate = self
            
            let itemModel = model.Contents[indexPath.row / 2] as! EquipmentPatrolGroupConentModel
            selectCell.refreshUI(model: itemModel, selectItemHeight: height(model: itemModel))
            
            selectCell.constructTextField.text = itemModel.IMemo
            if let infoDict = self.pinfoData(model: itemModel) {
                if let isRequire = infoDict["IsRequired"] as? String, isRequire == "0" {
                    selectCell.isMustImageView.image = UIImage(named: "sendmsgfail")
                } else {
                    selectCell.isMustImageView.image = UIImage(named: "")
                }
            }
            return select!
        }
        
        var patrol = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if patrol == nil {
            
            patrol = Bundle.main.loadNibNamed("EquipmentPatrolStartNormalTableViewCell", owner: nil, options: nil)?.first as! EquipmentPatrolStartNormalTableViewCell
            patrol?.accessoryType = .none
        }
        
        let parolTempCell: EquipmentPatrolStartNormalTableViewCell = patrol as! EquipmentPatrolStartNormalTableViewCell
        parolTempCell.tag = indexPath.section * 1000 + indexPath.row/2
        parolTempCell.delegate = self
        
        let itemModel = model.Contents[indexPath.row / 2] as! EquipmentPatrolGroupConentModel
        parolTempCell.refreshUI(model: itemModel)
        parolTempCell.checkTextField.text = itemModel.Value
        parolTempCell.instructionTextField.text = itemModel.IMemo
        
        if let infoDict = self.pinfoData(model: itemModel) {
            if let isRequire = infoDict["IsRequired"] as? String, isRequire == "0" {
                parolTempCell.isMustImageView.image = UIImage(named: "sendmsgfail")
            } else {
                parolTempCell.isMustImageView.image = UIImage(named: "")
            }
        }
        return patrol!
    }
}

extension EquipmentPatrolGroupStartViewController {
    func pinfoData(model: EquipmentPatrolGroupConentModel) -> NSDictionary? {
        for dict in pInfo {
            if let infoDict = dict as? NSDictionary {
                if let taskPK = infoDict["TaskPK"] as? String, taskPK == model.TaskPK {
                    return dict as? NSDictionary
                }
            }
        }
        
        return nil
    }
}
