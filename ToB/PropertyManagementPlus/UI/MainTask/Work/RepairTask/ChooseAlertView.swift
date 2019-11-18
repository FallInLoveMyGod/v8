//
//  ChooseAlertView.swift
//  PropertyManagementPlus
//
//  Created by 田耀琦 on 2018/5/24.
//  Copyright © 2018年 Lesoft. All rights reserved.
//

import UIKit

protocol ChooseAlertDelegate {
    func tableViewSelectWithHouseModel(model:HouseStructureModel)
}

class ChooseAlertView: UIView,UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myDataSource.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model:HouseStructureModel = self.myDataSource[indexPath.row] as! HouseStructureModel
        var cell = tableView .dequeueReusableCell(withIdentifier: "UITableViewCell");
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "UITableViewCell");
        }
        cell?.textLabel?.text = model.Name;
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.hidden()
        let model:HouseStructureModel = self.myDataSource[indexPath.row] as! HouseStructureModel
        if let dele = delegate {
            dele.tableViewSelectWithHouseModel(model: model);
        }
    }
    
    var isShow:Bool = false
    
    var dataSource:NSArray? {
        didSet {
            self.myDataSource.addObjects(from: dataSource as! [Any])
            print(self.myDataSource.count)
//            self.addSubview(self.mytable)
            self.mytable.reloadData()
        }
    }
    
    var myDataSource:NSMutableArray = NSMutableArray();
    
    var delegate:ChooseAlertDelegate?
    
    lazy var mytable:UITableView = {
        let tableView = UITableView.init(frame: CGRect(x: 90, y: 64, width: kScreenWidth - 90, height: kScreenHeight - kNavbarHeight - 64 - 20), style: UITableViewStyle.plain)
        tableView.backgroundColor = UIColor.white.withAlphaComponent(1.0);
        tableView.delegate = self as UITableViewDelegate;
        tableView.dataSource = self as UITableViewDataSource;
        return tableView;
    }();
    
    lazy var titleLab:UILabel = {
        let lab = UILabel.init(frame: CGRect(x: 90, y: 0, width: kScreenWidth - 90, height: 64))
        lab.backgroundColor = UIColor.blue.withAlphaComponent(1.0)
        lab.text = "请选择筛选楼盘";
        lab.alpha = 1;
        lab.font = UIFont.systemFont(ofSize: 18);
        lab.textAlignment = NSTextAlignment.center;
        return lab;
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGray.withAlphaComponent(0);
        self.addSubview(self.titleLab);
        self.addSubview(self.mytable)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func show() {
        isShow = true;
        UIView .animate(withDuration: 0.6) {
            self.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight);
            self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4);
        }
    }
    
    open func hidden() {
        isShow = false;
        UIView.animate(withDuration: 0.1) {
            self.frame = CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight);
            self.backgroundColor = UIColor.lightGray.withAlphaComponent(0);
        }
        self.removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.hidden()
    }
}
