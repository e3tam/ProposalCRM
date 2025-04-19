//
//  EditProposalItemView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


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
    @Binding var didSave: Bool  // Added binding to signal changes were saved
    
    // Editable properties
    @State private var customName: String
    @State private var quantity: Double
    @State private var discount: Double
    @State private var unitPrice: Double
    @State private var listPrice: Double  // For display/calculation - won't modify product directly
    @State private var multiplier: Double
    
    // Custom formatter for decimal values
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    init(item: ProposalItem, didSave: Binding<Bool>) {
        self.item = item
        self._didSave = didSave
        
        // Initialize state with current values
        _customName = State(initialValue: item.product?.name ?? "")
        _quantity = State(initialValue: item.quantity)
        _discount = State(initialValue: item.discount)
        _unitPrice = State(initialValue: item.unitPrice)
        _listPrice = State(initialValue: item.product?.listPrice ?? 0)
        
        // Calculate the multiplier from existing data
        let calculatedMultiplier: Double
        if let product = item.product, product.listPrice > 0 {
            let discountFactor = 1.0 - (item.discount / 100.0)
            if discountFactor > 0 {
                calculatedMultiplier = item.unitPrice / (product.listPrice * discountFactor)
            } else {
                calculatedMultiplier = 1.0
            }
        } else {
            calculatedMultiplier = 1.0
        }
        _multiplier = State(initialValue: calculatedMultiplier)
    }
    
    // Calculated values
    var amount: Double {
        return unitPrice * quantity
    }
    
    var partnerPrice: Double {
        return item.product?.partnerPrice ?? 0
    }
    
    var calculatedUnitPrice: Double {
        // Unit price can be affected by multiplier and list price
        return listPrice * multiplier * (1 - discount/100)
    }
    
    var profit: Double {
        let cost = partnerPrice * quantity
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
                    // Product name (editable for display only)
                    HStack {
                        Text("Product:")
                        Spacer()
                        TextField("Product Name", text: $customName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    // Product code (non-editable)
                    HStack {
                        Text("Code:")
                        Spacer()
                        Text(item.product?.code ?? "")
                            .foregroundColor(.secondary)
                    }
                    
                    // Quantity with stepper
                    HStack {
                        Text("Quantity:")
                        Spacer()
                        
                        Button(action: {
                            if quantity > 1 {
                                quantity -= 1
                            }
                        }) {
                            Image(systemName: "minus")
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                        
                        Text("\(Int(quantity))")
                            .frame(width: 30, alignment: .center)
                        
                        Button(action: {
                            quantity += 1
                        }) {
                            Image(systemName: "plus")
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    
                    // Discount with slider
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Discount (%)")
                            Spacer()
                            Text("\(Int(discount))%")
                        }
                        
                        HStack {
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            
                            Slider(value: $discount, in: 0...50)
                                .accentColor(.blue)
                        }
                    }
                }
                
                // PRICING section
                Section(header: Text("PRICING")) {
                    // List price (editable)
                    HStack {
                        Text("List Price")
                        Spacer()
                        TextField("List Price", value: $listPrice, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    // Partner price (non-editable)
                    HStack {
                        Text("Partner Price")
                        Spacer()
                        Text(String(format: "%.2f", partnerPrice))
                            .foregroundColor(.blue)
                    }
                    
                    // Multiplier (editable with better UI)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Multiplier")
                        
                        HStack {
                            // Decrease button
                            Button(action: {
                                // Decrease by 0.05 but not below 0.5
                                multiplier = max(0.5, multiplier - 0.05)
                                // Update unit price when multiplier changes
                                unitPrice = listPrice * multiplier * (1 - discount/100)
                            }) {
                                Image(systemName: "minus")
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            
                            // Direct text entry
                            TextField("", value: $multiplier, formatter: numberFormatter)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 60)
                                .padding(.vertical, 5)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .onChange(of: multiplier) { newValue in
                                    // Update unit price when multiplier changes
                                    unitPrice = listPrice * multiplier * (1 - discount/100)
                                }
                            
                            Text("×")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            // Increase button
                            Button(action: {
                                // Increase by 0.05 but not above 2.0
                                multiplier = min(2.0, multiplier + 0.05)
                                // Update unit price when multiplier changes
                                unitPrice = listPrice * multiplier * (1 - discount/100)
                            }) {
                                Image(systemName: "plus")
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                        }
                        
                        // Quick preset values
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach([0.8, 0.9, 1.0, 1.1, 1.2, 1.5], id: \.self) { value in
                                    Button(action: {
                                        multiplier = value
                                        // Update unit price when multiplier changes
                                        unitPrice = listPrice * multiplier * (1 - discount/100)
                                    }) {
                                        Text(String(format: "%.2f×", value))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(multiplier == value ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(multiplier == value ? .white : .primary)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Unit price (editable)
                    HStack {
                        Text("Unit Price")
                        Spacer()
                        TextField("Unit Price", value: $unitPrice, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: multiplier) { newValue in
                                // Update unit price when multiplier changes
                                unitPrice = listPrice * multiplier * (1 - discount/100)
                            }
                            .onChange(of: listPrice) { newValue in
                                // Update unit price when list price changes
                                unitPrice = listPrice * multiplier * (1 - discount/100)
                            }
                    }
                    
                    // Amount (calculated)
                    HStack {
                        Text("Amount")
                        Spacer()
                        Text(String(format: "%.2f", amount))
                            .bold()
                    }
                    
                    // Profit (calculated)
                    HStack {
                        Text("Profit")
                        Spacer()
                        Text(String(format: "%.2f", profit))
                            .foregroundColor(profit > 0 ? .green : .red)
                            .bold()
                    }
                    
                    // Margin (calculated)
                    HStack {
                        Text("Margin")
                        Spacer()
                        Text(String(format: "%.1f%%", margin))
                            .foregroundColor(margin >= 20 ? .green : (margin >= 10 ? .orange : .red))
                            .bold()
                    }
                }
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
    }
    
    private func saveChanges() {
        // Update fields in the proposal item
        item.quantity = quantity
        item.discount = discount
        
        // Calculate the final unit price based on list price, multiplier, and discount
        unitPrice = listPrice * multiplier * (1 - discount/100)
        item.unitPrice = unitPrice
        
        // Calculate and set the final amount
        item.amount = amount
        
        // DO NOT try to set multiplier directly - it's not in the Core Data model
        
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
            
            // Set the didSave flag to true to signal to parent view that changes were made
            didSave = true
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            print("Error saving changes: \(nsError), \(nsError.userInfo)")
        }
    }
}