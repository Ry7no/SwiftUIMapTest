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
    
    var body: some View {
        
        VStack {
            
            if let Meds = medData.NearMedModels {
                
                if Meds.isEmpty {
                    
                    VStack {
                        
                        HStack {
                            
                            Text("快篩地圖")
                                .font(.largeTitle)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                                .shadow(color: .black, radius: 0.2, x: 0.2, y: 0.2)
                            
                            Spacer()
                            
                        }
                        .padding()
                        .background(Color.white.ignoresSafeArea(.all, edges: .top))
                        
                        Spacer()
                        
                        ProgressView()
                        Text("Loading...")
                            .padding()
                        
                        Spacer()
                        
                        
                    }
                    .background(Color.black.opacity(0.06).ignoresSafeArea())
                    
                    
                } else {
                    
                    VStack {
                        
                        HStack {
                            
                            Text("快篩地圖")
                                .font(.largeTitle)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                                .shadow(color: .black, radius: 0.2, x: 0.2, y: 0.2)
                            
                            Spacer()
                            
                        }
                        .padding()
                        .background(Color.white.ignoresSafeArea(.all, edges: .top))
                        
                        gmapView()
                            .refreshable {
                                
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
        
        if locationManager.pastUserPosition.latitude != locationManager.userPosition.latitude
            || locationManager.pastUserPosition.longitude != locationManager.userPosition.longitude {
            
            uiView.clear()
            uiView.camera = GMSCameraPosition.camera(withTarget: locationManager.userPosition, zoom: 14.8)
            
            //            let userMarker = GMSMarker()
            //            userMarker.position = locationManager.userPosition
            //            userMarker.map = uiView
            
            let circle = GMSCircle(position: locationManager.userPosition, radius: CLLocationDistance(radius))
            circle.fillColor = UIColor(white: 0.7, alpha: 0.3)
            circle.strokeWidth = 3
            circle.strokeColor = .orange
            circle.map = uiView
            
            if medData.NearMedModels.isEmpty {
                medData.downloadCSVOnline()
            }
            
            let nearData = medData.NearMedModels
            
            print("Meds.count: \(nearData.count)")
            
            for i in 0..<nearData.count {
                let MedLat = nearData[i].medPlaceLat
                let MedLng = nearData[i].medPlaceLon
                let MedTitle = nearData[i].medName
                let MedSubtitle = nearData[i].medStoreNumber
                let MedPosition = CLLocationCoordinate2D(latitude: MedLat, longitude: MedLng)
                
                let MedMarker = GMSMarker()
                MedMarker.position = MedPosition
                MedMarker.icon = createImage(Int(MedSubtitle)!)
                MedMarker.map = uiView
                MedMarker.title = "藥局：\(MedTitle)"
                MedMarker.snippet = "快篩數量：\(MedSubtitle)"
            }
        }
    }
    
    func makeCoordinator() -> gmapView.Coordinator {
        return coordinator
    }
    
    static func dismantleUIView(_ uiView: GMSMapView, coordinator: Coordinator) {
        uiView.removeObserver(coordinator, forKeyPath: "myLocation")
    }
    
    final class Coordinator: NSObject {
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if let location = change?[.newKey] as? CLLocation, let mapView = object as? GMSMapView {
                mapView.animate(toLocation: location.coordinate)
            }
        }
    }
    
    func createImage(_ count: Int) -> UIImage {
        
        let color = count > 200 ? UIColor.black : UIColor.red
        // select needed color
        let string = "\(UInt(count))"
        // the string to colorize
        let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: color]
        let attrStr = NSAttributedString(string: string, attributes: attrs)
        // add Font according to your need
        let image = UIImage(named: "mapPin")!
        // The image on which text has to be added
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: CGFloat(5), y: CGFloat(0), width: CGFloat(image.size.width), height: CGFloat(image.size.height)))
        let rect = CGRect(x: CGFloat(12.5), y: CGFloat(18), width: CGFloat(image.size.width), height: CGFloat(image.size.height))
        
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
