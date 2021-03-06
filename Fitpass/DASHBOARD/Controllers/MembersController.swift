//
//  MembersController.swift
//  Fitpass
//
//  Created by SatishMac on 13/05/17.
//  Copyright © 2017 Satish. All rights reserved.
//

import UIKit

protocol memberDelegate {
    func getFilterDictionary (searchDict: NSMutableDictionary)
    func clearFilter ()
}

class MembersController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, memberDelegate {
        
        
        var subscriptionPlan: String?
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
        @IBOutlet weak var membersSearchBar: UISearchBar!
        @IBOutlet weak var membersTableView: UITableView!
        
        var membersArray : NSMutableArray = NSMutableArray()
        var searchActive : Bool = false
        var filteredArray: NSMutableArray = NSMutableArray()
        var searchString : String? = ""
        var selectedMemberObj : Members?
    var filterDict : NSMutableDictionary?

        
       override func viewDidLoad() {
            super.viewDidLoad()
//            membersSearchBar.showsCancelButton = true
        
        let filterBtn = UIButton(type: .custom)
        filterBtn.setImage(UIImage(named: "filter"), for: .normal)
        filterBtn.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        filterBtn.addTarget(self, action: #selector(navigateToMembersFilter), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: filterBtn)
        
        let downloadBtn = UIButton(type: .custom)
        downloadBtn.setImage(UIImage(named: "download"), for: .normal)
        downloadBtn.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        downloadBtn.addTarget(self, action: #selector(downloadMembers), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: downloadBtn)
        
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItems = [item1, item2]

        self.getMembers()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationItem.title = "Members"
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if(segue.identifier == "member_filter") {
                self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: segue.destination)
                segue.destination.modalPresentationStyle = .custom
                segue.destination.transitioningDelegate = self.halfModalTransitioningDelegate
                
                let filterVC : MembersFilterController = segue.destination as! MembersFilterController
                
                filterVC.delegate = self
                filterVC.filterDataDict = self.filterDict
                
            }
            else if(segue.identifier == "member_detail") {
                let memberDetailVC : MemberDetailController = segue.destination as! MemberDetailController
                memberDetailVC.memberObj = selectedMemberObj
            }
        }
        
        func getMembers() {
            
            if (appDelegate.userBean == nil) {
                return
            }
            if !isInternetAvailable() {
                AlertView.showCustomAlertWithMessage(message: StringFiles().CONNECTIONFAILUREALERT, yPos: 20, duration: NSInteger(2.0))
                return;
            }
            
            ProgressHUD.showProgress(targetView: self.view)
            
            NetworkManager.sharedInstance.getResponseForURLWithParameters(url: ServerConstants.URL_GET_ALL_MEMBERS , userInfo: nil, type: "GET") { (data, response, error) in
                
                ProgressHUD.hideProgress()
                
                if error == nil {
                    let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let responseDict:NSDictionary? = jsonObject as? NSDictionary
                    if (responseDict != nil) {
                        print(responseDict!)
                        
                        if(responseDict?.object(forKey: "status") as! String  == "401"){
                            AlertView.showCustomAlertWithMessage(message: responseDict?.object(forKey: "message") as! String, yPos: 20, duration: 5)
                            self.moveToLoginScreen()
                        }
                        else if(responseDict?.object(forKey: "status") as! String  == "200"){
                            self.membersArray.addObjects(from:  Members().updateMembers(responseDict : responseDict!) as [AnyObject])
                            self.membersTableView.reloadData()
                        }else{
                            AlertView.showCustomAlertWithMessage(message: responseDict?.object(forKey: "message") as! String, yPos: 20, duration: 5)
                        }
                    }
                }
                else{
                    AlertView.showCustomAlertWithMessage(message: StringFiles.ALERT_SOMETHING, yPos: 20, duration: NSInteger(2.0))
                    print("Get Members failed : \(String(describing: error?.localizedDescription))")
                }
            }
        }
        
        func getSearchMembers() {
            
            if (appDelegate.userBean == nil) {
                return
            }
            if !isInternetAvailable() {
                AlertView.showCustomAlertWithMessage(message: StringFiles().CONNECTIONFAILUREALERT, yPos: 20, duration: NSInteger(2.0))
                return;
            }
            
            ProgressHUD.showProgress(targetView: self.view)
            
            let parameters : [String : Any] = ["search_text" : self.membersSearchBar.text!, "search_by" : "Name"]
            let urlString  = self.createURLFromParameters(parameters: parameters)
            let str : String = ServerConstants.URL_GET_ALL_MEMBERS+urlString.absoluteString
            NetworkManager.sharedInstance.getResponseForURLWithParameters(url: str , userInfo: nil, type: "GET") { (data, response, error) in
                
                ProgressHUD.hideProgress()
                if error == nil {
                    let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let responseDic:NSDictionary? = jsonObject as? NSDictionary
                    if (responseDic != nil) {
                        print(responseDic!)
                        
                        if(responseDic?.object(forKey: "status") as! String  == "401"){
                            AlertView.showCustomAlertWithMessage(message: responseDic?.object(forKey: "message") as! String, yPos: 20, duration: 5)
                            self.moveToLoginScreen()
                        }
                        else if(responseDic?.object(forKey: "status") as! String  == "200"){
                            if(self.filteredArray.count>0){
                                self.filteredArray.removeAllObjects()
                            }
                            self.filteredArray.addObjects(from:  Members().updateMembers(responseDict : responseDic!) as [AnyObject])
                            self.membersTableView.reloadData()
                        }
                        else{
                            AlertView.showCustomAlertWithMessage(message: responseDic?.object(forKey: "message") as! String, yPos: 20, duration: 5)
                        }
                    }
                }
                else{
                    AlertView.showCustomAlertWithMessage(message: StringFiles.ALERT_SOMETHING, yPos: 20, duration: NSInteger(2.0))
                    print("Get Search Members failed : \(String(describing: error?.localizedDescription))")
                }
            }
        }
        
        func getSearchFilterMembers() {
            
            if (appDelegate.userBean == nil) {
                return
            }
            if !isInternetAvailable() {
                AlertView.showCustomAlertWithMessage(message: StringFiles().CONNECTIONFAILUREALERT, yPos: 20, duration: NSInteger(2.0))
                return;
            }
            
            ProgressHUD.showProgress(targetView: self.view)
            
            let parameters : [String : Any] = ["subscription_plan" : self.subscriptionPlan!]
            let urlString  = self.createURLFromParameters(parameters: parameters)
            let str : String = ServerConstants.URL_GET_ALL_MEMBERS+urlString.absoluteString
            NetworkManager.sharedInstance.getResponseForURLWithParameters(url: str , userInfo: nil, type: "GET") { (data, response, error) in
                if(self.filteredArray.count > 0){
                    self.filteredArray.removeAllObjects()
                }
                ProgressHUD.hideProgress()
                if error == nil {
                    let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let responseDic:NSDictionary? = jsonObject as? NSDictionary
                    if (responseDic != nil) {
                        print(responseDic!)
                        if(responseDic?.object(forKey: "status") as! String  == "401"){
                            AlertView.showCustomAlertWithMessage(message: responseDic?.object(forKey: "message") as! String, yPos: 20, duration: 5)
                            self.moveToLoginScreen()
                        }
                        else if(responseDic?.object(forKey: "status") as! String  == "200"){
                            self.filteredArray.addObjects(from:  Members().updateMembers(responseDict : responseDic!) as [AnyObject])
                            self.membersTableView.reloadData()
                        }
                        else{
                            AlertView.showCustomAlertWithMessage(message: responseDic?.object(forKey: "message") as! String, yPos: 20, duration: 5)
                        }
                    }
                }
                else{
                    AlertView.showCustomAlertWithMessage(message: StringFiles.ALERT_SOMETHING, yPos: 20, duration: NSInteger(2.0))
                    print("Get Filter Members failed : \(String(describing: error?.localizedDescription))")
                }
            }
        }
    
    // Tableview delegate methods
    
        func numberOfSections(in tableView: UITableView) -> Int {
            var arrayCount = 0
            if(searchActive) {
                arrayCount = filteredArray.count
            }
            else{
                arrayCount = membersArray.count
            }
            
            var numOfSections: Int = 0
            if (arrayCount > 0){
//                tableView.separatorStyle = .singleLine
                numOfSections            = 1
                tableView.backgroundView = nil
            }
            else{
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = "No Members data available"
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            return numOfSections
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if(searchActive) {
                return filteredArray.count
            }
            return membersArray.count
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 189
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 0
        }
        
        public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            
            let view : UIView = UIView()
            view.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30)
            view.backgroundColor = UIColor.white
            
            let membersLabel : UILabel = UILabel(frame: CGRect(x: 4, y: 0, width: view.frame.size.width/2, height: view.frame.size.height))
            membersLabel.textAlignment = .left
            membersLabel.text = "Members"
            membersLabel.font = UIFont.systemFont(ofSize: 15)
            membersLabel.textColor = UIColor.lightGray
            view.addSubview(membersLabel)
            
            let plansLabel : UILabel = UILabel(frame: CGRect(x: view.frame.size.width/2 , y: 0, width: view.frame.size.width/2-4, height: view.frame.size.height))
            plansLabel.textAlignment = .right
            plansLabel.text = "Plans"
            plansLabel.font = UIFont.systemFont(ofSize: 15)
            plansLabel.textColor = UIColor.lightGray
            view.addSubview(plansLabel)
            
            return view
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MembersCell") as! MembersCell
            if(searchActive){
                if filteredArray.count > 0 {
                    let memberObj = filteredArray.object(at: indexPath.row) as! Members
                    cell.updateMembersDetails(memberBean: memberObj)
                }
            } else {
                if membersArray.count > 0 {
                    let memberObj = membersArray.object(at: indexPath.row) as! Members
                    cell.updateMembersDetails(memberBean: memberObj)
                }
            }
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            cell.selectionStyle = UITableViewCellSelectionStyle.none

            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
            if(searchActive){
                selectedMemberObj = filteredArray.object(at: indexPath.row) as? Members
            }else {
                selectedMemberObj = membersArray.object(at: indexPath.row) as? Members
            }
            self.performSegue(withIdentifier: "member_detail", sender: self)
        }
        
        /////// Search Methods
        
        func searchBarTextDidBeginEditing( _ searchBar: UISearchBar) {
            searchActive = true;
            searchBar.showsCancelButton = true
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            //searchActive = false;
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchActive = false;
            searchBar.text = ""
            searchBar.showsCancelButton = false
            searchBar.resignFirstResponder()
            self.filteredArray.removeAllObjects()
            self.membersTableView.reloadData()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchActive = true;
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = true
            self.getSearchMembers()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            
        }
        
        func navigateToMembersFilter() {
            self.performSegue(withIdentifier: "member_filter", sender: self)
        }
        
        func clearFilter() {
            searchActive = false;
            self.filteredArray.removeAllObjects()
            self.membersTableView.reloadData()
        }
        
        func getFilterDictionary(searchDict: NSMutableDictionary) {
            self.filterDict = searchDict
            let tempVar = searchDict.object(forKey: "plan") as? NSNumber
            self.subscriptionPlan = tempVar?.stringValue
            searchActive = true
            self.getSearchFilterMembers()
        }
    
    
    func downloadMembers() {
        
        if (appDelegate.userBean == nil) {
            return
        }
        if !isInternetAvailable() {
            AlertView.showCustomAlertWithMessage(message: StringFiles().CONNECTIONFAILUREALERT, yPos: 20, duration: NSInteger(2.0))
            return;
        }
        
        ProgressHUD.showProgress(targetView: self.view)
        
        NetworkManager.sharedInstance.getResponseForURLWithParameters(url: ServerConstants.URL_MEMBERS_DOWNLOAD , userInfo: nil, type: "GET") { (data, response, error) in
            
            ProgressHUD.hideProgress()
            
            if error == nil {
                let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                let responseDic:NSDictionary? = jsonObject as? NSDictionary
                if (responseDic != nil) {
                    print(responseDic!)
                    
                    if(responseDic?.object(forKey: "status") as! String  == "401"){
                        AlertView.showCustomAlertWithMessage(message: responseDic?.object(forKey: "message") as! String, yPos: 20, duration: 5)
                        self.moveToLoginScreen()
                    }
                    else {
                        AlertView.showCustomAlertWithMessage(message: responseDic?.object(forKey: "message") as! String, yPos: 20, duration: 5)
                    }
                }
            }
            else{
                AlertView.showCustomAlertWithMessage(message: StringFiles.ALERT_SOMETHING, yPos: 20, duration: NSInteger(2.0))
                print("Download Members failed : \(String(describing: error?.localizedDescription))")
            }
        }
    }
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
}
