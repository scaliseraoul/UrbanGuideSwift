//
//  AppleMapController.swift
//  UrbanGuide
//
//  Created by Raoul Scalise on 18/02/24.
//

import Foundation

import UIKit
import MapKit

class AppleMapViewController: UIViewController, MKMapViewDelegate {
    
    var mapView: MKMapView!
    var mqttManager: MQTTManager?
    let baseTopic : String = "iOSSwiftAppleMap"
    var motionStartedTime : DispatchTime!
    var timestampSent : String = ""
    var registerMotion : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MKMapView(frame: self.view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
        
        let modena = CLLocationCoordinate2D(latitude: 44.646469, longitude: 10.925139) //Modena
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: modena,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        setupMQTT()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if !animated && self.registerMotion {
            self.registerMotion = false
            let endTime = DispatchTime.now()
            let nanoTime = endTime.uptimeNanoseconds - self.motionStartedTime.uptimeNanoseconds
            let elapsedTime = Double(nanoTime)
            let mqttPayload = "\(self.timestampSent),iOS,Swift,AppleMap,\(Topics.MoveMap),0,0,\(elapsedTime)"
            mqttManager?.publish(message: mqttPayload, to: "\(baseTopic)\(Topics.MoveMap)Complete")
            print(mqttPayload)
        }
    }
    
    private func setupMQTT() {
        mqttManager?.subscribe(to: "\(baseTopic)\(Topics.DrawPoint)Receive")
        mqttManager?.subscribe(to: "\(baseTopic)\(Topics.DrawPointBatch)Receive")
        mqttManager?.subscribe(to: "\(baseTopic)\(Topics.MoveMap)Receive")
        
        _ = EventPublisher.shared.subscribe { event in
            switch event {
            case .DrawPointEvent(title: let title, position: let position, topic: _,timestampSent: let timestampSent):
                self.addMarker(location: position, title: title,timestampSent: timestampSent)
            case .DrawPointBatchEvent(events: let events, timestampSent: let timestampSent):
                self.addBatchMarkers(events: events, timestampSent: timestampSent)
            case .MoveMapEvent(position: let position, topic: _, timestampSent: let timestampSent):
                self.centerMapOnLocation(location: position,timestampSent: timestampSent)
            default:
                break
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D,timestampSent: String) {
        self.registerMotion = true
        self.timestampSent = timestampSent
        self.motionStartedTime = DispatchTime.now()
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    func addMarker(location: CLLocationCoordinate2D, title: String,timestampSent: String) {
        let startTime = DispatchTime.now()
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = title
        mapView.addAnnotation(annotation)
        let endTime = DispatchTime.now()
        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        let elapsedTime = Double(nanoTime)
        let mqttPayload = "\(timestampSent),iOS,Swift,AppleMap,\(Topics.DrawPoint),0,0,\(elapsedTime)"
        mqttManager?.publish(message: mqttPayload, to: "\(baseTopic)\(Topics.DrawPoint)Complete")
        print(mqttPayload)
    }
    
    func addBatchMarkers(events: [MqttEvent], timestampSent: String) {
        let startTime = DispatchTime.now()
        
        
        events.forEach { mqttEvent in
            if case .DrawPointEvent(let title, let position, _, _) = mqttEvent {
                let annotation = MKPointAnnotation()
                annotation.coordinate = position
                annotation.title = title
                mapView.addAnnotation(annotation)
            }
        }
        
        let endTime = DispatchTime.now()
        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        let elapsedTime = Double(nanoTime)
        let mqttPayload = "\(timestampSent),iOS,Swift,AppleMap,\(Topics.DrawPointBatch),0,0,\(elapsedTime)"
        mqttManager?.publish(message: mqttPayload, to: "\(baseTopic)\(Topics.DrawPointBatch)Complete")
        print(mqttPayload)
    }
}
