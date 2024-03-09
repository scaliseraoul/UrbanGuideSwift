import SwiftUI
import MapKit

struct ContentView: View {
    private var mqttManager = MQTTManager()
    
    init() {
        mqttManager.setDidReceiveMessage(didReceiveMessage: mqttCallback)
    }
    
    var body: some View {
        ZStack {
            MapboxViewRepresentable(mqttManager: mqttManager)
            AlertPresenterRepresentable(mqttManager: mqttManager)
                .frame(width: 0, height: 0)
        }
    }
    
    private func mqttCallback(topic: String, message: String) {
        guard let data = message.data(using: .utf8) else { return }
        
        do {
            if let payload = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let topicEnum = Topics.fromTopic(topic)
                
                switch topicEnum {
                case .MoveMap:
                    if let lat = payload["lat"] as? Double, let lang = payload["lang"] as? Double, let timestamp = payload["timestamp"] as? String {
                        let event = MqttEvent.MoveMapEvent(position: CLLocationCoordinate2D(latitude: lat, longitude: lang), topic: topic, timestampSent: timestamp)
                        EventPublisher.shared.publish(event: event)
                    }
                case .DrawPoint:
                    if let title = payload["title"] as? String, let lat = payload["lat"] as? Double, let lang = payload["lang"] as? Double, let timestamp = payload["timestamp"] as? String {
                        let event = MqttEvent.DrawPointEvent(title: title, position: CLLocationCoordinate2D(latitude: lat, longitude: lang), topic: topic, timestampSent: timestamp)
                        EventPublisher.shared.publish(event: event)
                    }
                case .InAppNotification:
                    if let title = payload["title"] as? String, let text = payload["text"] as? String, let timestamp = payload["timestamp"] as? String {
                        let event = MqttEvent.InAppNotificationEvent(title: title, text: text, topic: topic, timestampSent: timestamp)
                        EventPublisher.shared.publish(event: event)
                    }
                    break
                case .InAppAlert:
                    if let text = payload["text"] as? String, let timestamp = payload["timestamp"] as? String {
                        let event = MqttEvent.InAppAlertEvent(text: text, topic: topic, timestampSent: timestamp)
                        EventPublisher.shared.publish(event: event)
                    }
                    break
                case .Unmanaged:
                    break
                }
            }
        } catch let error {
            print("Failed to parse message: \(error.localizedDescription)")
        }
    }
}


#Preview {
    ContentView()
}
