//
//  SplashScreenView.swift
//  RapidAntigenTestMap
//
//  Created by Br7 on 2022/6/12.
//

import SwiftUI

struct SplashScreenView: View {
    
    @State private var isActive = false
    
    // Balls Animation States
    @State var ball1MoveY = -100.0
    @State var ball2MoveY = 100.0
    @State var scale = 1.0
    @State var ball1Degree = 0.0
    @State var ball2Degree = 0.0
    @State var bgColor = Color.clear
    
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
                        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight / 3.5)
                    
                    GifImage("ShootAndShake100")
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
            .ignoresSafeArea()
            .background(Color("AppGreen"))
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                    withAnimation {
                        self.size = 80
                        self.opacity = 0.05
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                    withAnimation {
                        self.isActive = true
                    }
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

//                Circle()
//                    .fill(Color("AppGreen"))
//                    .frame(width: 20, height: 20)
//                    .scaleEffect(CGFloat(scale))
//                    .offset(y: ball1MoveY)
//                    .rotation3DEffect(.degrees(Double(ball1Degree)), axis: (x: 0.5, y: 0, z: 0))
//                    .onAppear() {
//                        withAnimation(.easeInOut.speed(0.5)) {
//                            ball1MoveY += 200
//                            scale += 5
//                            ball1Degree = 90
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                withAnimation {
//                                    bgColor = Color("AppGreen")
//                                }
//                            }
//                        }
//                    }
