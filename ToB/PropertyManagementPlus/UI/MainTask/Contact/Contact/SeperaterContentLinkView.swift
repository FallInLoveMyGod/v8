//
//  SeperaterContentLinkView.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/19.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

//TODO:
public protocol SeperaterContentLinkViewDelegate {
    func jumpWithObject(object: AnyObject)
}

open class SeperaterContentLinkView: UIView,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var topContrains: NSLayoutConstraint!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var linkTableView: UITableView!
    
    @IBOutlet weak var topTitleTextLabel: UILabel!
    @IBOutlet weak var nextTitleTextLabel: UILabel!
    
    var delegate : SeperaterContentLinkViewDelegate?
    
    //外协信息
    var outsourcingDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var resultDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var addressBookDict = [String:[OutsourcingDataModel]]()
    var nameKeys: Array<String> = []
    var resultPinYinDataSource: NSMutableDictionary = NSMutableDictionary(capacity: 20)
    
    //同事信息
    var isTopLevelShow: Bool = false
    var colleagueOrganizeSuperpkDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var colleagueOrganizepkDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var colleagueLinkPersonsDataSource: NSMutableArray = NSMutableArray(capacity: 20)
    var linksArray: NSMutableArray = NSMutableArray(capacity: 20)
    
    //外协信息：0 同事信息：1
    var seperaterContentType: Int = 0
    
    open func refresh(content: NSArray, type: Int) {
        
        self.seperaterContentType = type
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        self.linkTableView.estimatedRowHeight = 0;
        self.linkTableView.estimatedSectionHeaderHeight = 0;
        self.linkTableView.estimatedSectionFooterHeight = 0;
        linkTableView.delegate = self
        linkTableView.dataSource = self
        
        linkTableView.separatorStyle = .singleLine
        
        linkTableView.sectionIndexColor = UIColor.darkGray;
        linkTableView.sectionIndexBackgroundColor = UIColor.clear;
        
        if (self.seperaterContentType == 0) {
            
            resultDataSource.removeAllObjects()
            outsourcingDataSource = NSMutableArray(array: content)
            
            let tempDataSource = NSMutableArray(capacity: 20)
            
            if (outsourcingDataSource.count != 0) {
                tempDataSource.add(outsourcingDataSource.firstObject ?? OutsourcingDataModel())
            }
            
            for (index, model) in outsourcingDataSource.enumerated() {
                
                if (index == 0) {
                    continue
                }
                
                let indexModel = model as! OutsourcingDataModel
                let compareModel = tempDataSource[tempDataSource.count - 1] as! OutsourcingDataModel
                
                if (indexModel.type?.compare(compareModel.type!) == .orderedSame) {
                    tempDataSource.add(model)
                }else {
                    resultDataSource.add(NSMutableArray(array: tempDataSource));
                    tempDataSource.removeAllObjects()
                    tempDataSource.add(model)
                }
                
            }
            
            if (tempDataSource.count != 0) {
                resultDataSource.add(NSMutableArray(array: tempDataSource))
            }
            
            var noCategoryArray = NSMutableArray(capacity: 20)
            
            for (index, array) in resultDataSource.enumerated() {
                
                let model = (resultDataSource[index] as! NSArray)[0] as! OutsourcingDataModel
                if (model.type?.caseInsensitiveCompare("") == .orderedSame) {
                    noCategoryArray.addObjects(from: array as! [Any])
                    resultDataSource.removeObject(at: index)
                    break
                }
                
            }
            
            resultDataSource.insert(noCategoryArray, at: 0)
            
            categoryTableView.reloadData()
            
        }else if (self.seperaterContentType == 1) {
            
            print(categoryTableView.frame)
            
            
            
            categoryTableView.reloadData()
        }
        
        linkTableView.reloadData()
        
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        if (seperaterContentType == 0) {
            if (tableView == self.linkTableView) {
                return nameKeys.count
            }
            return 1
        }
        
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (seperaterContentType == 0) {
            if (tableView == self.linkTableView) {
                return addressBookDict[nameKeys[section]]!.count
            }
            return resultDataSource.count
        }else if (seperaterContentType == 1) {
            if (tableView == self.linkTableView) {
                return linksArray.count
            }
            
            if (isTopLevelShow) {
                return self.colleagueOrganizeSuperpkDataSource.count
            }
            return self.colleagueOrganizepkDataSource.count
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (tableView == self.linkTableView) {
            return 48
        }
        return 40
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (seperaterContentType == 0) {
            if (tableView == self.linkTableView) {
                return 25
            }
        }
        return 0.01
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (seperaterContentType == 0) {
            if (tableView == self.linkTableView) {
                
                let backView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 25))
                
                backView.backgroundColor = UIColor.groupTableViewBackground
                
                let titleLable = UILabel(frame: CGRect(x: 10, y: 0, width: kScreenWidth, height: 25))
                titleLable.font = UIFont.boldSystemFont(ofSize: 16)
                titleLable.text = nameKeys[section]
                titleLable.textColor = UIColor.black
                backView.addSubview(titleLable)
                
                return backView
            }
        }
        
        return UIView()
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        if (seperaterContentType == 0) {
            if (tableView == self.linkTableView) {
                var count = 0
                
                for letter in nameKeys {
                    if (letter.localizedCaseInsensitiveCompare(title) == .orderedSame) {
                        return count
                    }
                    count += 1
                }
            }
        }
        
        return 0;
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if (seperaterContentType == 0) {
            if (tableView == self.linkTableView) {
                return nameKeys
            }
        }
        return Array()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        var tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if tableViewCell == nil {
            
            tableViewCell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            tableViewCell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        
        if (seperaterContentType == 0) {
            
            if (tableView == categoryTableView) {
                let model = (resultDataSource[indexPath.row] as! NSArray)[0] as! OutsourcingDataModel
                if (model.type?.caseInsensitiveCompare("") == .orderedSame) {
                    tableViewCell?.textLabel?.text = "<无类别>"
                }else {
                    tableViewCell?.textLabel?.text = model.type
                }
            }else {
                
                tableViewCell?.imageView?.image = UIImage(named: "icon_cricle_green@2x")
                tableViewCell?.imageView?.contentMode = .scaleAspectFit
                
                let array = addressBookDict[nameKeys[indexPath.section]]
                let model = array?[indexPath.row]
                tableViewCell?.textLabel?.text = model?.name
                
                addLabelWithName(contentView: (tableViewCell?.imageView)!, contentTitle: (model?.name)!)
            }
            
        }else if (seperaterContentType == 1) {
            
            if (tableView == categoryTableView) {
                
                if (isTopLevelShow) {
                    let model = colleagueOrganizeSuperpkDataSource[indexPath.row] as! OrganizeDataModel
                    tableViewCell?.textLabel?.text = model.organizename
                }else {
                    let model = colleagueOrganizepkDataSource[indexPath.row] as! OrganizeDataModel
                    tableViewCell?.textLabel?.text = model.organizename
                }
                

            }else {
                
                tableViewCell?.imageView?.image = UIImage(named: "icon_cricle_green@2x")
                tableViewCell?.imageView?.contentMode = .scaleAspectFit
                
                let model = linksArray[indexPath.row] as! WorkerDataModel
                tableViewCell?.textLabel?.text = model.workername
                
                addLabelWithName(contentView: (tableViewCell?.imageView)!, contentTitle: (model.workername)!)
            }
            
        }
        
        return tableViewCell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (seperaterContentType == 0) {
            if (categoryTableView == tableView) {
                
                let hud: MBProgressHUD? = MBProgressHUD.showAdded(to: self, animated: true)
                hud?.mode = .indeterminate
                hud?.label.text = "正在加载外协单位列表"
                
                addressBookDict.removeAll()
                
                for model in resultDataSource[indexPath.row] as! NSArray {
                    
                    let indexModel = model as! OutsourcingDataModel
                    
                    let outputFormat = PinyinOutputFormat(toneType: .none, vCharType: .vCharacter, caseType: .lowercase)
                    
                    // 获取到姓名的大写首字母
                    let firstLetterString = getFirstLetterFromString(aString: indexModel.name!.toPinyin(withFormat: outputFormat, separator: ""))
                    
                    if addressBookDict[firstLetterString] != nil {
                        // swift的字典,如果对应的key在字典中没有,则会新增
                        addressBookDict[firstLetterString]?.append(indexModel)
                        
                    } else {
                        let arrGroupNames = [model]
                        addressBookDict[firstLetterString] = arrGroupNames as? [OutsourcingDataModel]
                    }
                    
                }
                
                // 将addressBookDict字典中的所有Key值进行排序: A~Z
                nameKeys = Array(addressBookDict.keys).sorted()
                
                // 将 "#" 排列在 A~Z 的后面
                if nameKeys.first == "#" {
                    nameKeys.insert(nameKeys.first!, at: nameKeys.count)
                    nameKeys.remove(at: 0);
                }
                
                linkTableView.reloadData()
                
                hud?.hide(animated: true)
            }else {
                //跳转
                let array = addressBookDict[nameKeys[indexPath.section]]
                let model = array?[indexPath.row]
                
                delegate?.jumpWithObject(object: model!)
            }
        }else if (seperaterContentType == 1) {
            
            if (categoryTableView == tableView) {
                let hud: MBProgressHUD? = MBProgressHUD.showAdded(to: self, animated: true)
                hud?.mode = .indeterminate
                hud?.label.text = "正在加载联系人列表"
                
                linksArray.removeAllObjects()
                
                if (isTopLevelShow) {
                    isTopLevelShow = false
                }
                
                if (!isTopLevelShow) {
                    let organizeDataModel = colleagueOrganizepkDataSource[indexPath.row] as! OrganizeDataModel
                    
                    for model in colleagueLinkPersonsDataSource {
                        let indexModel = model as! WorkerDataModel
                        if (organizeDataModel.organizepk?.caseInsensitiveCompare(indexModel.organizeid!) == .orderedSame) {
                            linksArray.add(model)
                        }
                    }
                }
                
                categoryTableView.reloadData()
                linkTableView.reloadData()
                
                hud?.hide(animated: true)
            }else {
                let model = linksArray[indexPath.row]
                delegate?.jumpWithObject(object: model as AnyObject)
            }
        }
        
    }
    
    // MARK: - 获取联系人姓名首字母(返回大写拼音首字母)
    public func getFirstLetterFromString(aString: String) -> (String) {
    
        // 将拼音首字母装换成大写
        let strPinYin = aString.uppercased()
        // 截取大写首字母
        let firstString = strPinYin.substring(to: strPinYin.index(strPinYin.startIndex, offsetBy:1))
        // 判断姓名首位是否为大写字母
        let regexA = "^[A-Z]$"
        let predA = NSPredicate.init(format: "SELF MATCHES %@", regexA)
        return predA.evaluate(with: firstString) ? firstString : "#"
    }
    
    func addLabelWithName(contentView: UIImageView, contentTitle: String ) {
        
        contentView.viewWithTag(5555)?.removeFromSuperview()
        
        //let frame = contentView.frame
        
        let contentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 33, height: 33))
        contentLabel.tag = 5555;
        contentLabel.textAlignment = .center
        contentLabel.font = UIFont.systemFont(ofSize: 11)
        contentLabel.textColor = UIColor.white
        contentLabel.backgroundColor = UIColor.clear
        contentView.addSubview(contentLabel)
        
        let name = NSString(string: contentTitle)
        if (name.length <= 2) {
            contentLabel.text = name as String
        }else {
            contentLabel.text = name.substring(from: name.length - 2)
        }
        
    }
    
}
