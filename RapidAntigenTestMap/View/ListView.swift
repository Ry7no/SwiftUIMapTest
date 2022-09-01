//
//  ListView.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/26.
//

import SwiftUI

struct ListView: View {
    
    @ObservedObject var medDataModel = MedDataModel()
    @ObservedObject var locationManager = LocationManager()
    
//    @GestureState var gestureOffset: CGFloat = 0
//    @State var offsetY: CGFloat = 0
    
    @State var timeRemaining = 10
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var showAlert = false
//    @State var scale = 1.0
    @State var color = Color("DarkOrange")
    
    @Environment(\.colorScheme) var scheme
    
    @Binding var currentTab: Tab
    
    var body: some View {
        
        VStack {
            
            NavBarView(medDataModel: medDataModel, locationManager: locationManager, title: "鄰近藥局清單")
            
            if let Meds = medDataModel.SortedNearMedModels {
                
                if Meds.isEmpty {
                    
                    Spacer()
                    
                    ProgressView()
                        .tint(.green)
                        .scaleEffect(x: 2, y: 2, anchor: .center)
                    
                    Text("Loading...")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding()
                        .offset(y: 3)
                        .alert("附近搜尋不到相關藥局", isPresented: $showAlert, actions: {
                            Button("重新搜尋") {
                                timeRemaining = 10
                                showAlert = false
                                medDataModel.NearMedModels.removeAll()
                                medDataModel.SortedNearMedModels.removeAll()
                                medDataModel.isStopUpdate = false
                                DispatchQueue.main.async {
                                    medDataModel.downloadCSVOnline()
                                }
                            }
                            Button("調整範圍"){
                                timeRemaining = 15
                                showAlert = false
                                currentTab = .settings
                            }
                        }, message: {
                            Text("\n請檢查連線重試一次 或 調整搜尋半徑")
                        })
  
                    Text("\(timeRemaining)")
                        .font(.title3)
                        .foregroundColor(.green)
                        .frame(width: 30, height: 30)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.green, lineWidth: 2)
                        )
                        .offset(y: -10)
                        .onReceive(timer) { _ in
                            if timeRemaining > 0 {
                                timeRemaining -= 1
                            } else if timeRemaining == 0 {
                                showAlert = true
                            }
                        }
                    
                    Spacer()
                    
                } else {
                        
                        List (0..<Meds.count) { i in
                            
                            Button {
                                
                                locationManager.openGoogleMap(latDouble: Double(Meds[i].medPlaceLat), longDouble: Double(Meds[i].medPlaceLon))
                                
                            } label: {
                                
                                VStack (alignment: .leading, spacing: 5) {
                                    
                                    HStack {
                                        
                                        Text("\(Int(Meds[i].medDistance))m")
                                            .minimumScaleFactor(0.2)
                                            .lineLimit(1)
                                            .font(.headline)
//                                            .fontWeight(.medium)
                                            .foregroundColor(i == 0 ? Color.white : (scheme == .dark ? .white : .black))
                                            .frame(width: 55, height: 55, alignment: .center)
//                                            .background(.ultraThinMaterial)
                                            .background(i == 0 ? Color.red : (scheme == .dark ? .black : .white))
                                            .cornerRadius(18)
                                            .padding([.trailing], 10)
                                        
                                        Text("\(Meds[i].medName)")
                                            .frame(alignment: .leading)
                                            .font(.title2)
                                        
                                        Spacer()
                                        
                                            
                                            if Int(Meds[i].medStoreNumber) ?? 0 <= 100 {
                                                Image(systemName: "star.fill")
                                                    .frame(width: 25, height: 25)
                                                    .foregroundColor(color)
//                                                    .scaleEffect(CGFloat(scale))
                                                    .onAppear {
                                                        withAnimation(.easeInOut.speed(0.8).repeatForever()) {
//                                                            scale += 0.1
                                                            color = Color("YellowReverse")
                                                        }
                                                    }
                                                
                                            } else if Meds[i].medBrand == "羅氏家用新冠病毒抗原自我檢測套組" {
                                                Text("羅")
                                                    .font(.headline)
                                                    .frame(width: 25, height: 25, alignment: .center)
                                                    .foregroundColor(scheme == .dark ? .white : .blue)
                                                    .background(scheme == .dark ? .clear : .white)
                                                    .cornerRadius(8)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(scheme == .dark ? .white : .blue, lineWidth: 2)
                                                    )
                                            }
                                    
                                        
                                        
                                        
//                                        VStack (spacing: 4){
//
//                                            Text("\(Meds[i].medBrand.components(separatedBy: " ").first)")
//                                                .font(.headline)
//                                                .frame(width: 25, height: 25, alignment: .center)
//                                                .foregroundColor(.blue)
//                                                .background(.white)
//                                                .cornerRadius(8)
//                                                .overlay(
//                                                    RoundedRectangle(cornerRadius: 8)
//                                                        .stroke(Color.blue, lineWidth: 2)
//                                                )
//
//                                            Text("亞")
//                                                .font(.headline)
//                                                .frame(width: 25, height: 25, alignment: .center)
//                                                .foregroundColor(.indigo)
//                                                .background(.white)
//                                                .cornerRadius(8)
//                                                .overlay(
//                                                    RoundedRectangle(cornerRadius: 8)
//                                                        .stroke(Color.indigo, lineWidth: 2)
//                                                )
//                                            }
                                            
                                            Text("快篩剩 \(Meds[i].medStoreNumber)")
                                                .minimumScaleFactor(0.2)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .frame(width: 100, height: 55, alignment: .center)
                                                .background(i == 0 ? Color("DarkRed") : Color("Navy"))
                                                .cornerRadius(18)
                                            
                                        
    
                                    }
                                    
                                    HStack (alignment: .top) {
                                        
                                        Image(systemName: "phone.circle.fill")
                                            .foregroundColor(.blue)
                                        Text("電話：\(Meds[i].medPhone)")
                                            .font(.body)
                                            .minimumScaleFactor(0.2)
                                        Spacer()
                                        
                                        
                                    }
                                    .padding([.top],10)
                                    
                                    HStack (alignment: .top) {
                                        
                                        Image(systemName: "map.circle.fill")
                                            .foregroundColor(.purple)
                                        Text("地址：\(Meds[i].medAddress)")
                                            .font(.body)
                                            .minimumScaleFactor(0.2)
                                        Spacer()
                                        
                                    }
                                    
                                    HStack (alignment: .top) {
                                        
                                        Image(systemName: "bookmark.circle.fill")
                                            .foregroundColor(.pink)
                                        Text("備註：\(Meds[i].medRemarks)")
                                            .font(.body)
                                            .minimumScaleFactor(0.2)
                                        Spacer()
                                        
                                    }
                                    
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .background(i == 0 ? Color("Yellow").opacity(0.7) : Color("Green").opacity(0.4))
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.red, lineWidth: i == 0 ? 4 : 0)
                                )
                            }
                        }// List End
                        .listStyle(.inset)
                    
                }
                
            }else{
                ProgressView()
                    .padding()
            }
        }
        //        .background(Color.black.opacity(0.06).ignoresSafeArea())
        .onAppear {
            if medDataModel.NearMedModels.isEmpty {
                DispatchQueue.main.async {
                    timeRemaining = 10
                    medDataModel.downloadCSVOnline()
                    
                }
            }
        }
        
    }
}

//struct ListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListView(, currentTab: <#Binding<Tab>#>)
//    }
//}
