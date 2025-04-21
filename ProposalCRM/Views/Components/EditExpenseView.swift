import SwiftUI
import CoreData

struct EditExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var expense: Expense
    
    @State private var description: String
    @State private var amount: String
    
    init(expense: Expense) {
        self.expense = expense
        _description = State(initialValue: expense.desc ?? "")
        _amount = State(initialValue: String(format: "%.2f", expense.amount))
    }
    
    var body: some View {
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
        }
        .navigationTitle("Edit Expense")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(!isFormValid)
            }
        }
    }
    
    private var isFormValid: Bool {
        !description.isEmpty && Double(amount) != nil
    }
    
    private func saveChanges() {
        expense.desc = description
        expense.amount = Double(amount) ?? 0
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}
