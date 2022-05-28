//
//  NavBarView.swift
//  RapidAntigenTestMap
//
//  Created by Br7 on 2022/5/28.
//

import SwiftUI

struct NavBarView: View {
    
    @StateObject var medData = MedData()
    @ObservedObject var locationManager = LocationManager()
    
    @State var title: String = ""
    
    var body: some View {
        
        HStack {
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundColor(.green)
                .shadow(color: .black, radius: 0.2, x: 0.2, y: 0.2)
            
            Spacer()
            
            Button {
                medData.NearMedModels.removeAll()
                medData.SortedNearMedModels.removeAll()
                DispatchQueue.main.async {
                    medData.downloadCSVOnline()
                }

            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .resizable()
                    .frame(width: 28, height: 24)
                    .padding()
                    .tint(.green)
            }
        }
        .padding()
        .background(Color.white.ignoresSafeArea(.all, edges: .top))
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView()
    }
}
