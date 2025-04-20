//
//  EditProposalItemView.swift
//  ProposalCRM
//

import SwiftUI
import CoreData

struct EditProposalItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var item: ProposalItem
    @Binding var didSave: Bool
    
    // Editable properties
    @State private var customName: String
    @State private var quantity: Double
    @State private var quantityText: String
    @State private var discount: Double
    @State private var unitPrice: Double
    @State private var listPrice: Double
    @State private var listPriceText: String
    @State private var multiplier: Double
    @State private var multiplierText: String
    @State private var partnerPriceOverride: Double
    @State private var partnerPriceText: String
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()
    
    private let quantityFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter
    }()
    
    init(item: ProposalItem, didSave: Binding<Bool>) {
        self.item = item
        self._didSave = didSave
        
        // Initialize state with current values
        _customName = State(initialValue: item.product?.name ?? "")
        
        let currentQuantity = item.quantity
        _quantity = State(initialValue: currentQuantity)
        _quantityText = State(initialValue: String(format: "%.0f", currentQuantity))
        
        _discount = State(initialValue: item.discount)
        _unitPrice = State(initialValue: item.unitPrice)
        
        // Initialize with actual product values or calculated values
        let initialListPrice = item.product?.listPrice ?? 0
        let initialPartnerPrice = item.product?.partnerPrice ?? 0
        
        // If unit price is different from default calculation, we'll calculate what the list price should have been
        let calculatedListPrice: Double
        if item.product?.listPrice ?? 0 > 0 {
            let defaultUnitPrice = (item.product?.listPrice ?? 0) * (1 - item.discount / 100.0)
            if abs(defaultUnitPrice - item.unitPrice) > 0.01 {
                // Price has been overridden, calculate what the list price would be
                calculatedListPrice = item.unitPrice / (1 - item.discount / 100.0)
            } else {
                calculatedListPrice = initialListPrice
            }
        } else {
            calculatedListPrice = initialListPrice
        }
        
        _listPrice = State(initialValue: calculatedListPrice)
        _listPriceText = State(initialValue: String(format: "%.2f", calculatedListPrice))
        
        _partnerPriceOverride = State(initialValue: initialPartnerPrice)
        _partnerPriceText = State(initialValue: String(format: "%.2f", initialPartnerPrice))
        
        // Calculate the multiplier from existing data
        let calculatedMultiplier: Double
        if calculatedListPrice > 0 {
            let discountFactor = 1.0 - (item.discount / 100.0)
            if discountFactor > 0 {
                calculatedMultiplier = item.unitPrice / (calculatedListPrice * discountFactor)
            } else {
                calculatedMultiplier = 1.0
            }
        } else {
            calculatedMultiplier = 1.0
        }
        _multiplier = State(initialValue: calculatedMultiplier)
        _multiplierText = State(initialValue: String(format: "%.2f", calculatedMultiplier))
    }
    
    // Calculated values
    var amount: Double {
        return unitPrice * quantity
    }
    
    var profit: Double {
        let cost = partnerPriceOverride * quantity
        return amount - cost
    }
    
    var margin: Double {
        if amount <= 0 {
            return 0
        }
        return (profit / amount) * 100
    }
    
    var body: some View {
        NavigationView {
            Form {
                // PRODUCT DETAILS section
                Section(header: Text("PRODUCT DETAILS")) {
                    // Product name (display only)
                    HStack {
                        Text("Product:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(customName)
                            .foregroundColor(.white)
                    }
                    
                    // Product code (display only)
                    HStack {
                        Text("Code:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(item.product?.code ?? "")
                            .foregroundColor(.white)
                    }
                    
                    // Quantity with editable TextField and stepper buttons
                    HStack {
                        Text("Quantity:")
                            .foregroundColor(.gray)
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Minus button
                            Button(action: {
                                if quantity > 1 {
                                    quantity = floor(quantity - 1)
                                    quantityText = String(format: "%.0f", quantity)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                            }
                            
                            // Editable quantity field
                            TextField("", text: $quantityText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 60)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .onChange(of: quantityText) { newValue in
                                    if let value = Double(newValue) {
                                        quantity = value
                                    }
                                }
                            
                            // Plus button
                            Button(action: {
                                quantity = floor(quantity + 1)
                                quantityText = String(format: "%.0f", quantity)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    // Discount with improved slider
                    VStack(spacing: 8) {
                        HStack {
                            Text("Discount (%)")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(String(format: "%.0f%%", discount))
                                .foregroundColor(.white)
                        }
                        
                        Slider(value: $discount, in: 0...50, step: 1.0) { _ in
                            updateUnitPrice()
                        }
                        .accentColor(.blue)
                    }
                }
                .listRowBackground(Color.gray.opacity(0.1))
                
                // PRICING section
                Section(header: Text("PRICING")) {
                    // List price (editable)
                    HStack {
                        Text("List Price")
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("", text: $listPriceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .onChange(of: listPriceText) { newValue in
                                if let value = Double(newValue) {
                                    listPrice = value
                                    updateUnitPrice()
                                }
                            }
                    }
                    
                    // Partner price (editable)
                    HStack {
                        Text("Partner Price")
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("", text: $partnerPriceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.blue)
                            .onChange(of: partnerPriceText) { newValue in
                                if let value = Double(newValue) {
                                    partnerPriceOverride = value
                                }
                            }
                    }
                    
                    // Multiplier with improved UI
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Multiplier")
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 16) {
                            // Direct input field with better styling
                            TextField("", text: $multiplierText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 80)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .onChange(of: multiplierText) { newValue in
                                    if let value = Double(newValue) {
                                        multiplier = value
                                        updateUnitPrice()
                                    }
                                }
                            
                            Text("×")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                        }
                        
                        // Quick preset values with better layout
                        HStack(spacing: 8) {
                            ForEach([0.8, 0.9, 1.0, 1.1, 1.2, 1.5], id: \.self) { value in
                                Button(action: {
                                    multiplier = value
                                    multiplierText = String(format: "%.2f", value)
                                    updateUnitPrice()
                                }) {
                                    Text(String(format: "%.1f×", value))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(multiplier == value ? Color.blue : Color.gray.opacity(0.3))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Unit price (display only, calculated)
                    HStack {
                        Text("Unit Price")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.2f", unitPrice))
                            .foregroundColor(.white)
                    }
                    
                    // Amount (display only, calculated)
                    HStack {
                        Text("Amount")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.2f", amount))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                }
                .listRowBackground(Color.gray.opacity(0.1))
                
                // PROFIT section
                Section(header: Text("PROFIT & MARGIN")) {
                    // Profit (calculated)
                    HStack {
                        Text("Profit")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.2f", profit))
                            .foregroundColor(profit > 0 ? .green : .red)
                            .fontWeight(.bold)
                    }
                    
                    // Margin (calculated)
                    HStack {
                        Text("Margin")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.1f%%", margin))
                            .foregroundColor(margin >= 20 ? .green : (margin >= 10 ? .orange : .red))
                            .fontWeight(.bold)
                    }
                }
                .listRowBackground(Color.gray.opacity(0.1))
            }
            .navigationTitle("Edit Product")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveChanges()
                }
            )
        }
        .preferredColorScheme(.dark)
    }
    
    private func updateUnitPrice() {
        // Update unit price based on list price, multiplier, and discount
        unitPrice = listPrice * multiplier * (1 - discount/100)
    }
    
    private func saveChanges() {
        // Ensure all text values are converted to doubles
        if let qtyValue = Double(quantityText) {
            quantity = qtyValue
        }
        if let listValue = Double(listPriceText) {
            listPrice = listValue
        }
        if let partnerValue = Double(partnerPriceText) {
            partnerPriceOverride = partnerValue
        }
        if let multiplierValue = Double(multiplierText) {
            multiplier = multiplierValue
        }
        
        // Update fields in the proposal item
        item.quantity = quantity
        item.discount = discount
        item.unitPrice = unitPrice
        item.amount = amount
        
        // If the prices were changed, we don't modify the product itself,
        // but we've already calculated the correct unit price above
        
        do {
            // Save the context
            try viewContext.save()
            
            // Force refresh the managed object
            viewContext.refresh(item, mergeChanges: true)
            
            // Update proposal total if available
            if let proposal = item.proposal {
                // Force refresh the proposal as well
                viewContext.refresh(proposal, mergeChanges: true)
                
                let productsTotal = proposal.subtotalProducts
                let engineeringTotal = proposal.subtotalEngineering
                let expensesTotal = proposal.subtotalExpenses
                let taxesTotal = proposal.subtotalTaxes
                
                proposal.totalAmount = productsTotal + engineeringTotal + expensesTotal + taxesTotal
                
                try viewContext.save()
            }
            
            // Set the didSave flag to true
            didSave = true
            
            // Dismiss the view
            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            let nsError = error as NSError
            print("Error saving changes: \(nsError), \(nsError.userInfo)")
        }
    }
}
