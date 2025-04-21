//
//  CustomTaxesTableView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 21.04.2025.
//


//
//  CustomTaxesTableView.swift
//  ProposalCRM
//

import SwiftUI
import CoreData

struct CustomTaxesTableView: View {
    let proposal: Proposal
    let onDelete: (CustomTax) -> Void
    let onEdit: (CustomTax) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Table header
            HStack(spacing: 0) {
                Text("Tax Name")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 300, alignment: .leading)
                    .padding(.horizontal, 5)
                
                Divider().frame(height: 36)
                
                Text("Rate (%)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 100, alignment: .center)
                    .padding(.horizontal, 5)
                
                Divider().frame(height: 36)
                
                Text("Amount")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 120, alignment: .trailing)
                    .padding(.horizontal, 5)
                
                Divider().frame(height: 36)
                
                Text("Actions")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 100, alignment: .center)
                    .padding(.horizontal, 5)
            }
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.3))
            
            Divider().background(Color.gray)
            
            // Content rows
            if proposal.taxesArray.isEmpty {
                Text("No custom taxes added yet")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.2))
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(proposal.taxesArray, id: \.self) { tax in
                            HStack(spacing: 0) {
                                Text(tax.name ?? "")
                                    .font(.system(size: 14))
                                    .frame(width: 300, alignment: .leading)
                                    .padding(.horizontal, 5)
                                
                                Divider().frame(height: 40)
                                
                                Text(String(format: "%.1f%%", tax.rate))
                                    .font(.system(size: 14))
                                    .frame(width: 100, alignment: .center)
                                    .padding(.horizontal, 5)
                                
                                Divider().frame(height: 40)
                                
                                Text(String(format: "%.2f", tax.amount))
                                    .font(.system(size: 14))
                                    .frame(width: 120, alignment: .trailing)
                                    .padding(.horizontal, 5)
                                
                                Divider().frame(height: 40)
                                
                                // Action buttons
                                HStack(spacing: 15) {
                                    Button(action: {
                                        onEdit(tax)
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Button(action: {
                                        onDelete(tax)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .frame(width: 100, alignment: .center)
                            }
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.2))
                            
                            Divider().background(Color.gray.opacity(0.5))
                        }
                    }
                }
            }
        }
        .background(Color.black.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// Missing view for custom taxes
struct EditCustomTaxView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var customTax: CustomTax
    @ObservedObject var proposal: Proposal
    
    @State private var name: String
    @State private var rate: String
    
    init(customTax: CustomTax, proposal: Proposal) {
        self.customTax = customTax
        self.proposal = proposal
        _name = State(initialValue: customTax.name ?? "")
        _rate = State(initialValue: String(format: "%.1f", customTax.rate))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Tax Details")) {
                TextField("Tax Name", text: $name)
                
                TextField("Rate (%)", text: $rate)
                    .keyboardType(.decimalPad)
                
                HStack {
                    Text("Tax Base:")
                    Spacer()
                    Text(String(format: "%.2f", taxBase))
                }
                
                HStack {
                    Text("Tax Amount:")
                    Spacer()
                    Text(String(format: "%.2f", calculateTaxAmount()))
                        .fontWeight(.bold)
                }
            }
        }
        .navigationTitle("Edit Custom Tax")
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
                .disabled(name.isEmpty)
            }
        }
    }
    
    private var taxBase: Double {
        return proposal.subtotalProducts + proposal.subtotalEngineering + proposal.subtotalExpenses
    }
    
    private func calculateTaxAmount() -> Double {
        let rateValue = Double(rate) ?? 0
        return (taxBase * rateValue) / 100
    }
    
    private func saveChanges() {
        customTax.name = name
        customTax.rate = Double(rate) ?? 0
        customTax.amount = calculateTaxAmount()
        
        do {
            try viewContext.save()
            
            // Update proposal totals
            let productsTotal = proposal.subtotalProducts
            let engineeringTotal = proposal.subtotalEngineering
            let expensesTotal = proposal.subtotalExpenses
            let taxesTotal = proposal.subtotalTaxes
            
            proposal.totalAmount = productsTotal + engineeringTotal + expensesTotal + taxesTotal
            
            try viewContext.save()
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}