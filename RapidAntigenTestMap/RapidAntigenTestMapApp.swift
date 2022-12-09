//
//  RapidAntigenTestMapApp.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/24.
//

import SwiftUI
import GoogleMaps
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct RapidAntigenTestMapApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    var ad = OpenInterstitialAD()
    
    init() {
        GMSServices.provideAPIKey("AIzaSyBp74yPDJDGIHB2UxeGQ6URF6j83JEInDs")
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                ad.tryToPresentAd()
            }
        }
        
    }
    
}
