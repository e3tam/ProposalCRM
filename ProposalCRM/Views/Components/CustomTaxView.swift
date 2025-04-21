//
//  CustomTaxView.swift
//  ProposalCRM
//

import SwiftUI
import CoreData

struct CustomTaxView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var proposal: Proposal
    
    @State private var name = ""
    @State private var rate: String = ""
    
    private var taxBase: Double {
        return proposal.subtotalProducts + proposal.subtotalEngineering + proposal.subtotalExpenses
    }
    
    private var calculatedAmount: Double {
        let rateValue = Double(rate) ?? 0
        return (taxBase * rateValue) / 100
    }
    
    var body: some View {
        NavigationView {
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
                        Text(String(format: "%.2f", calculatedAmount))
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("Add Custom Tax")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addCustomTax()
                    }
                    .disabled(name.isEmpty || rate.isEmpty)
                }
            }
        }
    }
    
    private func addCustomTax() {
        let newTax = CustomTax(context: viewContext)
        newTax.id = UUID()
        newTax.name = name
        newTax.rate = Double(rate) ?? 0
        newTax.amount = calculatedAmount
        newTax.proposal = proposal
        
        do {
            try viewContext.save()
            
            // Update proposal totals
            let productsTotal = proposal.subtotalProducts
            let engineeringTotal = proposal.subtotalEngineering
            let expensesTotal = proposal.subtotalExpenses
            let taxesTotal = proposal.subtotalTaxes
            
            proposal.totalAmount = productsTotal + engineeringTotal + expensesTotal + taxesTotal
            
            try viewContext.save()
            
            // Log activity
            ActivityLogger.logItemAdded(
                proposal: proposal,
                context: viewContext,
                itemType: "Tax",
                itemName: name
            )
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving custom tax: \(error)")
        }
    }
}
