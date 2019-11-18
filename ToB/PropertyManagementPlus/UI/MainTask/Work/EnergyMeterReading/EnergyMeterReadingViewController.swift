//
//  EnergyMeterReadingViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 17/5/29.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import UIKit

enum EnergyMeterReadingType:Int {
    case total = 0
    case alreadyRead = 1
    case noRead = 2
    case noUpload = 3
}

class EnergyMeterReadingViewController: BaseTableViewController,SearchBarViewDelegate,ManagementIndexFilterResultDelegate,UISearchBarDelegate {
    
    var dataSource: NSMutableArray = NSMutableArray()
    var storeDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    //CustomSearchBar
    var searchBar = SearchBarView()
    
    var mySearchBar = UISearchBar();
    
    var fileterBackView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
    var filterView = ManagementIndexFilterView()
    var filterDatas: NSMutableDictionary = NSMutableDictionary(capacity: 20)
    
    let energyMeterTag = 7

    var isCommon = true
    var commonNumber = 0
    var unitNumber = 0
    
    var type: EnergyMeterReadingType = EnergyMeterReadingType.total
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var energyMeterReadingSearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if energyMeterReadingSearchTableViewCell == nil {
            
            energyMeterReadingSearchTableViewCell = Bundle.main.loadNibNamed("EnergyMeterReadingSearchTableViewCell", owner: nil, options: nil)?.first as! EnergyMeterReadingSearchTableViewCell
            energyMeterReadingSearchTableViewCell?.accessoryType = .none
        }
        
        let tempCell: EnergyMeterReadingSearchTableViewCell = energyMeterReadingSearchTableViewCell as! EnergyMeterReadingSearchTableViewCell
        
        tempCell.contentView.viewWithTag(energyMeterTag)?.removeFromSuperview()
        
        let model = dataSource[indexPath.section] as! EnergyMeterReadingModel
        
        if (isCommon) {
            tempCell.titleLabel.text = model.MeterName!
        }else {
            tempCell.titleLabel.text = model.CustomerName?.appending("[").appending(model.MeterName!).appending("]")
        }
        
        if (model.isModify?.compare("1") == .orderedSame) {
            tempCell.readStatusImageView.isHidden = false
        }else {
            tempCell.readStatusImageView.isHidden = true
        }
        
        tempCell.codeLabel.text = ""
        
        var pBuildingName = ""
        if (model.PBuildingName?.compare("") != .orderedSame) {
            pBuildingName = "/".appending(model.PBuildingName!)
        }
        
        var pFloorName = ""
        if (model.PFloorName?.compare("") != .orderedSame) {
            pFloorName = "/".appending(model.PFloorName!)
        }
        
        var pRoomName = ""
        if (model.PRoomName != nil && model.PRoomName?.compare("") != .orderedSame) {
            pRoomName = "/".appending(model.PRoomName!)
        }
        
        tempCell.positionLabel.text = model.PProjectName?.appending(pBuildingName).appending(pFloorName).appending(pRoomName)
        
        for (_,value) in filterDatas {
            BaseTool.changeColor(withKey: filterDatas["MeterKind"] as! String, content: tempCell.titleLabel.text, textLabel: tempCell.titleLabel)
            BaseTool.changeColor(withKey: value as! String, content: tempCell.positionLabel.text, textLabel: tempCell.positionLabel)
        }
        
        /*
         本次用量
         ① 当本次读数 >= 上次读数 时，本次用量 = (本次度数 - 上次读书) * 表倍率 + 调整用量。
         ② 当本次读数 <  上次读数 时，本次用量 = (表量程 + 本次度数 - 上次读书) * 表倍率 + 调整用量。
         */
        
        var quantity = 0.0
        let multiPower = BaseTool.toFloat(model.MultiPower)
        let quantityAdjust = BaseTool.toFloat(model.QuantityAdjust)
        let curDegree = BaseTool.toFloat(model.CurDegree)
        let preDegree = BaseTool.toFloat(model.PreDegree)
        let quantityRange = BaseTool.toFloat(model.Range)
        
        if curDegree >= preDegree {
            quantity = Double((curDegree - preDegree) * multiPower + quantityAdjust)
        } else {
            quantity = Double((quantityRange + curDegree - preDegree) * multiPower + quantityAdjust)
        }
        
        let energyMeterReadingView = EnergyMeterReadingView(frame: CGRect(x: 0, y: 95, width: kScreenWidth, height: 30), names: ["上次","本次","用量"], contents: [model.PreDegree ?? "",model.CurDegree ?? "",String(quantity)])
        energyMeterReadingView?.tag = energyMeterTag
        tempCell.contentView.addSubview(energyMeterReadingView!)
        
        return energyMeterReadingSearchTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = dataSource[indexPath.section] as! EnergyMeterReadingModel
        
        let event = EventAddViewController()
        event.energyMeterReadingModel = model
        event.eventType = .energyMeterUnit
        self.push(viewController: event)
        
    }
    
    //MARK: SearchBarViewDelegate
    func textFieldDidChange(_ textField: UITextField!) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    //MARK: ManagementIndexFilterResultDelegate
    func selectFilter(withResultDict result: [AnyHashable : Any]!) {

        let dict = result as NSDictionary
        filterDatas = NSMutableDictionary(dictionary: dict)
        
        dataSource = NSMutableArray(array: DataInfoDetailManager.shareInstance().fetchEnergyMeterData(withData: dict, type: (isCommon ? 1 : 0)))
        self.contentTableView?.reloadData()
        
        var searchText = ""
        for (_,value) in filterDatas {
            let valueStr = value as! String
            if (valueStr.compare("") != .orderedSame) {
                searchText.append(valueStr)
                searchText.append(" ")
            }
        }
        if (searchText.compare("") != .orderedSame) {
            searchBar.textSearchDisplayController.searchBar.text = searchText
        }
    }
    
    func initData() {
        storeDataSource = NSMutableArray(array: dataSource)
        contentTableView?.reloadData()
    }
    
    func createUI() {
        
        let button = self.createTitleButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40.0), title: "", titleColor: UIColor.white, backGroundColor: UIColor.clear, textAlignment: .center, target: self, action: #selector(EnergyMeterReadingViewController.filter))
        button.setImage(UIImage(named: "ic_more_normal"), for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        searchBar = SearchBarView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 45), placeHolder: "请输入关键字,多个关键字用空格隔开",searchBarType: .energyMeter)
        searchBar.delegate = self
        self.view.addSubview(searchBar)
        searchBar.isCommon = isCommon
        searchBar.dataSource = dataSource
        let tempVC =  searchBar.textSearchDisplayController.searchResultsController as! SearchResultsTableViewController;
        tempVC.block = {model in
            let event = EventAddViewController()
            event.energyMeterReadingModel = model
            event.eventType = .energyMeterUnit
            self.navigationController?.pushViewController(event, animated: true);
//            self.push(viewController: event)
        }
        
//        mySearchBar = UISearchBar.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 45));
//        mySearchBar.placeholder  = "dd";
//        mySearchBar.delegate = self as UISearchBarDelegate;
//        self.view .addSubview(mySearchBar);
        
        var title = ""
        
        if (isCommon) {
            title = "公用表列表，共".appending(String(dataSource.count)).appending("张")
        }else {
            title = "单元表列表，共".appending(String(dataSource.count)).appending("张")
        }
        
        self.setTitleView(titles: [title as NSString])
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y:  searchBar.bounds.size.height, width: kScreenWidth, height: kScreenHeight - 49 - 40 - 40), hasHeader: false, hasFooter: false)
        
        contentTableView?.separatorStyle = .none
        
        buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        
        
        filterView = ManagementIndexFilterView(frame: CGRect(x: kScreenWidth, y: 0, width: kScreenWidth - 60, height: kScreenHeight), type: (isCommon ? 1 : 0))
        filterView.delegate = self
        //添加侧滑视图
        fileterBackView.isHidden = true
        fileterBackView.isUserInteractionEnabled = true
        UIApplication.shared.keyWindow?.addSubview(fileterBackView)
        fileterBackView.addSubview(filterView)
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(filterBack))
        fileterBackView.addGestureRecognizer(tapGes)
    }
    
    @objc func filter() {
        UIView.animate(withDuration: 1.0, animations: {
            self.fileterBackView.isHidden = false
            self.filterView.frame = CGRect(x: 60, y: 0, width: kScreenWidth - 60, height: kScreenHeight)
            self.fileterBackView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        })
    }
    
    @objc func filterBack() {
        
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            
            self.filterView.frame = CGRect(x: kScreenWidth, y: 0, width: kScreenWidth - 60, height: kScreenHeight)
            self.fileterBackView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            
        }){(finished) -> Void in
            self.fileterBackView.isHidden = true
        }
        
    }

//    func check(name:NSString,search:UISearchBar) {
//        
//    }
}
