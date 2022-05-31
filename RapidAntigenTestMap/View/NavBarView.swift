//
//  NavBarView.swift
//  RapidAntigenTestMap
//
//  Created by Br7 on 2022/5/28.
//

import SwiftUI

struct NavBarView: View {
    
    @StateObject var medDataModel = MedDataModel()
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
                medDataModel.NearMedModels.removeAll()
                medDataModel.SortedNearMedModels.removeAll()
                medDataModel.isStopUpdate = false
                DispatchQueue.main.async {
                    medDataModel.downloadCSVOnline()
                }
                
                print("currentRadius: \(medDataModel.radius)")

            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .resizable()
                    .frame(width: 28, height: 24)
                    .padding()
                    .tint(.green)
            }
        }
        .padding()
        .background(Color("NavBg").ignoresSafeArea(.all, edges: .top))
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView()
    }
}
