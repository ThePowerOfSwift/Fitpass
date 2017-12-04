//
//  AppDelegate.swift
//  Fitpass
//
//  Created by SatishMac on 26/04/17.
//  Copyright © 2017 Satish. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SideMenuController
import DropDown

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var userBean : UserBean?
    var isSignIn : Bool = false
    var isLocalNotification : Bool = false

     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        // Override point for customization after application launch.
        SideMenuController.preferences.drawing.menuButtonImage = UIImage(named: "sidemenu")
        SideMenuController.preferences.drawing.sidePanelPosition = .overCenterPanelLeft
        SideMenuController.preferences.drawing.sidePanelWidth = 300
        SideMenuController.preferences.drawing.centerPanelShadow = true
        SideMenuController.preferences.animating.statusBarBehaviour = .showUnderlay
        DropDown.startListeningToKeyboard()
        self.checkSingleSignIn()
        
        IQKeyboardManager.sharedManager().enable = true
        
        UIApplication.shared.statusBarStyle = .lightContent

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func checkSingleSignIn() {
        
        // retrieving a value for a key
        if let data = UserDefaults.standard.data(forKey: "userBean"),
                let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? [UserBean] {
                    user.forEach( {
//                print( $0.userName!, $0.authHeader!)
                
                self.userBean = $0
                self.isSignIn = true
                
                        if let studioData = UserDefaults.standard.data(forKey: "studioarray") {
                            self.userBean?.studioArray = NSKeyedUnarchiver.unarchiveObject(with: studioData) as! [StudioBean]
                        }
        let viewController : CustomSideMenuController = mainStoryboard.instantiateViewController(withIdentifier: "customsidemenucontroller") as! CustomSideMenuController
                    self.window?.rootViewController = viewController
            })
        } else {
            print("There is an issue")
            let viewController : LoginViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.window?.rootViewController? = viewController
        
        }
    }
}

