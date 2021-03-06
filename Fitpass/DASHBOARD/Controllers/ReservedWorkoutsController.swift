//
//  ReservedWorkoutsController.swift
//  Fitpass
//
//  Created by SatishMac on 13/05/17.
//  Copyright © 2017 Satish. All rights reserved.
//

import UIKit
import Alamofire

class ReservedWorkoutsController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
        
        @IBOutlet weak var reservedWorkoutsSearchBar: UISearchBar!
        @IBOutlet weak var reservedWorkoutsTableView: UITableView!
        
        var reservedWorkoutsArray : NSMutableArray = NSMutableArray()
        var searchActive : Bool = false
        var filteredArray: NSMutableArray = NSMutableArray()
        var searchString : String? = ""
        var selectedReservedWorkoutObj : ReservedWorkouts?
    var URCString : String? = ""
        
        override func viewDidLoad() {
            super.viewDidLoad()
            let downloadBtn = UIButton(type: .custom)
            downloadBtn.setImage(UIImage(named: "reservedworkouts"), for: .normal)
            downloadBtn.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
            downloadBtn.addTarget(self, action: #selector(verifyURC), for: .touchUpInside)
            let item1 = UIBarButtonItem(customView: downloadBtn)
            
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItems = [item1]

            
            let partnerForm = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"PartnerRequestViewController") as! PartnerRequestViewController
            partnerForm.view.frame = CGRect(x:0, y:0, width:self.view.bounds.width, height:self.view.bounds.height)
            self.addChildViewController(partnerForm)
            self.view.addSubview(partnerForm.view)
            
            if((appDelegate.userBean?.auth_key == "" || appDelegate.userBean?.auth_key == nil) || (appDelegate.userBean?.partner_id == "" || appDelegate.userBean?.partner_id == nil)){
                reservedWorkoutsSearchBar.isHidden = true
                reservedWorkoutsTableView.isHidden = true
                partnerForm.view.isHidden = false
            }else{
                reservedWorkoutsSearchBar.isHidden = false
                reservedWorkoutsTableView.isHidden = false
                partnerForm.view.isHidden = true
                
//                reservedWorkoutsSearchBar.showsCancelButton = true
                self.getReservedWorkouts()

            }

        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationItem.title = "Reserved Workouts"
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if(segue.identifier == "reservedworkout_detail") {
                let reservedWorkoutDetailVC : ReservedWorkoutDetailController = segue.destination as! ReservedWorkoutDetailController
                reservedWorkoutDetailVC.reservedWorkoutObj = selectedReservedWorkoutObj
            }
        }
        
        func getReservedWorkouts() {
            
            if (appDelegate.userBean == nil) {
                return
            }
            if !isInternetAvailable() {
                AlertView.showCustomAlertWithMessage(message: StringFiles().CONNECTIONFAILUREALERT, yPos: 20, duration: NSInteger(2.0))
                return;
            }
            
            ProgressHUD.showProgress(targetView: self.view)
            
            NetworkManager.sharedInstance.getResponseForURLWithParameters(url: ServerConstants.URL_GET_RESERVED_WORKOUTS , userInfo: nil, type: "GET") { (data, response, error) in
                
                ProgressHUD.hideProgress()
                
                if error == nil {
                    let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let responseDic:NSDictionary? = jsonObject as? NSDictionary
                    if (responseDic != nil) {
                        print(responseDic!)
                        if(responseDic?.object(forKey: "code") as! NSNumber  == 401){
                            AlertView.showCustomAlertWithMessage(message: responseDic?.object(forKey: "message") as! String, yPos: 20, duration: 5)
                            self.moveToLoginScreen()
                        }
                        else if(responseDic?.object(forKey: "code") as! NSNumber  == 200){

//                        if(responseDic!.object(forKey:"code") as! NSNumber == 200){
                            self.reservedWorkoutsArray.addObjects(from:  ReservedWorkouts().updateReservedWorkouts(responseDict : responseDic!) as [AnyObject])
                            self.reservedWorkoutsTableView.reloadData()
                        }else{
                            self.reservedWorkoutsArray.removeAllObjects()
                            self.reservedWorkoutsTableView.reloadData()
                            AlertView.showCustomAlertWithMessage(message: responseDic!.object(forKey:"message") as! String, yPos: 20, duration: NSInteger(2.0))
                        }
                    }
                }
                else{
                    AlertView.showCustomAlertWithMessage(message: StringFiles.ALERT_SOMETHING, yPos: 20, duration: NSInteger(2.0))
                    print("Get Reserved Workouts failed : \(String(describing: error?.localizedDescription))")
                }
            }
        }
        
        func getSearchReservedWorkouts() {
            
            if (appDelegate.userBean == nil) {
                return
            }
            if !isInternetAvailable() {
                AlertView.showCustomAlertWithMessage(message: StringFiles().CONNECTIONFAILUREALERT, yPos: 20, duration: NSInteger(2.0))
                return;
            }
            
            ProgressHUD.showProgress(targetView: self.view)
            
            let parameters : [String : Any] = ["workout_name" : self.reservedWorkoutsSearchBar.text!]
            let urlString  = self.createURLFromParameters(parameters: parameters)
            let str : String = ServerConstants.URL_GET_RESERVED_WORKOUTS+urlString.absoluteString
            NetworkManager.sharedInstance.getResponseForURLWithParameters(url: str , userInfo: nil, type: "GET") { (data, response, error) in
                
                ProgressHUD.hideProgress()
                if error == nil {
                    let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let responseDic:NSDictionary? = jsonObject as? NSDictionary
                    if (responseDic != nil) {
                        print(responseDic!)
                        if(responseDic?.object(forKey: "code") as! NSNumber  == 401){
                            AlertView.showCustomAlertWithMessage(message: responseDic?.object(forKey: "message") as! String, yPos: 20, duration: 5)
                            self.moveToLoginScreen()
                        }
                        else if(responseDic?.object(forKey: "code") as! NSNumber  == 200){

//                        if(responseDic!.object(forKey:"code") as! NSNumber == 200){
                            if(self.filteredArray.count>0){
                                self.filteredArray.removeAllObjects()
                            }
                            self.filteredArray.addObjects(from:  ReservedWorkouts().updateReservedWorkouts(responseDict : responseDic!) as [AnyObject])
                            self.reservedWorkoutsTableView.reloadData()
                        }else{
                            self.filteredArray.removeAllObjects()
                            self.reservedWorkoutsTableView.reloadData()
                            AlertView.showCustomAlertWithMessage(message: responseDic!.object(forKey:"message") as! String, yPos: 20, duration: NSInteger(2.0))
                        }
                    }
                }
                else{
                    AlertView.showCustomAlertWithMessage(message: StringFiles.ALERT_SOMETHING, yPos: 20, duration: NSInteger(2.0))
                    print("Get Search reservedWorkouts failed : \(String(describing: error?.localizedDescription))")
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
                arrayCount = reservedWorkoutsArray.count
            }
            
            var numOfSections: Int = 0
            if (arrayCount > 0){
                tableView.separatorStyle = .none
                numOfSections            = 1
                tableView.backgroundView = nil
            }
            else{
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = "No reserved workouts data available"
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
            return reservedWorkoutsArray.count
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 150
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 0
        }
                
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReservedWorkoutCell") as! ReservedWorkoutCell
            if(searchActive){
                if filteredArray.count > 0 {
                    let reservedWorkoutObj = filteredArray.object(at: indexPath.row) as! ReservedWorkouts
                    cell.updateReservedWorkoutDetails(reservedBean: reservedWorkoutObj)
                }
            } else {
                if reservedWorkoutsArray.count > 0 {
                    let reservedWorkoutObj = reservedWorkoutsArray.object(at: indexPath.row) as! ReservedWorkouts
                    cell.updateReservedWorkoutDetails(reservedBean: reservedWorkoutObj)
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
                selectedReservedWorkoutObj = filteredArray.object(at: indexPath.row) as? ReservedWorkouts
            }else {
                selectedReservedWorkoutObj = reservedWorkoutsArray.object(at: indexPath.row) as? ReservedWorkouts
            }
            self.performSegue(withIdentifier: "reservedworkout_detail", sender: self)
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
            self.reservedWorkoutsTableView.reloadData()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchActive = true;
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = true
            self.getSearchReservedWorkouts()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            
        }
        
    func verifyURC(){
        showAlertWithTextFieldAndTitle(title: "VALIDATE URC NUMBER", message: "Enter URC number", forTarget: self, buttonOK: "Validate", buttonCancel: "Cancel", isEmail: false, textPlaceholder: "Please enter URC number", alertOK: { (msgString) in
            self.URCString = msgString
            self.sendURC()
        }) { (Void) in
            
        }
    }
    
    func sendURC(){
        if (appDelegate.userBean == nil) {
            return
        }
        if !isInternetAvailable() {
            AlertView.showCustomAlertWithMessage(message: StringFiles().CONNECTIONFAILUREALERT, yPos: 20, duration: NSInteger(2.0))
            return;
        }
        
        ProgressHUD.showProgress(targetView: self.view)
        
//        let paramDict : [String : Any] = ["bank_utr_number" : self.URCString!]//security_code
        let paramDict : [String : Any] = ["security_code" : self.URCString!, "status":1]

        let urlRequest = URLRequest(url: URL(string: ServerConstants.URL_URC)!)
        let urlString = urlRequest.url?.absoluteString

        let headersDict: HTTPHeaders = [
            "X-APPKEY":(appDelegate.userBean?.auth_key)!,
            "X-partner-id":(appDelegate.userBean?.partner_id)!,
            "Content-Type":"application/x-www-form-urlencoded; charset=utf-8"
        ]
        
        Alamofire.request(urlString!, method: .post, parameters: paramDict, encoding: URLEncoding.httpBody, headers: headersDict).responseJSON { (response) in
            ProgressHUD.hideProgress()

            print(response.result)
            
            let responseDic =  response.result.value as! NSDictionary
//            if(responseDic.object(forKey:"code") as! NSNumber == 200){
                AlertView.showCustomAlertWithMessage(message: responseDic.object(forKey: "message") as! String, yPos: 20, duration: NSInteger(2.0))
//            }
//            else{
//                AlertView.showCustomAlertWithMessage(message: StringFiles.ALERT_SOMETHING, yPos: 20, duration: NSInteger(2.0))
//            }
        }

        
        
        
        
 /*       NetworkManager.sharedInstance.getResponseForURLWithParameters(url: ServerConstants.URL_URC , userInfo: paramDict as NSDictionary, type: "POST") { (data, response, error) in
            
            ProgressHUD.hideProgress()
            
            if error == nil {
                let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                let responseDic:NSDictionary? = jsonObject as? NSDictionary
                if (responseDic != nil) {
                    print(responseDic!)
                    AlertView.showCustomAlertWithMessage(message: responseDic?.object(forKey: "message") as! String, yPos: 20, duration: NSInteger(2.0))
                }
            }
            else{
                AlertView.showCustomAlertWithMessage(message: StringFiles.ALERT_SOMETHING, yPos: 20, duration: NSInteger(2.0))
                print("sending message to lead failed : \(String(describing: error?.localizedDescription))")
            }
        }*/
    }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
}
