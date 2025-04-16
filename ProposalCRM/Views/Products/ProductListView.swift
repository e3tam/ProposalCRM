// ProductListView.swift
// Displays a list of products with search and filter capabilities

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
    
    var categories: [String] {
        let categorySet = Set(products.compactMap { $0.category })
        return Array(categorySet).sorted()
    }
    
    var body: some View {
        VStack {
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
                    
                    List {
                        ForEach(filteredProducts, id: \.self) { product in
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
                        .onDelete(perform: deleteProducts)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search Products")
        .navigationTitle("Products")
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
    
    // Fix: Convert FetchedResults to Array immediately, then apply filters
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
                product.code?.localizedCaseInsensitiveContains(searchText) ?? false ||
                product.name?.localizedCaseInsensitiveContains(searchText) ?? false ||
                product.desc?.localizedCaseInsensitiveContains(searchText) ?? false
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
