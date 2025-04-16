// EngineeringView.swift
// Add engineering services to a proposal

import SwiftUI

struct EngineeringView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var proposal: Proposal
    
    @State private var description = ""
    @State private var days = 1.0
    @State private var rate = 800.0
    
    var amount: Double {
        return days * rate
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Engineering Details")) {
                    TextField("Description", text: $description)
                    
                    Stepper(value: $days, in: 0.5...100, step: 0.5) {
                        HStack {
                            Text("Days")
                            Spacer()
                            Text("\(days, specifier: "%.1f")")
                        }
                    }
                    
                    HStack {
                        Text("Day Rate")
                        Spacer()
                        TextField("Rate", value: $rate, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Total Amount")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.2f", amount))
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Add Engineering")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addEngineering()
                    }
                    .disabled(description.isEmpty)
                }
            }
        }
    }
    
    private func addEngineering() {
        let engineering = Engineering(context: viewContext)
        engineering.id = UUID()
        engineering.description = description
        engineering.days = days
        engineering.rate = rate
        engineering.amount = amount
        engineering.proposal = proposal
        
        do {
            try viewContext.save()
            
            // Update proposal total
            updateProposalTotal()
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            print("Error adding engineering: \(nsError), \(nsError.userInfo)")
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
