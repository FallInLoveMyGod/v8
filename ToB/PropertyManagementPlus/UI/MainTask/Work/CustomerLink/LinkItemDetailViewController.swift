//
//  LinkItemDetailViewController.swift
//  PropertyManagementPlus
//
//  Created by jana on 16/12/24.
//  Copyright © 2016年 Lesoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON

class LinkItemDetailViewController: BaseTableViewController,UIActionSheetDelegate,FJFloatingViewDelegate {

    var floatingView: FJFloatingView = FJFloatingView(frame: CGRect(x: kScreenWidth - 80, y: kScreenHeight - 190, width: 60, height: 60))
    
    var photoBrowser: PhotoBrowser?
    var imageView: UIImageView!
    
    let loginInfo = LocalStoreData.getLoginInfo()
    let userInfo = LocalStoreData.getUserInfo()
    
    var broswerArray = NSMutableArray(capacity: 20)
    let selectImageShowView = SelectImageShowView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 95.0))
    
    var titleNames = [["单据类型","联系人","联系电话","地址","联系种类","住户名称"],["创建日期","上报内容"]]
    var contentModel: SearchContactFormModel?
    
    var isNeedDeal: Bool = false
    var buttonSelectIndex = 0
    var notificationType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(popAction), name: kNotificationCenterFreshTurnComplaintList as NSNotification.Name, object: nil)

        self.view.backgroundColor = UIColor.white
        
        if (isNeedDeal) {
            self.setTitleView(titles: ["处理客服联系单"])
        }else {
            self.setTitleView(titles: ["查看客服联系单"])
        }
        
        
        refreshSetHeaderFooterUI(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 64 - 49), hasHeader: false, hasFooter: false)
        
        floatingView.iconImageView.image = UIImage(named: "ic_comment_normal.png")
        floatingView.delegate = self
        floatingView.numberLabel.isHidden = false
        if ((contentModel?.style?.compare("微信报事报修") == .orderedSame || contentModel?.style?.compare("社区APP") == .orderedSame)) {
            if (BaseTool.isZoreVule(withObject: contentModel?.MSGNum)) {
                floatingView.numberLabel.isHidden = true
            }
            floatingView.numberLabel.text = contentModel?.MSGNum
            self.view.addSubview(floatingView)
        }
        
        if notificationType == "3" {
            notificationType = ""
            floatingViewClick()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: kNotificationCenterFreshTurnComplaintList as NSNotification.Name, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (isNeedDeal) {
            buttonAction(titles: ["返回","处理"], actions: [#selector(pop),#selector(dealList)], target: self)
        }else {
            buttonAction(titles: ["返回"], actions: [#selector(pop)], target: self)
        }
    }
    
    // MARK:UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if (contentModel?.filePath?.compare("") == .orderedSame) {
            return 2
        }
        
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 6
        }
        
        if (section == 1) {
            return 2
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0 || indexPath.section == 1) {
            if (indexPath.section == 1 && indexPath.row == 1) {
                return BaseTool.calculateHeight(withText: contentModel?.content ?? "  ", textLabel: UIFont.systemFont(ofSize: 14), isCaculateWidth: false, widthOrHeightData: 250.0);
            }
            return 44
        }
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let contentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 35.0))
        contentLabel.backgroundColor = UIColor.groupTableViewBackground
        contentLabel.textColor = kMarkColor
        contentLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        contentLabel.text = "    基本信息"
        
        if (section == 0) {
            contentLabel.text = "    基本信息"
        }else if (section == 1) {
            contentLabel.text = "    上报内容"
        }else if (section == 2) {
            contentLabel.text = "    现场照片"
        }
        
        return contentLabel;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CellIdentifier"
        
        var linkItemDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if (indexPath.section == 2 && indexPath.row == 0) {
            
            if linkItemDetailTableViewCell == nil {
                
                linkItemDetailTableViewCell = Bundle.main.loadNibNamed("LinkItemDetailImageContentTableViewCell", owner: nil, options: nil)?.first as! LinkItemDetailImageContentTableViewCell
                linkItemDetailTableViewCell?.selectionStyle = .none
                
                
            }
            
            let tempCell: LinkItemDetailImageContentTableViewCell = (linkItemDetailTableViewCell as! LinkItemDetailImageContentTableViewCell)
            
            let urlFore = LocalStoreData.getPMSAddress().PMSAddress
            let array = urlFore?.components(separatedBy: "WebAPI")
            let finalURL = array?[0]
            
            broswerArray.add((finalURL as AnyObject).appending((contentModel?.filePath)!))
            
            var filePathArray = contentModel?.filePath?.components(separatedBy: "#")
            
            for (index,_) in (filePathArray?.enumerated())! {
                let imageView = tempCell.viewWithTag(1000 + index) as! UIImageView
                let a:Int = (finalURL?.lengthOfBytes(using: String.Encoding.nextstep))! - 6;
                let str = finalURL! as NSString;
                let strr = str.substring(to: a)
                
                imageView.imageFromURL((strr as AnyObject).appending((filePathArray?[index])!), placeholder: UIImage())
                
                let gesture = UITapGestureRecognizer(target: self, action: #selector(displayPhotoBrowser(ges:)))
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(gesture)
            }
            
            return linkItemDetailTableViewCell!
            
        }
        
        
        if indexPath.section == 0 || indexPath.section == 1 {
            if linkItemDetailTableViewCell == nil {
                
                linkItemDetailTableViewCell = Bundle.main.loadNibNamed("LinkItemDetailTableViewCell", owner: nil, options: nil)?.first as! LinkItemDetailTableViewCell
                linkItemDetailTableViewCell?.selectionStyle = .none
                
            }
            
            let tempCell: LinkItemDetailTableViewCell = (linkItemDetailTableViewCell as! LinkItemDetailTableViewCell)
            
            var content  = ""
            
            if (indexPath.section == 0) {
                
                if (indexPath.row == 0) {
                    content = contentModel?.type ?? "  "
                }else if (indexPath.row == 1) {
                    content = contentModel?.contactName ?? "  "
                }else if (indexPath.row == 2) {
                    content = contentModel?.contactPhone ?? "  "
                }else if (indexPath.row == 3) {
                    content = contentModel?.address ?? "  "
                }else if (indexPath.row == 4) {
                    content = contentModel?.style ?? "  "
                }else if (indexPath.row == 5) {
                    content = contentModel?.UserName ?? "  "
                }
                
            }else if (indexPath.section == 1) {
                if (indexPath.row == 0) {
                    content = contentModel?.contactDate ?? "  "
                }else {
                    tempCell.contentLabel.numberOfLines = 0
                    content = contentModel?.content ?? "  "
                }
            }
            
            tempCell.titleNameLabel.text = titleNames[indexPath.section][indexPath.row]
            tempCell.contentLabel.text = content
            
        }else {
            
            if linkItemDetailTableViewCell == nil {
                
                linkItemDetailTableViewCell = Bundle.main.loadNibNamed("LinkItemDetailContentTableViewCell", owner: nil, options: nil)?.first as! LinkItemDetailContentTableViewCell
                linkItemDetailTableViewCell?.selectionStyle = .none
                
            }
            
            let tempCell: LinkItemDetailContentTableViewCell = (linkItemDetailTableViewCell as! LinkItemDetailContentTableViewCell)
            tempCell.contentLabel.text = contentModel?.content
            
        }
        
        linkItemDetailTableViewCell?.separatorInset = .zero
        linkItemDetailTableViewCell?.layoutMargins = .zero
        linkItemDetailTableViewCell?.preservesSuperviewLayoutMargins = false
        
        return linkItemDetailTableViewCell!
    }
    
    @objc func dealList() {
        //处理
        showActionSheet(title: "选择处理方式", cancelTitle: "取消", titles: ["转维修单","转投诉单","直接完成"], tag: "Style")
        
    }
    
    func actionSheet(_ actionSheet: ActionSheet!, tag: String!, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            return
        }
        
        if (tag.compare("Style") == .orderedSame) {
            
            if (buttonIndex == 2) {
                //转投诉单
                
                /*
                 
                 "state" : "0",
                 "style" : "来电",
                 "contactDate" : "2016-12-20 17:46:00",
                 "Id" : "48",
                 "contactPhone" : "911",
                 "contactName" : "张大",
                 "UserName" : "上海鑫汇餐饮有限公司1",
                 "type" : "报修",
                 "source" : "",
                 "code" : "KHLX00000046",
                 "address" : "永新国际广场\/A座\/第02层\/201-10",
                 "PsCode" : "01010201",
                 "UserCode" : "01010201_01",
                 "PProjectCode" : "",
                 "filePath" : "AppBillFile\\LinkBill\\000220167\\1468240511_39857420160718160833.png",
                 "content" : "马桶坏了"
                 
                 */
                
                let compaintVC = ComplaintHandlingAddViewController()
                
                let compaintModel = AddComplaintFormModel()
                compaintModel.Location = contentModel?.address
                compaintModel.Complainant = contentModel?.UserName
                compaintModel.Content = contentModel?.content
                compaintModel.Way = contentModel?.style
                compaintModel.ComplainantTel = contentModel?.contactPhone
                compaintModel.ContactCode = contentModel?.code
                compaintModel.ComplainantPsCode = contentModel?.PsCode
                
                compaintVC.addComplaintFormModel = compaintModel
                compaintVC.contentModel = contentModel
                self.navigationController?.pushViewController(compaintVC, animated: true)
                
            }else if (buttonIndex == 3 || buttonIndex == 1) {
                //转维修单
                //直接完成
                
                if (buttonIndex == 1) {
                    buttonSelectIndex = 1
                }else {
                    buttonSelectIndex = buttonIndex
                }
                
                LoadView.storeLabelText = "正在处理信息......"
                
                let handelContactFormAPICmd = HandelContactFormAPICmd()
                handelContactFormAPICmd.baseUrl = LocalStoreData.getPMSAddress().PMSAddress!
                handelContactFormAPICmd.parameters = ["AccountCode":loginInfo?.accountCode ?? "","upk":userInfo?.upk ?? "","code":contentModel?.code ?? "","type":buttonIndex == 1 ? "1" : "3"]
                handelContactFormAPICmd.loadView = LoadView()
                handelContactFormAPICmd.loadParentView = self.view
                handelContactFormAPICmd.transactionWithSuccess({ (response) in
                    
                    let dict = JSON(response)
                    
                    //print(dict)
                    
                    let resultStatus = dict["result"].string
                    
                    if resultStatus?.localizedCaseInsensitiveCompare("success") == .orderedSame  {
                        //成功
                        
                        if (self.buttonSelectIndex == 1){
                            //LocalToastView.toast(text: "转维修单成功！")
                            let link = LinkItemSendTaskViewController()
                            link.billCode = dict["Code"].string!
                            self.push(viewController: link)
                        }else if (self.buttonSelectIndex == 3){
                            LocalToastView.toast(text: "直接完成成功！")
                            self.pop()
                        }
                        
                    }else {
                        LocalToastView.toast(text: dict["msg"].string!)
                    }
                    
                    self.stopFresh()
                    
                }) { (response) in
                    LocalToastView.toast(text: DisNetWork)
                    self.stopFresh()
                }
            }
            
        }
        
    }
    
    //MARK: UIActionSheetDelegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        
        //"选择派单人","选择派单人+离线","选择维修人","选择维修人+离线","发起抢单","发起抢单+离线"
        
        if (buttonIndex == 0) {
            return
        }
        
//        let choose = RepairChooseSenderViewController()
//        choose.billCode = billCode
//        choose.accountCode = loginInfo?.accountCode ?? ""
//        choose.upk = userInfo?.upk ?? ""
//        choose.baseUrl = LocalStoreData.getPMSAddress().PMSAddress
//        
//        if (buttonIndex == 1 || buttonIndex == 3 || buttonIndex == 5) {
//            choose.lineState = "1"
//        }else {
//            choose.lineState = "0"
//        }
//        choose.chooseTitle = actionSheet.buttonTitle(at: buttonIndex)
//        self.navigationController?.pushViewController(choose, animated: true)
        
    }
    
    //MARK: FJFloatingViewDelegate
    
    func floatingViewClick() {
        let chat = ChatViewRoomController()
        chat.billcode = contentModel?.code
        self.pushNormalViewController(viewController: chat)
    }
    
    @objc func displayPhotoBrowser(ges: UITapGestureRecognizer) {
    
        let thumbnail1 = UIImage.init(named: "thumbnail1")
        let photoUrl1 = URL.init(string: (broswerArray[0] as! String).replacingOccurrences(of: "\\", with: "/"))
        
        let photo = Photo.init(image: nil, title:"查看图片", thumbnailImage: thumbnail1, photoUrl: photoUrl1)
        
        let item1 = PBActionBarItem(title: "", style: .plain) { (photoBrowser, item) in
            let photos = [photo]
            photoBrowser.photos = photos
        }
        
        photoBrowser = PhotoBrowser()
        if let browser = photoBrowser {
            browser.isFromPhotoPicker = true
            browser.selectedIndex = [0, 1]
            browser.photos = [photo]
            browser.actionItems = [item1]
            browser.photoBrowserDelegate = self
            browser.currentIndex = 0
            presentPhotoBrowser(browser, fromView: ges.view!)
        }
    }
    
    func saveToAlbum(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error:NSError?, contextInfo:UnsafeRawPointer) {
        if error == nil {
            print("save success")
        } else {
            print(error as Any)
        }
    }
}

extension LinkItemDetailViewController: PhotoBrowserDelegate {
    
    func photoBrowser(_ browser: PhotoBrowser, didShowPhotoAtIndex index: Int) {
        print("photo browser did show at index: \(index)")
    }
    
    func dismissPhotoBrowser(_ photoBrowser: PhotoBrowser) {
        dismissPhotoBrowser(toView: imageView)
    }
    
    func longPressOnImage(_ gesture: UILongPressGestureRecognizer) {
        guard (gesture.view as? UIImageView) != nil else {
            return
        }
        /*
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        let saveAction = UIAlertAction.init(title: "保存", style: UIAlertActionStyle.default) {[unowned self] (action) -> Void in
            if let image = imageView.image {
                self.saveToAlbum(image)
            }
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.photoBrowser?.present(alertController, animated: true, completion: nil)
        } else {
            let location = gesture.location(in: gesture.view)
            let rect = CGRect(x: location.x - 5, y: location.y - 5, width: 10, height: 10)
            alertController.modalPresentationStyle = .popover
            alertController.popoverPresentationController?.sourceRect = rect
            alertController.popoverPresentationController?.sourceView = gesture.view
            self.photoBrowser?.present(alertController, animated: true, completion: nil)
        }
 */
    }
    
    func photoBrowser(_ browser: PhotoBrowser, willSharePhoto photo: Photo) {
        print("Custom share action here")
    }
    
    func photoBrowser(_ browser: PhotoBrowser, canSelectPhotoAtIndex index: Int) -> Bool {
        print("canSelectPhotoAtIndex \(index)")
        if index == 2 {
            return false
        }
        return true
    }
    
    func photoBrowser(_ browser: PhotoBrowser, didSelectPhotoAtIndex index: Int) {
        print("didSelectPhotoAtIndex \(index)")
    }
    
    @objc func popAction() {
        
        NotificationCenter.default.post(name: kNotificationCenterFreshLinkItemList as NSNotification.Name, object: nil)
        
        super.pop()
    }
}
