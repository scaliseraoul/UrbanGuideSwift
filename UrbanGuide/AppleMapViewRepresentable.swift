//
//  UIViewControllerRepresentable.swift
//  UrbanGuide
//
//  Created by Raoul Scalise on 01/03/24.
//

import SwiftUI

struct AppleMapViewRepresentable: UIViewControllerRepresentable {
    var mqttManager: MQTTManager
    
    func makeUIViewController(context: Context) -> AppleMapViewController {
        let controller = AppleMapViewController()
        controller.mqttManager = mqttManager
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AppleMapViewController, context: Context) {
        // Update the view controller if needed
    }
    
}
