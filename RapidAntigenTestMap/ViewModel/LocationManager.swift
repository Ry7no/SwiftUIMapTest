//
//  LocationManager.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/26.
//

import SwiftUI
import GoogleMaps
import CoreLocation
import UIKit

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
//        manager.distanceFilter = 1
//        manager.headingFilter = 1
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
    
    func stopMonitoringLocation() {
        manager.stopMonitoringSignificantLocationChanges()
        manager.stopUpdatingLocation()
    }
    
    func handleLocationError() {
        // Handle Error
    }
    
    func openGoogleMap(latDouble: CLLocationDegrees, longDouble: CLLocationDegrees) {
//        guard let lat = booking?.booking?.pickup_lat, let latDouble =  Double(lat) else {Toast.show(message: StringMessages.CurrentLocNotRight);return }
//        guard let long = booking?.booking?.pickup_long, let longDouble =  Double(long) else {Toast.show(message: StringMessages.CurrentLocNotRight);return }
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
            
            if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(latDouble),\(longDouble)&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:])
            }}
        else {
            //Open in browser
            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(latDouble),\(longDouble)&directionsmode=driving") {
                UIApplication.shared.open(urlDestination)
            }
        }
        
    }
}
