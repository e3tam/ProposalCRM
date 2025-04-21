import SwiftUI

struct ExpensesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var proposal: Proposal
    
    @State private var description = ""
    @State private var amount = 0.0
    @State private var showingPresets = false
    
    // Common expense presets
    let expensePresets = [
        "Accommodation",
        "Food",
        "Travel",
        "Hotel Night",
        "Transportation",
        "Equipment Rental",
        "Office Supplies",
        "Meeting Room",
        "Internet/Communication",
        "Marketing Materials"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("EXPENSE DETAILS")) {
                    TextField("Description", text: $description)
                        .overlay(
                            Button(action: {
                                showingPresets.toggle()
                            }) {
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 8),
                            alignment: .trailing
                        )
                    
                    if showingPresets {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(expensePresets, id: \.self) { preset in
                                    Button(action: {
                                        description = preset
                                        showingPresets = false
                                    }) {
                                        HStack {
                                            Image(systemName: "tag")
                                                .foregroundColor(.blue)
                                            Text(preset)
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .frame(height: 200)
                    }
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("Amount", value: $amount, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    // Common expense amount presets
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach([100.0, 150.0, 200.0, 250.0, 300.0, 500.0, 1000.0], id: \.self) { value in
                                Button(action: {
                                    amount = value
                                }) {
                                    Text("\(Int(value))")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(amount == value ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(amount == value ? .white : .primary)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Suggested Expenses")) {
                    Button(action: {
                        description = "Accommodation"
                        amount = 200.0
                    }) {
                        HStack {
                            Image(systemName: "bed.double.fill")
                                .foregroundColor(.orange)
                            Text("Accommodation")
                            Spacer()
                            Text("$200.00")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        description = "Food"
                        amount = 100.0
                    }) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.green)
                            Text("Food")
                            Spacer()
                            Text("$100.00")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        description = "Travel"
                        amount = 300.0
                    }) {
                        HStack {
                            Image(systemName: "airplane")
                                .foregroundColor(.blue)
                            Text("Travel")
                            Spacer()
                            Text("$300.00")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        description = "Hotel Night"
                        amount = 150.0
                    }) {
                        HStack {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.purple)
                            Text("Hotel Night")
                            Spacer()
                            Text("$150.00")
                                .foregroundColor(.secondary)
                        }
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

// Also update the EditExpenseView to have similar features
