// ItemSelectionView.swift
// Select products to add to a proposal with enhanced calculations

import SwiftUI
import CoreData

struct ItemSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var proposal: Proposal
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default)
    private var products: FetchedResults<Product>
    
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var selectedProducts: Set<UUID> = []
    @State private var quantities: [UUID: Double] = [:]
    @State private var discounts: [UUID: Double] = [:]
    @State private var multipliers: [UUID: Double] = [:]
    @State private var applyCustomTax: [UUID: Bool] = [:]
    @State private var customDescriptions: [UUID: String] = [:]
    
    var categories: [String] {
        let categorySet = Set(products.compactMap { $0.category })
        return Array(categorySet).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button(action: { selectedCategory = nil }) {
                            Text("All")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedCategory == nil ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCategory == nil ? .white : .primary)
                                .cornerRadius(20)
                        }
                        
                        ForEach(categories, id: \.self) { category in
                            Button(action: { selectedCategory = category }) {
                                Text(category)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                List {
                    ForEach(filteredProducts, id: \.self) { product in
                        HStack {
                            Button(action: {
                                toggleProductSelection(product)
                            }) {
                                HStack {
                                    Image(systemName: isSelected(product) ? "checkmark.square.fill" : "square")
                                        .foregroundColor(isSelected(product) ? .blue : .gray)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.formattedName)
                                            .font(.headline)
                                        
                                        HStack {
                                            Text(product.formattedCode)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            Text(String(format: "%.2f", product.listPrice))
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if isSelected(product) {
                                Stepper(
                                    value: Binding(
                                        get: { self.quantities[product.id!] ?? 1 },
                                        set: { self.quantities[product.id!] = $0 }
                                    ),
                                    in: 1...100
                                ) {
                                    Text("\(Int(quantities[product.id!] ?? 1))")
                                        .frame(minWidth: 30)
                                }
                                .frame(width: 120)
                            }
                        }
                    }
                }
                
                // Selected products
                if !selectedProducts.isEmpty {
                    VStack {
                        Text("Selected Products (\(selectedProducts.count))")
                            .font(.headline)
                            .padding(.top)
                        
                        Divider()
                        
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(selectedProductsArray(), id: \.self) { product in
                                    VStack {
                                        HStack {
                                            Text(product.formattedName)
                                                .font(.headline)
                                            
                                            Spacer()
                                            
                                            Text("Qty: \(Int(quantities[product.id!] ?? 1))")
                                        }
                                        
                                        HStack {
                                            Text("Discount %:")
                                            
                                            Slider(
                                                value: Binding(
                                                    get: { self.discounts[product.id!] ?? 0 },
                                                    set: { self.discounts[product.id!] = $0 }
                                                ),
                                                in: 0...50,
                                                step: 1
                                            )
                                            
                                            Text("\(Int(discounts[product.id!] ?? 0))%")
                                                .frame(width: 50, alignment: .trailing)
                                        }
                                        
                                        // New multiplier field
                                        HStack {
                                            Text("Multiplier:")
                                            
                                            Slider(
                                                value: Binding(
                                                    get: { self.multipliers[product.id!] ?? 1.0 },
                                                    set: { self.multipliers[product.id!] = $0 }
                                                ),
                                                in: 0.5...2,
                                                step: 0.05
                                            )
                                            
                                            Text("\(String(format: "%.2f", multipliers[product.id!] ?? 1.0))x")
                                                .frame(width: 50, alignment: .trailing)
                                        }
                                        
                                        // New custom description field
                                        TextField("Custom Description", text: Binding(
                                            get: { self.customDescriptions[product.id!] ?? "" },
                                            set: { self.customDescriptions[product.id!] = $0 }
                                        ))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.vertical, 4)
                                        
                                        // New custom tax checkbox
                                        Toggle("Apply Custom Tax", isOn: Binding(
                                            get: { self.applyCustomTax[product.id!] ?? false },
                                            set: { self.applyCustomTax[product.id!] = $0 }
                                        ))
                                        
                                        Divider()
                                        
                                        // Pricing summary
                                        Group {
                                            HStack {
                                                Text("Unit List: \(String(format: "%.2f", product.listPrice))")
                                                    .font(.subheadline)
                                                
                                                Spacer()
                                                
                                                Text("Unit Partner: \(String(format: "%.2f", product.partnerPrice))")
                                                    .font(.subheadline)
                                                    .foregroundColor(.blue)
                                            }
                                            
                                            HStack {
                                                Text("Extended List: \(String(format: "%.2f", calculateExtendedListPrice(for: product)))")
                                                    .font(.subheadline)
                                                
                                                Spacer()
                                                
                                                Text("Extended Partner: \(String(format: "%.2f", calculateExtendedPartnerPrice(for: product)))")
                                                    .font(.subheadline)
                                                    .foregroundColor(.blue)
                                            }
                                            
                                            HStack {
                                                Text("Customer Price: \(String(format: "%.2f", calculateExtendedCustomerPrice(for: product)))")
                                                    .font(.headline)
                                                
                                                Spacer()
                                                
                                                Text("Profit: \(String(format: "%.2f", calculateTotalProfit(for: product)))")
                                                    .font(.headline)
                                                    .foregroundColor(calculateTotalProfit(for: product) > 0 ? .green : .red)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 300)
                        
                        // Summary and add button
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total: \(String(format: "%.2f", calculateGrandTotalCustomerPrice()))")
                                    .font(.headline)
                                
                                Text("\(selectedProducts.count) products, \(calculateTotalQuantity()) items")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                addItemsToProposal()
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Add to Proposal")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                }
            }
            .searchable(text: $searchText, prompt: "Search Products")
            .navigationTitle("Select Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var filteredProducts: [Product] {
        // Start with converting FetchedResults to Array
        var filtered = Array(products)
        
        // Apply category filter if selected
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter { product in
                // Handle optional strings properly without optional chaining on non-optional strings
                let codeMatch = product.code != nil ? product.code!.localizedCaseInsensitiveContains(searchText) : false
                let nameMatch = product.name != nil ? product.name!.localizedCaseInsensitiveContains(searchText) : false
                let descMatch = product.desc != nil ? product.desc!.localizedCaseInsensitiveContains(searchText) : false
                
                return codeMatch || nameMatch || descMatch
            }
        }
        
        return filtered
    }
    
    private func toggleProductSelection(_ product: Product) {
        if let id = product.id {
            if selectedProducts.contains(id) {
                selectedProducts.remove(id)
            } else {
                selectedProducts.insert(id)
                if quantities[id] == nil {
                    quantities[id] = 1
                }
                if discounts[id] == nil {
                    discounts[id] = 0
                }
                if multipliers[id] == nil {
                    multipliers[id] = 1.0
                }
                if applyCustomTax[id] == nil {
                    applyCustomTax[id] = false
                }
                if customDescriptions[id] == nil {
                    customDescriptions[id] = ""
                }
            }
        }
    }
    
    private func isSelected(_ product: Product) -> Bool {
        if let id = product.id {
            return selectedProducts.contains(id)
        }
        return false
    }
    
    private func selectedProductsArray() -> [Product] {
        return Array(products).filter { product in
            if let id = product.id {
                return selectedProducts.contains(id)
            }
            return false
        }
    }
    
    // Calculate extended partner price (unit partner price * quantity)
    private func calculateExtendedPartnerPrice(for product: Product) -> Double {
        guard let id = product.id else { return 0 }
        let quantity = quantities[id] ?? 1
        return product.partnerPrice * quantity
    }
    
    // Calculate extended list price (unit list price * quantity)
    private func calculateExtendedListPrice(for product: Product) -> Double {
        guard let id = product.id else { return 0 }
        let quantity = quantities[id] ?? 1
        return product.listPrice * quantity
    }
    
    // Calculate extended customer price (extended list price * multiplier)
    private func calculateExtendedCustomerPrice(for product: Product) -> Double {
        guard let id = product.id else { return 0 }
        let extendedListPrice = calculateExtendedListPrice(for: product)
        let multiplier = multipliers[id] ?? 1.0
        let discount = discounts[id] ?? 0
        return extendedListPrice * multiplier * (1 - discount / 100)
    }
    
    // Calculate total profit (extended customer price - extended partner price)
    private func calculateTotalProfit(for product: Product) -> Double {
        let extendedCustomerPrice = calculateExtendedCustomerPrice(for: product)
        let extendedPartnerPrice = calculateExtendedPartnerPrice(for: product)
        return extendedCustomerPrice - extendedPartnerPrice
    }
    
    // Calculate grand total for customer price
    private func calculateGrandTotalCustomerPrice() -> Double {
        let selectedProducts = selectedProductsArray()
        return selectedProducts.reduce(0) { total, product in
            return total + calculateExtendedCustomerPrice(for: product)
        }
    }
    
    private func calculateTotalQuantity() -> Int {
        return selectedProducts.reduce(0) { total, id in
            return total + Int(quantities[id] ?? 1)
        }
    }
    
    // COMPLETELY FIXED VERSION - No dynamic property access at all for ProposalItem
    private func addItemsToProposal() {
        for product in selectedProductsArray() {
            guard let productId = product.id else { continue }
            
            let quantity = quantities[productId] ?? 1
            let discount = discounts[productId] ?? 0
            
            // Calculate the final unit price with discount
            let unitPrice = product.listPrice * (1 - discount / 100)
            
            // Calculate the extended amount
            let amount = unitPrice * quantity
            
            // Create proposal item with ONLY the standard attributes
            let proposalItem = ProposalItem(context: viewContext)
            proposalItem.id = UUID()
            proposalItem.product = product
            proposalItem.proposal = proposal
            proposalItem.quantity = quantity
            proposalItem.unitPrice = unitPrice
            proposalItem.discount = discount
            proposalItem.amount = amount
            
            // DO NOT use any setValue or value(forKey) methods here
            // We will use only the properties that already exist in the model
        }
        
        do {
            try viewContext.save()
            
            // Update proposal total
            updateProposalTotal()
        } catch {
            let nsError = error as NSError
            print("Error adding items to proposal: \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func updateProposalTotal() {
        // Calculate total amount
        let productsTotal = proposal.subtotalProducts
        let engineeringTotal = proposal.subtotalEngineering
        let expensesTotal = proposal.subtotalExpenses
        let taxesTotal = proposal.subtotalTaxes
        
        proposal.totalAmount = productsTotal + engineeringTotal + expensesTotal + taxesTotal
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error updating proposal total: \(nsError), \(nsError.userInfo)")
        }
    }
}
