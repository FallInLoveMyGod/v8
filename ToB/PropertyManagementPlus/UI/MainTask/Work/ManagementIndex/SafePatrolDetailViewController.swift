//
//  SafePatrolDetailViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/6/10.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

class SafePatrolDetailViewController: BaseTableViewController {

    fileprivate var floatingView: FJFloatingView = FJFloatingView(frame: CGRect(x: kScreenWidth - 80, y: kScreenHeight - 190, width: 60, height: 60))
    
    var info = NSDictionary()
    var projectInfo = NSDictionary()
    var dataSource = NSMutableArray(capacity: 20)
    var safePatrolModel: SafePatrolModel?
    var isComplete = false
    
    let safePatrolDetailTAG = 7
    
    var checkTime = ""
    var checkState = ""
    var checkMemo = ""
    
    fileprivate let dateFmt = DateFormatter()
    
    var isPop = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //SafePatrolDetailView
        initData()
        createUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            cell?.selectionStyle = .none
        }
        //SafePatrolDetailView
        cell?.contentView.viewWithTag(safePatrolDetailTAG)?.removeFromSuperview()
        
        let safePatrolDetailView = SafePatrolDetailView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44.0), width: 50.0, count: 3)
        let dict = dataSource[indexPath.row] as! NSDictionary
        
        var pollingPosition = dict["PollingPosition"] ?? ""
        var tip = "未巡检"
        var tipColor = UIColor.red
        if isComplete {
            pollingPosition = dict["CheckMemo"] ?? ""
            if let checkState = dict["CheckState"] as? String {
                if checkState == "2" {
                    tip = "已跳过"
                } else if checkState == "3" {
                    tip = "异常终止"
                } else if checkState == "1" {
                    tip = "已巡检"
                }
                tipColor = UIColor.green
            }
        }
        safePatrolDetailView?.reload(withTitles: [dict["PointIndex"] ?? "",pollingPosition,tip], image:"", colors:[UIColor.darkText,UIColor.darkText,tipColor])
        cell?.contentView.addSubview(safePatrolDetailView!)
        return cell!
    }
    
    func initData() {
        
        dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let model = self.safePatrolModel {
            
            dataSource = NSMutableArray(array: BaseTool.dictionary(withJsonString: model.LinePoints) as! NSArray)
            let source = NSMutableArray(capacity: 20)
            for sub in dataSource {
                if let subDict = sub as? NSDictionary {
                    if let currentState = projectInfo["CurrentState"] as? String{
                        if currentState == "未完成" {
                            if let _ = subDict["CheckState"] {
                                
                            } else {
                                source.add(subDict)
                            }
                        } else {
                            source.add(subDict)
                        }
                    }
                }
            }
            dataSource = source
        } else {
            
            dataSource = NSMutableArray(array: (info["LinePoints"] as! NSArray).sorted(by: { (first, second) -> Bool in
                if let firstDict = first as? NSDictionary, let secondDict = second as? NSDictionary {
                    let index1 = firstDict["PointIndex"] as! String
                    let index2 = secondDict["PointIndex"] as! String
                    return index1.compare(index2) == .orderedAscending ? true : false
                }
                return false
            }))
            
        }
        
        if let currentState = projectInfo["CurrentState"] as? String {
            if currentState != "未完成" {
                isComplete = true
            }
        }
        
    }
    
    func createUI() {
        
        self.setTitleView(titles: [info["LineName"] as! NSString])
        
        var titles = ["序号","位置信息","巡检情况"]
        
        if isComplete {
            titles = ["序号","巡检备注","巡检情况"]
        }
        
        let managementItemView = ManagementItemView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40), titles: titles, width: 50.0)
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y:  (managementItemView?.frame.size.height)!, width: kScreenWidth, height: kScreenHeight - 49 - (managementItemView?.frame.size.height)!), hasHeader: false, hasFooter: false)
        
        contentTableView?.separatorStyle = .none
        
        self.view.addSubview(managementItemView!)
        
        var bottomTitles = ["返回","跳过","异常结束"]
        
        if isComplete {
            bottomTitles = ["返回"]
        } else {
            floatingView.iconImageView.image = UIImage(named: "icon_sys_pressed")
            floatingView.delegate = self
            self.view.addSubview(floatingView)
        }
        
        buttonAction(titles: bottomTitles as NSArray, actions: [#selector(pop),#selector(skip),#selector(exceptionFinish)], target: self)
        
        self.contentTableView?.reloadData()
    }
    
    override func pop() {
        
        if isComplete {
            super.pop()
            return
        }
        
        let tipAlertView: UIAlertController = UIAlertController(title: "提示", message: "尚未巡检结束，确认退出？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "返回", style: .default, handler: {
            (action: UIAlertAction) -> Void in
        })
        let confirmAction = UIAlertAction(title: "确认", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            
            if (self.isPop) {
                self.navigationController?.popViewController(animated: true)
            }else {
                let childs = self.navigationController?.childViewControllers
                if (Int((childs?.count)!) > 3) {
                    self.navigationController?.popToViewController((childs?[Int((childs?.count)!) - 3])!, animated: true)
                }
            }
            
        })
        
        tipAlertView.addAction(confirmAction)
        tipAlertView.addAction(cancelAction)
        self.present(tipAlertView, animated: true, completion: {})
    }
    
    //跳过
    @objc func skip() {
        self.alertType(type: 0)
    }
    //异常结束
    @objc func exceptionFinish() {
        self.alertType(type: 1)
    }
    
    func alertType(type: NSInteger) {
        var title = "输入跳过原因"
        if (type == 1) {
            title = "输入异常结束原因"
        }
        let tipAlertView: UIAlertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        tipAlertView.addTextField { (contentTextField) in
            
            if (type == 0) {
                contentTextField.placeholder = "请输入跳过原因"
            }else {
                contentTextField.placeholder = "请输入异常结束原因"
            }
            contentTextField.addTarget(self, action: #selector(SafePatrolDetailViewController.textFieldDidChange(_:)), for: .editingChanged)
        }
        let cancelAction = UIAlertAction(title: "返回", style: .default, handler: {
            (action: UIAlertAction) -> Void in
        })
        let confirmAction = UIAlertAction(title: "确认", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            
            var description = ""
            if (type == 0) {
                self.checkState = "2"
            }else {
                self.checkState = "3"
                description = self.checkMemo
            }
            
            let dateStr = self.dateFmt.string(from: Date())
            self.checkTime = dateStr
            
            if type == 0 {
                
                self.dataSource.replaceObject(at: 0, with: self.addValue(dictionary: self.dataSource[0] as! NSDictionary))
                
            } else {
                
                //异常结束
                
                var index = 0
                for sub in self.dataSource {
                    self.dataSource.replaceObject(at: index, with: self.addValue(dictionary: sub as! NSDictionary))
                    index = index + 1
                }
                
            }
            self.saveData(description: description, isScan: false)
        })
        tipAlertView.addAction(confirmAction)
        tipAlertView.addAction(cancelAction)
        self.present(tipAlertView, animated: true, completion: {})
    }
    
    @objc open func textFieldDidChange(_ textField : UITextField) {
        self.checkMemo = textField.text!
    }
    
    func addValue(dictionary: NSDictionary) -> NSDictionary {
        let changeDict = NSMutableDictionary(dictionary: dictionary)
        changeDict["CheckTime"] = self.checkTime
        changeDict["CheckState"] = self.checkState
        changeDict["CheckMemo"] = self.checkMemo
        return changeDict
    }
    
    func saveData(description: String, isScan: Bool) {
        
        let multProjectInfo = NSMutableDictionary(dictionary: self.projectInfo)
        multProjectInfo["isScan"] = "0"
        multProjectInfo["StartTime"] = self.checkTime
        multProjectInfo["LineCheckState"] = self.checkState
        multProjectInfo["Description"] = description
        
        multProjectInfo["CurrentState"] = "未完成"
        
        let endTime = dateFmt.string(from: Date())
        
        if self.checkState == "2" || self.checkState == "1" {
            
            if self.checkState == "1" {
                if isScan {
                    multProjectInfo["isScan"] = "1"
                }
            }
            
            if self.dataSource.count == 1 {
                multProjectInfo["CurrentState"] = "未提交"
                multProjectInfo["EndTime"] = endTime
                if let scan = multProjectInfo["isScan"] as? String {
                    if scan == "0" {
                        multProjectInfo["LineCheckState"] = "2"
                    } else {
                        multProjectInfo["LineCheckState"] = "1"
                    }
                }
            }
            
        } else if self.checkState == "3" {
            multProjectInfo["CurrentState"] = "未提交"
            multProjectInfo["EndTime"] = endTime
        }
        
        if let model = self.safePatrolModel {
            self.safePatrolModel = model.set(multProjectInfo, self.info, NSArray(array: self.dataSource))
        } else {
            self.safePatrolModel = SafePatrolModel().set(multProjectInfo, self.info, NSArray(array: self.dataSource))
        }
        self.safePatrolModel?.saveOrUpdate()
        
        if self.checkState == "2" || self.checkState == "1" {
            
            self.dataSource.removeObject(at: 0)
            self.contentTableView?.reloadData()
            
            if self.dataSource.count == 0 {
                LocalToastView.toast(text: "该路线已完成!")
                super.pop()
            }
        } else if self.checkState == "3" {
            let childs = self.navigationController?.childViewControllers
            if (Int((childs?.count)!) > 3) {
                LocalToastView.toast(text: "该路线已完成!")
                self.navigationController?.popToViewController((childs?[Int((childs?.count)!) - 3])!, animated: true)
            }
        }
    }
}

extension SafePatrolDetailViewController: FJFloatingViewDelegate {
    func floatingViewClick() {
        
//        self.scan(result: "XJD00000005")
//        return
        let qrcodeVC: QRCodeScanViewController = QRCodeScanViewController()
        qrcodeVC.scanDelegate = self
        self.push(viewController: qrcodeVC)
    }
}

extension SafePatrolDetailViewController: ScanResultDelegate {
    func scan(result: String) {
        var index = 0
        var isExist = false
        for sub in self.dataSource {
            
            let dict = sub as! NSDictionary
            if let pollPK = dict["PollingNo"] as? String {
                if result == pollPK {
                    isExist = true
                    break
                }
            }
            index = index + 1
        }
        
        if isExist {
            
            self.checkState = "1"
            self.checkMemo = "正常巡检"
            self.checkTime = self.dateFmt.string(from: Date())
            
            self.dataSource.replaceObject(at: index, with: self.addValue(dictionary: self.dataSource[index] as! NSDictionary))
            
            saveData(description: "", isScan: true)
            
        } else {
            LocalToastView.toast(text: "该点不是要巡检的对象！")
        }
    }
}
