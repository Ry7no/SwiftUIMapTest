//
//  ContentView.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/24.
//

import SwiftUI
import GoogleMaps

struct ContentView: View {
    
    init(){
        UITabBar.appearance().isHidden = true
    }
    
    @State var currentTab: Tab = .map
    
    var body: some View {
        VStack(spacing: 0){
            TabView(selection: $currentTab) {
                
                MapView()
                    .tag(Tab.map)
                
                ListView()
                    .tag(Tab.list)
                
                Text("Settings")
                    .tag(Tab.settings)
   
            }
            
            TabBarView(currentTab: $currentTab)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
