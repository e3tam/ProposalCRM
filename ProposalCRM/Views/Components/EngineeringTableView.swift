//
//  EngineeringTableView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 21.04.2025.
//


//
//  EngineeringTableView.swift
//  ProposalCRM
//

import SwiftUI
import CoreData

struct EngineeringTableView: View {
    let proposal: Proposal
    let onDelete: (Engineering) -> Void
    let onEdit: (Engineering) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Table header
            HStack(spacing: 0) {
                Text("Description")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 300, alignment: .leading)
                    .padding(.horizontal, 5)
                
                Divider().frame(height: 36)
                
                Text("Days")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 70, alignment: .center)
                    .padding(.horizontal, 5)
                
                Divider().frame(height: 36)
                
                Text("Rate")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 100, alignment: .trailing)
                    .padding(.horizontal, 5)
                
                Divider().frame(height: 36)
                
                Text("Amount")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 100, alignment: .trailing)
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
            if proposal.engineeringArray.isEmpty {
                Text("No engineering entries added yet")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.2))
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(proposal.engineeringArray, id: \.self) { engineering in
                            HStack(spacing: 0) {
                                Text(engineering.desc ?? "")
                                    .font(.system(size: 14))
                                    .frame(width: 300, alignment: .leading)
                                    .padding(.horizontal, 5)
                                
                                Divider().frame(height: 40)
                                
                                Text(String(format: "%.1f", engineering.days))
                                    .font(.system(size: 14))
                                    .frame(width: 70, alignment: .center)
                                    .padding(.horizontal, 5)
                                
                                Divider().frame(height: 40)
                                
                                Text(String(format: "%.2f", engineering.rate))
                                    .font(.system(size: 14))
                                    .frame(width: 100, alignment: .trailing)
                                    .padding(.horizontal, 5)
                                
                                Divider().frame(height: 40)
                                
                                Text(String(format: "%.2f", engineering.amount))
                                    .font(.system(size: 14))
                                    .frame(width: 100, alignment: .trailing)
                                    .padding(.horizontal, 5)
                                
                                Divider().frame(height: 40)
                                
                                // Action buttons
                                HStack(spacing: 15) {
                                    Button(action: {
                                        onEdit(engineering)
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Button(action: {
                                        onDelete(engineering)
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

// Missing view for engineering
struct EditEngineeringView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var engineering: Engineering
    
    @State private var description: String
    @State private var days: String
    @State private var rate: String
    
    init(engineering: Engineering) {
        self.engineering = engineering
        _description = State(initialValue: engineering.desc ?? "")
        _days = State(initialValue: String(format: "%.1f", engineering.days))
        _rate = State(initialValue: String(format: "%.2f", engineering.rate))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Description", text: $description)
                
                TextField("Days", text: $days)
                    .keyboardType(.decimalPad)
                
                TextField("Daily Rate", text: $rate)
                    .keyboardType(.decimalPad)
                
                HStack {
                    Text("Amount:")
                    Spacer()
                    Text(String(format: "%.2f", calculateAmount()))
                        .fontWeight(.bold)
                }
            }
        }
        .navigationTitle("Edit Engineering")
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
    
    private func calculateAmount() -> Double {
        let daysValue = Double(days) ?? 0
        let rateValue = Double(rate) ?? 0
        return daysValue * rateValue
    }
    
    private func saveChanges() {
        engineering.desc = description
        engineering.days = Double(days) ?? 0
        engineering.rate = Double(rate) ?? 0
        engineering.amount = calculateAmount()
        
        do {
            try viewContext.save()
            
            // Update proposal totals
            if let proposal = engineering.proposal {
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