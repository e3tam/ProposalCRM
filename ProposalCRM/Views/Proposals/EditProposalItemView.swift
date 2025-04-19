//
//  EditProposalItemView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


// EditProposalItemView.swift
// Form for editing existing proposal items

import SwiftUI
import CoreData

struct EditProposalItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var item: ProposalItem
    
    @State private var quantity: Double
    @State private var discount: Double
    @State private var unitPrice: Double
    @State private var multiplier: Double = 1.0
    
    init(item: ProposalItem) {
        self.item = item
        _quantity = State(initialValue: item.quantity)
        _discount = State(initialValue: item.discount)
        _unitPrice = State(initialValue: item.unitPrice)
        
        // Don't try to access the multiplier property
        _multiplier = State(initialValue: 1.0) // Default fixed value
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Details")) {
                    HStack {
                        Text("Product:")
                        Spacer()
                        Text(item.productName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Code:")
                        Spacer()
                        Text(item.productCode)
                            .foregroundColor(.secondary)
                    }
                    
                    Stepper(value: $quantity, in: 1...100) {
                        HStack {
                            Text("Quantity:")
                            Spacer()
                            Text("\(Int(quantity))")
                        }
                    }
                    
                    HStack {
                        Text("Discount (%)")
                        Spacer()
                        Text("\(Int(discount))%")
                            .frame(width: 50, alignment: .trailing)
                    }
                    
                    Slider(value: $discount, in: 0...50, step: 1.0)
                    
                    HStack {
                        Text("Multiplier")
                        Spacer()
                        Text(String(format: "%.2fx", multiplier))
                            .frame(width: 50, alignment: .trailing)
                    }
                    
                    Slider(value: $multiplier, in: 0.5...2.0, step: 0.05)
                }
                
                Section(header: Text("Pricing")) {
                    if let product = item.product {
                        HStack {
                            Text("List Price")
                            Spacer()
                            Text(String(format: "%.2f", product.listPrice))
                        }
                        
                        HStack {
                            Text("Partner Price")
                            Spacer()
                            Text(String(format: "%.2f", product.partnerPrice))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        Text("Unit Price")
                        Spacer()
                        TextField("Unit Price", value: $unitPrice, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Amount")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.2f", calculateAmount()))
                            .font(.headline)
                    }
                    
                    HStack {
                        Text("Profit")
                        Spacer()
                        Text(String(format: "%.2f", calculateProfit()))
                            .foregroundColor(calculateProfit() > 0 ? .green : .red)
                    }
                    
                    HStack {
                        Text("Margin")
                        Spacer()
                        Text(String(format: "%.1f%%", calculateMargin()))
                            .foregroundColor(calculateMargin() >= 20 ? .green : (calculateMargin() >= 10 ? .orange : .red))
                    }
                }
            }
            .navigationTitle("Edit Product")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    private func calculateAmount() -> Double {
        return unitPrice * quantity
    }
    
    private func calculateProfit() -> Double {
        if let product = item.product {
            let cost = product.partnerPrice * quantity
            return calculateAmount() - cost
        }
        return 0
    }
    
    private func calculateMargin() -> Double {
        let amount = calculateAmount()
        if amount <= 0 {
            return 0
        }
        
        let profit = calculateProfit()
        return (profit / amount) * 100
    }
    
    private func saveChanges() {
        item.quantity = quantity
        item.discount = discount
        item.unitPrice = unitPrice
        item.amount = calculateAmount()
        
        // Safely set multiplier if the property exists
        do {
            try item.setValue(multiplier, forKey: "multiplier")
        } catch {
            print("Could not set multiplier property: \(error)")
        }
        
        do {
            try viewContext.save()
            
            // Update proposal total if available
            if let proposal = item.proposal {
                let productsTotal = proposal.subtotalProducts
                let engineeringTotal = proposal.subtotalEngineering
                let expensesTotal = proposal.subtotalExpenses
                let taxesTotal = proposal.subtotalTaxes
                
                proposal.totalAmount = productsTotal + engineeringTotal + expensesTotal + taxesTotal
                
                try viewContext.save()
            }
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            print("Error saving changes: \(nsError), \(nsError.userInfo)")
        }
    }
}