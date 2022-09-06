//
//  SettingsView.swift
//  RapidAntigenTestMap
//
//  Created by Br7 on 2022/5/28.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("isNewList") var isNewList: Bool = DefaultSettings.isNewList
    
    @ObservedObject var medDataModel: MedDataModel

    @Binding var currentTab: Tab
//    @State var maxRadius: CGFloat = 1800
    @State var radiusValue: CGFloat = 1000
    
//    var maxBarLength = UIScreen.main.bounds.width - 65
    
//    init() {
//        medDataModel.radius = radiusValue
//    }
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Text("設定")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                    .shadow(color: .black, radius: 0.2, x: 0.2, y: 0.2)
                
                Spacer()
                
                Button {

                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .resizable()
                        .frame(width: 28, height: 24)
                        .padding()
                        .tint(.green)
                        .foregroundColor(.white)
                        .hidden()
                }
            }
            .padding()
            .background(Color("NavBg").ignoresSafeArea(.all, edges: .top))
            
            VStack (alignment: .leading) {
                
                HStack {
                    Text("地圖範圍(半徑)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
//                    Text("\(getRadius(startRadius: medData.radius))m")
                    Text("\(String(format: "%.0f", medDataModel.radius))m")
                        .fontWeight(.heavy)
                        .foregroundColor(.green)
                    
                }
                
                Slider(value: $medDataModel.radius, in: 300...1800)
                    .accentColor(.green)
                    .padding(.vertical, 20)
                
                Button {
                    currentTab = .list
                    medDataModel.NearMedModels.removeAll()
                    medDataModel.SortedNearMedModels.removeAll()
                    medDataModel.isStopUpdate = false
                    DispatchQueue.main.async {
                        medDataModel.downloadCSVOnline()
                    }
                    if Int(medDataModel.radius) == 1000 {
                        showHUD(image: "checkmark.diamond", title: "搜尋半徑維持\(Int(medDataModel.radius))m") {_,_ in }
                    } else {
                        showHUD(image: "checkmark.diamond", title: "搜尋半徑改為\(Int(medDataModel.radius))m") {_,_ in }
                    }
                    
                    print("currentRadius: \(medDataModel.radius)")
                } label: {
                    Text("確認修改")
                        .fontWeight(.bold)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width / 2.5, height: 45)
                        .background(Color.green.clipShape(RoundedRectangle(cornerRadius: 10)))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                
//                .buttonStyle(.borderedProminent)
//                .controlSize(.regular)
    
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .padding(.horizontal, 15)
            

            Toggle(isOn: $isNewList) {
                Text("新式表單")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            
//

            Spacer()
            
            
        
        }
//        .background(Color.black.opacity(0.06).ignoresSafeArea())
    }
                

}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}


//                ZStack (alignment: Alignment(horizontal: .leading, vertical: .center), content: {
//
//                    Capsule()
//                        .fill(Color.black.opacity(0.25))
//                        .frame(height: 30)
//
//                    Capsule()
//                        .fill(Color.green.opacity(0.4))
//                        .frame(width: ((medData.radius/maxRadius * maxBarLength) + offset) + 20, height: 30)
//
//                    HStack(spacing: (UIScreen.main.bounds.width - 100)/12){
//                        ForEach(0..<12, id: \.self){index in
//                            Circle()
//                                .fill(Color.white)
//                                .frame(width: index % 4 == 0 ? 7 : 4, height: index % 4 == 0 ? 7 : 4)
//                        }
//                    }
//                    .padding(.leading)
//
//                    Circle()
//                        .fill(Color.green)
//                        .frame(width: 35, height: 35)
//                        .background(Circle().stroke(Color.red.opacity(0.6), lineWidth: 5))
//                        .offset(x: offset)
//                        .offset(x: (medData.radius/maxRadius * maxBarLength))
//                        .gesture(DragGesture().onChanged({ (value) in
//
//                            // PaddingH = 30, Circle radius = 20 => 50
//                            if value.location.x > -(medData.radius/maxRadius * maxBarLength) && value.location.x < (maxBarLength - (medData.radius/maxRadius * maxBarLength)) {
//
//                                //circle radius = 20
//                                offset = value.location.x - 20
//                            }
//
//                        }))
//                })

    
    
//    func getRadius(startRadius: CGFloat) -> String {
//
//        let radiusPercent = startRadius / maxRadius
//        let percent = offset / (UIScreen.main.bounds.width - 65)
//        let amount = (radiusPercent + percent) * maxRadius
//
//        return String(format: "%.2f", amount)
//    }
