//
//  HUDView.swift
//  RapidAntigenTestMap
//
//  Created by Br7 on 2022/6/9.
//

import SwiftUI

struct HUD: View {
    
    var body: some View {
        
        VStack{
            Button {
                
            } label: {
                Text("show HUD")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct HUD_Previews: PreviewProvider {
    static var previews: some View {
        HUD()
    }
}

extension View{
    
    func getRootController()->UIViewController{
        
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.last?.rootViewController else {
            return .init()
        }
        
        return root
    }
    
    
    func showHUD(image: String, color: Color = .primary, title: String, completion: @escaping (Bool, String)->()){
        
        if getRootController().view.subviews.contains(where: { view in
            return view.tag == 1009
        }){
            
            completion(false, "Already Presenting")
            return
        }
        
        let hudViewController = UIHostingController(rootView: HUDView(image: image, color: color, title: title))
        let size = hudViewController.view.intrinsicContentSize
        
        hudViewController.view.frame.size = size
        hudViewController.view.frame.origin = CGPoint(x: (getRect().width / 2) - (size.width / 2), y: 50)
        hudViewController.view.backgroundColor = .clear
        hudViewController.view.tag = 1009
        
        getRootController().view.addSubview(hudViewController.view)
        
    }
}

struct HUDView: View {
    
//    @EnvironmentObject var sharedData: SharedDataModel
    
    var image: String
    var color: Color
    var title: String
    
    @Environment(\.colorScheme) var scheme
    
    @State var showHUD: Bool = false
    
    var body: some View{
        
        HStack(spacing: 10){
            
            Image(systemName: image)
                .font(.title3)
                .foregroundColor(scheme == .dark ? Color("DarkScheme") : Color("LightGreen"))
            
            Text(title)
                .font(.title3).bold()
                .foregroundColor(scheme == .dark ? Color("DarkScheme") : Color("LightGreen"))
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(
//            MaterialEffect(style: .systemThinMaterial) //scheme == .dark
            scheme == .dark ? Color.green.opacity(0.9) : Color("DarkScheme").opacity(0.9)
        )
        .clipShape(Capsule())
        .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 1, y: 5)
        .shadow(color: Color.primary.opacity(0.03), radius: 5, x: 0, y: -5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // top
        .offset(y: showHUD ? 0 : -300)
        .onAppear {
            
            withAnimation(.easeInOut(duration: 0.5)){
                showHUD = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.5)){
                    showHUD = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    
                    getRootController().view.subviews.forEach { view in
                        if view.tag == 1009{
                            
                            view.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
}


extension View{
    func getRect()->CGRect{
        return UIScreen.main.bounds
    }
}


