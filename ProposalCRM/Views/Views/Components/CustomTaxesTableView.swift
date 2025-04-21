//
//  CustomTaxesTableView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


// CustomTaxesTableView.swift
// Displays custom taxes in a table format with edit and delete capabilities

import SwiftUI
import CoreData

struct CustomTaxesTableView: View {
    @ObservedObject var proposal: Proposal
    let onDelete: (CustomTax) -> Void
    let onEdit: (CustomTax) -> Void
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingEditMenu = false
    @State private var selectedTax: CustomTax?
    
    init(_ proposal: Proposal, onDelete: @escaping (CustomTax) -> Void, onEdit: @escaping (CustomTax) -> Void) {
        self.proposal = proposal
        self.onDelete = onDelete
        self.onEdit = onEdit
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Table header
                HStack(spacing: 0) {
                    Text("Tax Name")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 200, alignment: .leading)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Rate")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 100, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Base Amount")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 120, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Tax Amount")
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
                
                // Custom taxes rows
                if proposal.taxesArray.isEmpty {
                    Text("No custom taxes added yet")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.2))
                } else {
                    ForEach(proposal.taxesArray, id: \.self) { tax in
                        HStack(spacing: 0) {
                            // Tax name
                            Text(tax.name ?? "")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .frame(width: 200, alignment: .leading)
                                .padding(.horizontal, 5)
                            
                            Divider().frame(height: 40)
                            
                            // Rate
                            Text(String(format: "%.2f%%", tax.rate))
                                .font(.system(size: 14))
                                .frame(width: 100, alignment: .trailing)
                                .padding(.horizontal, 5)
                            
                            Divider().frame(height: 40)
                            
                            // Base amount (calculated from rate and amount)
                            let baseAmount = tax.rate > 0 ? (tax.amount / (tax.rate / 100)) : 0
                            Text(String(format: "%.2f", baseAmount))
                                .font(.system(size: 14))
                                .frame(width: 120, alignment: .trailing)
                                .padding(.horizontal, 5)
                            
                            Divider().frame(height: 40)
                            
                            // Amount
                            Text(String(format: "%.2f", tax.amount))
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 120, alignment: .trailing)
                                .padding(.horizontal, 5)
                            
                            Divider().frame(height: 40)
                            
                            // Action buttons
                            HStack(spacing: 15) {
                                Button(action: {
                                    selectedTax = tax
                                    showingEditMenu = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                
                                Button(action: {
                                    onDelete(tax)
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
            if showingEditMenu, let tax = selectedTax {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showingEditMenu = false
                        }
                    
                    CustomTaxEditMenu(
                        customTax: tax,
                        proposal: proposal,
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
CustomTaxesTableView(
    proposal,
    onDelete: { tax in
        // Delete tax
        viewContext.delete(tax)
        try? viewContext.save()
        updateProposalTotal()
    },
    onEdit: { tax in
        // Set tax to edit and show edit sheet
        taxToEdit = tax
        showEditTaxSheet = true
    }
)
*/