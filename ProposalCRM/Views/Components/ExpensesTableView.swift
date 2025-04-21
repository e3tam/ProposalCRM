//
//  ExpensesTableView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 21.04.2025.
//


//
//  ExpensesTableView.swift
//  ProposalCRM
//

import SwiftUI
import CoreData

struct ExpensesTableView: View {
    let proposal: Proposal
    let onDelete: (Expense) -> Void
    let onEdit: (Expense) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Table header
            HStack(spacing: 0) {
                Text("Description")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 400, alignment: .leading)
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
            if proposal.expensesArray.isEmpty {
                Text("No expenses added yet")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.2))
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(proposal.expensesArray, id: \.self) { expense in
                            HStack(spacing: 0) {
                                Text(expense.desc ?? "")
                                    .font(.system(size: 14))
                                    .frame(width: 400, alignment: .leading)
                                    .padding(.horizontal, 5)
                                
                                Divider().frame(height: 40)
                                
                                Text(String(format: "%.2f", expense.amount))
                                    .font(.system(size: 14))
                                    .frame(width: 120, alignment: .trailing)
                                    .padding(.horizontal, 5)
                                
                                Divider().frame(height: 40)
                                
                                // Action buttons
                                HStack(spacing: 15) {
                                    Button(action: {
                                        onEdit(expense)
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Button(action: {
                                        onDelete(expense)
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

// Missing view for expenses
struct EditExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
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
            Section(header: Text("Details")) {
                TextField("Description", text: $description)
                
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }
        }
        .navigationTitle("Edit Expense")
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
                .disabled(description.isEmpty)
            }
        }
    }
    
    private func saveChanges() {
        expense.desc = description
        expense.amount = Double(amount) ?? 0
        
        do {
            try viewContext.save()
            
            // Update proposal totals
            if let proposal = expense.proposal {
                let productsTotal = proposal.subtotalProducts
                let engineeringTotal = proposal.subtotalEngineering
                let expensesTotal = proposal.subtotalExpenses
                let taxesTotal = proposal.subtotalTaxes
                
                proposal.totalAmount = productsTotal + engineeringTotal + expensesTotal + taxesTotal
                
                try viewContext.save()
            }
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}