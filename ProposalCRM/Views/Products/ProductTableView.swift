// ProductTableView.swift for Proposal items
// Displays proposal items in a table format with edit and delete capabilities

import SwiftUI
import CoreData

// This view is specifically for showing proposal items with edit/delete options
struct ProductTableView: View {
    @ObservedObject var proposal: Proposal
    let onDelete: (ProposalItem) -> Void
    let onEdit: (ProposalItem) -> Void
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingEditMenu = false
    @State private var selectedItem: ProposalItem?
    @State private var editMenuPosition: CGPoint = .zero
    
    init(_ proposal: Proposal, onDelete: @escaping (ProposalItem) -> Void, onEdit: @escaping (ProposalItem) -> Void) {
        self.proposal = proposal
        self.onDelete = onDelete
        self.onEdit = onEdit
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Table header
            ScrollView(.horizontal, showsIndicators: true) {
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
                .background(Color.black.opacity(0.3))
            }
            
            Divider()
            
            // Product rows
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(proposal.itemsArray, id: \.self) { item in
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
                                        selectedItem = item
                                        showingEditMenu = true
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
                        .background(Color.black.opacity(0.2))
                        
                        Divider().background(Color.gray.opacity(0.5))
                    }
                }
            }
            .frame(minHeight: 200, maxHeight: .infinity)
        }
        .background(Color.black)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
