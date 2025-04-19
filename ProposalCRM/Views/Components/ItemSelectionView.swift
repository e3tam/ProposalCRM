
// ItemSelectionView.swift
// Select products to add to a proposal with enhanced calculations and search functionality

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
                // Search bar - New addition
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search Products", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
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
                                            .lineLimit(1)
                                        
                                        // Show product description if available
                                        if let description = product.desc, !description.isEmpty {
                                            Text(description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        
                                        HStack {
                                            Text(product.formattedCode)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(3)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(4)
                                            
                                            Spacer()
                                            
                                            Text(String(format: "%.2f", product.listPrice))
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                                                                        if isSelected(product) {
                                HStack {
                                    Text("Qty:")
                                        .foregroundColor(.secondary)
                                        
                                    // Number input field for quantity
                                    TextField("1",
                                        text: Binding(
                                            get: { String(format: "%d", Int(self.quantities[product.id!] ?? 1)) },
                                            set: { if let value = Double($0), value >= 1 && value <= 100 {
                                                self.quantities[product.id!] = value
                                            }}
                                        )
                                    )
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 50)
                                    .padding(4)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)
                                    
                                    // Keep the stepper for easy adjustment
                                    Stepper("",
                                        value: Binding(
                                            get: { self.quantities[product.id!] ?? 1 },
                                            set: { self.quantities[product.id!] = $0 }
                                        ),
                                        in: 1...100
                                    )
                                }
                                .frame(width: 150)
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
                                        // Enhanced product name and description display
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(product.formattedName)
                                                .font(.headline)
                                                .fontWeight(.bold)
                                            
                                            if let description = product.desc, !description.isEmpty {
                                                Text(description)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(2)
                                                    .padding(.bottom, 2)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        HStack {
                                            Text("Qty:")
                                                .font(.body)
                                                .foregroundColor(.secondary)
                                            
                                            // Number entry for quantity
                                            TextField("1",
                                                text: Binding(
                                                    get: { String(format: "%d", Int(self.quantities[product.id!] ?? 1)) },
                                                    set: { if let value = Double($0), value >= 1 && value <= 100 {
                                                        self.quantities[product.id!] = value
                                                    }}
                                                )
                                            )
                                            .keyboardType(.numberPad)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 50)
                                            .padding(4)
                                            .background(Color(UIColor.secondarySystemBackground))
                                            .cornerRadius(8)
                                            
                                            Spacer()
                                            
                                            Text(product.formattedCode)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(3)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(4)
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
                                        
                                        // Multiplier as number entry box instead of slider
                                        HStack {
                                            Text("Multiplier:")
                                            
                                            Spacer()
                                            
                                            // Number entry box for multiplier
                                            HStack {
                                                TextField("1.00",
                                                    text: Binding(
                                                        get: { String(format: "%.2f", self.multipliers[product.id!] ?? 1.0) },
                                                        set: { if let value = Double($0), value >= 0.5 && value <= 2.0 {
                                                            self.multipliers[product.id!] = value
                                                        }}
                                                    )
                                                )
                                                .keyboardType(.decimalPad)
                                                .multilineTextAlignment(.trailing)
                                                .frame(width: 80)
                                                .padding(6)
                                                .background(Color(UIColor.secondarySystemBackground))
                                                .cornerRadius(8)
                                                
                                                Text("x")
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        // Custom description field
                                        VStack(alignment: .leading) {
                                            Text("Custom Description:")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            TextField("Enter custom description", text: Binding(
                                                get: { self.customDescriptions[product.id!] ?? "" },
                                                set: { self.customDescriptions[product.id!] = $0 }
                                            ))
                                            .padding(8)
                                            .background(Color(UIColor.secondarySystemBackground))
                                            .cornerRadius(8)
                                        }
                                        
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
            
            // Log the activity of adding a product
            ActivityLogger.logItemAdded(
                proposal: proposal,
                context: viewContext,
                itemType: "Product",
                itemName: product.name ?? "Unknown"
            )
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
