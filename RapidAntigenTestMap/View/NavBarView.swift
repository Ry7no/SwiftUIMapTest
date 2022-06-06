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
    
    let myDate = Date()
    let weekday = Calendar.current.component(.weekday, from: Date())
    
    var body: some View {
        
        HStack {
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundColor(.green)
                .shadow(color: .black, radius: 0.2, x: 0.2, y: 0.2)
            
            Spacer()
            
            ZStack {
                if weekday == 1 {
                    
                    Text("全")
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundColor(.green)
                        .frame(width: 30, height: 30)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.green, lineWidth: 2)
                        )
                    
                } else if  weekday == 2 || weekday == 4 || weekday == 6 {
                    
                    Text("單")
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundColor(.orange)
                        .frame(width: 30, height: 30)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                    
                } else {
                    
                    Text("雙")
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundColor(.cyan)
                        .frame(width: 30, height: 30)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.cyan, lineWidth: 2)
                        )
                    
                }
            }
            
            Button {
                medDataModel.NearMedModels.removeAll()
                medDataModel.SortedNearMedModels.removeAll()
                medDataModel.isStopUpdate = false
                DispatchQueue.main.async {
                    medDataModel.downloadCSVOnline()
                }
                
                print("currentRadius: \(medDataModel.radius)")
                print("\(weekday)")

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
