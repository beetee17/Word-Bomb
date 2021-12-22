//
//  PurchaseService.swift
//  Word Bomb
//
//  Created by Brandon Thio on 16/12/21.
//

import Foundation
import Purchases

class PurchaseService {
    enum ProductRetrievalStatus {
        case success(SKProduct)
        case failure
    }
    static func retrieve(_ id: String, completed: @escaping(ProductRetrievalStatus) -> Void) {
        Purchases.shared.products([id]) { products in
            guard !products.isEmpty else {
                completed(.failure)
                return
            }
            
            let skProduct = products[0]
            completed(.success(skProduct))
        }
    }
    
    static func purchase(productId:String?, successfulPurchase:@escaping () -> Void) {
        guard productId != nil else { return }
        
        // Perform the Purchase
        // Get SKProduct
        Purchases.shared.products([productId!]) { products in
            if !products.isEmpty {
                let skProduct = products[0]
                Purchases.shared.purchaseProduct(skProduct) { (transaction, purchaserInfo, error, userCancelled) in
                    if error == nil && !userCancelled {
                        // Successful Purchase Made
                        successfulPurchase()
                    }
                }
            }
        }
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
