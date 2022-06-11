//
//  SplashScreenView.swift
//  RapidAntigenTestMap
//
//  Created by Br7 on 2022/6/12.
//

import SwiftUI

struct SplashScreenView: View {
    
    @State private var isActive = false
    
    @State var size = 0.9
    @State var opacity = 0.6
    @State var moveX = 0.0
    
    var body: some View {
        
        if isActive {
            
            ContentView()
            
        } else {
            
            VStack {
                
                VStack {
                    
                Text("")
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight / 4)
                GifImage("IconMove")
                    .background(Color("AppGreen"))
                    .offset(x: moveX)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 6).speed(3.5)) {
                            self.moveX = UIScreen.screenWidth / 4 - 10
                        }
                    }
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear{
                    withAnimation(.easeInOut(duration: 3.5).speed(2)){
                        self.size = 1.2
                        self.opacity = 1.0
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("AppGreen"))
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.isActive = true
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
