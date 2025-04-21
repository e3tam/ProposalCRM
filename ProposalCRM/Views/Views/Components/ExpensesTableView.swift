//
//  ExpensesTableView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


// ExpensesTableView.swift
// Displays expenses in a table format with edit and delete capabilities

import SwiftUI
import CoreData

struct ExpensesTableView: View {
    @ObservedObject var proposal: Proposal
    let onDelete: (Expense) -> Void
    let onEdit: (Expense) -> Void
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingEditMenu = false
    @State private var selectedExpense: Expense?
    
    init(_ proposal: Proposal, onDelete: @escaping (Expense) -> Void, onEdit: @escaping (Expense) -> Void) {
        self.proposal = proposal
        self.onDelete = onDelete
        self.onEdit = onEdit
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Table header
                HStack(spacing: 0) {
                    Text("Description")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 300, alignment: .leading)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Amount")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 120, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Act")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 80, alignment: .center)
                        .padding(.horizontal, 5)
                }
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.3))
                
                Divider()
                
                // Expenses rows
                if proposal.expensesArray.isEmpty {
                    Text("No expenses added yet")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.2))
                } else {
                    ForEach(proposal.expensesArray, id: \.self) { expense in
                        HStack(spacing: 0) {
                            // Description
                            Text(expense.desc ?? "")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .frame(width: 300, alignment: .leading)
                                .padding(.horizontal, 5)
                            
                            Divider().frame(height: 40)
                            
                            // Amount
                            Text(String(format: "%.2f", expense.amount))
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 120, alignment: .trailing)
                                .padding(.horizontal, 5)
                            
                            Divider().frame(height: 40)
                            
                            // Action buttons
                            HStack(spacing: 15) {
                                Button(action: {
                                    selectedExpense = expense
                                    showingEditMenu = true
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
                            .frame(width: 80, alignment: .center)
                        }
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.2))
                        
                        Divider().background(Color.gray.opacity(0.5))
                    }
                }
            }
            .background(Color.black)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            // Pop-up Edit Menu
            if showingEditMenu, let expense = selectedExpense {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showingEditMenu = false
                        }
                    
                    ExpensesEditMenu(
                        expense: expense,
                        isPresented: $showingEditMenu,
                        onSave: {
                            // Update proposal total
                            updateProposalTotal()
                        }
                    )
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                }
                .zIndex(1)
            }
        }
    }
    
    // Function to update the proposal total
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

// Usage example in ProposalDetailView:
/*
ExpensesTableView(
    proposal,
    onDelete: { expense in
        // Delete expense
        viewContext.delete(expense)
        try? viewContext.save()
        updateProposalTotal()
    },
    onEdit: { expense in
        // Set expense to edit and show edit sheet
        expenseToEdit = expense
        showEditExpenseSheet = true
    }
)
*/