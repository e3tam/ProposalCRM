// ProductTableView.swift
// Broken into smaller components to prevent compiler type-checking issues

import SwiftUI
import CoreData

// MARK: - Main Table View
struct ProductTableView: View {
    @ObservedObject var proposal: Proposal
    let onDelete: (ProposalItem) -> Void
    let onEdit: (ProposalItem) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Table header
            ProductTableHeader()
            
            Divider().background(Color.gray)
            
            // Main table content with rows
            if proposal.itemsArray.isEmpty {
                EmptyProductsView()
            } else {
                ProductRowsView(
                    proposal: proposal,
                    onDelete: onDelete,
                    onEdit: onEdit
                )
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

// MARK: - Empty State View
struct EmptyProductsView: View {
    var body: some View {
        Text("No products added yet")
            .foregroundColor(.gray)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.2))
    }
}

// MARK: - Table Header
struct ProductTableHeader: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 0) {
                // Product Name
                HeaderCell(title: "Product Name", width: 180, alignment: .leading)
                VerticalDivider()
                
                // Qty
                HeaderCell(title: "Qty", width: 50, alignment: .center)
                VerticalDivider()
                
                // Unit Partner Price
                HeaderCell(title: "Unit Partner Price", width: 120, alignment: .trailing)
                VerticalDivider()
                
                // Unit List Price
                HeaderCell(title: "Unit List Price", width: 120, alignment: .trailing)
                VerticalDivider()
                
                // Multiplier
                HeaderCell(title: "Multiplier", width: 80, alignment: .center)
                VerticalDivider()
                
                // Discount
                HeaderCell(title: "Discount", width: 80, alignment: .center)
                VerticalDivider()
                
                // Ext Partner Price
                HeaderCell(title: "Ext Partner Price", width: 120, alignment: .trailing)
                VerticalDivider()
                
                // Ext List Price
                HeaderCell(title: "Ext List Price", width: 120, alignment: .trailing)
                VerticalDivider()
                
                // Ext Customer Price
                HeaderCell(title: "Ext Customer Price", width: 120, alignment: .trailing)
                VerticalDivider()
                
                // Total Profit
                HeaderCell(title: "Total Profit", width: 100, alignment: .trailing)
                VerticalDivider()
                
                // Custom Tax?
                HeaderCell(title: "Custom Tax?", width: 90, alignment: .center)
                VerticalDivider()
                
                // Actions
                HeaderCell(title: "Act", width: 60, alignment: .center)
            }
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.3))
        }
    }
}

// MARK: - Product Rows View
struct ProductRowsView: View {
    @ObservedObject var proposal: Proposal
    let onDelete: (ProposalItem) -> Void
    let onEdit: (ProposalItem) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(proposal.itemsArray, id: \.self) { item in
                    ProductRow(
                        item: item,
                        onDelete: onDelete,
                        onEdit: onEdit
                    )
                    
                    Divider().background(Color.gray.opacity(0.5))
                }
            }
        }
    }
}

// MARK: - Individual Product Row
struct ProductRow: View {
    let item: ProposalItem
    let onDelete: (ProposalItem) -> Void
    let onEdit: (ProposalItem) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 0) {
                // Product Name with code
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.productName)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    if let code = item.product?.code, !code.isEmpty {
                        Text(code)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 180, alignment: .leading)
                .padding(.horizontal, 5)
                
                VerticalDivider()
                
                // Quantity
                Text("\(Int(item.quantity))")
                    .font(.system(size: 14))
                    .frame(width: 50, alignment: .center)
                    .padding(.horizontal, 5)
                
                VerticalDivider()
                
                // Unit Partner Price
                let partnerPrice = item.product?.partnerPrice ?? 0
                Text(formatEuro(partnerPrice))
                    .font(.system(size: 14))
                    .frame(width: 120, alignment: .trailing)
                    .padding(.horizontal, 5)
                
                VerticalDivider()
                
                // Unit List Price
                let listPrice = item.product?.listPrice ?? 0
                Text(formatEuro(listPrice))
                    .font(.system(size: 14))
                    .frame(width: 120, alignment: .trailing)
                    .padding(.horizontal, 5)
                
                VerticalDivider()
                
                // Multiplier (calculate or use default 1.00)
                let multiplier = calculateMultiplier(item: item)
                Text(String(format: "%.2f", multiplier))
                    .font(.system(size: 14))
                    .frame(width: 80, alignment: .center)
                    .padding(.horizontal, 5)
                
                VerticalDivider()
                
                // Discount
                Text(String(format: "%.1f%%", item.discount))
                    .font(.system(size: 14))
                    .frame(width: 80, alignment: .center)
                    .padding(.horizontal, 5)
                
                VerticalDivider()
                
                // Ext Partner Price
                let extPartnerPrice = partnerPrice * item.quantity
                Text(formatEuro(extPartnerPrice))
                    .font(.system(size: 14))
                    .frame(width: 120, alignment: .trailing)
                    .padding(.horizontal, 5)
                
                VerticalDivider()
                
                // Ext List Price
                let extListPrice = listPrice * item.quantity
                Text(formatEuro(extListPrice))
                    .font(.system(size: 14))
                    .frame(width: 120, alignment: .trailing)
                    .padding(.horizontal, 5)
                
                VerticalDivider()
                
                // Ext Customer Price (amount)
                Text(formatEuro(item.amount))
                    .font(.system(size: 14))
                    .frame(width: 120, alignment: .trailing)
                    .padding(.horizontal, 5)
                
                VerticalDivider()
                
                // Total Profit
                let profit = item.amount - extPartnerPrice
                Text(formatEuro(profit))
                    .font(.system(size: 14))
                    .foregroundColor(profit > 0 ? .green : .red)
                    .frame(width: 100, alignment: .trailing)
                    .padding(.horizontal, 5)
                
                VerticalDivider()
                
                // Custom Tax?
                Text("No")
                    .font(.system(size: 14))
                    .frame(width: 90, alignment: .center)
                    .padding(.horizontal, 5)
                
                VerticalDivider()
                
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
            .background(Color.black.opacity(0.2))
        }
    }
    
    // Helper function to calculate multiplier
    private func calculateMultiplier(item: ProposalItem) -> Double {
        let listPrice = item.product?.listPrice ?? 1.0
        let discountFactor = 1.0 - (item.discount / 100.0)
        
        if listPrice > 0 && discountFactor > 0 {
            return item.unitPrice / (listPrice * discountFactor)
        }
        return 1.0
    }
    
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
}

// MARK: - Reusable Components

struct HeaderCell: View {
    let title: String
    let width: CGFloat
    let alignment: Alignment
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.bold)
            .frame(width: width, alignment: alignment)
            .padding(.horizontal, 5)
    }
}

struct VerticalDivider: View {
    var body: some View {
        Divider().frame(height: 36)
    }
}

// MARK: - Helper Extension
extension NumberFormatter {
    static var euroFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
}
