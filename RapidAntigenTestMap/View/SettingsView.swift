//
//  SettingsView.swift
//  RapidAntigenTestMap
//
//  Created by Br7 on 2022/5/28.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var medDataModel: MedDataModel
    
//    @Binding var radius: MedData.radius
//    @State var offset: CGFloat = 0
    @State var maxRadius: CGFloat = 1800
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
                }
            }
            .padding()
            .background(Color.white.ignoresSafeArea(.all, edges: .top))
            
            VStack (alignment: .leading) {
                
                HStack {
                    Text("地圖範圍")
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
                
            }
            .padding()
            
            
//            Button("確認修改") {
//                medData.radius = radiusValue
//            }
//            .frame(maxWidth: .infinity)
//            .frame(height: 55)
//            .buttonStyle(.borderedProminent)
//            .controlSize(.regular)
//            .padding()
            
            Button {
//                medDataModel.radius = radiusValue
                print("currentRadius: \(medDataModel.radius)")
            } label: {
                Text("確認修改")
                    .fontWeight(.bold)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .tint(.green)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)

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
