// AddProductView.swift
// Form for adding a new product

import SwiftUI

struct AddProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var code = ""
    @State private var name = ""
    @State private var productDescription = ""
    @State private var category = ""
    @State private var listPrice = ""
    @State private var partnerPrice = ""
    
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
                }
            }
            .navigationTitle("New Product")
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
    
    private func saveProduct() {
        let product = Product(context: viewContext)
        product.id = UUID()
        product.code = code
        product.name = name
        product.description = productDescription
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
