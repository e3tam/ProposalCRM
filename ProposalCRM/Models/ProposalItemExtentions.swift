// ProposalItemExtensions.swift
// Extensions for ProposalItem to handle the new calculation fields

import Foundation
import CoreData

extension ProposalItem {
    // MARK: - Dynamic Properties
    // These properties are implemented as computed properties
    // but should be added as actual attributes to the Core Data model
    
    // Multiplier property (default: 1.0)
    var multiplier: Double {
        get {
            return value(forKey: "multiplier") as? Double ?? 1.0
        }
        set {
            setValue(newValue, forKey: "multiplier")
        }
    }
    
    // Partner price property (from the product)
    var partnerPrice: Double {
        get {
            return value(forKey: "partnerPrice") as? Double ?? product?.partnerPrice ?? 0
        }
        set {
            setValue(newValue, forKey: "partnerPrice")
        }
    }
    
    // Apply custom tax flag

    
    // Custom description
    var customDescription: String {
        get {
            return value(forKey: "customDescription") as? String ?? ""
        }
        set {
            setValue(newValue, forKey: "customDescription")
        }
    }
    
    // Profit
    var profit: Double {
        get {
            return value(forKey: "profit") as? Double ?? 0
        }
        set {
            setValue(newValue, forKey: "profit")
        }
    }
    
    // MARK: - Calculated Properties
    
    // Unit list price (from the product)
    var unitListPrice: Double {
        return product?.listPrice ?? 0
    }
    
    // Extended partner price
    var extendedPartnerPrice: Double {
        return partnerPrice * quantity
    }
    
    // Extended list price
    var extendedListPrice: Double {
        return unitListPrice * quantity
    }
    
    // Extended customer price (with multiplier and discount)
    var extendedCustomerPrice: Double {
        return extendedListPrice * multiplier * (1 - discount / 100)
    }
    
    // Discount ratio (partner/list price)
    var discountRatio: Double {
        if unitListPrice == 0 {
            return 0
        }
        return (partnerPrice / unitListPrice) * 100
    }
    
    // Calculated profit
    var calculatedProfit: Double {
        return extendedCustomerPrice - extendedPartnerPrice
    }
    
    // Profit margin percentage
    var profitMargin: Double {
        if extendedCustomerPrice == 0 {
            return 0
        }
        return (calculatedProfit / extendedCustomerPrice) * 100
    }
    
    // Formatted strings for display
    var formattedUnitListPrice: String {
        return String(format: "%.2f", unitListPrice)
    }
    
    var formattedUnitPartnerPrice: String {
        return String(format: "%.2f", partnerPrice)
    }
    
    var formattedExtendedListPrice: String {
        return String(format: "%.2f", extendedListPrice)
    }
    
    var formattedExtendedPartnerPrice: String {
        return String(format: "%.2f", extendedPartnerPrice)
    }
    
    var formattedExtendedCustomerPrice: String {
        return String(format: "%.2f", extendedCustomerPrice)
    }
    
    var formattedProfit: String {
        return String(format: "%.2f", calculatedProfit)
    }
    
    var formattedProfitMargin: String {
        return String(format: "%.1f%%", profitMargin)
    }
    
    var formattedMultiplier: String {
        return String(format: "%.2fx", multiplier)
    }
}

// MARK: - Core Data Model Extension Guide
/*
 To fully implement these changes, update your Core Data model by:
 
 1. Open ProposalCRM.xcdatamodeld in Xcode
 2. Select the ProposalItem entity
 3. Add the following attributes:
    - multiplier: Double, default: 1.0
    - partnerPrice: Double, default: 0.0
    - applyCustomTax: Boolean, default: false
    - customDescription: String, optional
    - profit: Double, default: 0.0
 
 Note: Until you can update the Core Data model directly, this extension
 provides computed properties that use Core Data's dynamic features to
 store and retrieve these values. This is a temporary solution that will
 work but is not optimal for performance.
 
 For a production app, you should properly update the Core Data model
 and run the migration process.
 */
