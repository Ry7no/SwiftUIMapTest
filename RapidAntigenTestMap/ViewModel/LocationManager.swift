//
//  LocationManager.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/26.
//

import SwiftUI
import GoogleMaps
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var manager: CLLocationManager = .init()
    @Published var userPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 25.044633, longitude: 121.559722)
    @Published var pastUserPosition: CLLocationCoordinate2D = .init()
    @Published var currentLocation: CLLocation = .init()
    
    override init() {
        super.init()
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        
        getLocation()

    }
        
    func getLocation() {
        
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.startUpdatingLocation()
        manager.startMonitoringVisits()
        manager.startMonitoringSignificantLocationChanges()
//        manager.allowsBackgroundLocationUpdates = true
//        manager.pausesLocationUpdatesAutomatically = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle Error
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let _ = locations.last else { return }
        manager.stopMonitoringSignificantLocationChanges()
        let locationValue: CLLocationCoordinate2D = manager.location!.coordinate
        pastUserPosition = userPosition
        userPosition = locationValue
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways: manager.requestLocation()
        case .authorizedWhenInUse: manager.requestLocation()
        case .denied: handleLocationError()
        case .notDetermined: manager.requestWhenInUseAuthorization()
        default: ()
        }
    }
    
    func handleLocationError() {
        // Handle Error
    }
}
