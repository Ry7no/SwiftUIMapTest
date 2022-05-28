//
//  ListView.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/26.
//

import SwiftUI

struct ListView: View {
    
    @StateObject var medData = MedData()
    @ObservedObject var locationManager = LocationManager()
    
    var body: some View {
        
        VStack {
            
            NavBarView(medData: medData, locationManager: locationManager, title: "鄰近藥局清單")
            
//            HStack {
//                
//                Text("鄰近藥局清單")
//                    .font(.largeTitle)
//                    .fontWeight(.medium)
//                    .foregroundColor(.green)
//                    .shadow(color: .black, radius: 0.2, x: 0.2, y: 0.2)
//                
//                Spacer()
//                
//                Button {
//                    medData.NearMedModels.removeAll()
//                    medData.SortedNearMedModels.removeAll()
//                    DispatchQueue.main.async {
//                        medData.downloadCSVOnline()
//                    }
//                    
//                } label: {
//                    Image(systemName: "repeat.circle.fill")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .padding()
//                }
//                
//            }
//            .padding()
//            .background(Color.white.ignoresSafeArea(.all, edges: .top))
            
            if let Meds = medData.SortedNearMedModels {
                
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
                                    
                                    Text("快篩剩 \(Meds[i].medStoreNumber)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 100, height: 55, alignment: .center)
                                        .background(i == 0 ? Color("DarkRed") : Color("Navy"))
                                        .cornerRadius(18)
                                        
//                                        .overlay(
//                                            Circle()
//                                                .size(width: 35, height: 35)
//                                                .scale(1.2)
//                                                .stroke(Color.red, lineWidth: 5)
//                                        )
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
                                
//                                HStack (alignment: .top) {
//
//                                    Image(systemName: "paperplane.circle.fill")
//                                        .foregroundColor(.orange)
//                                    Text("距離約 \(Int(Meds[i].medDistance))m")
//                                        .font(.body)
//                                    Spacer()
//
//                                }
                            }
                            .padding()
                            .background(i == 0 ? Color("Yellow").opacity(0.7) : Color("Green").opacity(0.4))
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.red, lineWidth: i == 0 ? 4 : 0)
                            )
                        }
                        .listStyle(.plain)
                        .background(Color.black.opacity(0.06).ignoresSafeArea())

                }
                
            }else{
                ProgressView()
                    .padding()
            }
        }
        .background(Color.black.opacity(0.06).ignoresSafeArea())
        .onAppear {
            if medData.NearMedModels.isEmpty {
                DispatchQueue.main.async {
                    medData.downloadCSVOnline()
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
