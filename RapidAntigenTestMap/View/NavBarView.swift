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
    
    @AppStorage("isNewList") var isNewList: Bool = DefaultSettings.isNewList
    @AppStorage("isExpanding") var isExpanding: Bool = DefaultSettings.isExpanding

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
//            VStack {
//                Text("avg: \(locationManager.avgSpeed.string(fractionDigits: 0))km/h")
//                    .font(.system(size: 20))
//                
//                Text("spd: \(locationManager.speedInt)km/h")
//                    .font(.system(size: 20))
//            }
            
            Button {
                withAnimation {
                    isExpanding.toggle()
                }
            } label: {
                Image(systemName: isExpanding ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: 22, height: 22)
                    .padding(10)
                    .tint(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 10).foregroundColor(isExpanding ? .green : .orange)
                    }
            }
            .offset(x: 5)
            .opacity(title == "鄰近藥局清單" && isNewList ? 1 : 0)
            
            Button {
                medDataModel.NearMedModels.removeAll()
                medDataModel.SortedNearMedModels.removeAll()
                medDataModel.isStopUpdate = false
                DispatchQueue.main.async {
                    medDataModel.downloadCSVOnline()
                }
                
//                fatalError("Crash was triggered")
                
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 24, weight: .semibold))
//                    .resizable()
                    .frame(width: 26, height: 25)
                    .padding()
                    .tint(.green)
            }
        }
        .padding()
        .background(Color("NavBg").ignoresSafeArea(.all, edges: .top))
        .onAppear {
            print("isExpanding: \(isExpanding)")
        }
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView()
    }
}
