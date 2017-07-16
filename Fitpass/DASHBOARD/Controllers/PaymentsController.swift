//
//  PaymentsController.swift
//  Fitpass
//
//  Created by SatishMac on 13/05/17.
//  Copyright © 2017 Satish. All rights reserved.
//


import UIKit

protocol paymentDelegate {
    func getDictionary (searchDict: NSDictionary)
    func clearFilter ()
}

class PaymentsController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, paymentDelegate {
    
    
    @IBOutlet weak var paymentsSearchBar: UISearchBar!
    @IBOutlet weak var paymentsTableView: UITableView!
    
    var bankUtrNumber: String?
    var paymentDate: String?
    var paymentMonth: String?
    var paymentsArray : NSMutableArray = NSMutableArray()
    var searchActive : Bool = false
    var filtered: NSMutableArray = NSMutableArray()
    var searchString : String? = ""
    var selectedPaymentObj : Payments?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paymentsSearchBar.showsCancelButton = true
        
        let filterBtn = UIButton(type: .custom)
        filterBtn.setImage(UIImage(named: "filter"), for: .normal)
        filterBtn.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        filterBtn.addTarget(self, action: #selector(navigateToPaymentsFilter), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: filterBtn)
        
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = item1
        self.getPayments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Payments"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "payment_filter") {
            let paymentVC : PaymentsFilterController = segue.destination as! PaymentsFilterController
            paymentVC.delegate = self
        }
        else if(segue.identifier == "payment_detail") {
            let paymentDetailVC : PaymentDetailController = segue.destination as! PaymentDetailController
            paymentDetailVC.paymentObj = selectedPaymentObj
        }
    }
    
    func getPayments() {
        
        if (appDelegate.userBean == nil) {
            return
        }
        if !isInternetAvailable() {
            AlertView.showCustomAlertWithMessage(message: StringFiles().CONNECTIONFAILUREALERT, yPos: 20, duration: NSInteger(2.0))
            return;
        }
        
        ProgressHUD.showProgress(targetView: self.view)
        
        NetworkManager.sharedInstance.getResponseForURLWithParameters(url: ServerConstants.URL_GET_ALL_PAYMENTS , userInfo: nil, type: "GET") { (data, response, error) in
            
            ProgressHUD.hideProgress()
            
            if error == nil {
                let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                let responseDic:NSDictionary? = jsonObject as? NSDictionary
                if (responseDic != nil) {
                    print(responseDic!)
                    self.paymentsArray.addObjects(from:  Payments().updatePayments(responseDict : responseDic!) as [AnyObject])
                    self.paymentsTableView.reloadData()
                }
            }
            else{
                AlertView.showCustomAlertWithMessage(message: StringFiles.ALERT_SOMETHING, yPos: 20, duration: NSInteger(2.0))
                print("Get Payments failed : \(String(describing: error?.localizedDescription))")
            }
        }
    }
    func getSearchPayments() {
        
        if (appDelegate.userBean == nil) {
            return
        }
        if !isInternetAvailable() {
            AlertView.showCustomAlertWithMessage(message: StringFiles().CONNECTIONFAILUREALERT, yPos: 20, duration: NSInteger(2.0))
            return;
        }
        
        ProgressHUD.showProgress(targetView: self.view)
        
        let parameters : [String : Any] = ["search_text" : self.paymentsSearchBar.text!, "search_by" : "Name"]
        let urlString  = self.createURLFromParameters(parameters: parameters)
        let str : String = ServerConstants.URL_GET_ALL_PAYMENTS+urlString.absoluteString
        NetworkManager.sharedInstance.getResponseForURLWithParameters(url: str , userInfo: nil, type: "GET") { (data, response, error) in
            
            ProgressHUD.hideProgress()
            if error == nil {
                let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                let responseDic:NSDictionary? = jsonObject as? NSDictionary
                if (responseDic != nil) {
                    print(responseDic!)
                    self.filtered.addObjects(from:  Payments().updatePayments(responseDict : responseDic!) as [AnyObject])
                    self.paymentsTableView.reloadData()
                }
            }
            else{
                AlertView.showCustomAlertWithMessage(message: StringFiles.ALERT_SOMETHING, yPos: 20, duration: NSInteger(2.0))
                print("Get Search Payments failed : \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func getSearchFilterPayments() {
        
        if (appDelegate.userBean == nil) {
            return
        }
        if !isInternetAvailable() {
            AlertView.showCustomAlertWithMessage(message: StringFiles().CONNECTIONFAILUREALERT, yPos: 20, duration: NSInteger(2.0))
            return;
        }
        
        ProgressHUD.showProgress(targetView: self.view)
        
        let parameters : [String : Any] = ["payment_of_month" : self.paymentMonth! , "payment_date" : self.paymentDate!, "bank_utr_number" : self.bankUtrNumber!]
        let urlString  = self.createURLFromParameters(parameters: parameters)
        let str : String = ServerConstants.URL_GET_ALL_PAYMENTS+urlString.absoluteString
        NetworkManager.sharedInstance.getResponseForURLWithParameters(url: str , userInfo: nil, type: "GET") { (data, response, error) in
            if(self.filtered.count > 0){
                self.filtered.removeAllObjects()
            }
            ProgressHUD.hideProgress()
            if error == nil {
                let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                let responseDic:NSDictionary? = jsonObject as? NSDictionary
                if (responseDic != nil) {
                    print(responseDic!)
                    self.filtered.addObjects(from:  Payments().updatePayments(responseDict : responseDic!) as [AnyObject])
                    self.paymentsTableView.reloadData()
                }
            }
            else{
                AlertView.showCustomAlertWithMessage(message: StringFiles.ALERT_SOMETHING, yPos: 20, duration: NSInteger(2.0))
                print("Get Filter Payments failed : \(String(describing: error?.localizedDescription))")
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        var arrayCount = 0
        if(searchActive) {
            arrayCount = filtered.count
        }
        else{
            arrayCount = paymentsArray.count
        }
        
        var numOfSections: Int = 0
        if (arrayCount > 0){
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else{
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No payments data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return paymentsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view : UIView = UIView()
        view.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30)
        view.backgroundColor = UIColor.white
        
        let leadsLabel : UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width/3, height: view.frame.size.height))
        leadsLabel.textAlignment = .left
        leadsLabel.text = "    Leads"
        leadsLabel.font = UIFont.systemFont(ofSize: 15)
        leadsLabel.textColor = UIColor.lightGray
        view.addSubview(leadsLabel)
        
        
        let createdAtLabel : UILabel = UILabel(frame: CGRect(x: view.frame.size.width/3 , y: 0, width: view.frame.size.width/3, height: view.frame.size.height))
        createdAtLabel.textAlignment = .center
        createdAtLabel.text = "                Created At"
        createdAtLabel.font = UIFont.systemFont(ofSize: 15)
        createdAtLabel.textColor = UIColor.lightGray
        view.addSubview(createdAtLabel)
        
        let statusLabel : UILabel = UILabel(frame: CGRect(x: view.frame.size.width/3 + view.frame.size.width/3 , y: 0, width: view.frame.size.width/3, height: view.frame.size.height))
        statusLabel.textAlignment = .center
        statusLabel.text = "               Status"
        statusLabel.font = UIFont.systemFont(ofSize: 15)
        statusLabel.textColor = UIColor.lightGray
        view.addSubview(statusLabel)
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentsCell") as! PaymentsCell
        if(searchActive){
            if filtered.count > 0 {
                let paymentObj = filtered.object(at: indexPath.row) as! Payments
                cell.updatePaymentsDetails(paymentBean: paymentObj)
            }
        } else {
            if paymentsArray.count > 0 {
                let paymentObj = paymentsArray.object(at: indexPath.row) as! Payments
                cell.updatePaymentsDetails(paymentBean: paymentObj)
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
            selectedPaymentObj = filtered.object(at: indexPath.row) as? Payments
        }else {
            selectedPaymentObj = paymentsArray.object(at: indexPath.row) as? Payments
        }
        self.performSegue(withIdentifier: "payment_detail", sender: self)
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
        self.filtered.removeAllObjects()
        self.paymentsTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true;
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = true
        self.getSearchPayments()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func navigateToPaymentsFilter() {
        self.performSegue(withIdentifier: "payment_filter", sender: self)
    }
    
    func clearFilter() {
        searchActive = false;
        self.filtered.removeAllObjects()
        self.paymentsTableView.reloadData()
    }
    
    func getDictionary(searchDict: NSDictionary) {
        self.bankUtrNumber = searchDict.object(forKey: "bankUtrNumber") as? String
        self.paymentDate = searchDict.object(forKey: "paymentDate") as? String
        self.paymentMonth = searchDict.object(forKey: "paymentMonth") as? String
        searchActive = true
        self.getSearchFilterPayments()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
