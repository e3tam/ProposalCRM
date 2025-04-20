//
//  EditProposalItemManager.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 21.04.2025.
//


//
//  EditProposalItemManager.swift
//  ProposalCRM
//

import Foundation
import CoreData
import SwiftUI

class EditProposalItemManager: ObservableObject {
    @Published var isLoading = true
    @Published var productName = ""
    @Published var productCode = ""
    @Published var quantity: Double = 1.0
    @Published var quantityText = "1"
    @Published var discount: Double = 0.0
    @Published var listPrice: Double = 0.0
    @Published var listPriceText = "0.00"
    @Published var partnerPrice: Double = 0.0
    @Published var partnerPriceText = "0.00"
    @Published var multiplier: Double = 1.0
    @Published var multiplierText = "1.00"
    @Published var unitPrice: Double = 0.0
    @Published var error: String?
    
    private var item: ProposalItem
    private var viewContext: NSManagedObjectContext
    
    init(item: ProposalItem, context: NSManagedObjectContext) {
        self.item = item
        self.viewContext = context
        
        loadItemData()
    }
    
    func loadItemData() {
        viewContext.performAndWait {
            // Force fault the item
            if item.isFault {
                viewContext.refresh(item, mergeChanges: true)
            }
            
            // Load product data
            if let product = item.product {
                if product.isFault {
                    viewContext.refresh(product, mergeChanges: true)
                }
                
                // Populate fields
                productName = product.name ?? "Unknown Product"
                productCode = product.code ?? "No Code"
                listPrice = product.listPrice
                partnerPrice = product.partnerPrice
            } else {
                productName = "Product Not Found"
                productCode = "N/A"
                listPrice = item.unitPrice
                partnerPrice = 0.0
            }
            
            // Load item properties
            quantity = max(1.0, item.quantity)
            quantityText = String(format: "%.0f", quantity)
            discount = item.discount
            unitPrice = item.unitPrice
            
            // Format text fields
            listPriceText = String(format: "%.2f", listPrice)
            partnerPriceText = String(format: "%.2f", partnerPrice)
            
            // Calculate multiplier
            if listPrice > 0 {
                let discountFactor = 1.0 - (discount / 100.0)
                if discountFactor > 0 {
                    multiplier = unitPrice / (listPrice * discountFactor)
                }
            }
            multiplierText = String(format: "%.2f", multiplier)
            
            isLoading = false
        }
    }
    
    func updateUnitPrice() {
        unitPrice = listPrice * multiplier * (1 - discount/100)
    }
    
    func validateQuantityText() {
        if let value = Double(quantityText), value >= 1 {
            quantity = value
        }
        quantityText = String(format: "%.0f", quantity)
    }
    
    func saveChanges(completion: @escaping (Bool) -> Void) {
        viewContext.perform {
            do {
                // Update item
                self.item.quantity = self.quantity
                self.item.discount = self.discount
                self.item.unitPrice = self.unitPrice
                self.item.amount = self.unitPrice * self.quantity
                
                try self.viewContext.save()
                
                // Update proposal totals
                if let proposal = self.item.proposal {
                    let productsTotal = proposal.subtotalProducts
                    let engineeringTotal = proposal.subtotalEngineering
                    let expensesTotal = proposal.subtotalExpenses
                    let taxesTotal = proposal.subtotalTaxes
                    
                    proposal.totalAmount = productsTotal + engineeringTotal + expensesTotal + taxesTotal
                    
                    try self.viewContext.save()
                }
                
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}