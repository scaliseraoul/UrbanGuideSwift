//
//  AlertPresenterRepresentable.swift
//  UrbanGuide
//
//  Created by Raoul Scalise on 09/03/24.
//

import Foundation
import SwiftUI

struct AlertPresenterRepresentable: UIViewControllerRepresentable {
    var mqttManager: MQTTManager
    
    func makeUIViewController(context: Context) -> AlertPresenterController {
        let controller = AlertPresenterController()
        controller.mqttManager = mqttManager
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AlertPresenterController, context: Context) {
    }
}
