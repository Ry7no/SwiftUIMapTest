//
//  ContentView.swift
//  AnimationTest
//
//  Created by Br7 on 2022/6/14.
//

import SwiftUI

struct ContentView: View {
    
//    @State var moveX = -100.0
    @State var moveY = 0.0
    @State var moveY2 = 0.0
    @State var scale = 1.0
    @State var degree = 0.0
    @State var degree2 = 0.0
    
    var body: some View {
        
        VStack {
        Circle()
            .fill(Color.orange)
            .frame(width: 50, height: 50)
            .scaleEffect(CGFloat(scale))
            .offset(y: moveY)
            .rotation3DEffect(.degrees(Double(degree)), axis: (x: 0.5, y: 0, z: 0))
            .animation(Animation.easeInOut.speed(0.5).repeatForever())
            .onAppear() {
//                moveX += 200
                moveY += 200
                scale += 5
                degree = 90
            }
        
        Circle()
            .fill(Color.green)
            .frame(width: 50, height: 50)
            .scaleEffect(CGFloat(scale))
            .offset(y: moveY2)
            .rotation3DEffect(.degrees(Double(degree2)), axis: (x: 0.5, y: 0, z: 0))
            .animation(Animation.easeInOut.speed(0.5).repeatForever())
            .onAppear() {
//                moveX += 200
                moveY2 += -200
                scale += 5
                degree2 = -90
            }
        }
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
