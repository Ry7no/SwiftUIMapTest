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
    
    @GestureState var gestureOffset: CGFloat = 0
    @State var offsetY: CGFloat = 0
    
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
                    
                    Spacer()
                    
                } else {
                        
                        List (0..<Meds.count){ i in
                            
                            Button {
                                
                                locationManager.openGoogleMap(latDouble: Double(Meds[i].medPlaceLat), longDouble: Double(Meds[i].medPlaceLon))
                                
                            } label: {
                                
                                VStack (alignment: .leading, spacing: 5) {
                                    
                                    HStack {
                                        
                                        Text("\(Int(Meds[i].medDistance))m")
                                            .font(.headline)
                                            .fontWeight(.medium)
                                            .foregroundColor(i == 0 ? Color.white :Color.black)
                                            .frame(width: 55, height: 55, alignment: .center)
                                            .background(i == 0 ? Color.red :Color.white)
                                            .cornerRadius(18)
                                            .padding([.trailing], 10)
                                        
                                        Text("\(Meds[i].medName)")
                                            .frame(alignment: .leading)
                                            .font(.title)
                                        
                                        Spacer()
                                        
                                        if Int(Meds[i].medStoreNumber) ?? 0 <= 100 {
                                            Image(systemName: "star.fill")
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(Color("DarkOrange"))
                                        }
                                        
                                        Text("快篩剩 \(Meds[i].medStoreNumber)")
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
                                        Spacer()
                                        
                                    }
                                    .padding([.top],10)
                                    
                                    HStack (alignment: .top) {
                                        
                                        Image(systemName: "map.circle.fill")
                                            .foregroundColor(.purple)
                                        Text("地址：\(Meds[i].medAddress)")
                                            .font(.body)
                                        Spacer()
                                        
                                    }
                                    
                                    HStack (alignment: .top) {
                                        
                                        Image(systemName: "bookmark.circle.fill")
                                            .foregroundColor(.pink)
                                        Text("備註：\(Meds[i].medRemarks)")
                                            .font(.body)
                                        Spacer()
                                        
                                    }
                                    
                                }
                                .padding()
                                .background(i == 0 ? Color("Yellow").opacity(0.7) : Color("Green").opacity(0.4))
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.red, lineWidth: i == 0 ? 4 : 0)
                                )
                            }
                        }// List End
                        .listStyle(.inset)
                        
//                        if gestureOffset > 80 {
//                            ProgressView()
//                                .tint(.green)
//                                .scaleEffect(x: 2, y: 2, anchor: .center)
//                                .padding(.top, 40)
//                        }
                    
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
                    medDataModel.downloadCSVOnline()
                }
            }
            
        }
        
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
