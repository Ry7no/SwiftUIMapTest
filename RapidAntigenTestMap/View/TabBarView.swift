//
//  TabBarView.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/26.
//

import SwiftUI

struct TabBarView: View {
    
    @ObservedObject var medDataModel = MedDataModel()
    @Binding var currentTab: Tab
    
    var body: some View {
        GeometryReader {proxy in
            let width = proxy.size.width
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.rawValue){ tab in
                    
                    ZStack {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)){
                                currentTab = tab
                            }
                        } label: {
                            Image(systemName: tab.rawValue)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(currentTab == tab ? .gray : .gray.opacity(0.3))
                        }
                        
                        if currentTab == tab && tab == .list || currentTab == tab && tab == .map {
                            Text("\(medDataModel.sortedNumber)")
                                .foregroundColor(medDataModel.sortedNumber == 0 ? .white.opacity(0) : .white)
                                .font(Font.system(size: 15))
                                .frame(width: 20, height: 20)
                                .offset(x: 20, y: -12)
                                .background(
                                    Circle()
                                        .fill(medDataModel.sortedNumber == 0 ? .white.opacity(0) : .orange)
                                        .frame(width: 20, height: 20)
                                        .offset(x: 20, y: -12 )
                                )
                        }
   
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(alignment: .leading) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 20, height: 20)
                    .offset(x: 40)
                    .offset(y: 10)
                    .offset(x: indicatorOffset(width: width))
            }
            
        }
        .frame(height: 30)
        .padding(.bottom, 10)
        .padding([.horizontal, .top])
    }
    
    func indicatorOffset(width: CGFloat) -> CGFloat {
        
        let index = CGFloat(getIndex())
        if index == 0 { return 0 }
        
        let buttonWidth = width / CGFloat(Tab.allCases.count)
        
        return index * buttonWidth
    }
    
    func getIndex() -> Int {
        switch currentTab {
        case .list:
            return 0
        case .map:
            return 1
        case .settings:
            return 2
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
