//
//  File.swift
//  UrbanGuide
//
//  Created by Raoul Scalise on 18/02/24.
//

import Foundation
import CocoaMQTT
import MapKit

enum Topics {
    case DrawPoint
    case InAppAlert
    case InAppNotification
    case MoveMap
    case Unmanaged

    static func fromTopic(_ topic: String?) -> Topics {
        guard let topic = topic else { return .Unmanaged }

        if topic.lowercased().contains("drawpoint") {
            return .DrawPoint
        } else if topic.lowercased().contains("inappalert") {
            return .InAppAlert
        } else if topic.lowercased().contains("inappnotification") {
            return .InAppNotification
        } else if topic.lowercased().contains("movemap") {
            return .MoveMap
        } else {
            return .Unmanaged
        }
    }
}

enum MqttEvent {
    case MoveMapEvent(position: CLLocationCoordinate2D, topic: String, timestampSent: String)
    case DrawPointEvent(title: String, position: CLLocationCoordinate2D, topic: String, timestampSent: String)
    case InAppAlertEvent(text: String, topic: String, timestampSent: String)
    case InAppNotificationEvent(title: String, text: String, topic: String, timestampSent: String)
}

class MQTTManager {
    private var mqtt: CocoaMQTT?
    private var topicsToSubscribe = [(String, CocoaMQTTQoS)]()
    
    init() {
        setupMQTT()
    }
    
    private func setupMQTT() {
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        
        self.mqtt = CocoaMQTT(clientID: clientID, host: "localhost", port: 1883)
        guard let mqtt = self.mqtt else { return }
        
        mqtt.keepAlive = 60
        
        mqtt.didConnectAck = { [weak self] mqtt, ack in
                    if ack == .accept {
                        self?.topicsToSubscribe.forEach { topic, qos in
                            mqtt.subscribe(topic, qos: qos)
                        }
                        self?.topicsToSubscribe.removeAll()
                    }
                }
        
        mqtt.connect()
    }
    
    func subscribe(to topic: String) {
        topicsToSubscribe.append((topic, .qos2))
                
        if mqtt?.connState == .connected {
            mqtt?.subscribe(topic, qos: .qos2)
        }
    }
    
    func publish(message: String, to topic: String) {
        mqtt?.publish(topic, withString: message)
    }
    
    func setDidReceiveMessage(didReceiveMessage: @escaping (_ topic: String, _ message: String) -> Void) {
        mqtt?.didReceiveMessage = { mqtt, message, id in
            didReceiveMessage(message.topic, message.string ?? "")
        }
    }
}
