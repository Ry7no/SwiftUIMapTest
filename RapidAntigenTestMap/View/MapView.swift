//
//  MapView.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/26.
//

import SwiftUI
import GoogleMaps



struct MapView: View {
    
    @StateObject var medData = MedData()
    @ObservedObject var locationManager = LocationManager()
    //    @EnvironmentObject var medData: MedData
    
    @State var isStop = false
    
    var body: some View {
        
        VStack {
            
            if let Meds = medData.NearMedModels {
                
                
                
                if Meds.isEmpty {
                    
                    
                    VStack {
                        
                        NavBarView(medData: medData, locationManager: locationManager, title: "快篩地圖")
                        
                        Spacer()
                        
                        ProgressView()
                            .tint(.green)
                            .scaleEffect(x: 2, y: 2, anchor: .center)
                        Text("Loading...")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .padding()
                        
                        Spacer()
                        
                        
                    }
                    .background(Color.black.opacity(0.06).ignoresSafeArea())
                    
                } else {
                    
                    VStack {

                        NavBarView(medData: medData, locationManager: locationManager, title: "快篩地圖")
 
                        ZStack (alignment: .center) {
                            
                            gmapView()
                                .refreshable {}
                            
                            if !medData.isStopUpdate {
                                
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
                            

                                
//                                Button {
//  
//                                    if !medData.isStopUpdate {
//                                        medData.isStopUpdate = true
//                                        isStop = true
//                                    } else {
//                                        medData.isStopUpdate = false
//                                        isStop = false
//                                    }
//                                    
//                                } label: {
//                                    Text(medData.isStopUpdate ? "Hold" : "Updating..")
//                                        .font(.title3)
//                                        .fontWeight(.bold)
//                                }
//                                .padding()
//                                .tint(medData.isStopUpdate ? .red : .green)
//                                .refreshable {
//                                    
//                                }
                            
                        }
                        
                    }
                    .background(Color.black.opacity(0.06).ignoresSafeArea())
                }
                
            }else{
                ProgressView()
                    .padding()
            }
        }
        .onAppear {
            if medData.NearMedModels.isEmpty {
                DispatchQueue.main.async {
                    medData.downloadCSVOnline()
                }
            }
        }
    }
    
}

struct gmapView: UIViewRepresentable {
    
    @StateObject var medData = MedData()
    @ObservedObject var locationManager = LocationManager()
    @State var coordinator = Coordinator()
    
    typealias UIViewType = GMSMapView
    
    func makeUIView(context: Context) -> GMSMapView {
        
        let camera = GMSCameraPosition.camera(withTarget: locationManager.userPosition, zoom: 18)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        
        mapView.setMinZoom(13, maxZoom: 23)
        //        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.animate(toZoom: 14.8)
        //        mapView.addObserver(coordinator, forKeyPath: "myLocation", options: .new, context: nil)
        
        
        return mapView
    }

    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        
        print("Button status: \(medData.isStopUpdate)")
        
        if medData.isStopUpdate {
            return
        } else if locationManager.pastUserPosition.latitude != locationManager.userPosition.latitude && locationManager.pastUserPosition.longitude != locationManager.userPosition.longitude && !medData.isStopUpdate {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                
                uiView.clear()
                uiView.camera = GMSCameraPosition.camera(withTarget: locationManager.userPosition, zoom: 14.8)
                
                let circle = GMSCircle(position: locationManager.userPosition, radius: CLLocationDistance(medData.radius))
                circle.fillColor = UIColor(white: 0.7, alpha: 0.3)
                circle.strokeWidth = 3
                circle.strokeColor = .orange
                circle.map = uiView
                
                count += 1
                
                if medData.NearMedModels.isEmpty {
                    medData.downloadCSVOnline()
                }
                
                let nearData = medData.SortedNearMedModels
                
                for i in 0..<nearData.count {
                    
                    let MedLat = nearData[i].medPlaceLat
                    let MedLng = nearData[i].medPlaceLon
                    let MedTitle = nearData[i].medName
                    let MedSubtitle = nearData[i].medStoreNumber
                    let MedDistance = nearData[i].medDistance
                    let MedPosition = CLLocationCoordinate2D(latitude: MedLat, longitude: MedLng)
                    
                    let MedMarker = GMSMarker()
                    MedMarker.position = MedPosition
                    MedMarker.icon = i == 0 ? createOrangePin(Int(MedSubtitle)!) : createImage(Int(MedSubtitle)!)
                    if i == 0 { MedMarker.zIndex = 1 }
                    MedMarker.map = uiView
                    MedMarker.title = "藥局：\(MedTitle)"
                    MedMarker.snippet = "快篩數量：\(MedSubtitle), 距離：\(Int(MedDistance))m"
                    MedMarker.accessibilityLabel = "\(i)"
                    
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    medData.isStopUpdate = true
                }
            }
        }
    }
    
    func makeCoordinator() -> gmapView.Coordinator {
        return coordinator
    }
    
    //    static func dismantleUIView(_ uiView: GMSMapView, coordinator: Coordinator) {
    //        uiView.removeObserver(coordinator, forKeyPath: "myLocation")
    //    }
    
    final class Coordinator: NSObject {
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if let location = change?[.newKey] as? CLLocation, let mapView = object as? GMSMapView {
                mapView.animate(toLocation: location.coordinate)
            }
        }
    }
    
    // -x => Move Left, +x => Move Right
    // -y => Move up, +y => Move down
    
    func createOrangePin(_ count: Int) -> UIImage {
        
        let color = count > 200 ? UIColor.black : UIColor.red
        // select needed color
        let string = "\(UInt(count))"
        // the string to colorize
        let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: color, .font: UIFont.boldSystemFont(ofSize: 14)]
        let attrStr = NSAttributedString(string: string, attributes: attrs)
        // add Font according to your need
        let image = UIImage(named: "OrangePin")!
        // The image on which text has to be added
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: CGFloat(5), y: CGFloat(0), width: CGFloat(image.size.width), height: CGFloat(image.size.height)))
        let rect = CGRect(x: CGFloat(13.5), y: CGFloat(24), width: CGFloat(image.size.width), height: CGFloat(image.size.height))
        // -x => Move Left, +x => Move Right
        // -y => Move up, +y => Move down
        
        attrStr.draw(in: rect)
        
        let markerImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return markerImage
    }
    
    func createImage(_ count: Int) -> UIImage {
        
        let color = count > 200 ? UIColor.black : UIColor.red
        // select needed color
        let string = "\(UInt(count))"
        // the string to colorize
        let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: color, .font: UIFont.systemFont(ofSize: 12)]
        let attrStr = NSAttributedString(string: string, attributes: attrs)
        // add Font according to your need
        let image = UIImage(named: "mapPin")!
        // The image on which text has to be added
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: CGFloat(5), y: CGFloat(0), width: CGFloat(image.size.width), height: CGFloat(image.size.height)))
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
