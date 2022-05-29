//
//  ContentView.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/24.
//

import SwiftUI
import GoogleMaps

struct ContentView: View {
    
    @ObservedObject var locationManager = LocationManager()
//    @ObservedObject var medDataModel = MedDataModel()
//    @State var sortedNumber = 0
    
    init(){
        UITabBar.appearance().isHidden = true
//        sortedNumber = medDataModel.SortedNearMedModels.count
    }
    
    @State var medDataModel = MedDataModel()
    @State var currentTab: Tab = .list
    
    
    var body: some View {
        
        VStack(spacing: 0){
            
            TabView(selection: $currentTab) {
                
                ListView(medDataModel: medDataModel)
                    .tag(Tab.list)
                
                MapView(medDataModel: medDataModel)
                    .tag(Tab.map)
                
                SettingsView(medDataModel: medDataModel)
                    .tag(Tab.settings)
            }
            
            TabBarView(medDataModel: medDataModel, currentTab: $currentTab)
        }
        .onAppear{
                DispatchQueue.main.async {
                    print("\(locationManager.userPosition)")
                }

        }
        .environmentObject(medDataModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
