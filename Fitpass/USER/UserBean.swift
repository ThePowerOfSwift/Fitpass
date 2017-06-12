//
//  UserBean.swift
//  Fitpass
//
//  Created by SatishMac on 26/04/17.
//  Copyright © 2017 Satish. All rights reserved.
//

import UIKit

class UserBean: NSObject, NSCoding {
    
    var address : String? = ""
    var displayName : String? = ""
    var email : String? = ""
    var first_name : String? = ""
    var last_name : String? = ""
    var user_id : NSNumber?
    var is_active : Bool?
    var is_deleted : Bool?
    var number : String?
    var password_plain : String? = ""
    var profilePic : UIImage? = nil
    var remarks : String? = ""
    var authHeader : String? = ""
    var studioName : String? = ""
    var studioArray : NSMutableArray = NSMutableArray()
    
    override init() {
        
    }
    
    required init(coder decoder: NSCoder) {
        self.address = decoder.decodeObject(forKey: "address") as? String ?? ""
        self.displayName = decoder.decodeObject(forKey: "displayName") as? String ?? ""
        self.email = decoder.decodeObject(forKey: "email") as? String ?? ""
        self.first_name = decoder.decodeObject(forKey: "first_name") as? String ?? ""
        self.last_name = decoder.decodeObject(forKey: "last_name") as? String ?? ""
        self.user_id = decoder.decodeObject(forKey: "id") as? NSNumber
        self.is_active = decoder.decodeObject(forKey: "is_active") as? Bool
        self.is_deleted = decoder.decodeObject(forKey : "is_deleted") as? Bool
        self.number = decoder.decodeObject(forKey : "number") as? String ?? ""
        self.password_plain = decoder.decodeObject(forKey : "password_plain") as? String ?? ""
        self.remarks = decoder.decodeObject(forKey : "remarks") as? String ?? ""
        self.authHeader = decoder.decodeObject(forKey : "studio_token") as? String ?? ""
        self.studioName = decoder.decodeObject(forKey: "studio_name") as? String ?? ""
//        self.studioArray = (decoder.decodeObject(forKey: "studio_details") as! NSMutableArray).mutableCopy() as! NSMutableArray
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(address, forKey: "address")
        coder.encode(displayName, forKey: "displayName")
        coder.encode(email, forKey : "email")
        coder.encode(first_name, forKey : "first_name")
        coder.encode(last_name, forKey: "last_name")
        coder.encode(user_id, forKey : "id")
        coder.encode(is_active, forKey : "is_active")
        coder.encode(is_deleted, forKey : "is_deleted")
        coder.encode(number, forKey : "number")
        coder.encode(password_plain, forKey : "password_plain")
        coder.encode(remarks, forKey : "remarks")
        coder.encode(authHeader, forKey : "studio_token")
        coder.encode(studioName, forKey : "studio_name")
//        coder.encode(studioArray, forKey : "studio_details")
    }
    
    // update user bean
    func updateUserBean(responseDict : NSDictionary?) {
        
        let userDet: NSDictionary = responseDict!.object(forKey: "user_details") as! NSDictionary
        
        if let addressTemp =  userDet["address"], !(addressTemp is NSNull){
            self.address = addressTemp as? String
        }else{
            self.address = ""
        }
        
        if let displayName = userDet["displayName"], !(displayName is NSNull){
            self.displayName = displayName as? String
        }
        else{
            self.displayName = ""
        }

        if let email = userDet["email"], !(email is NSNull){
            self.email = email as? String
        }
        else{
            self.email = ""
        }
        
        if let firstname = userDet["first_name"], !(firstname is NSNull){
            self.first_name = firstname as? String
        }
        else{
            self.first_name = ""
        }
        if let lastname = userDet["last_name"], !(lastname is NSNull){
            self.last_name = lastname as? String
        }
        else{
            self.last_name = ""
        }
        if let tempid = userDet["id"], !(tempid is NSNull){
            self.user_id = tempid as? NSNumber
        }
        else{
            self.user_id = 0
        }
        if let number = userDet["number"], !(number is NSNull){
            self.number = number as? String
        }
        else{
            self.number = ""
        }
        self.is_active = userDet["is_active"] as! Bool?
        self.is_deleted = userDet["is_deleted"] as! Bool?
        
        if let passwordTemp =  userDet["password_plain"], !(passwordTemp is NSNull){
            self.password_plain = passwordTemp as? String
        }else{
            self.password_plain = ""
        }

        if let remarksTemp =  userDet["remarks"], !(remarksTemp is NSNull){
            self.remarks = remarksTemp as? String
        }else{
            self.remarks = ""
        }
        
        let studioDetailsArray: NSMutableArray = (responseDict!.object(forKey: "studio_details") as! NSArray).mutableCopy() as! NSMutableArray
        
        let tempArray : NSMutableArray = NSMutableArray()
        
        for studioObj in (studioDetailsArray as? [[String:Any]])! {
            
            let studioBean : StudioBean = StudioBean()
            
            studioBean.auth_key = studioObj[ "auth_key"] as? String
            studioBean.banner_url = studioObj["banner_url"] as? String
            studioBean.city = studioObj["city"] as? String
            studioBean.logo_url = studioObj["logo_url"] as? String
            studioBean.nick_name = studioObj["nick_name"] as? String
            studioBean.partner_id = studioObj["partner_id"] as? String
            studioBean.studio_id = studioObj["studio_id"] as? String
            studioBean.studio_name = studioObj["studio_name"] as? String
            studioBean.studio_token = studioObj["studio_token"] as? String
            
            tempArray.add(studioBean)
        }
        
        self.studioArray = tempArray
        
        if(self.studioArray.count > 0){
            let studioBeanObj : StudioBean = studioArray.object(at: 0) as! StudioBean
            self.authHeader = studioBeanObj.studio_token
            self.studioName = studioBeanObj.studio_name
        }
        appDelegate.userBean = self
    }
    
    func updateProfileDetails(responseDict : NSDictionary?) {
        
        let userDet: NSDictionary = responseDict!.object(forKey: "result") as! NSDictionary
        
        appDelegate.userBean?.email = userDet["email"] as! String?
        appDelegate.userBean?.displayName = userDet["displayName"] as! String?
        appDelegate.userBean?.number = userDet["number"] as! String?
        
    }
    
}

class StudioBean : NSObject{
    var auth_key : String?
    var banner_url : String?
    var city : String?
    var logo_url : String?
    var nick_name : String?
    var partner_id : String?
    var studio_id : String?
    var studio_name : String?
    var studio_token : String?
}
