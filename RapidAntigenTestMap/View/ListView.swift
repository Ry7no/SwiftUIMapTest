//
//  ListView.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/26.
//

import SwiftUI

struct ListView: View {
    @StateObject var medData = MedData()
    
    var body: some View {
        
        VStack {
            
            if let Meds = medData.NearMedModels {
                
                if Meds.isEmpty {
                    
                    VStack {
                        
                        HStack {
                            
                            Text("鄰近藥局清單")
                                .font(.largeTitle)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                                .shadow(color: .black, radius: 0.2, x: 0.2, y: 0.2)
                            
                            Spacer()
                            
                        }
                        .padding()
                        .background(Color.white.ignoresSafeArea(.all, edges: .top))
                        
                        Spacer()
                        
                        ProgressView()
                        Text("Loading...")
                            .padding()
                        
                        Spacer()
                    }
                    .background(Color.black.opacity(0.06).ignoresSafeArea())
                    
                } else {
                    
                    VStack {
                        HStack {
                            
                            Text("鄰近藥局清單")
                                .font(.largeTitle)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                                .shadow(color: .black, radius: 0.2, x: 0.2, y: 0.2)
                            
                            Spacer()
                            
                        }
                        .padding()
                        .background(Color.white.ignoresSafeArea(.all, edges: .top))
                        
                        List (0..<Meds.count - 1){ i in
                            
                            VStack (alignment: .leading, spacing: 5) {
                                
                                HStack {
                                    Text("\(Meds[i].medName)")
                                        .frame(alignment: .leading)
                                        .font(.title2)
                                    
                                    Spacer()
                                    
                                    Text("\(Meds[i].medStoreNumber)")
                                        .frame(width: 35, height: 35, alignment: .center)
                                        .background(.orange)
                                        .cornerRadius(17.5)
                                        .overlay(
                                            Circle()
                                                .size(width: 35, height: 35)
                                                .scale(1.2)
                                                .stroke(Color.red, lineWidth: 5)
                                        )
                                }
                                
                                HStack (alignment: .top) {
                                    
                                    Image(systemName: "phone.circle.fill")
                                        .foregroundColor(.green)
                                    Text("\(Meds[i].medPhone)")
                                        .font(.body)
                                    Spacer()
                                    
                                }
                                
                                HStack (alignment: .top) {
                                    
                                    Image(systemName: "map.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("\(Meds[i].medAddress)")
                                        .font(.body)
                                    Spacer()
                                    
                                }
                                
                                HStack (alignment: .top) {
                                    
                                    Image(systemName: "bookmark.circle.fill")
                                        .foregroundColor(.yellow)
                                    Text("\(Meds[i].medRemarks)")
                                        .font(.body)
                                    Spacer()
                                    
                                }
                            }
                            .padding()
                            .background(Color(UIColor.lightGray))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 5)
                            )
                            
                            
                        }
                        .listStyle(.plain)
                        .padding()
                        
                    }
                }
                
            }else{
                ProgressView()
                    .padding()
            }
        }
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
