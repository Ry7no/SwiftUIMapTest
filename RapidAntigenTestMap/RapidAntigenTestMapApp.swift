//
//  RapidAntigenTestMapApp.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/24.
//

import SwiftUI
import GoogleMaps

@main
struct RapidAntigenTestMapApp: App {
    
    init() {
        GMSServices.provideAPIKey("AIzaSyBp74yPDJDGIHB2UxeGQ6URF6j83JEInDs")
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
