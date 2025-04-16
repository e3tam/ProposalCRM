// CoreDataModel.swift
// This file provides programmatic definitions for the Core Data model entities

import Foundation
import CoreData

// Core Data Model Manager
// COMMENTED OUT TO AVOID DUPLICATION WITH Persistence.swift
/*
// COMMENTED OUT TO AVOID DUPLICATION WITH Persistence.swift
/*
class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ProposalCRM")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

// Extension for creating sample data for preview
*/

*/


// MARK: - CoreData entity extensions

// Customer extension
extension Customer {
    var formattedName: String {
        return name ?? "Unknown Customer"
    }
    
    var proposalsArray: [Proposal] {
        let set = proposals as? Set<Proposal> ?? []
        return set.sorted {
            $0.creationDate ?? Date() > $1.creationDate ?? Date()
        }
    }
}

// Product extension
extension Product {
    var formattedCode: String {
        return code ?? "Unknown Code"
    }
    
    var formattedName: String {
        return name ?? "Unknown Product"
    }
    
    var formattedPrice: String {
        return String(format: "%.2f", listPrice)
    }
}

// Proposal extension
extension Proposal {
    var formattedNumber: String {
        return number ?? "New Proposal"
    }
    
    var formattedDate: String {
        guard let date = creationDate else {
            return "Unknown Date"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var formattedStatus: String {
        return status ?? "Draft"
    }
    
    var formattedTotal: String {
        return String(format: "%.2f", totalAmount)
    }
    
    var customerName: String {
        return customer?.name ?? "No Customer"
    }
    
    var itemsArray: [ProposalItem] {
        let set = items as? Set<ProposalItem> ?? []
        return set.sorted {
            $0.product?.name ?? "" < $1.product?.name ?? ""
        }
    }
    
    var engineeringArray: [Engineering] {
        let set = engineering as? Set<Engineering> ?? []
        return set.sorted {
            $0.description ?? "" < $1.description ?? ""
        }
    }
    
    var expensesArray: [Expense] {
        let set = expenses as? Set<Expense> ?? []
        return set.sorted {
            $0.description ?? "" < $1.description ?? ""
        }
    }
    
    var taxesArray: [CustomTax] {
        let set = taxes as? Set<CustomTax> ?? []
        return set.sorted {
            $0.name ?? "" < $1.name ?? ""
        }
    }
    
    var subtotalProducts: Double {
        let items = itemsArray
        return items.reduce(0) { $0 + $1.amount }
    }
    
    var subtotalEngineering: Double {
        let engineering = engineeringArray
        return engineering.reduce(0) { $0 + $1.amount }
    }
    
    var subtotalExpenses: Double {
        let expenses = expensesArray
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    var subtotalTaxes: Double {
        let taxes = taxesArray
        return taxes.reduce(0) { $0 + $1.amount }
    }
    
    var totalCost: Double {
        var cost = 0.0
        for item in itemsArray {
            if let product = item.product {
                cost += product.partnerPrice * item.quantity
            }
        }
        return cost + subtotalExpenses
    }
    
    var grossProfit: Double {
        return totalAmount - totalCost
    }
    
    var profitMargin: Double {
        if totalAmount == 0 {
            return 0
        }
        return (grossProfit / totalAmount) * 100
    }
}

// ProposalItem extension
extension ProposalItem {
    var productName: String {
        return product?.name ?? "Unknown Product"
    }
    
    var productCode: String {
        return product?.code ?? "Unknown Code"
    }
    
    var formattedAmount: String {
        return String(format: "%.2f", amount)
    }
}

// Engineering extension
extension Engineering {
    var formattedAmount: String {
        return String(format: "%.2f", amount)
    }
}

// Expense extension
extension Expense {
    var formattedAmount: String {
        return String(format: "%.2f", amount)
    }
}

// CustomTax extension
extension CustomTax {
    var formattedRate: String {
        return String(format: "%.2f%%", rate)
    }
    
    var formattedAmount: String {
        return String(format: "%.2f", amount)
    }
}
