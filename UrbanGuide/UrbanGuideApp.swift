//
//  UrbanGuideApp.swift
//  UrbanGuide
//
//  Created by Raoul Scalise on 05/02/24.
//

import SwiftUI
import UserNotifications

@main
struct UrbanGuideApp: App {
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Permission granted: \(granted)")
        }
        
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
        
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
