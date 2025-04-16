// ProductImportView.swift
// Import products from CSV files

import SwiftUI
import UniformTypeIdentifiers

struct ProductImportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isImporting = false
    @State private var importedCSVString: String?
    @State private var importedProducts: [CSVProduct] = []
    @State private var showPreview = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var isImportingData = false
    
    struct CSVProduct: Identifiable {
        let id = UUID()
        let code: String
        let name: String
        let description: String
        let category: String
        let listPrice: Double
        let partnerPrice: Double
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if importedCSVString == nil {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Import Products from CSV")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("The CSV file should have headers and the following columns:\ncode,name,description,category,listPrice,partnerPrice")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button(action: {
                            isImporting = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Select CSV File")
                            }
                            .frame(minWidth: 200)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                } else if showPreview {
                    VStack {
                        // Preview header
                        HStack {
                            Text("Products to Import: \(importedProducts.count)")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                importedCSVString = nil
                                importedProducts = []
                                showPreview = false
                            }) {
                                Text("Cancel")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Products preview
                        List {
                            ForEach(importedProducts) { product in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(product.code)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Text(product.category)
                                            .font(.caption)
                                            .padding(4)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                    
                                    Text(product.name)
                                        .font(.headline)
                                    
                                    Text(product.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    
                                    HStack {
                                        Text("List: \(String(format: "%.2f", product.listPrice))")
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
                        
                        // Import button
                        Button(action: {
                            isImportingData = true
                            saveImportedProducts()
                        }) {
                            if isImportingData {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Import \(importedProducts.count) Products")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .disabled(isImportingData)
                        .padding()
                    }
                }
            }
            .navigationTitle("Import Products")
            .sheet(isPresented: $isImporting) {
                DocumentPicker(importedCSVString: $importedCSVString, errorMessage: $errorMessage)
                    .onDisappear {
                        if let csvString = importedCSVString {
                            parseCSV(csvString)
                        }
                    }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Import Error"),
                    message: Text(errorMessage ?? "Unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func parseCSV(_ csvString: String) {
        // Simple CSV parsing logic
        let rows = csvString.components(separatedBy: .newlines)
        guard rows.count > 1 else {
            errorMessage = "CSV file is empty or invalid"
            showError = true
            return
        }
        
        // Check header row
        let headerRow = rows[0].components(separatedBy: ",")
        let expectedHeaders = ["code", "name", "description", "category", "listPrice", "partnerPrice"]
        
        // Simple header validation (in a real app, would be more robust)
        if !headerRow.map({ $0.lowercased() }).containsAll(elements: expectedHeaders) {
            errorMessage = "CSV headers do not match expected format"
            showError = true
            return
        }
        
        // Parse data rows
        importedProducts = []
        for i in 1..<rows.count {
            let row = rows[i]
            if row.isEmpty { continue }
            
            let columns = row.components(separatedBy: ",")
            if columns.count >= 6 {
                // Basic error handling for number parsing
                let listPrice = Double(columns[4].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
                let partnerPrice = Double(columns[5].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
                
                let product = CSVProduct(
                    code: columns[0].trimmingCharacters(in: .whitespacesAndNewlines),
                    name: columns[1].trimmingCharacters(in: .whitespacesAndNewlines),
                    description: columns[2].trimmingCharacters(in: .whitespacesAndNewlines),
                    category: columns[3].trimmingCharacters(in: .whitespacesAndNewlines),
                    listPrice: listPrice,
                    partnerPrice: partnerPrice
                )
                importedProducts.append(product)
            }
        }
        
        showPreview = true
    }
    
    private func saveImportedProducts() {
        for csvProduct in importedProducts {
            let product = Product(context: viewContext)
            product.id = UUID()
            product.code = csvProduct.code
            product.name = csvProduct.name
            product.desc = csvProduct.description
            product.category = csvProduct.category
            product.listPrice = csvProduct.listPrice
            product.partnerPrice = csvProduct.partnerPrice
        }
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            errorMessage = "Failed to save products: \(nsError.localizedDescription)"
            showError = true
            isImportingData = false
        }
    }
}

// Document picker for CSV files
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var importedCSVString: String?
    @Binding var errorMessage: String?
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.commaSeparatedText])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                parent.errorMessage = "No file selected"
                return
            }
            
            guard url.startAccessingSecurityScopedResource() else {
                parent.errorMessage = "Cannot access the file"
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let data = try Data(contentsOf: url)
                if let string = String(data: data, encoding: .utf8) {
                    parent.importedCSVString = string
                } else {
                    parent.errorMessage = "Failed to convert file to text"
                }
            } catch {
                parent.errorMessage = "Failed to read file: \(error.localizedDescription)"
            }
        }
    }
}

extension Array where Element: Equatable {
    func containsAll(elements: [Element]) -> Bool {
        for element in elements {
            if !self.contains(element) {
                return false
            }
        }
        return true
    }
}
