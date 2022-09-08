//
//  AnnotationViewWidget.swift
//  RapidAntigenTestMapWidgetExtension
//
//  Created by @Ryan on 2022/9/6.
//

import SwiftUI

struct AnnotationViewWidget: View {
    
    @Environment(\.colorScheme) var scheme
    
    @State var name: String
    @State var distance: Int
    
    @State private var annotationColorDigits = Color.green
    
    var body: some View {
        
        ZStack {
            
            Ellipse()
                .foregroundColor(.gray)
                .frame(width: 12, height: 5)
                .offset(y: 5)
            
            VStack(spacing: 0) {
                
                Text(name.prefix(2))
                    .font(.system(size: 14).bold())
                    .foregroundColor(annotationColorDigits)
                    .frame(width: 40, height: 40)
                    .background(.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 3.5).foregroundColor(annotationColorDigits))
                
                Image(systemName: "triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(annotationColorDigits)
                    .frame(width: 7, height: 7)
                    .rotationEffect(Angle(degrees: 180))
                    .scaleEffect(x: 1.1, y: 0.7, anchor: .center)
                    .offset(y: -1)
                    .padding(.bottom, 40)
                
            }
            
            VStack {

                Text("距離")
                    .font(.system(size: 6, weight: .bold))
                    .foregroundColor(scheme == .dark ? .gray :  Color(UIColor.lightGray))

                Text("\(distance)")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(scheme == .dark ? .black : .white)
                    

            }
            .padding(.vertical, 2.5)
            .padding(.horizontal, 4)
            .background(scheme == .dark ? .white : .black)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .offset(x: -17, y: -5)
            
        }
        
    }
}

struct AnnotationViewWidget_Previews: PreviewProvider {
    static var previews: some View {
        AnnotationViewWidget(name: "健康藥局", distance: 50)
    }
}
