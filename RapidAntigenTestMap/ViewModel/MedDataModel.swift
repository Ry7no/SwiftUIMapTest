//
//  MedDataModel.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/26.
//

import SwiftUI
import Foundation
import CoreLocation
import GoogleMaps
import GoogleMapsCore
import UIKit

class MedDataModel: ObservableObject {
    
    @ObservedObject var locationManager = LocationManager()
    
    @Published var MedModels = [MedModel]()
    @Published var NearMedModels: [MedModel] = []
    @Published var SortedNearMedModels: [MedModel] = []
    @Published var NearestMed: [MedModel] = []
    
    @Published var radius: CGFloat = 1000
    @Published var isStopUpdate: Bool = false
    @Published var sortedNumber: Int = 0
    
    func downloadCSVOnline() {
        
        // Create destination URL
        let documentsUrl: URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = documentsUrl.appendingPathComponent("downloadedFile.csv")
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: "https://data.nhi.gov.tw/Datasets/Download.ashx?rid=A21030000I-D03001-001&l=https://data.nhi.gov.tw/resource/Nhi_Fst/Fstdata.csv")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("DEBUG: Successfully downloaded. Status code: \(statusCode)")
                }
                do {
                    try FileManager.default.replaceItemAt(destinationFileUrl, withItemAt: tempLocalUrl)
                    
                    var destinationFileUrlString = destinationFileUrl.absoluteString.replacingOccurrences(of: "file://", with: "", options: NSString.CompareOptions.literal, range: nil)
                    print("DEBUG: Copy successfully => destinationFileURL = \(destinationFileUrl)")
                    
                    DispatchQueue.main.async {
                        self.MedModels.removeAll()
                        self.convertCSVIntoArray(filepath: destinationFileUrlString)
//                        compareWithRadius(radius: 900)
                    }
                    
                } catch (let writeError) {
                    var destinationFileUrlString = destinationFileUrl.absoluteString.replacingOccurrences(of: "file://", with: "", options: NSString.CompareOptions.literal, range: nil)
                    print("DEBUG: Error creating a file \(destinationFileUrl) : \(writeError)")
                    
                    DispatchQueue.main.async {
                        self.MedModels.removeAll()
                        self.convertCSVIntoArray(filepath: destinationFileUrlString)
//                        compareWithRadius(radius: 900)
                    }
                }
                
            } else {
                print("DEBUG: Error took place while downloading a file. Error description: %@", error?.localizedDescription);
            }
        }
        task.resume()
    }
    
    func convertCSVIntoArray(filepath: String) {
        
        //locate the file you want to use
//        guard let filepath = Bundle.main.path(forResource: "Fstdata", ofType: "csv") else {
//            return
//        }
        
        //convert that file into one long string
        var data = ""
        do {
            data = try String(contentsOfFile: filepath)
        } catch {
            print(error)
            return
        }
        
        //now split that string into an array of "rows" of data.  Each row is a string.
        var rows = data.components(separatedBy: "\n")
        
        //if you have a header row, remove it here
        rows.removeFirst()
        
        //now loop around each row, and split it into each of its columns
        for row in rows {
            
            let columns = row.components(separatedBy: ",")
            
            //check that we have enough columns
            if columns.count == 10 {

                var medCode = columns[0]
                let medName = columns[1]
                let medAddress = columns[2]
                let medPlaceLon = Double(columns[3]) ?? 0.0
                let medPlaceLat = Double(columns[4]) ?? 0.0
                let medPhone = columns[5]
                let medBrand = columns[6]
                let medStoreNumber = columns[7]
                let medUpdateTime = columns[8]
                let medRemarks = columns[9]
                
                medCode = medCode.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                let MedDataInColumn = MedModel(medCode: medCode, medName: medName, medAddress: medAddress, medPlaceLon: medPlaceLon, medPlaceLat: medPlaceLat, medPhone: medPhone, medBrand: medBrand, medStoreNumber: medStoreNumber, medUpdateTime: medUpdateTime, medRemarks: medRemarks)
                
                MedModels.append(MedDataInColumn)
            }
        }
        compareWithRadius(radius: radius)
        print("csv MedModels.count \(MedModels.count)")
    }
    
    func compareWithRadius(radius: CGFloat) {
        
        var pastDistance: CGFloat = radius
        NearMedModels.removeAll()
        SortedNearMedModels.removeAll()
        
            for i in 0..<MedModels.count-1 {
                
                let userPosition = CLLocation(latitude: locationManager.userPosition.latitude, longitude: locationManager.userPosition.longitude)
                let MedLat = MedModels[i].medPlaceLat
                let MedLng = MedModels[i].medPlaceLon
                let MedPosition = CLLocation(latitude: MedLat, longitude: MedLng)
                
                let distanceBetween = userPosition.distance(from: MedPosition).rounded()

                if distanceBetween < radius {
                    MedModels[i].medDistance = distanceBetween
                    NearMedModels.append(MedModels[i])
                    
                    if pastDistance > distanceBetween {
                        pastDistance = distanceBetween
                        NearestMed.removeAll()
                        NearestMed.append(MedModels[i])
                    }
                }
            }
    SortedNearMedModels = NearMedModels.sorted(by: { $0.medDistance < $1.medDistance })
    sortedNumber = SortedNearMedModels.count
        
    print("NEAR: \(NearMedModels.count)")
    print("SORTEDNEAR: \(sortedNumber)")
    print("NEAREST: \(NearestMed.count)")
        
    }
    
}

extension Double {
    func rounding(toDecimal decimal: Int) -> Double {
        let numberOfDigits = pow(10.0, Double(decimal))
        return (self * numberOfDigits).rounded(.toNearestOrAwayFromZero) / numberOfDigits
    }
    
    func string(fractionDigits:Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: self as NSNumber) ?? "\(self)"
    }
}
