//
//  SettingsView.swift
//  RapidAntigenTestMap
//
//  Created by Br7 on 2022/5/28.
//

import SwiftUI

struct SettingsView: View {
    
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Text("設定")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                    .shadow(color: .black, radius: 0.2, x: 0.2, y: 0.2)
                
                Spacer()
                
            }
            .padding()
            .background(Color.white.ignoresSafeArea(.all, edges: .top))
            
            
            Spacer()
            
        
        }
        .background(Color.black.opacity(0.06).ignoresSafeArea())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
