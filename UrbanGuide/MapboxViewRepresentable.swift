//
//  MapboxViewRepresentable.swift
//  UrbanGuide
//
//  Created by Raoul Scalise on 02/03/24.
//

import Foundation
import SwiftUI

struct MapboxViewRepresentable: UIViewControllerRepresentable {
    var mqttManager: MQTTManager
    
    func makeUIViewController(context: Context) -> MapboxMapViewController {
        let controller = MapboxMapViewController()
        controller.mqttManager = mqttManager
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MapboxMapViewController, context: Context) {
        // Update the view controller if needed
    }
    
}
