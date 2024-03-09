//
//  AlertPresenterController.swift
//  UrbanGuide
//
//  Created by Raoul Scalise on 09/03/24.
//

import Foundation
import UIKit
import SwiftUI

class AlertPresenterController: UIViewController {
    var mqttManager: MQTTManager?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mqttManager?.subscribe(to: "iOSSwift\(Topics.InAppAlert)Receive")
        mqttManager?.subscribe(to: "iOSSwift\(Topics.InAppNotification)Receive")
        
        _ = EventPublisher.shared.subscribe { event in
            switch event {
            case .InAppAlertEvent(text: let text, topic: _, timestampSent: let timestampSent):
                let startTime = DispatchTime.now()
                let alert = UIAlertController(title: "", message: text, preferredStyle: .alert)
                self.present(alert, animated: false) {
                    let endTime = DispatchTime.now()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        alert.dismiss(animated: false)
                    }
                    let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                    let elapsedTime = Double(nanoTime)
                    let mqttPayload = "\(timestampSent),iOS,Swift,-,\(Topics.InAppAlert),0,0,\(elapsedTime)"
                    self.mqttManager?.publish(message: mqttPayload, to: "iOSSwift\(Topics.InAppAlert)Complete")
                    print(mqttPayload)
                }
                break
            case .InAppNotificationEvent(title: let title, text: let text, topic: _, timestampSent: let timestampSent):
                let startTime = DispatchTime.now()
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = text
                content.sound = UNNotificationSound.default
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                
                // Schedule the request with the system.
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    } else {
                        let endTime = DispatchTime.now()
                        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                        let elapsedTime = Double(nanoTime)
                        let mqttPayload = "\(timestampSent),iOS,Swift,-,\(Topics.InAppAlert),0,0,\(elapsedTime)"
                        self.mqttManager?.publish(message: mqttPayload, to: "iOSSwift\(Topics.InAppNotification)Complete")
                        print(mqttPayload)
                    }
                }
                break
            default:
                break
            }
        }
    }
}
