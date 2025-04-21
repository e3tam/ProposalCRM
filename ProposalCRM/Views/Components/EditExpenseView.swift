//
//  EditExpenseView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


// EditExpenseView.swift
// Edit view for expense entries

import SwiftUI
import CoreData

struct EditExpenseView_: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var expense: Expense
    
    @State private var description: String
    @State private var amount: Double
    
    init(expense: Expense) {
        self.expense = expense
        _description = State(initialValue: expense.desc ?? "")
        _amount = State(initialValue: expense.amount)
    }
    
    var body: some View {
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
                
                // Common expense presets
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach([100.0, 200.0, 500.0, 1000.0, 1500.0], id: \.self) { preset in
                            Button(action: {
                                amount = preset
                            }) {
                                Text(String(format: "%.0f", preset))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(amount == preset ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            Button("Save Changes") {
                saveChanges()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    private func saveChanges() {
        expense.desc = description
        expense.amount = amount
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}
