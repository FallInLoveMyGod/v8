//
//  BaseTableViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/10.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit

open class BaseTableViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    @objc var pageIndex = 1
    @objc var pageSize = 30
    
    var localHasHeader = true
    var localHasFooter = true

    @objc var contentTableView: UITableView?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func initContentUI(frame: CGRect) {
        
        self.view.backgroundColor = UIColor.white
        
        contentTableView = UITableView(frame: frame, style: .grouped)
        contentTableView?.estimatedRowHeight = 0
        contentTableView?.estimatedSectionHeaderHeight = 0
        contentTableView?.estimatedSectionFooterHeight = 0
        contentTableView?.delegate = self
        contentTableView?.dataSource = self
        contentTableView?.separatorStyle = .singleLine
        self.view.addSubview(contentTableView!)
        
        contentTableView?.emptyDataSetSource = self;
        contentTableView?.emptyDataSetDelegate = self;
    }
    
    open func refreshUI(frame: CGRect) {
        self.initContentUI(frame: frame)
        addFresh()
    }
    
    open func refreshSetHeaderFooterUI(frame: CGRect, hasHeader: Bool, hasFooter: Bool) {
        self.initContentUI(frame: frame)
        
        localHasHeader = hasHeader
        localHasFooter = hasFooter
        
        addFresh()
    }
    
    open func addFresh() {
        
        let normalHeader = NormalAnimator.normalAnimator()
        normalHeader.lastRefreshTimeKey = "exampleHeader1"
        
        let normalFooter = NormalAnimator.normalAnimator()
        normalFooter.lastRefreshTimeKey = "exampleFooter1"
        
        addHeader(normalHeader, footer: normalFooter)
        
    }
    
    open func addHeader<Animator>(_ header: Animator, footer: Animator) where Animator: UIView, Animator: RefreshViewDelegate {
        
        
        if (self.localHasHeader) {
            contentTableView?.zj_addRefreshHeader(header, refreshHandler: {[weak self] in
                
                self?.pageIndex = 1
                self?.requestData()
                
            })
        }
        
        if (self.localHasFooter) {
            contentTableView!.zj_addRefreshFooter(footer) {[weak self] in
                
                self?.pageIndex = (self?.pageIndex)! + 1
                self?.requestData()
                
            }
        }
    }
    
    open func requestData() {
        
        if (BaseTool.isExistenceNetwork() == false) {
            //如果网络未连接，暂停刷新，并进行无网络提示
            LocalToastView.toast(text: NoNetWork)
            stopFresh()
            return
        }
        
    }
    
    open func stopFresh() {
        
        self.stopHeader()
        self.stopFooter()
    }
    
    open func stopHeader() {
        
        DispatchQueue.main.async(execute: {
            self.contentTableView!.reloadData()
            /// 刷新完毕, 停止动画
            self.contentTableView!.zj_stopHeaderAnimation()
            
        })
        
    }
    
    open func stopFooter() {
        
        DispatchQueue.main.async(execute: {
            self.contentTableView!.reloadData()
            self.contentTableView!.zj_stopFooterAnimation()
            
        })
    }
    
    override open func netDisconnet() {
        
        DispatchQueue.main.async(execute: {
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
            
            let netDisConnectView = Bundle.main.loadNibNamed("NetDisConnectView", owner: self, options: nil)?.first as! NetDisConnectView
            netDisConnectView.tag = kNetDisConnectViewTag
            
            self.contentTableView?.tableHeaderView = headerView
            
            netDisConnectView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 40)
            self.view.addSubview(netDisConnectView)
            
        })
    }
    
    open override func netConnect() {
        
        DispatchQueue.main.async(execute: {
            
            self.contentTableView?.tableHeaderView = nil
            self.view.viewWithTag(kNetDisConnectViewTag)?.removeFromSuperview()
            
        })
        
    }
    
    func popToLinksHome() {
        
        for vc in (self.navigationController?.childViewControllers.reversed())! {
            if (vc.isKind(of: LinkListViewController.self)) {
                self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
        
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
