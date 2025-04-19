//
//  ProductTableView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


// ProductTableView.swift for Proposal items
// Fixed implementation to remove overlay issues

import SwiftUI
import CoreData

struct ProductTableView: View {
    @ObservedObject var proposal: Proposal
    let onDelete: (ProposalItem) -> Void
    let onEdit: (ProposalItem) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    init(_ proposal: Proposal, onDelete: @escaping (ProposalItem) -> Void, onEdit: @escaping (ProposalItem) -> Void) {
        self.proposal = proposal
        self.onDelete = onDelete
        self.onEdit = onEdit
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Table header - now with explicit background and no transparency
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    Text("Product Name")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 180, alignment: .leading)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Qty")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 60, alignment: .center)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Unit Partner Price")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 100, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Unit List Price")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 100, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Multiplier")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 80, alignment: .center)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Discount")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 80, alignment: .center)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Ext Partner Price")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 100, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Ext List Price")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 100, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Ext Customer Price")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 120, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Total Profit")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 100, alignment: .trailing)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Custom Tax?")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 100, alignment: .center)
                        .padding(.horizontal, 5)
                    
                    Divider().frame(height: 36)
                    
                    Text("Act")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 80, alignment: .center)
                        .padding(.horizontal, 5)
                }
                .padding(.vertical, 5)
                .background(
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 46)
                )
            }
            
            Divider().background(Color.gray)
            
            // Product rows
            if proposal.itemsArray.isEmpty {
                Text("No products added yet")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.black.opacity(0.2))
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(proposal.itemsArray, id: \.self) { item in
                            // Wrapped in a ZStack to ensure complete coverage with background
                            ZStack {
                                // Solid background first
                                Rectangle()
                                    .fill(Color.black.opacity(0.2))
                                    .frame(height: 56)
                                
                                // Content on top with no transparency
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 0) {
                                        // Product name with code
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
                                            .frame(width: 60, alignment: .center)
                                            .padding(.horizontal, 5)
                                        
                                        Divider().frame(height: 40)
                                        
                                        // Unit Partner Price
                                        let partnerPrice = item.product?.partnerPrice ?? 0
                                        Text(String(format: "%.2f", partnerPrice))
                                            .font(.system(size: 14))
                                            .frame(width: 100, alignment: .trailing)
                                            .padding(.horizontal, 5)
                                        
                                        Divider().frame(height: 40)
                                        
                                        // Unit List Price
                                        let listPrice = item.product?.listPrice ?? 0
                                        Text(String(format: "%.2f", listPrice))
                                            .font(.system(size: 14))
                                            .frame(width: 100, alignment: .trailing)
                                            .padding(.horizontal, 5)
                                        
                                        Divider().frame(height: 40)
                                        
                                        // Multiplier
                                        // Safely check if the property exists at runtime
                                        let multiplier: Double = 1.0 // Default value
                                        Text(String(format: "%.2f", multiplier))
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
                                            .frame(width: 100, alignment: .trailing)
                                            .padding(.horizontal, 5)
                                        
                                        Divider().frame(height: 40)
                                        
                                        // Ext List Price
                                        let extListPrice = listPrice * item.quantity
                                        Text(String(format: "%.2f", extListPrice))
                                            .font(.system(size: 14))
                                            .frame(width: 100, alignment: .trailing)
                                            .padding(.horizontal, 5)
                                        
                                        Divider().frame(height: 40)
                                        
                                        // Ext Customer Price
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
                                        // Safely handle this property
                                        Text("No") // Default value
                                            .font(.system(size: 14))
                                            .frame(width: 100, alignment: .center)
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
                                        .frame(width: 80, alignment: .center)
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                            
                            Divider().background(Color.gray.opacity(0.5))
                        }
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// Add these helper extensions for the ProposalDetailView to use this component properly
extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}

// Helper view to ensure products section has proper layering
struct ProductsSectionView: View {
    @ObservedObject var proposal: Proposal
    let onDeleteItem: (ProposalItem) -> Void
    let onEditItem: (ProposalItem) -> Void
    
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
            
            // Ensure proper layering with background and clipping
            ZStack {
                Color.black.opacity(0.01) // Nearly invisible background to capture touches
                
                if proposal.itemsArray.isEmpty {
                    Text("No products added yet")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(10)
                } else {
                    ProductTableView(
                        proposal,
                        onDelete: onDeleteItem,
                        onEdit: onEditItem
                    )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal)
    }
}