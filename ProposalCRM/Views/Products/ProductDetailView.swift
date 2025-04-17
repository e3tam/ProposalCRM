//
//  ProductDetailView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 17.04.2025.
//


// ProductDetailView.swift
// Detailed view of product with comprehensive information

import SwiftUI
import CoreData

struct ProductDetailView: View {
    @ObservedObject var product: Product
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Product header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.name ?? "Unknown Product")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(product.code ?? "No Code")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Price display
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("List: \(formatPrice(product.listPrice))")
                            .font(.headline)
                        
                        Text("Partner: \(formatPrice(product.partnerPrice))")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        let discount = calculateDiscount(list: product.listPrice, partner: product.partnerPrice)
                        Text("Discount: \(formatPercent(discount))")
                            .font(.subheadline)
                            .foregroundColor(discount > 0 ? .green : .red)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                
                // Product details
                VStack(alignment: .leading, spacing: 15) {
                    Text("Product Details")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Divider()
                    
                    DetailRow(title: "Category", value: product.category ?? "Uncategorized")
                    
                    DetailRow(title: "Description", value: product.desc ?? "No description available")
                        .frame(minHeight: 60)
                    
                    Divider()
                    
                    Text("Financial Information")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    let profit = product.listPrice - product.partnerPrice
                    let marginPercent = product.listPrice > 0 ? (profit / product.listPrice) * 100 : 0
                    
                    DetailRow(title: "List Price", value: formatPrice(product.listPrice))
                    DetailRow(title: "Partner Price", value: formatPrice(product.partnerPrice))
                    DetailRow(title: "Profit", value: formatPrice(profit))
                    DetailRow(title: "Margin", value: formatPercent(marginPercent))
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                
                // Usage statistics (placeholder for future implementation)
                VStack(alignment: .leading, spacing: 15) {
                    Text("Usage Statistics")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Divider()
                    
                    Text("This product has been used in 0 proposals")
                        .foregroundColor(.secondary)
                    
                    // Placeholder for future implementation
                    Text("No usage data available yet")
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Product Details")
    }
    
    private func formatPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$\(String(format: "%.2f", value))"
    }
    
    private func formatPercent(_ value: Double) -> String {
        return String(format: "%.1f%%", value)
    }
    
    private func calculateDiscount(list: Double, partner: Double) -> Double {
        if list <= 0 {
            return 0
        }
        return ((list - partner) / list) * 100
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}