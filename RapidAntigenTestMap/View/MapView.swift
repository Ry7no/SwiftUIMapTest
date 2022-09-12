//
//  MapView.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/26.
//

import SwiftUI
import GoogleMaps
import MapKit
import UIKit
import GoogleMapsUtils

struct MapView: View {
    
    @ObservedObject var medDataModel = MedDataModel()
    @ObservedObject var locationManager = LocationManager()
    //    @EnvironmentObject var medData: MedData
    
    @State var isStop = false
    @State var timeRemaining = 10
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var showAlert = false
    
    var body: some View {
        
        VStack {
            
            if let Meds = medDataModel.NearMedModels {
                          
                if Meds.isEmpty {
           
                    VStack {
                        
                            NavBarView(medDataModel: medDataModel, locationManager: locationManager, title: "快篩地圖")
                        
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
                                }
                            }
                        
                        Spacer()
                        
                        
                    }
                    .background(Color.black.opacity(0.06).ignoresSafeArea())
                    
                } else {
                    
                    VStack {

                        NavBarView(medDataModel: medDataModel, locationManager: locationManager, title: "快篩地圖")
 
                        ZStack (alignment: .center) {
                            
                            gmapView(medDataModel: medDataModel)
                                .refreshable {}
                            
                            if !medDataModel.isStopUpdate {
                                
                                VStack {
                                    
                                    ProgressView()
                                        .tint(.green)
                                        .scaleEffect(x: 2, y: 2, anchor: .center)
                                    Text("Loading...")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
            //                            .shadow(color: .black, radius: 0.2, x: 0.2, y: 0.2)
                                        .padding()
                                }
                                .padding()
                                .hidden()
                                
                            }
                            
                        }
                        
                    }
//                    .background(Color.black.opacity(0.06).ignoresSafeArea())
                }
                
            }else{
                ProgressView()
                    .padding()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showHUD(image: "checkmark.diamond", title: "共搜尋到\(Int(medDataModel.sortedNumber))家") { status, msg in
                    if !status {
                        print(msg)
                    }
                }
            }
            
            if medDataModel.NearMedModels.isEmpty {
                DispatchQueue.main.async {
                    medDataModel.downloadCSVOnline()
                }
            }
        }
    }

    
}

struct gmapView: UIViewRepresentable {
    
//    var colorScheme: ColorScheme
    @ObservedObject var medDataModel = MedDataModel()
    @ObservedObject var locationManager = LocationManager()
//    @State var coordinator = Coordinator()
    
//    @State var clusterManager: GMUClusterManager!
    
    typealias UIViewType = GMSMapView
    
    func makeUIView(context: Context) -> GMSMapView {
        
        let camera = GMSCameraPosition.camera(withTarget: locationManager.userPosition, zoom: 18)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        let zoom = calculateZoom(radius: Float(medDataModel.radius))
        
        if #available(iOS 13.0, *) {
            
            if UITraitCollection.current.userInterfaceStyle == .dark {
                
                do {
                  // Set the map style by passing the URL of the local file.
                  if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                  } else {
                    NSLog("Unable to find style.json")
                  }
                } catch {
                  NSLog("One or more of the map styles failed to load. \(error)")
                }    
            }
        }
        
//        let iconGenerator = GMUDefaultClusterIconGenerator()
//        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
//        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
//                                                 clusterIconGenerator: iconGenerator)
//        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
//                                           renderer: renderer)

        
        mapView.delegate = context.coordinator
        mapView.setMinZoom(13, maxZoom: 23)
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.animate(toZoom: zoom)
        
        // 300  16.5  // 700 1.7 // 800 1  //
        // 1000 14.8
        // 1800 13.9

        return mapView
    }

    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        
//        print("Button status: \(medDataModel.isStopUpdate)")
//        print(uiView.camera.zoom)
        
        if medDataModel.isStopUpdate {
            
            return
            
        } else if locationManager.pastUserPosition.latitude != locationManager.userPosition.latitude && locationManager.pastUserPosition.longitude != locationManager.userPosition.longitude && !medDataModel.isStopUpdate {
            
            let zoom = calculateZoom(radius: Float(medDataModel.radius))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                
                uiView.clear()
                uiView.camera = GMSCameraPosition.camera(withTarget: locationManager.userPosition, zoom: zoom)
                
                let circle = GMSCircle(position: locationManager.userPosition, radius: CLLocationDistance(medDataModel.radius))
                circle.fillColor = UIColor(white: 0.7, alpha: 0.3)
                circle.strokeWidth = 3
                circle.strokeColor = .orange
                circle.map = uiView
                
                count += 1
                
                if medDataModel.NearMedModels.isEmpty {
                    medDataModel.downloadCSVOnline()
                }
                
                let nearData = medDataModel.SortedNearMedModels
                
//                clusterManager.clearItems()
                
                for i in 0..<nearData.count {
                    
                    let MedLat = nearData[i].medPlaceLat
                    let MedLng = nearData[i].medPlaceLon
                    let MedTitle = nearData[i].medName
                    let MedAddress = nearData[i].medAddress
                    let MedStoreNumber = nearData[i].medStoreNumber
                    let MedRemarks = nearData[i].medRemarks
                    let MedDistance = nearData[i].medDistance
                    let MedUpdateTime = nearData[i].medUpdateTime
                    let MedPosition = CLLocationCoordinate2D(latitude: MedLat, longitude: MedLng)
                    
                    let MedMarker = GMSMarker()
                    MedMarker.position = MedPosition
                    MedMarker.icon = i == 0 ? createOrangePin(Int(MedStoreNumber)!) : createImage(Int(MedStoreNumber)!)
                    if i == 0 { MedMarker.zIndex = 1 }
                    MedMarker.map = uiView
                    MedMarker.title = Int(MedStoreNumber)! < 100 ? "[快篩] x\(MedStoreNumber)⭐︎  (@\(MedTitle))" : "[快篩] x\(MedStoreNumber)  (@\(MedTitle))"
                    MedMarker.snippet = "距離：\(Int(MedDistance))m\n地址：\(MedAddress)\n備註：\(MedRemarks)\n更新時間：\(MedUpdateTime)"
                    MedMarker.accessibilityLabel = "\(i)"
                    MedMarker.tracksInfoWindowChanges = false
//                    clusterManager.add(MedMarker)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    medDataModel.isStopUpdate = true
//                    clusterManager.cluster()
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(owner: self)
    }
    
    //    static func dismantleUIView(_ uiView: GMSMapView, coordinator: Coordinator) {
    //        uiView.removeObserver(coordinator, forKeyPath: "myLocation")
    //    }
    
    final class Coordinator: NSObject, GMSMapViewDelegate {
        
        let owner: gmapView
        
        init(owner: gmapView){
            self.owner = owner
        }
        
        func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {

            let latDouble = Double(marker.position.latitude)
            let longDouble = Double(marker.position.longitude)

            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
                
                if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(latDouble),\(longDouble)&directionsmode=driving") {
                    UIApplication.shared.open(url, options: [:])
                }}
            else {
                //Open in browser
                if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(latDouble),\(longDouble)&directionsmode=driving") {
                    UIApplication.shared.open(urlDestination)
                }
            }
        }
        
//        func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
//            let callout = UIHostingController(rootView: MarkerView())
//            callout.view.frame = CGRect(x: 0, y: 0, width: mapView.frame.width - 60, height: 200)
//            return callout.view
//        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if let location = change?[.newKey] as? CLLocation, let mapView = object as? GMSMapView {
                mapView.animate(toLocation: location.coordinate)
            }
        }
    }
    
    // -x => Move Left, +x => Move Right
    // -y => Move up, +y => Move down
    
    // Float(16.5 - (medDataModel.radius - 300) * 0.0017)
    
    func calculateZoom(radius: Float) -> Float {
        
        var zoomValue: Float = 0
        
        if radius >= 300 && radius <= 500 {
            zoomValue = 16.5 - ((radius - 300) * 0.004)
        }
        else if radius > 500 && radius < 1000 {
            zoomValue = 15.8 - ((radius - 500) * 0.002)
        }
        else if radius >= 1000 && radius < 1200 {
            zoomValue = 14.8 - ((radius - 1000) * 0.001)
        }
        else if radius >= 1200 && radius <= 1800 {
            zoomValue = 14.5 - ((radius - 1200) * 0.001)
        }
        
        return Float(zoomValue)
    }
    
    func createOrangePin(_ count: Int) -> UIImage {
        
        let color = count > 100 ? UIColor.black : UIColor.red
        // select needed color
        let string = count < 100 ? " \(UInt(count))" : "\(UInt(count))"
        // the string to colorize
        let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: color, .font: UIFont.boldSystemFont(ofSize: 14)]
        let attrStr = NSAttributedString(string: string, attributes: attrs)
        // add Font according to your need
        let image = UIImage(named: "OrangePin")!
        // The image on which text has to be added
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: CGFloat(count < 10 ? 0.6 : 4.5), y: CGFloat(-0.4), width: CGFloat(image.size.width), height: CGFloat(image.size.height)))
        let rect = CGRect(x: CGFloat(13.5), y: CGFloat(24), width: CGFloat(image.size.width), height: CGFloat(image.size.height))
        // -x => Move Left, +x => Move Right
        // -y => Move up, +y => Move down
        
        attrStr.draw(in: rect)
        
        let markerImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return markerImage
    }
    
    func createImage(_ count: Int) -> UIImage {
        
        let color = count > 100 ? UIColor.black : UIColor.red
        // select needed color
        let string = count < 100 ? " \(UInt(count))" : "\(UInt(count))"
        // the string to colorize
        let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: color, .font: UIFont.systemFont(ofSize: 12)]
        let attrStr = NSAttributedString(string: string, attributes: attrs)
        // add Font according to your need
        let image = UIImage(named: "mapPin")!
        // The image on which text has to be added
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: CGFloat(count < 10 ? 0.6 : 4.5), y: CGFloat(-0.4), width: CGFloat(image.size.width), height: CGFloat(image.size.height)))
        let rect = CGRect(x: CGFloat(11.3), y: CGFloat(18), width: CGFloat(image.size.width), height: CGFloat(image.size.height))
        // -x => Move Left, +x => Move Right
        // -y => Move up, +y => Move down
        
        attrStr.draw(in: rect)
        
        let markerImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return markerImage
    }
    
}


//    func createImage3(_ count: Int) -> UIImage {
//
//        let color = count > 200 ? UIColor.black : UIColor.red
//        // select needed color
//        let string = "\(UInt(count))"
//        // the string to colorize
//        let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: color]
//        let attrStr = NSAttributedString(string: string, attributes: attrs)
//        // add Font according to your need
//        let image = UIImage(named: "mapPin3")!
//        // The image on which text has to be added
//        UIGraphicsBeginImageContext(image.size)
//        image.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(image.size.width), height: CGFloat(image.size.height)))
//        let rect = CGRect(x: CGFloat(17), y: CGFloat(10), width: CGFloat(image.size.width), height: CGFloat(image.size.height))
//
//        attrStr.draw(in: rect)
//
//        let markerImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return markerImage
//    }
//

//    func createImage2(_ count: Int) -> UIImage {
//
//        let color = count > 200 ? UIColor.black : UIColor.red
//        // select needed color
//        let string = "\(UInt(count))"
//        // the string to colorize
//        let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: color]
//        let attrStr = NSAttributedString(string: string, attributes: attrs)
//        // add Font according to your need
//        let image = UIImage(named: "mapPin2")!
//        // The image on which text has to be added
//        UIGraphicsBeginImageContext(image.size)
//        image.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(image.size.width), height: CGFloat(image.size.height)))
//        let rect = CGRect(x: CGFloat(7), y: CGFloat(9), width: CGFloat(image.size.width), height: CGFloat(image.size.height))
//
//        attrStr.draw(in: rect)
//
//        let markerImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return markerImage
//    }



//func createGreenPin(_ count: Int) -> UIImage {
//
//    let color = count > 200 ? UIColor.black : UIColor.red
//    // select needed color
//    let string = "\(UInt(count))"
//    // the string to colorize
//    let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: color]
//    let attrStr = NSAttributedString(string: string, attributes: attrs)
//    // add Font according to your need
//    let image = UIImage(named: "GreenPin")!
//    // The image on which text has to be added
//    UIGraphicsBeginImageContext(image.size)
//    image.draw(in: CGRect(x: CGFloat(5), y: CGFloat(0), width: CGFloat(image.size.width), height: CGFloat(image.size.height)))
//    let rect = CGRect(x: CGFloat(10), y: CGFloat(14), width: CGFloat(image.size.width), height: CGFloat(image.size.height))
//
//    attrStr.draw(in: rect)
//
//    let markerImage = UIGraphicsGetImageFromCurrentImageContext()!
//    UIGraphicsEndImageContext()
//    return markerImage
//}
