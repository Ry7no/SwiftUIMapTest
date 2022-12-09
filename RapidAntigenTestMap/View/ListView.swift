//
//  ListView.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/26.
//

import SwiftUI

struct ListView: View {
    
    @ObservedObject var medDataModel = MedDataModel()
    @ObservedObject var locationManager = LocationManager()
    
    @Environment(\.scenePhase) private var scenePhase
    var ad = OpenInterstitialAD()
    
    @AppStorage("isNewList") var isNewList: Bool = DefaultSettings.isNewList
    @AppStorage("isExpanding") var isExpanding: Bool = DefaultSettings.isExpanding
    
    let gradientColor1 = LinearGradient(colors: [Color(#colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)) ,Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))],
                                      startPoint: .topTrailing,
                                      endPoint: .bottomLeading)
    
    let gradientColor2 = LinearGradient(colors: [Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)) ,Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))],
                                      startPoint: .topTrailing,
                                      endPoint: .bottomLeading)
    
    let gradientColor3 = LinearGradient(colors: [Color(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)) ,Color(#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1))],
                                      startPoint: .topTrailing,
                                      endPoint: .bottomLeading)
    
    @State var timeRemaining = 10
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var showAlert = false
//    @State var scale = 1.0
    @State var color = Color("DarkOrange")
    @State var buttonHeight: CGFloat = 85
    @State var buttonHeightMax: CGFloat = 220
    @State var buttonHeightMin: CGFloat = 85
    
    @State var refresh = Refresh(started: false, released: false)
//    @State var minusOffset: CGFloat = 0
    
    @Environment(\.colorScheme) var scheme
    
    @Binding var currentTab: Tab
    
    var body: some View {
        
        VStack {

            NavBarView(medDataModel: medDataModel, locationManager: locationManager, title: "鄰近藥局清單")
            
            if let Meds = medDataModel.SortedNearMedModels {
                
                if Meds.isEmpty {
                    
                    Spacer()
                    
                    ProgressView()
                        .tint(.green)
                        .scaleEffect(x: 2, y: 2, anchor: .center)
                    
                    Text("Loading...")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding()
                        .offset(y: 3)
                        .alert("附近搜尋不到相關藥局", isPresented: $showAlert, actions: {
                            Button("重新搜尋") {
                                timeRemaining = 10
                                showAlert = false
                                medDataModel.NearMedModels.removeAll()
                                medDataModel.SortedNearMedModels.removeAll()
                                medDataModel.isStopUpdate = false
                                DispatchQueue.main.async {
                                    medDataModel.downloadCSVOnline()
                                }
                            }
                            Button("調整範圍"){
                                timeRemaining = 15
                                showAlert = false
                                currentTab = .settings
                            }
                        }, message: {
                            Text("\n請檢查連線重試一次 或 調整搜尋半徑")
                        })
  
                    Text("\(timeRemaining)")
                        .font(.title3)
                        .foregroundColor(.green)
                        .frame(width: 30, height: 30)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.green, lineWidth: 2)
                        )
                        .offset(y: -10)
                        .onReceive(timer) { _ in
                            if timeRemaining > 0 {
                                timeRemaining -= 1
                            } else if timeRemaining == 0 {
                                showAlert = true
                            }
                        }
                    
                    Spacer()
                    
                } else {
                    
                    if isNewList {
                        NewScrollView(meds: Meds)
                    } else {
                        PreviousListView(meds: Meds)
                    }
     
   
                }
                
            }

            Banner()
            
        }
        .onAppear {
            if medDataModel.NearMedModels.isEmpty {
                DispatchQueue.main.async {
                    timeRemaining = 10
                    medDataModel.downloadCSVOnline()
                    
                }
            }
            
            ad.tryToPresentAd()
        }
        
    }
}

extension ListView {
    
    @ViewBuilder
    func PreviousListView(meds: [MedModel]) -> some View {
        
        List (0..<meds.count) { i in

            Button {

                locationManager.openGoogleMap(latDouble: Double(meds[i].medPlaceLat), longDouble: Double(meds[i].medPlaceLon))

            } label: {

                ZStack {

                    VStack (alignment: .leading, spacing: 5) {

                        HStack {

                            Text("\(Int(meds[i].medDistance))m")
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                                .font(.headline)
                                .foregroundColor(i == 0 ? Color.white : (scheme == .dark ? .white : .black))
                                .frame(width: 55, height: 55, alignment: .center)
                                .background(i == 0 ? Color.red : (scheme == .dark ? .black : .white))
                                .cornerRadius(18)
                                .padding([.trailing], 10)

                            Text("\(meds[i].medName)")
                                .frame(alignment: .leading)
                                .font(.title2)

                            Spacer()


                            if Int(meds[i].medStoreNumber) ?? 0 <= 100 {
                                Image(systemName: "star.fill")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(color)
                                    .onAppear {
                                        withAnimation(.easeInOut.speed(0.8).repeatForever()) {
                                            color = Color("YellowReverse")
                                        }
                                    }

                            }

                            Text("快篩剩 \(meds[i].medStoreNumber)")
                                .minimumScaleFactor(0.2)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 55, alignment: .center)
                                .background(i == 0 ? Color("DarkRed") : Color("Navy"))
                                .cornerRadius(18)



                        }

                        HStack (alignment: .top) {

                            Image(systemName: "phone.circle.fill")
                                .foregroundColor(.blue)
                            Text("電話：\(meds[i].medPhone)")
                                .font(.body)
                                .minimumScaleFactor(0.2)
                            Spacer()


                        }
                        .padding([.top],10)

                        HStack (alignment: .top) {

                            Image(systemName: "map.circle.fill")
                                .foregroundColor(.purple)
                            Text("地址：\(meds[i].medAddress)")
                                .font(.body)
                                .minimumScaleFactor(0.2)
                            Spacer()

                        }

                        HStack (alignment: .top) {

                            Image(systemName: "bookmark.circle.fill")
                                .foregroundColor(.pink)
                            Text("備註：\(meds[i].medRemarks)")
                                .font(.body)
                                .minimumScaleFactor(0.2)
                            Spacer()

                        }

                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .background(i == 0 ? Color("Yellow").opacity(0.7) : Color("Green").opacity(0.4))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.red, lineWidth: i == 0 ? 4 : 0)
                    )

                }
            }
            .listRowSeparator(.hidden)
        }// List End
        .listStyle(.inset)
        .refreshable {
            refreshData()
        }

    }
    
    func refreshData() {
        
        medDataModel.NearMedModels.removeAll()
        medDataModel.SortedNearMedModels.removeAll()
        medDataModel.isStopUpdate = false
        DispatchQueue.main.async {
            medDataModel.downloadCSVOnline()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.linear){
                
                refresh.released = false
                refresh.started = false
                
//                if refresh.startOffset == refresh.offset {
//                    refresh.released = false
//                    refresh.started = false
//                } else {
//                    refresh.invalid = true
//                }
                
            }
        }
        
    }
    
    @ViewBuilder
    func NewScrollView(meds: [MedModel]) -> some View {
        
        ZStack {

            Circle()
                .fill(LinearGradient(colors: [Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)),
                                              Color(#colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1))],
                                     startPoint: .topTrailing,
                                     endPoint: .bottomLeading))
                .frame(width: 240)
                .offset(x: 150, y: -90)

            Circle()
                .fill(LinearGradient(colors: [Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)),
                                              Color(#colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1))],
                                     startPoint: .topTrailing,
                                     endPoint: .bottomLeading))
                .frame(width: 140)
                .offset(x: -150, y: 90)

            Circle()
                .fill(LinearGradient(colors: [Color(#colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)),
                                              Color(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))],
                                     startPoint: .topTrailing,
                                     endPoint: .bottomLeading))
                .frame(width: 50)
                .offset(x: -40, y: -100)

        ScrollView {
            
            GeometryReader { reader -> AnyView in
                
                DispatchQueue.main.async {
                    
                    if refresh.startOffset == 0 {
                        refresh.startOffset = reader.frame(in: .global).minY
                    }
                    
                    refresh.offset = reader.frame(in: .global).minY
                    
                    if refresh.offset - refresh.startOffset > 90 && !refresh.started {
                        
                        refresh.started = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            let impactHeavy = UIImpactFeedbackGenerator(style: .rigid)
                            impactHeavy.impactOccurred()
                        }
                    }
                    
                    if refresh.startOffset == refresh.offset && refresh.started && !refresh.released {
                        withAnimation(.linear) {
                            refresh.released = true
                        }
                        refreshData()
                    }
                }
                
                return AnyView(Color.black.frame(width: 0, height: 0))
            }
            .frame(width: 0, height: 0)
            
            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                
                if refresh.started && refresh.released {
                    
                    ProgressView()
                        .offset(y: 35)
                    
                } else {
                    
                    Image(systemName: "arrow.down")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(.gray)
                        .rotationEffect(.init(degrees: refresh.started ? 180 : 0))
                        .offset(y: -28)
                        .animation(.easeIn, value: refresh.started)
                }
                
                VStack {
                    
                    ForEach(meds.indices, id: \.self) { index in
                        Button {
                            locationManager.openGoogleMap(latDouble: Double(meds[index].medPlaceLat), longDouble: Double(meds[index].medPlaceLon))
                        } label: {
                            GlassCardView(meds: meds[index], index: index)
                        }
                        .padding(.vertical, 4)

                    }
                }
            }
            .offset(y: refresh.released ? 40 : -10)
  

            }
        }
        .onAppear {
            
            if isExpanding {
                buttonHeight = buttonHeightMax
            } else {
                buttonHeight = buttonHeightMin
            }
            
        }
        .onChange(of: isExpanding) { newValue in
            DispatchQueue.main.async {
                withAnimation {
                    if newValue {
                            buttonHeight = buttonHeightMax
                    } else {
                        buttonHeight = buttonHeightMin
                    }
                }
   
            }
        }
    }
    
    @ViewBuilder
    func GlassCardView(meds: MedModel, index: Int) -> some View {
        
        ZStack {
            CustomBlurView(effect: .systemUltraThinMaterialDark) { view in

            }
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    .linearGradient(colors:[
                        .white.opacity(0.25),
                        .white.opacity(0.05)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                
                )
                .blur(radius: 3)
            
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .stroke(
                    .linearGradient(colors:[
                        .white.opacity(0.6),
                        .orange.opacity(0.2),
                        .green.opacity(0.2),
                        .green.opacity(0.5)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 3
                
                )
        }
        .shadow(color: .black.opacity(0.15), radius: 2, x: -2, y: 2)
        .shadow(color: .black.opacity(0.15), radius: 2, x: 2, y: -2)
        .overlay(content: {
            CardContent(meds: meds, index: index)
        })
        .padding(.horizontal, 10)
        .frame(height: buttonHeight)
    }
    
    @ViewBuilder
    func CardContent(meds: MedModel, index: Int) -> some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            ZStack(alignment: .trailing) {
                
                Text("\(meds.medName)")
                    .modifier(CustomModifier(font: .system(size: 28).bold(), color: Color(#colorLiteral(red: 0, green: 1, blue: 0.2800222635, alpha: 1)), alignment: .leading))
                    .lineLimit(1)
                    .padding(.top, 15)
                    .padding(.leading ,15)
                
                Text("\(meds.medStoreNumber)")
                    .modifier(CustomModifier(font: .system(size: 28, weight: .bold), color: .white, alignment: .trailing))
                    .lineLimit(1)
                    .padding(.top, 15)
                    .padding(.trailing ,30)

                Text("組")
                    .modifier(CustomModifier(font: .system(size: 10, weight: .bold), color: .white, alignment: .bottomTrailing))
                    .padding(.top, 26)
                    .padding(.trailing ,15)
            }
            
            HStack(spacing: 0) {
                
                Text("\(Int(meds.medDistance))")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(Color(#colorLiteral(red: 0.7622110248, green: 0.7430574298, blue: 1, alpha: 1)))
                    .shadow(radius: 15)
                    .padding(.leading ,15)
                
                Text("米")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(#colorLiteral(red: 0.7622110248, green: 0.7430574298, blue: 1, alpha: 1)))
                    .shadow(radius: 15)
                    .padding(.top, 8)
                    .padding(.leading ,4)
            }
            .opacity(buttonHeight == buttonHeightMax ? 1 : 0)
            
            HStack(spacing: 0) {
                
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(radius: 15)
                
                Text(meds.medPhone)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(radius: 15)
                    .padding(.leading ,8)
            }
            .padding(.horizontal, 18)
            .padding(.top, 5)
            .opacity(buttonHeight == buttonHeightMax ? 1 : 0)
            
            
            HStack(spacing: 0) {
                
                Image(systemName: "location.north.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(radius: 15)
                
                Text(meds.medAddress)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(radius: 15)
                    .padding(.leading ,8)
            }
            .padding(.horizontal, 18)
            .opacity(buttonHeight == buttonHeightMax ? 1 : 0)
            
            
            HStack(spacing: 0) {
                
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(radius: 15)
                
                Text(meds.medRemarks)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .shadow(radius: 15)
                    .padding(.leading ,8)
            }
            .padding(.horizontal, 18)
            .opacity(buttonHeight == buttonHeightMax ? 1 : 0)

     
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .blendMode(.overlay)
        .frame(maxWidth: .infinity, maxHeight: buttonHeight == buttonHeightMax ? .infinity : buttonHeightMin, alignment: .topLeading)
        
    }
}

struct RefreshScrollView: UIViewRepresentable {
    
    @Binding var refreshControl: UIRefreshControl
    
    func makeUIView(context: Context) -> some UIView {
        
        let view = UIScrollView()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        view.showsVerticalScrollIndicator = false
        view.refreshControl = refreshControl
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct CustomModifier: ViewModifier {
    var font: Font
    var color: Color
    var alignment: Alignment
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
            .shadow(radius: 15)
            .frame(maxWidth: .infinity, alignment: alignment)
        
    }
}

struct CustomBlurView: UIViewRepresentable {
    var effect: UIBlurEffect.Style
    var onChange: (UIVisualEffectView) -> ()
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: effect))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        DispatchQueue.main.async {
            onChange(uiView)
        }
    }
}

//struct ListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListView(, currentTab: <#Binding<Tab>#>)
//    }
//}
