//
//  ProductTableView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


import SwiftUI
import CoreData

struct ProductTableView: View {
    @ObservedObject var proposal: Proposal
    let onDelete: (ProposalItem) -> Void
    let onEdit: (ProposalItem) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Table header with scrollable view for all columns
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 0) {
                    // Product Name
                    Text("Product Name")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 180, alignment: .leading)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    // Qty
                    Text("Qty")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 50, alignment: .center)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    // Unit Partner Price
                    Text("Unit Partner Price")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 120, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    // Unit List Price
                    Text("Unit List Price")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 120, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    // Multiplier
                    Text("Multiplier")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 80, alignment: .center)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    // Discount
                    Text("Discount")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 80, alignment: .center)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    // Ext Partner Price
                    Text("Ext Partner Price")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 120, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    // Ext List Price
                    Text("Ext List Price")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 120, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    // Ext Customer Price
                    Text("Ext Customer Price")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 120, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    // Total Profit
                    Text("Total Profit")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 100, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    // Custom Tax?
                    Text("Custom Tax?")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 90, alignment: .center)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    // Actions
                    Text("Act")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 60, alignment: .center)
                        .padding(.horizontal, 5)
                }
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.3))
            }
            
            Divider().background(Color.gray)
            
            // Main table content with rows
            if proposal.itemsArray.isEmpty {
                Text("No products added yet")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.2))
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(proposal.itemsArray, id: \.self) { item in
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack(spacing: 0) {
                                    // Product Name with code
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.productName)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                        Text(item.productCode)
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 180, alignment: .leading)
                                    .padding(.horizontal, 5)
                                    
                                    Divider().frame(height: 40)
                                    
                                    // Quantity
                                    Text("\(Int(item.quantity))")
                                        .font(.system(size: 14))
                                        .frame(width: 50, alignment: .center)
                                        .padding(.horizontal, 5)
                                    
                                    Divider().frame(height: 40)
                                    
                                    // Unit Partner Price
                                    let partnerPrice = item.product?.partnerPrice ?? 0
                                    Text(String(format: "%.2f", partnerPrice))
                                        .font(.system(size: 14))
                                        .frame(width: 120, alignment: .trailing)
                                        .padding(.horizontal, 5)
                                    
                                    Divider().frame(height: 40)
                                    
                                    // Unit List Price
                                    let listPrice = item.product?.listPrice ?? 0
                                    Text(String(format: "%.2f", listPrice))
                                        .font(.system(size: 14))
                                        .frame(width: 120, alignment: .trailing)
                                        .padding(.horizontal, 5)
                                    
                                    Divider().frame(height: 40)
                                    
                                    // Multiplier (default to 1.00)
                                    Text("1.00")
                                        .font(.system(size: 14))
                                        .frame(width: 80, alignment: .center)
                                        .padding(.horizontal, 5)
                                    
                                    Divider().frame(height: 40)
                                    
                                    // Discount
                                    Text(String(format: "%.1f%%", item.discount))
                                        .font(.system(size: 14))
                                        .frame(width: 80, alignment: .center)
                                        .padding(.horizontal, 5)
                                    
                                    Divider().frame(height: 40)
                                    
                                    // Ext Partner Price
                                    let extPartnerPrice = partnerPrice * item.quantity
                                    Text(String(format: "%.2f", extPartnerPrice))
                                        .font(.system(size: 14))
                                        .frame(width: 120, alignment: .trailing)
                                        .padding(.horizontal, 5)
                                    
                                    Divider().frame(height: 40)
                                    
                                    // Ext List Price
                                    let extListPrice = listPrice * item.quantity
                                    Text(String(format: "%.2f", extListPrice))
                                        .font(.system(size: 14))
                                        .frame(width: 120, alignment: .trailing)
                                        .padding(.horizontal, 5)
                                    
                                    Divider().frame(height: 40)
                                    
                                    // Ext Customer Price (amount)
                                    Text(String(format: "%.2f", item.amount))
                                        .font(.system(size: 14))
                                        .frame(width: 120, alignment: .trailing)
                                        .padding(.horizontal, 5)
                                    
                                    Divider().frame(height: 40)
                                    
                                    // Total Profit
                                    let profit = item.amount - extPartnerPrice
                                    Text(String(format: "%.2f", profit))
                                        .font(.system(size: 14))
                                        .foregroundColor(profit > 0 ? .green : .red)
                                        .frame(width: 100, alignment: .trailing)
                                        .padding(.horizontal, 5)
                                    
                                    Divider().frame(height: 40)
                                    
                                    // Custom Tax?
                                    Text("No")
                                        .font(.system(size: 14))
                                        .frame(width: 90, alignment: .center)
                                        .padding(.horizontal, 5)
                                    
                                    Divider().frame(height: 40)
                                    
                                    // Action buttons
                                    HStack(spacing: 15) {
                                        Button(action: {
                                            onEdit(item)
                                        }) {
                                            Image(systemName: "pencil")
                                                .foregroundColor(.blue)
                                        }
                                        
                                        Button(action: {
                                            onDelete(item)
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .frame(width: 60, alignment: .center)
                                }
                                .padding(.vertical, 8)
                            }
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

// Usage in ProposalDetailView:
struct ProductsSection: View {
  
    @ObservedObject var proposal: Proposal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Products")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { /* show item selection */ }) {
                    Label("Add Products", systemImage: "plus")
                        .foregroundColor(.blue)
                }
            }
            
            ProductTableView(
                proposal: proposal,
                onDelete: { item in
                    // Delete item implementation
                },
                onEdit: { item in
                    // Edit item implementation
                }
            )
        }
        .padding(.horizontal)
    }
}
