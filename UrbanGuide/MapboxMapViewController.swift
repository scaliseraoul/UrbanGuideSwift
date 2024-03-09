//
//  MapboxMapViewController.swift
//  UrbanGuide
//
//  Created by Raoul Scalise on 02/03/24.
//

import Foundation
import UIKit
import MapboxMaps

class MapboxMapViewController: UIViewController {
    var mqttManager: MQTTManager?
    var mapView: MapView!
    let baseTopic : String = "iOSSwiftMapbox"
    var cancelables = Set<AnyCancelable>()
    var motionStartedTime : DispatchTime!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
    }
    
    private func initializeMapView() {
        mapView = MapView(frame: view.bounds)
        let cameraOptions = CameraOptions(center:
                                            CLLocationCoordinate2D(latitude: 44.646469, longitude: 10.925139),
                                          zoom: 15, bearing: 0, pitch: 30)
        mapView.mapboxMap.setCamera(to: cameraOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(mapView)
        
        setupMQTT()
    }
    
    private func setupMQTT() {
        mqttManager?.subscribe(to: "\(baseTopic)\(Topics.DrawPoint)Receive")
        mqttManager?.subscribe(to: "\(baseTopic)\(Topics.MoveMap)Receive")
        
        _ = EventPublisher.shared.subscribe { event in
            switch event {
            case .DrawPointEvent(title: let title, position: let position, topic: _,timestampSent: let timestampSent):
                self.addMarker(location: position, title: title,timestampSent: timestampSent)
            case .MoveMapEvent(position: let position, topic: _, timestampSent: let timestampSent):
                self.centerMapOnLocation(location: position,timestampSent: timestampSent)
            default:
                break
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D,timestampSent: String) {
        cancelables.forEach { cancelable in
            cancelable.cancel()
        }
        cancelables.removeAll()
        mapView.mapboxMap.onCameraChanged.observe { [weak self] _ in
            guard let self = self else { return }
            let endTime = DispatchTime.now()
            let nanoTime = endTime.uptimeNanoseconds - self.motionStartedTime.uptimeNanoseconds
            let elapsedTime = Double(nanoTime)
            let mqttPayload = "\(timestampSent),iOS,Swift,Mapbox,\(Topics.MoveMap),0,0,\(elapsedTime)"
            mqttManager?.publish(message: mqttPayload, to: "\(baseTopic)\(Topics.MoveMap)Complete")
            print(mqttPayload)
        }.store(in: &cancelables)
        
        self.motionStartedTime = DispatchTime.now()
        let cameraOptions = CameraOptions(center: location, zoom: 15, bearing: 0, pitch: 30)
        mapView.mapboxMap.setCamera(to: cameraOptions)
    }
    
    func addMarker(location: CLLocationCoordinate2D, title: String,timestampSent: String) {
        let startTime = DispatchTime.now()
        var pointAnnotation = PointAnnotation(coordinate: location)
        pointAnnotation.image = .init(image: UIImage(named: "mapbox_marker_icon_20px_blue")!, name: "mapbox_marker_icon_20px_blue")
        pointAnnotation.textField = title
        let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        pointAnnotationManager.annotations.append(pointAnnotation)
        let endTime = DispatchTime.now()
        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        let elapsedTime = Double(nanoTime)
        let mqttPayload = "\(timestampSent),iOS,Swift,Mapbox,\(Topics.DrawPoint),0,0,\(elapsedTime)"
        mqttManager?.publish(message: mqttPayload, to: "\(baseTopic)\(Topics.DrawPoint)Complete")
        print(mqttPayload)
    }
}
