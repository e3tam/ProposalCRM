//
//  ItemSelectionView.swift
//  ProposalCRM
//

import SwiftUI
import CoreData

struct ItemSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var proposal: Proposal
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default
    )
    private var products: FetchedResults<Product>
    
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var selectedProducts: [Product] = []
    @State private var quantities: [UUID: Double] = [:]
    @State private var discounts: [UUID: Double] = [:]
    
    var categories: [String] {
        let categorySet = Set(products.compactMap { $0.category })
        return Array(categorySet).sorted()
    }
    
    var filteredProducts: [Product] {
        var result = Array(products)
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            result = result.filter { product in
                let nameMatch = product.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let codeMatch = product.code?.localizedCaseInsensitiveContains(searchText) ?? false
                return nameMatch || codeMatch
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search Products", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button(action: { selectedCategory = nil }) {
                            Text("All")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedCategory == nil ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCategory == nil ? .white : .primary)
                                .cornerRadius(12)
                        }
                        
                        ForEach(categories, id: \.self) { category in
                            Button(action: { selectedCategory = category }) {
                                Text(category)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Product list
                List {
                    ForEach(filteredProducts, id: \.self) { product in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.name ?? "")
                                    .font(.headline)
                                
                                Text(product.code ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(String(format: "%.2f", product.listPrice))
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            if selectedProducts.contains(product) {
                                VStack(alignment: .trailing) {
                                    TextField("Qty", value: quantityBinding(for: product), format: .number)
                                        .keyboardType(.decimalPad)
                                        .frame(width: 50)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Picker("Discount", selection: discountBinding(for: product)) {
                                        ForEach([0, 5, 10, 15, 20, 25, 30], id: \.self) { discount in
                                            Text("\(discount)%").tag(Double(discount))
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                }
                            }
                            
                            Button(action: {
                                toggleProduct(product)
                            }) {
                                Image(systemName: selectedProducts.contains(product) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Selected") {
                        addSelectedProducts()
                    }
                    .disabled(selectedProducts.isEmpty)
                }
            }
        }
    }
    
    private func toggleProduct(_ product: Product) {
        if let index = selectedProducts.firstIndex(of: product) {
            selectedProducts.remove(at: index)
            quantities[product.id ?? UUID()] = nil
            discounts[product.id ?? UUID()] = nil
        } else {
            selectedProducts.append(product)
            quantities[product.id ?? UUID()] = 1
            discounts[product.id ?? UUID()] = 0
        }
    }
    
    private func quantityBinding(for product: Product) -> Binding<Double> {
        Binding(
            get: { quantities[product.id ?? UUID()] ?? 1 },
            set: { quantities[product.id ?? UUID()] = max(1, $0) }
        )
    }
    
    private func discountBinding(for product: Product) -> Binding<Double> {
        Binding(
            get: { discounts[product.id ?? UUID()] ?? 0 },
            set: { discounts[product.id ?? UUID()] = $0 }
        )
    }
    
    private func addSelectedProducts() {
        for product in selectedProducts {
            let quantity = quantities[product.id ?? UUID()] ?? 1
            let discount = discounts[product.id ?? UUID()] ?? 0
            
            let proposalItem = ProposalItem(context: viewContext)
            proposalItem.id = UUID()
            proposalItem.product = product
            proposalItem.proposal = proposal
            proposalItem.quantity = quantity
            proposalItem.discount = discount
            proposalItem.unitPrice = product.listPrice * (1 - discount/100)
            proposalItem.amount = proposalItem.unitPrice * quantity
            
            // Log activity
            ActivityLogger.logItemAdded(
                proposal: proposal,
                context: viewContext,
                itemType: "Product",
                itemName: product.name ?? "Unknown"
            )
        }
        
        do {
            try viewContext.save()
            
            // Update proposal totals
            let productsTotal = proposal.subtotalProducts
            let engineeringTotal = proposal.subtotalEngineering
            let expensesTotal = proposal.subtotalExpenses
            let taxesTotal = proposal.subtotalTaxes
            
            proposal.totalAmount = productsTotal + engineeringTotal + expensesTotal + taxesTotal
            
            try viewContext.save()
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving selected products: \(error)")
        }
    }
}
