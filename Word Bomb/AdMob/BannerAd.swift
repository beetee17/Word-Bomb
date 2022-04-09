//
//  BannerAd.swift
//  Word Bomb
//
//  Created by Brandon Thio on 9/4/22.
//

import SwiftUI
import GoogleMobileAds

enum AdUnitID: String {
    case Test = "ca-app-pub-3940256099942544/2934735716"
    case Release = "ca-app-pub-2426760767593477/6731921542"
}

struct BannerAd: UIViewRepresentable {
    
    var adID: AdUnitID
    
    func makeUIView(context: UIViewRepresentableContext<BannerAd>) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        
        banner.adUnitID = adID.rawValue
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(GADRequest())
        
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        
    }
}


struct BannerAd_Previews: PreviewProvider {
    static var previews: some View {
        BannerAd(adID: .Test)
    }
}
