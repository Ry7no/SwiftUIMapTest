//
//  TabBarView.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/26.
//

import SwiftUI

struct TabBarView: View {
    
    @Binding var currentTab: Tab
    
    var body: some View {
        GeometryReader {proxy in
            let width = proxy.size.width
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.rawValue){ tab in
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
                            .foregroundColor(currentTab == tab ? .white : .gray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(alignment: .leading) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 50, height: 50)
                    .offset(x: 35)
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
        case .map:
            return 0
        case .list:
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
