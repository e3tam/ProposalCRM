// ProductListView.swift
// Enhanced version with detailed table view for products

import SwiftUI
import CoreData

struct ProductListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default)
    private var products: FetchedResults<Product>
    
    @State private var searchText = ""
    @State private var showingAddProduct = false
    @State private var showingImportCSV = false
    @State private var selectedCategory: String? = nil
    @State private var isTableView = true // Toggle between list and table view
    
    var categories: [String] {
        let categorySet = Set(products.compactMap { $0.category })
        return Array(categorySet).sorted()
    }
    
    var body: some View {
        VStack {
            // View type toggle
            Picker("View Type", selection: $isTableView) {
                Text("List View").tag(false)
                Text("Table View").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if products.isEmpty {
                VStack(spacing: 20) {
                    Text("No Products Available")
                        .font(.title)
                        .foregroundColor(.secondary)
                    
                    Text("Import products from CSV or add them manually")
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        Button(action: { showingImportCSV = true }) {
                            Label("Import CSV", systemImage: "square.and.arrow.down")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { showingAddProduct = true }) {
                            Label("Add Product", systemImage: "plus")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            } else {
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
                    
                    if isTableView {
                        // TABLE VIEW (new detailed view)
                        ProductTableView(products: filteredProducts)
                    } else {
                        // STANDARD LIST VIEW
                        List {
                            ForEach(filteredProducts, id: \.self) { product in
                                NavigationLink(destination: ProductDetailView(product: product)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(product.formattedCode)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            Text(product.category ?? "Uncategorized")
                                                .font(.caption)
                                                .padding(4)
                                                .background(Color.gray.opacity(0.2))
                                                .cornerRadius(4)
                                        }
                                        
                                        Text(product.formattedName)
                                            .font(.headline)
                                        
                                        Text(product.desc ?? "")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                        
                                        HStack {
                                            Text("List: \(product.formattedPrice)")
                                                .font(.subheadline)
                                            
                                            Spacer()
                                            
                                            Text("Partner: \(String(format: "%.2f", product.partnerPrice))")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .onDelete(perform: deleteProducts)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search Products")
        .navigationTitle("Products (\(products.count))")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingAddProduct = true }) {
                        Label("Add Product", systemImage: "plus")
                    }
                    
                    Button(action: { showingImportCSV = true }) {
                        Label("Import CSV", systemImage: "square.and.arrow.down")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddProduct) {
            AddProductView()
        }
        .sheet(isPresented: $showingImportCSV) {
            ProductImportView()
        }
    }
    
    private var filteredProducts: [Product] {
        var filtered = Array(products)
        
        // Apply category filter if selected
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter { product in
                (product.code?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (product.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (product.desc?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (product.category?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return filtered
    }
    
    private func deleteProducts(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredProducts[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting product: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ProductTableView: View {
    let products: [Product]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Table header
            HStack(spacing: 0) {
                Text("Code")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 90, alignment: .leading)
                    .padding(.horizontal, 5)
                
                Divider().frame(height: 30)
                
                Text("Name")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 150, alignment: .leading)
                    .padding(.horizontal, 5)
                
                Divider().frame(height: 30)
                
                Text("Category")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 100, alignment: .leading)
                    .padding(.horizontal, 5)
                
                Divider().frame(height: 30)
                
                Text("List Price")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 80, alignment: .trailing)
                    .padding(.horizontal, 5)
                
                Divider().frame(height: 30)
                
                Text("Partner")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 80, alignment: .trailing)
                    .padding(.horizontal, 5)
                
                Divider().frame(height: 30)
                
                Text("Margin")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 70, alignment: .trailing)
                    .padding(.horizontal, 5)
            }
            .padding(.vertical, 10)
            .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color(UIColor.systemGray5))
            
            Divider()
            
            // Table rows in scrolling list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(products, id: \.self) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            HStack(spacing: 0) {
                                Text(product.code ?? "")
                                    .font(.system(size: 14))
                                    .frame(width: 90, alignment: .leading)
                                    .padding(.horizontal, 5)
                                    .lineLimit(1)
                                
                                Divider().frame(height: 40)
                                
                                Text(product.name ?? "")
                                    .font(.system(size: 14))
                                    .frame(width: 150, alignment: .leading)
                                    .padding(.horizontal, 5)
                                    .lineLimit(1)
                                
                                Divider().frame(height: 40)
                                
                                Text(product.category ?? "")
                                    .font(.system(size: 14))
                                    .frame(width: 100, alignment: .leading)
                                    .padding(.horizontal, 5)
                                    .lineLimit(1)
                                
                                Divider().frame(height: 40)
                                
                                Text(formatPrice(product.listPrice))
                                    .font(.system(size: 14))
                                    .frame(width: 80, alignment: .trailing)
                                    .padding(.horizontal, 5)
                                
                                Divider().frame(height: 40)
                                
                                Text(formatPrice(product.partnerPrice))
                                    .font(.system(size: 14))
                                    .frame(width: 80, alignment: .trailing)
                                    .padding(.horizontal, 5)
                                
                                Divider().frame(height: 40)
                                
                                let margin = calculateMargin(product.listPrice, product.partnerPrice)
                                Text(String(format: "%.1f%%", margin))
                                    .font(.system(size: 14))
                                    .frame(width: 70, alignment: .trailing)
                                    .padding(.horizontal, 5)
                                    .foregroundColor(margin >= 20 ? .green : (margin >= 10 ? .orange : .red))
                            }
                            .padding(.vertical, 8)
                            .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                    }
                }
            }
        }
        .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color.white)
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private func formatPrice(_ value: Double) -> String {
        return String(format: "$%.2f", value)
    }
    
    private func calculateMargin(_ list: Double, _ partner: Double) -> Double {
        return list > 0 ? ((list - partner) / list) * 100 : 0
    }
}
