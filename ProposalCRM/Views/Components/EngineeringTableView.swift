//
//  EngineeringTableView.swift
//  ProposalCRM
//

import SwiftUI
import CoreData

struct EngineeringTableView: View {
    @ObservedObject var proposal: Proposal
    let onDelete: (Engineering) -> Void
    let onEdit: (Engineering) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    // Format currency to euros
    private func formatEuro(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "€\(String(format: "%.2f", value))"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Table header
            HStack(spacing: 0) {
                // Description
                Text("Description")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                
                // Days
                Text("Days")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 80, alignment: .center)
                    .padding(.horizontal, 5)
                
                // Rate (€)
                Text("Rate (€)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 100, alignment: .trailing)
                    .padding(.horizontal, 5)
                
                // Amount (€)
                Text("Amount (€)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 100, alignment: .trailing)
                    .padding(.horizontal, 5)
                
                // Actions
                Text("Act")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 60, alignment: .center)
                    .padding(.horizontal, 5)
            }
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.3))
            
            Divider().background(Color.gray)
            
            // Main table content with rows
            if proposal.engineeringArray.isEmpty {
                Text("No engineering services added yet")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.2))
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(proposal.engineeringArray, id: \.self) { engineering in
                            HStack(spacing: 0) {
                                // Description
                                Text(engineering.desc ?? "No Description")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 10)
                                
                                // Days
                                Text(String(format: "%.1f", engineering.days))
                                    .font(.system(size: 14))
                                    .frame(width: 80, alignment: .center)
                                    .padding(.horizontal, 5)
                                
                                // Rate
                                Text(formatEuro(engineering.rate))
                                    .font(.system(size: 14))
                                    .frame(width: 100, alignment: .trailing)
                                    .padding(.horizontal, 5)
                                
                                // Amount
                                Text(formatEuro(engineering.amount))
                                    .font(.system(size: 14))
                                    .frame(width: 100, alignment: .trailing)
                                    .padding(.horizontal, 5)
                                
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
                                .frame(width: 60, alignment: .center)
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
