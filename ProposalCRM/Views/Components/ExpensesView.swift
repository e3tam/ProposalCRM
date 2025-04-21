//
//  ExpensesView.swift
//  ProposalCRM
//

import SwiftUI
import CoreData

struct ExpensesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var proposal: Proposal
    
    @State private var description = ""
    @State private var amount: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Description", text: $description)
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addExpense()
                    }
                    .disabled(description.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    private func addExpense() {
        let newExpense = Expense(context: viewContext)
        newExpense.id = UUID()
        newExpense.desc = description
        newExpense.amount = Double(amount) ?? 0
        newExpense.proposal = proposal
        
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
                itemType: "Expense",
                itemName: description
            )
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving expense: \(error)")
        }
    }
}
