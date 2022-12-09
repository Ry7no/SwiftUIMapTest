//
//  AdManager.swift
//  RapidAntigenTestMap
//
//  Created by @Ryan on 2022/12/7.
//

import Foundation
import GoogleMobileAds
import UIKit
import SwiftUI

final class OpenInterstitialAD: NSObject, GADFullScreenContentDelegate {
    
   var appOpenAd: GADAppOpenAd?
   var loadTime = Date()
   let interstitialID = "ca-app-pub-1460199512759261/6082736234"
   
   func requestAppOpenAd() {
       let request = GADRequest()
       GADAppOpenAd.load(withAdUnitID: interstitialID,
                         request: request,
                         orientation: UIInterfaceOrientation.portrait,
                         completionHandler: { (appOpenAdIn, _) in
                           self.appOpenAd = appOpenAdIn
                           self.appOpenAd?.fullScreenContentDelegate = self
                           self.loadTime = Date()
                           print("[OPEN AD] Ad is ready")
                         })
   }
   
   func tryToPresentAd() {
       if let gOpenAd = self.appOpenAd, wasLoadTimeLessThanNHoursAgo(thresholdN: 4) {
           gOpenAd.present(fromRootViewController: (UIApplication.shared.windows.first?.rootViewController)!)
       } else {
           self.requestAppOpenAd()
       }
   }
   
   func wasLoadTimeLessThanNHoursAgo(thresholdN: Int) -> Bool {
       let now = Date()
       let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(self.loadTime)
       let secondsPerHour = 3600.0
       let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
       return intervalInHours < Double(thresholdN)
   }
   
   func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
       print("[OPEN AD] Failed: \(error)")
       requestAppOpenAd()
   }
   
   func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
       requestAppOpenAd()
       print("[OPEN AD] Ad dismissed")
   }
   
//   func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//       print("[OPEN AD] Ad did present")
//   }
}


struct BannerVC: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        
        let bannerID = "ca-app-pub-1460199512759261/3164697340"
        let bannerView = GADBannerView(adSize: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width - 20))

        let viewController = UIViewController()
        bannerView.adUnitID = bannerID
        bannerView.rootViewController = viewController
        viewController.view.addSubview(bannerView)
        updateVCFrame(view: viewController.view)
        let request = GADRequest()
        bannerView.load(request)
        bannerView.tag = 999
        return viewController
        
//        viewController.view.frame = CGRect(origin: .zero, size: kGADAdSizeSmartBannerPortrait.size)
//        view.load(GADRequest())
//
//        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func updateVCFrame(view: UIView) {
        view.frame = CGRect(origin: .zero, size: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(view.frame.width).size)
    }
}

struct Banner: View {
    
    var body: some View {
        
        HStack {
            
            Spacer()
            
            BannerVC()
                .frame(width: (UIScreen.main.bounds.width - 20), height: 55, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 2).foregroundColor(.secondary)
                }
                .padding(.top, 5)
                .padding(.bottom, 10)
            
            Spacer()
        }
    }
}
