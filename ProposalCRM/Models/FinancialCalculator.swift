// FinancialCalculator.swift
// Handles complex pricing calculations for proposals

import Foundation
import CoreData

class FinancialCalculator {
    // Calculate pricing with various discount levels
    static func calculatePrice(listPrice: Double, discount: Double) -> Double {
        return listPrice * (1 - discount / 100)
    }
    
    // Calculate profit margin percentage
    static func calculateProfitMargin(revenue: Double, cost: Double) -> Double {
        if revenue == 0 {
            return 0
        }
        return ((revenue - cost) / revenue) * 100
    }
    
    // Calculate break-even discount
    static func calculateBreakEvenDiscount(listPrice: Double, partnerPrice: Double) -> Double {
        if listPrice == 0 {
            return 0
        }
        let breakEvenDiscount = ((listPrice - partnerPrice) / listPrice) * 100
        return breakEvenDiscount
    }
    
    // Calculate tax amount
    static func calculateTaxAmount(amount: Double, taxRate: Double) -> Double {
        return amount * (taxRate / 100)
    }
    
    // Calculate total proposal amount with all components
    static func calculateTotalProposalAmount(proposal: Proposal) -> Double {
        let productsTotal = proposal.subtotalProducts
        let engineeringTotal = proposal.subtotalEngineering
        let expensesTotal = proposal.subtotalExpenses
        let taxesTotal = proposal.subtotalTaxes
        
        return productsTotal + engineeringTotal + expensesTotal + taxesTotal
    }
    
    // Format currency based on locale
    static func formatCurrency(_ amount: Double, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currencyCode) \(String(format: "%.2f", amount))"
    }
}
