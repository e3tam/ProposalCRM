// ProductImportView.swift
// Debug version with extensive logging

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
    @State private var importProgress: Float = 0.0
    @State private var processingStatus = "Ready to import"
    @State private var debugInfo: String = ""
    @State private var showDebugInfo = false
    
    struct CSVProduct: Identifiable {
        let id = UUID()
        let code: String
        let name: String
        let listPrice: Double
        let partnerPrice: Double
        let discount: Int
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
                        
                        Text("Use a CSV file with Product ID, Description, List Price, Partner Price and Discount columns")
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
                } else if importProgress < 1.0 && !showPreview {
                    // Show processing screen with progress
                    VStack(spacing: 20) {
                        ProgressView(value: importProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding()
                        
                        Text("Processing CSV file...")
                            .font(.headline)
                        
                        Text(processingStatus)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            // Toggle debug info
                            showDebugInfo.toggle()
                        }) {
                            Text(showDebugInfo ? "Hide Debug Info" : "Show Debug Info")
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                        }
                        
                        if showDebugInfo {
                            ScrollView {
                                Text(debugInfo)
                                    .font(.system(size: 12, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
                            .frame(height: 200)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            // Cancel import
                            importedCSVString = nil
                            importedProducts = []
                            importProgress = 0.0
                            processingStatus = "Ready to import"
                            debugInfo = ""
                        }) {
                            Text("Cancel")
                                .foregroundColor(.red)
                                .padding()
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
                                showDebugInfo.toggle()
                            }) {
                                Text(showDebugInfo ? "Hide Debug" : "Show Debug")
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                importedCSVString = nil
                                importedProducts = []
                                showPreview = false
                                importProgress = 0.0
                                processingStatus = "Ready to import"
                                debugInfo = ""
                            }) {
                                Text("Cancel")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        
                        if showDebugInfo {
                            ScrollView {
                                Text(debugInfo)
                                    .font(.system(size: 12, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
                            .frame(height: 200)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                        
                        // Summary at the top
                        VStack(spacing: 5) {
                            HStack {
                                Text("List: €\(String(format: "%.2f", importedProducts.reduce(0.0) { $0 + $1.listPrice }))")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("Partner: €\(String(format: "%.2f", importedProducts.reduce(0.0) { $0 + $1.partnerPrice }))")
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                let avgDiscount = importedProducts.isEmpty ? 0 :
                                    importedProducts.reduce(0) { $0 + $1.discount } / importedProducts.count
                                Text("Discount: \(avgDiscount)%")
                                    .foregroundColor(.green)
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        // Products preview
                        if importedProducts.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.orange)
                                
                                Text("No products found in the CSV file")
                                    .font(.headline)
                                
                                Text("Please check the file format and try again")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding()
                        } else {
                            List {
                                ForEach(importedProducts.prefix(50), id: \.id) { product in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.code)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Text(product.name)
                                            .font(.headline)
                                            .lineLimit(2)
                                        
                                        HStack {
                                            Text("List: €\(String(format: "%.2f", product.listPrice))")
                                                .font(.subheadline)
                                            
                                            Spacer()
                                            
                                            Text("Partner: €\(String(format: "%.2f", product.partnerPrice))")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        Text("Discount: \(product.discount)%")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                    .padding(.vertical, 4)
                                }
                                
                                if importedProducts.count > 50 {
                                    Text("... and \(importedProducts.count - 50) more items")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding()
                                }
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
                                    .background(importedProducts.isEmpty ? Color.gray : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .disabled(importedProducts.isEmpty || isImportingData)
                        .padding()
                    }
                }
            }
            .navigationTitle("Import Products")
            .sheet(isPresented: $isImporting) {
                DocumentPicker(importedCSVString: $importedCSVString, errorMessage: $errorMessage)
                    .onDisappear {
                        if let csvString = importedCSVString {
                            // Start parsing in background to avoid freezing UI
                            DispatchQueue.global(qos: .userInitiated).async {
                                parseCSV(csvString)
                            }
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
        // Reset state
        importedProducts = []
        importProgress = 0.0
        debugInfo = ""
        
        addDebugInfo("Starting CSV parsing...")
        addDebugInfo("CSV length: \(csvString.count) characters")
        
        if csvString.count > 500 {
            // Show first 500 chars of CSV
            let startIndex = csvString.startIndex
            let endIndex = csvString.index(startIndex, offsetBy: min(500, csvString.count))
            let preview = csvString[startIndex..<endIndex]
            addDebugInfo("CSV Preview (first 500 chars):\n\(preview)")
        } else {
            addDebugInfo("CSV Content:\n\(csvString)")
        }
        
        DispatchQueue.main.async {
            processingStatus = "Analyzing CSV format..."
        }
        
        // Split into lines
        var lines = csvString.components(separatedBy: .newlines)
        addDebugInfo("Found \(lines.count) lines in CSV")
        
        // Filter out empty lines
        lines = lines.filter { !$0.trimmed.isEmpty }
        addDebugInfo("After filtering empty lines: \(lines.count) lines")
        
        guard lines.count > 0 else {
            addDebugInfo("No non-empty lines found in CSV")
            DispatchQueue.main.async {
                errorMessage = "CSV file is empty or contains no valid data"
                showError = true
                importProgress = 1.0
                showPreview = true
            }
            return
        }
        
        // First line is assumed to be the header
        let headerLine = lines[0]
        addDebugInfo("Header line: \(headerLine)")
        
        // Try several different parsing strategies
        // 1. Standard comma-separated
        // 2. Tab-separated
        // 3. Semicolon-separated
        
        // First try comma-separated (standard CSV)
        var headers = parseCSVLine(headerLine, separator: ",")
        var separator = ","
        
        // If we only got one column, try tab
        if headers.count <= 1 {
            headers = parseCSVLine(headerLine, separator: "\t")
            separator = "\t"
            addDebugInfo("Trying tab separator: found \(headers.count) columns")
        }
        
        // If still only one column, try semicolon
        if headers.count <= 1 {
            headers = parseCSVLine(headerLine, separator: ";")
            separator = ";"
            addDebugInfo("Trying semicolon separator: found \(headers.count) columns")
        }
        
        addDebugInfo("Using separator: '\(separator == "\t" ? "TAB" : separator)'")
        addDebugInfo("Detected headers: \(headers.joined(separator: ", "))")
        
        // Look for the columns we need
        let productIdIndex = findColumnIndex(headers, for: ["Product ID", "ProductID", "Product", "Code", "ID"])
        let descriptionIndex = findColumnIndex(headers, for: ["Description", "Desc", "Product Name", "Name"])
        let listPriceIndex = findColumnIndex(headers, for: ["List Price", "ListPrice", "Price", "List"])
        let partnerPriceIndex = findColumnIndex(headers, for: ["Partner Price", "PartnerPrice", "Partner", "Wholesale"])
        let discountIndex = findColumnIndex(headers, for: ["Discount", "Disc", "Discount %", "Percentage"])
        
        addDebugInfo("Column indices: Product ID=\(productIdIndex), Description=\(descriptionIndex), List Price=\(listPriceIndex), Partner Price=\(partnerPriceIndex), Discount=\(discountIndex)")
        
        // Check if we found the necessary columns
        if productIdIndex < 0 || descriptionIndex < 0 || listPriceIndex < 0 ||
           partnerPriceIndex < 0 || discountIndex < 0 {
            
            // If automatic detection failed, try fixed column indices based on the screenshot
            addDebugInfo("Couldn't detect all columns automatically. Trying fixed column indices based on the example...")
            
            // Based on the screenshot, assuming columns are in this order:
            // 0: Product ID, 1: Description, 2: List Price, 3: Partner Price, 4: Discount
            if headers.count >= 5 {
                // First try basic indices
                var products = parseWithFixedIndices(lines, 0, 1, 2, 3, 4, separator)
                
                if products.isEmpty && lines.count > 1 {
                    // Try parsing without header row
                    addDebugInfo("Trying to parse without header row...")
                    var dataLines = lines
                    if isLikelyHeader(lines[0]) {
                        dataLines.removeFirst()
                    }
                    products = parseRawData(dataLines)
                }
                
                DispatchQueue.main.async {
                    importedProducts = products
                    importProgress = 1.0
                    processingStatus = "Found \(products.count) valid products"
                    showPreview = true
                }
                return
            }
            
            DispatchQueue.main.async {
                errorMessage = "Could not identify all required columns in the CSV file"
                addDebugInfo("Failed to detect required columns")
                showError = true
                importProgress = 1.0
                showPreview = true
            }
            return
        }
        
        DispatchQueue.main.async {
            processingStatus = "Found \(lines.count - 1) potential product rows"
        }
        
        // Process data rows with the detected column indices
        let products = parseWithFixedIndices(
            Array(lines.dropFirst()), // Skip header
            productIdIndex,
            descriptionIndex,
            listPriceIndex,
            partnerPriceIndex,
            discountIndex,
            separator
        )
        
        // Update UI on main thread
        DispatchQueue.main.async {
            importedProducts = products
            importProgress = 1.0
            processingStatus = "Found \(products.count) valid products"
            addDebugInfo("Successfully parsed \(products.count) products")
            showPreview = true
        }
    }
    
    // Parse with fixed column indices
    private func parseWithFixedIndices(_ lines: [String], _ pidx: Int, _ didx: Int, _ lpidx: Int, _ ppidx: Int, _ discidx: Int, _ separator: String) -> [CSVProduct] {
        var products: [CSVProduct] = []
        let totalRows = lines.count
        
        addDebugInfo("Parsing \(totalRows) data rows with fixed indices")
        
        for (i, line) in lines.enumerated() {
            // Update progress periodically
            if i % 100 == 0 || i == lines.count - 1 {
                let progress = Float(i) / Float(totalRows)
                DispatchQueue.main.async {
                    importProgress = progress
                    processingStatus = "Processed \(i) of \(totalRows) rows..."
                }
            }
         
            let columns = parseCSVLine(line, separator: separator)
            
            // Skip rows that don't have enough columns
            if columns.count <= max(pidx, didx, lpidx, ppidx, discidx) {
                if i < 5 { // Only log the first few for brevity
                    addDebugInfo("Row \(i) doesn't have enough columns: \(columns.count) < required max index \(max(pidx, didx, lpidx, ppidx, discidx))")
                }
                continue
            }
            
            // Extract field values
            let productId = columns[pidx].trimmed
            let description = columns[didx].trimmed
            let listPriceStr = columns[lpidx].trimmed
            let partnerPriceStr = columns[ppidx].trimmed
            let discountStr = columns[discidx].trimmed
            
            // Parse prices
            let listPrice = parseEuroPrice(listPriceStr)
            let partnerPrice = parseEuroPrice(partnerPriceStr)
            let discount = parseDiscount(discountStr)
            
            // Create product if we have valid data
            if !productId.isEmpty {
                let product = CSVProduct(
                    code: productId,
                    name: description,
                    listPrice: listPrice,
                    partnerPrice: partnerPrice,
                    discount: discount
                )
                
                products.append(product)
                
                // Log first few products for debugging
                if products.count <= 5 {
                    addDebugInfo("Added product: \(productId), Price: €\(listPrice), Partner: €\(partnerPrice), Disc: \(discount)%")
                }
            }
        }
        
        return products
    }
    
    // Try to parse rows without any header information
    private func parseRawData(_ lines: [String]) -> [CSVProduct] {
        var products: [CSVProduct] = []
        
        addDebugInfo("Trying raw data parsing for \(lines.count) lines...")
        
        for (i, line) in lines.enumerated() {
            if i < 5 {
                addDebugInfo("Raw line \(i): \(line)")
            }
            
            // Try to extract product code, description and price
            // Assume format might be like the screenshots
            
            // Check for common code patterns like "280-XXX-YYY" or "DM280-XXX-YYY"
            if let codeRange = line.range(of: "(DM280|280)-[A-Za-z0-9]+-[A-Za-z0-9]+", options: .regularExpression) {
                let code = String(line[codeRange])
                var remainingText = line
                
                if let startIndex = line.range(of: code)?.lowerBound {
                    remainingText = String(line[startIndex...])
                }
                
                // Look for price patterns like "€ XXX,XX" or "€XXX.XX"
                var listPrice: Double = 0
                var partnerPrice: Double = 0
                var discount: Int = 26 // Default based on samples
                
                // Try to find a price in the remaining text
                if let priceRange = remainingText.range(of: "€\\s*[0-9.,]+", options: .regularExpression) {
                    let priceText = String(remainingText[priceRange])
                    listPrice = parseEuroPrice(priceText)
                    
                    // Calculate partner price based on discount
                    partnerPrice = listPrice * (1.0 - Double(discount) / 100.0)
                }
                
                // Get description by removing code and price
                var description = remainingText
                    .replacingOccurrences(of: code, with: "")
                    .trimmed
                
                // Remove any remaining price text
                if let priceRange = description.range(of: "€\\s*[0-9.,]+", options: .regularExpression) {
                    let priceText = String(description[priceRange])
                    description = description.replacingOccurrences(of: priceText, with: "").trimmed
                }
                
                // Clean up any separators in the description
                description = description.replacingOccurrences(of: ";", with: " ")
                    .replacingOccurrences(of: ",", with: " ")
                    .trimmed
                
                // Only add if we have a code and it looks legitimate
                if code.contains("280-") && !code.isEmpty {
                    let product = CSVProduct(
                        code: code,
                        name: description,
                        listPrice: listPrice,
                        partnerPrice: partnerPrice,
                        discount: discount
                    )
                    
                    products.append(product)
                    
                    if products.count <= 5 {
                        addDebugInfo("Parsed raw product: \(code), Price: €\(listPrice)")
                    }
                }
            }
        }
        
        return products
    }
    
    // Check if a line is likely a header rather than data
    private func isLikelyHeader(_ line: String) -> Bool {
        // Headers usually don't contain product codes or prices
        return !line.contains("280-") &&
               !line.contains("DM280") &&
               !line.contains("€") &&
               (line.lowercased().contains("product") ||
                line.lowercased().contains("description") ||
                line.lowercased().contains("price"))
    }
    
    // Find the index of a column by trying different possible header names
    private func findColumnIndex(_ headers: [String], for possibleNames: [String]) -> Int {
        // Try exact matches first
        for name in possibleNames {
            for (index, header) in headers.enumerated() {
                if header.trimmed.lowercased() == name.lowercased() {
                    return index
                }
            }
        }
        
        // Try contains matches
        for name in possibleNames {
            for (index, header) in headers.enumerated() {
                if header.trimmed.lowercased().contains(name.lowercased()) {
                    return index
                }
            }
        }
        
        return -1
    }
    
    // Parse a CSV line with specified separator
    private func parseCSVLine(_ line: String, separator: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes = !inQuotes
            } else if String(char) == separator && !inQuotes {
                result.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        // Add the last field
        result.append(currentField)
        
        return result
    }
    
    // Parse price in Euro format (e.g. "€ 180,00" -> 180.00)
    private func parseEuroPrice(_ priceString: String) -> Double {
        // Remove Euro symbol, whitespace and clean the string
        var cleaned = priceString
            .replacingOccurrences(of: "€", with: "")
            .trimmed
        
        // Replace comma with period for decimal point
        cleaned = cleaned.replacingOccurrences(of: ",", with: ".")
        
        // Add debug info for troublesome prices
        if !cleaned.isEmpty && Double(cleaned) == nil {
            addDebugInfo("Failed to parse price: '\(priceString)' -> '\(cleaned)'")
        }
        
        return Double(cleaned) ?? 0.0
    }
    
    // Parse discount percentage
    private func parseDiscount(_ discountString: String) -> Int {
        // Remove % symbol and whitespace
        let cleaned = discountString
            .replacingOccurrences(of: "%", with: "")
            .trimmed
        
        return Int(cleaned) ?? 0
    }
    
    // Add debug information
    private func addDebugInfo(_ info: String) {
        debugInfo += info + "\n"
        print(info)
    }
    
    private func saveImportedProducts() {
        // Update status
        processingStatus = "Saving products to database..."
        addDebugInfo("Starting to save \(importedProducts.count) products...")
        
        // Use a background context for better performance
        let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
        
        // Group the saves in batches for better performance
        let batchSize = 200
        let totalBatches = (importedProducts.count + batchSize - 1) / batchSize
        
        // Track progress
        var savedCount = 0
        
        for batchIndex in 0..<totalBatches {
            // Create a batch of products
            let startIndex = batchIndex * batchSize
            let endIndex = min(startIndex + batchSize, importedProducts.count)
            let currentBatch = Array(importedProducts[startIndex..<endIndex])
            
            // Save this batch
            backgroundContext.perform {
                for csvProduct in currentBatch {
                    let product = Product(context: backgroundContext)
                    product.id = UUID()
                    product.code = csvProduct.code
                    product.name = csvProduct.name
                    product.desc = ""
                    product.category = ""
                    product.listPrice = csvProduct.listPrice
                    product.partnerPrice = csvProduct.partnerPrice
                }
                
                // Save the context
                do {
                    try backgroundContext.save()
                    
                    // Update progress on main thread
                    savedCount += currentBatch.count
                    
                    DispatchQueue.main.async {
                        processingStatus = "Saved \(savedCount) of \(importedProducts.count) products..."
                        addDebugInfo("Saved batch \(batchIndex+1)/\(totalBatches) with \(currentBatch.count) products")
                        
                        if batchIndex == totalBatches - 1 {
                            // All done
                            addDebugInfo("All products saved successfully!")
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } catch {
                    let nsError = error as NSError
                    DispatchQueue.main.async {
                        errorMessage = "Failed to save products: \(nsError.localizedDescription)"
                        addDebugInfo("Error saving batch \(batchIndex+1): \(nsError.localizedDescription)")
                        showError = true
                        isImportingData = false
                    }
                }
            }
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
                } else if let string = String(data: data, encoding: .isoLatin1) {
                    // Try ISO Latin 1 encoding if UTF-8 fails
                    parent.importedCSVString = string
                } else if let string = String(data: data, encoding: .windowsCP1252) {
                    // Try Windows CP1252 encoding if others fail
                    parent.importedCSVString = string
                } else {
                    parent.errorMessage = "Failed to convert file to text - unsupported encoding"
                }
            } catch {
                parent.errorMessage = "Failed to read file: \(error.localizedDescription)"
            }
        }
    }
}

// String extension to handle trimming
extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
