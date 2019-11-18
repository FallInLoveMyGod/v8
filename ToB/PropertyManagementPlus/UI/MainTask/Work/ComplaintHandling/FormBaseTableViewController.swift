//
//  FormBaseTableViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import Eureka

open class FormBaseTableViewController: FormViewController,ActionSheetDelegate {

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        // Do any additional setup after loading the view.
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func setTitleView(titles: [NSString])  {
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        
        titleLabel.text = titles[0] as String;
        
        self.navigationItem.titleView = titleLabel
        
        let item = UIBarButtonItem(image: UIImage(named: "ryback_topBar_Icon_white"), style: .done, target: self, action: #selector(pop))
        self.navigationItem.leftBarButtonItem = item;
        
    }
    
    open func buttonAction(titles: NSArray, actions: NSArray, target: UIViewController) {
        
        var startY = kScreenHeight - kNavbarHeight - 50
        if navigationController?.navigationBar.subviews.count != 0 {
            if let view = target.navigationController?.navigationBar.subviews[0], view.isHidden {
                startY = kScreenHeight - 50
            }
        }
        
        
        let bottomView = UIView(frame: CGRect(x: 0, y: startY, width: kScreenWidth, height: 50))
        bottomView.tag = 1177
        bottomView.backgroundColor = UIColor.clear
        
        for (index, name) in titles.enumerated() {
            let width = kScreenWidth / (CGFloat(titles.count) * 1.0)
            print(name)
            let button = createTitleButton(frame: CGRect(x: width*CGFloat(index), y: 0, width: width, height: 50), title: name as! String, titleColor: UIColor.white, backGroundColor: kThemeColor, textAlignment: .center, target: target, action: actions[index] as? Selector)
            button.layer.borderWidth = 0.5;
            button.layer.borderColor = UIColor.white.cgColor
            bottomView.addSubview(button)
        }
        
        self.view.addSubview(bottomView)
        
    }
    
    open func bottomButtonAction(titles: NSArray, images: NSArray, actions: NSArray, target: UIViewController) {
        
        self.view.viewWithTag(1178)?.removeFromSuperview()
        
        var startY = kScreenHeight - kNavbarHeight - 80
        if navigationController?.navigationBar.subviews.count != 0 {
            if let view = target.navigationController?.navigationBar.subviews[0], view.isHidden {
                startY = kScreenHeight - 80
            }
        }
        
        let bottomView = UIView(frame: CGRect(x: 0, y: startY, width: kScreenWidth, height: 80))
        bottomView.tag = 1178
        bottomView.backgroundColor = UIColor.white
        
        for (index, name) in titles.enumerated() {
            
            let width = kScreenWidth / (CGFloat(titles.count) * 1.0)
            print(name)
            let button = createTitleButton(frame: CGRect(x: width*CGFloat(index), y: 0, width: width, height: 80), title: name as! String, titleColor: UIColor.black, backGroundColor: UIColor.white, textAlignment: .center, target: target, action: actions[index] as? Selector)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setImage(UIImage(named: images[index] as! String), for: .normal)
            button.contentHorizontalAlignment = .center
            
            button.titleEdgeInsets = UIEdgeInsets(top: (button.imageView?.frame.size.height)! + 10, left: -(button.imageView?.frame.size.width)!, bottom: 0.0, right: 0.0)
            button.imageEdgeInsets = UIEdgeInsets(top: -10.0, left: 0.0, bottom: 0.0, right: -(button.titleLabel?.bounds.size.width)!)
            
            button.layer.borderWidth = 0.5;
            button.layer.borderColor = UIColor.lightGray.cgColor
            
            bottomView.addSubview(button)
            
        }
        
        self.view.addSubview(bottomView)
        
    }
    
    open func createButton(frame: CGRect, title: String, titleColor: UIColor,backGroundColor: UIColor,textAlignment: NSTextAlignment,image: UIImage?,target: Any?, action: Selector?) -> UIButton {
        
        let button = createTitleButton(frame: frame, title: title, titleColor: titleColor, backGroundColor: backGroundColor, textAlignment: textAlignment, target: target, action: action)
        button.setImage(image, for: .normal)
        return button
    }
    
    open func createTitleButton(frame: CGRect, title: String, titleColor: UIColor,backGroundColor: UIColor,textAlignment: NSTextAlignment,target: Any?, action: Selector?) -> UIButton {
        
        let button = UIButton(frame: frame)
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = backGroundColor
        button.titleLabel?.textAlignment = textAlignment
        button.setTitle(title, for: .normal)
        button.addTarget(target, action: action!, for: .touchUpInside)
        return button
    }
    
    @objc open func pop() {
        self.navigationController?.popViewController(animated: true)
    }
    
    open func popToRoot() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    open func showAlertChoose(title: NSString ,message: NSString,placeHolder: NSString,titles: NSArray, selector: Selector, target: UIViewController) {
        
        let alertVC: LSAlertViewController = LSAlertViewController.alert(withTitle: title as String!, message: message as String!, placeHolder: placeHolder as String!, type: CKAlertViewType(rawValue: UInt(1))!)
        
        for (index, name) in titles.enumerated() {
            
            //#selector(LinkItemDetailViewController.chooseDealStyle(type:)), with: String(index)
            let alertAction = CKAlertAction(title: name as! String, handler: { (action) in
                self.perform(selector, with: String(index))
            })
            alertVC.addAction(alertAction)
        }
        
        self.present(alertVC, animated: false, completion: {() in })
        
    }
    
    open func showActionSheet(title: String ,cancelTitle: String, titles: [Any], tag: String) {
        
        let actionSheet = ActionSheet.shareManager()
        actionSheet?.tag = tag
        actionSheet?.delegate = self
        actionSheet?.sheet(withTitle: title, cancelButtonTitle: cancelTitle, otherButtonTitleArray: titles)
    }
    
    open func formateTime(time: String) -> String{
        if (time.compare(kEmptyTimeKey) == .orderedSame) {
            return ""
        }
        return time
    }
    
    //打电话
    open func dailNumber(phoneNumber: String) {
        UIApplication.shared.openURL(NSURL(string :"tel://"+"\(phoneNumber)")! as URL)
    }
    
    //字数控制
    func numberCharacterLeft(cell: ComplaintHandleContentInputTableViewCell, content: String) -> String{
        
        var content = NSString(string: content)
        var numberLeft = "0"
        
        if (content.length > 200) {
            content = content.substring(from: 200) as NSString
        }else {
            numberLeft = (String(200 - content.length) as NSString) as String
        }
        
        return numberLeft
    }
    //ActionSheetDelegate
    
    public func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
    }
    
    func popToRepairTaskHome() {
        
        for vc in (self.navigationController?.childViewControllers.reversed())! {
            if (vc.isKind(of: RepairTaskViewController.self)) {
                self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
        
    }
    
    func popToLinksHome() {
        
        for vc in (self.navigationController?.childViewControllers.reversed())! {
            if (vc.isKind(of: LinkListViewController.self)) {
                self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
        
    }
}
