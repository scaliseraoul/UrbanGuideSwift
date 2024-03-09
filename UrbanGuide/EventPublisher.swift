//
//  EventPublisher.swift
//  UrbanGuide
//
//  Created by Raoul Scalise on 01/03/24.
//

import Foundation

class EventPublisher {
    static let shared = EventPublisher()
    private init() {}

    private var subscribers = [UUID: (MqttEvent) -> Void]()

    func subscribe(_ subscriber: @escaping (MqttEvent) -> Void) -> UUID {
        let id = UUID()
        subscribers[id] = subscriber
        return id
    }

    func unsubscribe(_ id: UUID) {
        subscribers.removeValue(forKey: id)
    }

    func publish(event: MqttEvent) {
        subscribers.forEach { $1(event) }
    }
}
