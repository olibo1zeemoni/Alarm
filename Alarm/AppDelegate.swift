//
//  AppDelegate.swift
//  Alarm
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let center = UNUserNotificationCenter.current()
        
        let snoozeAction = UNNotificationAction(identifier: Alarm.snoozeActionID, title: "snooze", options: [])
        let categoryAction = UNNotificationCategory(identifier: Alarm.notificationCategoryId, actions: [snoozeAction], intentIdentifiers: [], options: [])
        center.setNotificationCategories([categoryAction])
        center.delegate = self
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == Alarm.snoozeActionID {
            let snoozeDate = Date().addingTimeInterval(9*60) //time interval in seconds
            let alarm = Alarm(date: snoozeDate)
            alarm.schedule { granted in
                if !granted {
                    print("Can't schedule snooze because notification permissions were revoked.")
                }
            }
        }
        completionHandler()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
        Alarm.scheduled = nil 
    }
}

