// ExpensesView.swift
// Add expenses to a proposal

import SwiftUI

struct ExpensesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var proposal: Proposal
    
    @State private var description = ""
    @State private var amount = 0.0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Description", text: $description)
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("Amount", value: $amount, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
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
                    Button("Add") {
                        addExpense()
                    }
                    .disabled(description.isEmpty || amount <= 0)
                }
            }
        }
    }
    
    private func addExpense() {
        let expense = Expense(context: viewContext)
        expense.id = UUID()
        expense.desc = description
        expense.amount = amount
        expense.proposal = proposal
        
        do {
            try viewContext.save()
            
            // Update proposal total
            updateProposalTotal()
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            print("Error adding expense: \(nsError), \(nsError.userInfo)")
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
