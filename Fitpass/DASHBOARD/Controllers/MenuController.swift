//
//  MenuController.swift
//  Fitpass
//
//  Created by SatishMac on 13/05/17.
//  Copyright © 2017 Satish. All rights reserved.
//

import UIKit
import DropDown

class MenuController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var studioTypeBtn: UIButton!
    
    @IBOutlet weak var menuTableView: UITableView!
    
    let segues = ["showDashBoardVC", "showLeadsVC" , "showMembersVC", "showPaymentsVC", "showAssetsVC", "showStaffsVC", "showWorkoutVC", "showReservedWorkoutsVC", "showWorkoutScheduleVC",  "showLogoutVC"]
    
    let menuArray :Array =  ["Dashboard", "Leads", "Members", "Payments", "Assets", "Staffs", "Workout", "Reserved Workouts", "Workout Schedule", "Logout"]

    let imagesArray : Array = ["home", "leads", "members", "payments", "assets", "staffs", "workout", "workout", "workout", "logout"]
    
    private var previousIndex: NSIndexPath?
    let dropDown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()

        menuTableView.tableFooterView = UIView(frame: .zero)
        self.studioTypeBtn.setTitle(appDelegate.userBean?.studioName, for: UIControlState.normal)
        self.studioTypeBtn.addTarget(self, action: #selector(showStudioList(sender:)), for: UIControlEvents.touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.loadProfileDetails()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadProfileDetails() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.borderColor = UIColor.black.cgColor
        self.profileImageView.layer.borderWidth = 1
        
        let logoURL = URL(string: (appDelegate.userBean?.logourl)!)
        
        // Creating a session object with the default configuration.
        // You can read more about it here https://developer.apple.com/reference/foundation/urlsessionconfiguration
        let session = URLSession(configuration: .default)
        
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPicTask = session.dataTask(with: logoURL!) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading logo picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded logo picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        let image = UIImage(data: imageData)
                        // Do something with your image.
                        self.profileImageView.image = image //UIImage(named : "profileEmpty")
                        
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        downloadPicTask.resume()
        
        /*let bannerURL = URL(string: (appDelegate.userBean?.bannerurl)!)
        
        let session1 = URLSession(configuration: .default)
        
        let downloadPicTask1 = session1.dataTask(with: bannerURL!) { (data, response, error) in
            if let e = error {
                print("Error downloading banner picture: \(e)")
            } else {
                if let res = response as? HTTPURLResponse {
                    print("Downloaded banner picture with response code \(res.statusCode)")
                    if let imageData1 = data {
                        let image1 = UIImage(data: imageData1)
                        self.profileView.image = image1
                        
                    } else {
                        print("Couldn't get banner image: Image is nil")
                    }
                } else {
                    print("Couldn't get banner response code for some reason")
                }
            }
        }
        
        downloadPicTask1.resume()*/
        
        self.profileView.image = UIImage(named: "banner")

        
        self.userName.text = (appDelegate.userBean?.first_name)! + " " + (appDelegate.userBean?.last_name)!
        self.emailLabel.text = appDelegate.userBean?.email
        
        let studioNamesArray : NSMutableArray = NSMutableArray()

        for studioObj in (appDelegate.userBean?.studioArray as? [StudioBean])! {
            let studioName : String = studioObj.studio_name!
            studioNamesArray.add(studioName)
        }
        dropDown.anchorView = self.studioTypeBtn
        dropDown.dataSource = studioNamesArray as! [String]
        dropDown.direction = .any
        dropDown.width = 280
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.studioTypeBtn.setTitle(item, for: UIControlState.normal)
        }
    }
    
    func showStudioList(sender: Any) {
        dropDown.show()
    }
    

     func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 1){
            return 4
        }
        return menuArray.count-4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if(section == 1){
            return 50
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hView : UILabel = UILabel()
        hView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.sectionHeaderHeight)
        hView.text = "    Fitpass Workouts"
        hView.backgroundColor = UIColor(red: 35/255, green: 52/255, blue: 71/255, alpha: 0.85)
        hView.textColor = UIColor.white
        return hView
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell")!
        //cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        if(indexPath.section == 1) {
            cell.textLabel?.text = menuArray[indexPath.row + menuArray.count - 4]
            cell.imageView?.image = UIImage(named : imagesArray[indexPath.row + menuArray.count - 4])
        }
        else{
            cell.textLabel?.text = menuArray[indexPath.row]
            cell.imageView?.image = UIImage(named : imagesArray[indexPath.row])
        }
        
        cell.textLabel?.textColor = UIColor.white
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        return cell
    }
    
     func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath)  {
        
        if(indexPath.row == 9){
            return
        }
        if let index = previousIndex {
            tableView.deselectRow(at: index as IndexPath, animated: true)
        }
        if(indexPath.section == 1){
            sideMenuController?.performSegue(withIdentifier: segues[indexPath.row + menuArray.count - 4], sender: nil)
        }
        else {
            if(indexPath.row != 7){
                sideMenuController?.performSegue(withIdentifier: segues[indexPath.row], sender: nil)
            }
        }
        previousIndex = indexPath as NSIndexPath?
    }
}
