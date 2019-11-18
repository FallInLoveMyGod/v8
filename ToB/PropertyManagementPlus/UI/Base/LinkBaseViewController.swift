//
//  LinkBaseViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/9.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

open class LinkBaseViewController: BaseViewController,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var contentTableView: UITableView?
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //let item = UIBarButtonItem(image: UIImage(named: "icon_setting_normal"), style: .done, target: self, action: #selector(sliderOpen))
        //self.navigationItem.leftBarButtonItem = item;
        
        initContentUI()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //去掉NavigationBar的背景和横线
        
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.slider.tabbarShow()
        
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func sliderOpen() {
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.slider.showMenu()
    }
    
    private func initContentUI () {
        
        self.view.backgroundColor = UIColor.white
        
        contentTableView = UITableView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kTabBarHeight), style: .grouped)
        contentTableView?.separatorStyle = .none
        contentTableView?.isHidden = true
        self.view.addSubview(contentTableView!)
        
        contentTableView?.emptyDataSetSource = self;
        contentTableView?.emptyDataSetDelegate = self;
    }
    
    func addFresh() {
        
        let normalHeader = NormalAnimator.normalAnimator()
        normalHeader.lastRefreshTimeKey = "exampleHeader1"
        
        let normalFooter = NormalAnimator.normalAnimator()
        normalFooter.lastRefreshTimeKey = "exampleFooter1"
        
        addHeader(normalHeader, footer: normalFooter)
        
    }
    
    func addHeader<Animator>(_ header: Animator, footer: Animator) where Animator: UIView, Animator: RefreshViewDelegate {
        
        
        contentTableView?.zj_addRefreshHeader(header, refreshHandler: {[weak self] in
            
            self?.requestData()
            
        })
        
        contentTableView!.zj_addRefreshFooter(footer) {[weak self] in
            
            self?.requestData()
            
        }
    }
    
    func requestData() {
        
        if (BaseTool.isExistenceNetwork() == false) {
            //如果网络未连接，暂停刷新，并进行无网络提示
            LocalToastView.toast(text: NoNetWork)
            stopFresh()
            return
        }
        
    }
    
    func stopFresh() {
        self.stopHeader()
        self.stopFooter()
    }
    
    func stopHeader() {
        
        DispatchQueue.main.async(execute: {
            self.contentTableView!.reloadData()
            /// 刷新完毕, 停止动画
            self.contentTableView!.zj_stopHeaderAnimation()
            
        })
        
    }
    
    func stopFooter() {
        
        DispatchQueue.main.async(execute: {
            self.contentTableView!.reloadData()
            self.contentTableView!.zj_stopFooterAnimation()
            
        })
    }
    
    func buttonEvent() {
        
    }
    
    
    //空页面
    public func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        if (self.noDataImgName.compare("") != .orderedSame) {
            return UIImage(named: self.noDataImgName)
        }
        return UIImage(named: "")
    }
    
    public func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        let text = "暂时无内容"
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16.0),NSAttributedStringKey.foregroundColor:UIColor.gray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    public func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = self.noDataDetailTitle
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14.0),NSAttributedStringKey.foregroundColor:UIColor.lightGray,
                          NSAttributedStringKey.paragraphStyle:paragraph]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    public func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return self.isShowEmptyData
    }
    
    public func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    public func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 0.0
    }
    
    public func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString? {
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16.0)]
        if (self.btnTitle.compare("") != .orderedSame) {
            return NSAttributedString(string: self.btnTitle, attributes: attributes)
        }
        return nil
    }
    
    public func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> UIImage? {
        if (self.btnImgName.compare("") != .orderedSame) {
            return UIImage(named: self.btnImgName)
        }
        return nil
    }
    
    public func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        self.buttonEvent()
    }

}
