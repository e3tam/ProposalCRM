// CustomTaxView.swift
// Add custom taxes to a proposal

import SwiftUI

struct CustomTaxView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var proposal: Proposal
    
    @State private var name = ""
    @State private var rate = 0.0
    
    var subtotal: Double {
        return proposal.subtotalProducts + proposal.subtotalEngineering + proposal.subtotalExpenses
    }
    
    var amount: Double {
        return subtotal * (rate / 100)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Custom Tax Details")) {
                    TextField("Tax Name", text: $name)
                    
                    HStack {
                        Text("Rate (%)")
                        Spacer()
                        Slider(value: $rate, in: 0...30, step: 0.5)
                        Text("\(rate, specifier: "%.1f")%")
                            .frame(width: 50)
                    }
                    
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text(String(format: "%.2f", subtotal))
                    }
                    
                    HStack {
                        Text("Tax Amount")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.2f", amount))
                            .font(.headline)
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
                    Button("Add") {
                        addCustomTax()
                    }
                    .disabled(name.isEmpty || rate <= 0)
                }
            }
        }
    }
    
    private func addCustomTax() {
        let tax = CustomTax(context: viewContext)
        tax.id = UUID()
        tax.name = name
        tax.rate = rate
        tax.amount = amount
        tax.proposal = proposal
        
        do {
            try viewContext.save()
            
            // Update proposal total
            updateProposalTotal()
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            print("Error adding custom tax: \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func updateProposalTotal() {
        // Calculate total amount
        let productsTotal = proposal.subtotalProducts
        let engineeringTotal = proposal.subtotalEngineering
        let expensesTotal = proposal.subtotalExpenses
        let taxesTotal = proposal.subtotalTaxes
        
        proposal.totalAmount = productsTotal + engineeringTotal + expensesTotal + taxesTotal
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error updating proposal total: \(nsError), \(nsError.userInfo)")
        }
    }
}
