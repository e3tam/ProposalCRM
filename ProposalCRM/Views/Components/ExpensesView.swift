import SwiftUI
import CoreData

struct ExpensesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var proposal: Proposal
    
    @State private var description = ""
    @State private var amount = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("EXPENSE DETAILS")) {
                    TextField("Description", text: $description)
                    
                    HStack {
                        Text("Amount (€)")
                        Spacer()
                        TextField("", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                }
                
                // Common expense templates
                Section(header: Text("QUICK ADD")) {
                    Button("Shipping/Freight") {
                        description = "Shipping and Freight"
                        // Amount remains empty for user to fill
                    }
                    
                    Button("Installation") {
                        description = "Installation Services"
                        // Amount remains empty for user to fill
                    }
                    
                    Button("Travel Expenses") {
                        description = "Travel and Accommodation"
                        // Amount remains empty for user to fill
                    }
                    
                    Button("Materials") {
                        description = "Additional Materials"
                        // Amount remains empty for user to fill
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addExpense()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !description.isEmpty && Double(amount) != nil
    }
    
    private func addExpense() {
        let expense = Expense(context: viewContext)
        expense.id = UUID()
        expense.desc = description
        expense.amount = Double(amount) ?? 0
        expense.proposal = proposal
        
        do {
            try viewContext.save()
            
            // Update proposal total
            updateProposalTotal()
            
            // Log activity
            ActivityLogger.logItemAdded(
                proposal: proposal,
                context: viewContext,
                itemType: "Expense",
                itemName: description
            )
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error adding expense: \(error)")
        }
    }
    
    private func updateProposalTotal() {
        let productsTotal = proposal.subtotalProducts
        let engineeringTotal = proposal.subtotalEngineering
        let expensesTotal = proposal.subtotalExpenses
        let taxesTotal = proposal.subtotalTaxes
        
        proposal.totalAmount = productsTotal + engineeringTotal + expensesTotal + taxesTotal
        
        do {
            try viewContext.save()
        } catch {
            print("Error updating proposal total: \(error)")
        }
    }
}
