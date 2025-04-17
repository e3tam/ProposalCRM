// ProductDetailView.swift
// Detailed view of product with comprehensive information

import SwiftUI
import CoreData

struct ProductDetailView: View {
    @ObservedObject var product: Product
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isEditing = false
    
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
                    
                    Button(action: { isEditing = true }) {
                        Label("Edit", systemImage: "pencil")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                
                // Financial summary card
                VStack(alignment: .leading, spacing: 15) {
                    Text("Financial Overview")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Divider()
                    
                    HStack(spacing: 20) {
                        // Price card
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Price")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(formatPrice(product.listPrice))
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("List Price")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        
                        // Partner Price card
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Cost")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(formatPrice(product.partnerPrice))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Text("Partner Price")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        
                        // Margin card
                        let margin = calculateMargin(product.listPrice, product.partnerPrice)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Margin")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(formatPercent(margin))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(margin >= 20 ? .green : (margin >= 10 ? .orange : .red))
                            
                            Text("Profit Margin")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                
                // Product details table
                VStack(alignment: .leading, spacing: 15) {
                    Text("Product Details")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Divider()
                    
                    // Enhanced table view for product details
                    ProductDetailsTable(product: product)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                
                // Description section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Description")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Divider()
                    
                    Text(product.desc ?? "No description available")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                
                // Usage in proposals section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Usage Statistics")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Divider()
                    
                    // This would be populated with actual data in a real implementation
                    HStack {
                        UsageStatCard(title: "Proposals", value: "0", icon: "doc.text")
                        UsageStatCard(title: "Total Quantity", value: "0", icon: "number")
                        UsageStatCard(title: "Total Revenue", value: "$0.00", icon: "dollarsign.circle")
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Product Details")
        .sheet(isPresented: $isEditing) {
            EditProductView(product: product)
        }
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
    
    private func calculateMargin(_ list: Double, _ partner: Double) -> Double {
        if list <= 0 {
            return 0
        }
        return ((list - partner) / list) * 100
    }
}

struct ProductDetailsTable: View {
    @ObservedObject var product: Product
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Table header
            HStack(spacing: 0) {
                Text("Property")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(width: 120, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                
                Divider()
                    .frame(height: 36)
                
                Text("Value")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
            .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color(UIColor.systemGray5))
            .cornerRadius(8, corners: [.topLeft, .topRight])
            
            Divider()
            
            // Table rows
            Group {
                DetailRow(property: "Product Code", value: product.code ?? "N/A")
                Divider()
                DetailRow(property: "Name", value: product.name ?? "N/A")
                Divider()
                DetailRow(property: "Category", value: product.category ?? "Uncategorized")
                Divider()
                DetailRow(property: "List Price", value: formatPrice(product.listPrice))
                Divider()
                DetailRow(property: "Partner Price", value: formatPrice(product.partnerPrice))
                Divider()
                let profit = product.listPrice - product.partnerPrice
                DetailRow(property: "Profit", value: formatPrice(profit))
                Divider()
                let margin = calculateMargin(product.listPrice, product.partnerPrice)
                DetailRow(property: "Margin", value: formatPercent(margin),
                          valueColor: margin >= 20 ? .green : (margin >= 10 ? .orange : .red))
            }
            .background(colorScheme == .dark ? Color(UIColor.systemGray6).opacity(0.3) : Color.white)
            .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
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
    
    private func calculateMargin(_ list: Double, _ partner: Double) -> Double {
        if list <= 0 {
            return 0
        }
        return ((list - partner) / list) * 100
    }
}

struct DetailRow: View {
    let property: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack(spacing: 0) {
            Text(property)
                .font(.system(size: 14))
                .frame(width: 120, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
            
            Divider()
                .frame(height: 40)
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(valueColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
        }
    }
}

struct UsageStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
    }
}

struct EditProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var product: Product
    
    @State private var code: String
    @State private var name: String
    @State private var productDescription: String
    @State private var category: String
    @State private var listPrice: String
    @State private var partnerPrice: String
    
    init(product: Product) {
        self.product = product
        _code = State(initialValue: product.code ?? "")
        _name = State(initialValue: product.name ?? "")
        _productDescription = State(initialValue: product.desc ?? "")
        _category = State(initialValue: product.category ?? "")
        _listPrice = State(initialValue: String(format: "%.2f", product.listPrice))
        _partnerPrice = State(initialValue: String(format: "%.2f", product.partnerPrice))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Information")) {
                    TextField("Product Code", text: $code)
                        .autocapitalization(.none)
                    
                    TextField("Product Name", text: $name)
                        .autocapitalization(.words)
                    
                    TextField("Description", text: $productDescription)
                    
                    TextField("Category", text: $category)
                        .autocapitalization(.words)
                }
                
                Section(header: Text("Pricing")) {
                    TextField("List Price", text: $listPrice)
                        .keyboardType(.decimalPad)
                    
                    TextField("Partner Price", text: $partnerPrice)
                        .keyboardType(.decimalPad)
                    
                    // Display calculated values
                    HStack {
                        Text("Profit")
                        Spacer()
                        Text(calculateProfit())
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Margin")
                        Spacer()
                        Text(calculateMargin())
                            .foregroundColor(calculateMarginPercent() >= 20 ? .green :
                                            (calculateMarginPercent() >= 10 ? .orange : .red))
                    }
                }
            }
            .navigationTitle("Edit Product")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProduct()
                    }
                    .disabled(code.isEmpty || name.isEmpty || listPrice.isEmpty)
                }
            }
        }
    }
    
    private func calculateProfit() -> String {
        let list = Double(listPrice) ?? 0
        let partner = Double(partnerPrice) ?? 0
        let profit = list - partner
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: profit)) ?? "$\(String(format: "%.2f", profit))"
    }
    
    private func calculateMargin() -> String {
        return String(format: "%.1f%%", calculateMarginPercent())
    }
    
    private func calculateMarginPercent() -> Double {
        let list = Double(listPrice) ?? 0
        let partner = Double(partnerPrice) ?? 0
        
        if list <= 0 {
            return 0
        }
        
        return ((list - partner) / list) * 100
    }
    
    private func saveProduct() {
        product.code = code
        product.name = name
        product.desc = productDescription
        product.category = category
        product.listPrice = Double(listPrice) ?? 0.0
        product.partnerPrice = Double(partnerPrice) ?? 0.0
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            print("Error saving product: \(nsError), \(nsError.userInfo)")
        }
    }
}

// Helper extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
