//
//  Alarm.swift
//  Alarm
//
//  Created by Olibo moni on 10/01/2022.
//  Copyright © 2022 AppDev Training. All rights reserved.
//

import UserNotifications

struct Alarm {
    
    var date: Date
    private var notificationId: String
    
    init(date: Date, notificationId: String? = nil){
        self.date = date
        self.notificationId = notificationId ?? UUID().uuidString
    }
    
    func schedule(completion: @escaping (Bool)-> ()){
        authorizeIfNeeded { (granted) in
            guard granted else {
                DispatchQueue.main.async {
                completion(false)
            }
                return
            }
            let content = UNMutableNotificationContent()
            content.body = "Beep Beep"
            content.title = "Alarm"
            content.badge = 1
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = Alarm.notificationCategoryId
            
            let triggerDateComponent = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: self.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponent, repeats: false)
            let request = UNNotificationRequest(identifier: self.notificationId, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error: Error?) in
                DispatchQueue.main.async {
                    if let error = error{
                        print(error.localizedDescription)
                        completion(false)
                    } else {
                        Alarm.scheduled = self
                        completion(true)
                    }
                }
            }
        }
        
    }
    
    func unschedule(){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.notificationId])
        Alarm.scheduled = nil
    }
    
    private func authorizeIfNeeded(completion: @escaping (Bool) ->()){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus{
                
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound, ]) { (granted, _) in
                    completion(granted)
                }
            case .authorized:
                completion(true)
            case .provisional, .denied, .ephemeral:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
        
    }
    
}

extension Alarm: Codable{
    static let notificationCategoryId = "AlarmNotification"
    static let snoozeActionID = "snooze"
    
    
    private static let alarmURL: URL = {
        guard let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first  else {
            fatalError("Can't get URL for documents directory")
        }
        return baseURL.appendingPathComponent("ScheduledAlarm")
  }()
    
    static var scheduled: Alarm?{
        get{
            guard let data = try? Data(contentsOf: alarmURL) else {
                return nil
            }
            return try? JSONDecoder().decode(Alarm.self, from: data)
        }
        
        set{
            if let alarm = newValue {
                guard let data = try? JSONEncoder().encode(alarm) else {
                    return
                }
                try? data.write(to: alarmURL)
            } else {
                try? FileManager.default.removeItem(at: alarmURL)
            }
            NotificationCenter.default.post(name: .alarmUpdated, object: nil)
        }
    }
    
      
    
    
}
