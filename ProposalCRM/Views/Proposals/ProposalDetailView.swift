// ProposalDetailView.swift - Enhanced Table Component
// This preserves all original columns while adding visual enhancements and edit/delete functionality

import SwiftUI
import CoreData

struct ProposalDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var proposal: Proposal
    
    @State private var showingItemSelection = false
    @State private var showingEngineeringForm = false
    @State private var showingExpensesForm = false
    @State private var showingCustomTaxForm = false
    @State private var showingEditProposal = false
    @State private var showingFinancialDetails = false
    @State private var showDeleteConfirmation = false
    @State private var itemToDelete: ProposalItem?
    @State private var itemToEdit: ProposalItem?
    @State private var showEditItemSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Proposal header
                ProposalHeaderView(proposal: proposal)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Products Section with enhanced table
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Products")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: { showingItemSelection = true }) {
                            Label("Add Products", systemImage: "plus")
                        }
                    }
                    
                    Divider()
                    
                    // Enhanced product table
                    if proposal.itemsArray.isEmpty {
                        Text("No products added yet")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
                            .cornerRadius(8)
                    } else {
                        ProductTableView(
                            proposal: proposal,
                            onDelete: { item in
                                itemToDelete = item
                                showDeleteConfirmation = true
                            },
                            onEdit: { item in
                                itemToEdit = item
                                showEditItemSheet = true
                            }
                        )
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Engineering Section
                SectionWithAddButton(
                    title: "Engineering",
                    count: proposal.engineeringArray.count,
                    onAdd: { showingEngineeringForm = true }
                ) {
                    ForEach(proposal.engineeringArray, id: \.self) { engineering in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(engineering.desc ?? "")
                                    .font(.headline)
                                Text("\(engineering.days) days @ \(engineering.rate)/day")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(engineering.formattedAmount)
                                .font(.headline)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Expenses Section
                SectionWithAddButton(
                    title: "Expenses",
                    count: proposal.expensesArray.count,
                    onAdd: { showingExpensesForm = true }
                ) {
                    ForEach(proposal.expensesArray, id: \.self) { expense in
                        HStack {
                            Text(expense.desc ?? "")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text(expense.formattedAmount)
                                .font(.headline)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Custom Taxes Section
                SectionWithAddButton(
                    title: "Custom Taxes",
                    count: proposal.taxesArray.count,
                    onAdd: { showingCustomTaxForm = true }
                ) {
                    ForEach(proposal.taxesArray, id: \.self) { tax in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(tax.name ?? "")
                                    .font(.headline)
                                Text(tax.formattedRate)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(tax.formattedAmount)
                                .font(.headline)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Financial Summary
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Financial Summary")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: { showingFinancialDetails = true }) {
                            Label("Details", systemImage: "chart.bar")
                        }
                    }
                    
                    Divider()
                    
                    Group {
                        HStack {
                            Text("Products Subtotal")
                            Spacer()
                            Text(String(format: "%.2f", proposal.subtotalProducts))
                        }
                        
                        HStack {
                            Text("Engineering Subtotal")
                            Spacer()
                            Text(String(format: "%.2f", proposal.subtotalEngineering))
                        }
                        
                        HStack {
                            Text("Expenses Subtotal")
                            Spacer()
                            Text(String(format: "%.2f", proposal.subtotalExpenses))
                        }
                        
                        HStack {
                            Text("Taxes")
                            Spacer()
                            Text(String(format: "%.2f", proposal.subtotalTaxes))
                        }
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.2f", proposal.totalAmount))
                                .font(.headline)
                        }
                        
                        Divider()
                        
                        // Partner Cost Section
                        let partnerCost = calculatePartnerCost()
                        HStack {
                            Text("Partner Cost")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.2f", partnerCost))
                                .foregroundColor(.secondary)
                        }
                        
                        // Total Profit
                        let totalProfit = proposal.totalAmount - partnerCost
                        HStack {
                            Text("Total Profit")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.2f", totalProfit))
                                .font(.headline)
                                .foregroundColor(totalProfit >= 0 ? .green : .red)
                        }
                        
                        HStack {
                            Text("Profit Margin")
                            Spacer()
                            Text(String(format: "%.1f%%", proposal.totalAmount > 0 ? (totalProfit / proposal.totalAmount) * 100 : 0))
                                .foregroundColor(totalProfit >= 0 ? .green : .red)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Notes Section
                if let notes = proposal.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Divider()
                        
                        Text(notes)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
            }
            .padding()
        }
        .navigationTitle("Proposal Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditProposal = true }) {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingItemSelection) {
            ItemSelectionView(proposal: proposal)
        }
        .sheet(isPresented: $showingEngineeringForm) {
            EngineeringView(proposal: proposal)
        }
        .sheet(isPresented: $showingExpensesForm) {
            ExpensesView(proposal: proposal)
        }
        .sheet(isPresented: $showingCustomTaxForm) {
            CustomTaxView(proposal: proposal)
        }
        .sheet(isPresented: $showingEditProposal) {
            EditProposalView(proposal: proposal)
        }
        .sheet(isPresented: $showingFinancialDetails) {
            FinancialSummaryDetailView(proposal: proposal)
        }
        .sheet(isPresented: $showEditItemSheet) {
            if let item = itemToEdit {
                EditProposalItemView(item: item)
            }
        }
        .alert("Delete Item?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let item = itemToDelete {
                    deleteItem(item)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this item from the proposal?")
        }
    }
    
    // Calculate partner cost for all items
    private func calculatePartnerCost() -> Double {
        var totalCost = 0.0
        
        // Sum partner cost for all products
        for item in proposal.itemsArray {
            if let product = item.product {
                totalCost += product.partnerPrice * item.quantity
            }
        }
        
        // Add expenses
        totalCost += proposal.subtotalExpenses
        
        return totalCost
    }
    
    // Delete an item from the proposal
    private func deleteItem(_ item: ProposalItem) {
        withAnimation {
            viewContext.delete(item)
            
            do {
                try viewContext.save()
                
                // Update proposal total
                let productsTotal = proposal.subtotalProducts
                let engineeringTotal = proposal.subtotalEngineering
                let expensesTotal = proposal.subtotalExpenses
                let taxesTotal = proposal.subtotalTaxes
                
                proposal.totalAmount = productsTotal + engineeringTotal + expensesTotal + taxesTotal
                
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting item: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// Enhanced Product Table View
// Fixed Table View with Proper Height and Visibility
// Ensures the table is properly displayed on screen


struct ProductTableView: View {
    @ObservedObject var proposal: Proposal
    var onDelete: (ProposalItem) -> Void
    var onEdit: (ProposalItem) -> Void
    
    var body: some View {
        ResponsiveProductTable(
            proposal: proposal,
            onDelete: onDelete,
            onEdit: onEdit
        )
    }
}

// Column definition struct
struct TableColumn: Identifiable {
    let id = UUID()
    let title: String
    var width: CGFloat
    let minWidth: CGFloat
    let alignment: Alignment
    let isResizable: Bool
    
    init(title: String, width: CGFloat, minWidth: CGFloat = 60, alignment: Alignment = .leading, isResizable: Bool = true) {
        self.title = title
        self.width = width
        self.minWidth = minWidth
        self.alignment = alignment
        self.isResizable = isResizable
    }
}

// Main responsive table component
struct ResponsiveProductTable: View {
    @ObservedObject var proposal: Proposal
    var onDelete: (ProposalItem) -> Void
    var onEdit: (ProposalItem) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    // State to track column widths
    @State private var columns: [TableColumn] = [
        TableColumn(title: "Product Name", width: 150, minWidth: 100, alignment: .leading),
        TableColumn(title: "Qty", width: 60, minWidth: 40, alignment: .center),
        TableColumn(title: "Unit Partner\nPrice", width: 90, minWidth: 70, alignment: .trailing),
        TableColumn(title: "Unit List\nPrice", width: 90, minWidth: 70, alignment: .trailing),
        TableColumn(title: "Multiplier", width: 80, minWidth: 60, alignment: .center),
        TableColumn(title: "Discount", width: 80, minWidth: 60, alignment: .center),
        TableColumn(title: "Ext Partner\nPrice", width: 100, minWidth: 80, alignment: .trailing),
        TableColumn(title: "Ext List\nPrice", width: 100, minWidth: 80, alignment: .trailing),
        TableColumn(title: "Ext Customer\nPrice", width: 110, minWidth: 90, alignment: .trailing),
        TableColumn(title: "Total\nProfit", width: 90, minWidth: 70, alignment: .trailing),
        TableColumn(title: "Custom\nTax?", width: 70, minWidth: 50, alignment: .center),
        TableColumn(title: "Actions", width: 80, minWidth: 80, alignment: .center)
    ]
    
    // State to track column resizing
    @State private var resizingColumnIndex: Int? = nil
    @State private var startLocation: CGFloat = 0
    @State private var startWidth: CGFloat = 0
    
    // State to detect orientation and sidebar changes
    @State private var availableWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Detect available width changes
                Color.clear
                    .frame(width: 1, height: 1)
                    .onAppear {
                        availableWidth = geometry.size.width
                        containerWidth = geometry.size.width
                        adaptColumnsToScreenSize()
                    }
                    .onChange(of: geometry.size.width) { newWidth in
                        let widthChange = newWidth - availableWidth
                        availableWidth = newWidth
                        containerWidth = newWidth
                        if abs(widthChange) > 20 { // Only adjust for significant changes
                            adaptColumnsToScreenSize()
                        }
                    }
                
                // Main table container with horizontal scroll when needed
                ScrollView(.horizontal, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Table Header with resizable columns
                        ResizableHeaderRow(
                            columns: $columns,
                            resizingColumnIndex: $resizingColumnIndex,
                            startLocation: $startLocation,
                            startWidth: $startWidth,
                            containerWidth: containerWidth
                        )
                        
                        if proposal.itemsArray.isEmpty {
                            // Empty state with visible height
                            Text("No products added yet")
                                .foregroundColor(.secondary)
                                .frame(minWidth: min(getTotalColumnsWidth(), containerWidth), minHeight: 100)
                                .padding()
                                .background(Color.black.opacity(0.05))
                        } else {
                            // Table Rows
                            ForEach(proposal.itemsArray.indices, id: \.self) { index in
                                let item = proposal.itemsArray[index]
                                
                                ProductRowView(
                                    item: item,
                                    index: index,
                                    columns: columns,
                                    onDelete: onDelete,
                                    onEdit: onEdit
                                )
                            }
                        }
                    }
                    .frame(minWidth: min(getTotalColumnsWidth(), containerWidth))
                }
                .frame(minHeight: calculateTableHeight())
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            .frame(minHeight: calculateTableHeight() + 20) // Add some padding to overall height
        }
        .frame(height: calculateTableHeight() + 20) // Fixed height to ensure table is visible
    }
    
    // Calculate total width of all columns
    private func getTotalColumnsWidth() -> CGFloat {
        return columns.reduce(0) { $0 + $1.width }
    }
    
    // Calculate appropriate table height based on content
    private func calculateTableHeight() -> CGFloat {
        let headerHeight: CGFloat = 44
        let rowHeight: CGFloat = 60
        let minRowsToShow: CGFloat = 3
        
        let itemCount = CGFloat(proposal.itemsArray.count)
        
        if itemCount == 0 {
            // Show at least space for header + "No items" message
            return headerHeight + 100
        } else {
            // Show header + all rows (with a minimum height for small item counts)
            return headerHeight + max(minRowsToShow, itemCount) * rowHeight
        }
    }
    
    // Adapt columns to fit the screen size
    private func adaptColumnsToScreenSize() {
        let totalWidth = getTotalColumnsWidth()
        let availableWidthWithMargin = availableWidth - 20 // Small margin
        
        // Only adjust if we need to fit columns to the screen
        if totalWidth > availableWidthWithMargin && availableWidthWithMargin > 0 {
            // First preserve minimum widths
            var minWidthSum: CGFloat = 0
            var adjustableWidth: CGFloat = 0
            var adjustableColumns: [Int] = []
            
            // Calculate minimum required width and find adjustable columns
            for (index, column) in columns.enumerated() {
                minWidthSum += column.minWidth
                if column.isResizable {
                    adjustableWidth += (column.width - column.minWidth)
                    adjustableColumns.append(index)
                }
            }
            
            // If we can fit within the minimum widths, adjust proportionally
            if minWidthSum <= availableWidthWithMargin {
                // Scale factor for adjustable portion of each column
                let scaleFactor = (availableWidthWithMargin - minWidthSum) / adjustableWidth
                
                // Adjust each resizable column proportionally
                for index in adjustableColumns {
                    let minWidth = columns[index].minWidth
                    let adjustableAmount = columns[index].width - minWidth
                    columns[index].width = minWidth + (adjustableAmount * scaleFactor)
                }
            } else {
                // If even minimum widths don't fit, set all columns to their minimum
                for i in 0..<columns.count {
                    if columns[i].isResizable {
                        columns[i].width = columns[i].minWidth
                    }
                }
            }
        }
    }
}

// Resizable header row component
struct ResizableHeaderRow: View {
    @Binding var columns: [TableColumn]
    @Binding var resizingColumnIndex: Int?
    @Binding var startLocation: CGFloat
    @Binding var startWidth: CGFloat
    var containerWidth: CGFloat
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.1)
                .cornerRadius(8, corners: [.topLeft, .topRight])
            
            // Header cells
            HStack(spacing: 0) {
                ForEach(0..<columns.count, id: \.self) { index in
                    headerCell(for: columns[index], at: index)
                }
            }
        }
        .frame(height: 44)
    }
    
    // Individual header cell with resize handle
    private func headerCell(for column: TableColumn, at index: Int) -> some View {
        HStack(spacing: 0) {
            // Header content
            Text(column.title)
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: column.width - (column.isResizable ? 10 : 0), alignment: column.alignment)
                .lineLimit(2)
                .padding(.horizontal, 4)
            
            // Resize handle
            if column.isResizable && index < columns.count - 1 {
                ResizeHandle(
                    resizingColumnIndex: $resizingColumnIndex,
                    startLocation: $startLocation,
                    startWidth: $startWidth,
                    columns: $columns,
                    index: index
                )
            }
        }
    }
}

// Resize handle component
struct ResizeHandle: View {
    @Binding var resizingColumnIndex: Int?
    @Binding var startLocation: CGFloat
    @Binding var startWidth: CGFloat
    @Binding var columns: [TableColumn]
    let index: Int
    
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(resizingColumnIndex == index ? 0.8 : 0.3))
            .frame(width: 4, height: 24)
            .cornerRadius(2)
            // Make handle draggable
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        if resizingColumnIndex == nil {
                            resizingColumnIndex = index
                            startLocation = value.startLocation.x
                            startWidth = columns[index].width
                        }
                        
                        let delta = value.location.x - startLocation
                        let newWidth = max(columns[index].minWidth, startWidth + delta)
                        
                        // Update column width
                        columns[index].width = newWidth
                    }
                    .onEnded { _ in
                        resizingColumnIndex = nil
                    }
            )
            .padding(.vertical, 2)
    }
}

// Product row view
struct ProductRowView: View {
    let item: ProposalItem
    let index: Int
    let columns: [TableColumn]
    let onDelete: (ProposalItem) -> Void
    let onEdit: (ProposalItem) -> Void
    
    var body: some View {
        ZStack {
            // Row background - alternating colors
            Color(index % 2 == 0 ?
                UIColor.systemBackground :
                UIColor.secondarySystemBackground.withAlphaComponent(0.5))
            
            // Row content
            HStack(spacing: 0) {
                // Product Name (0)
                productNameCell()
                
                // Quantity (1)
                valueCell(
                    text: "\(Int(item.quantity))",
                    width: columns[1].width,
                    alignment: columns[1].alignment,
                    isHighlighted: true
                )
                
                // Unit Partner Price (2)
                let unitPartnerPrice = item.product?.partnerPrice ?? 0
                valueCell(
                    text: formatCurrency(unitPartnerPrice),
                    width: columns[2].width,
                    alignment: columns[2].alignment
                )
                
                // Unit List Price (3)
                let unitListPrice = item.product?.listPrice ?? 0
                valueCell(
                    text: formatCurrency(unitListPrice),
                    width: columns[3].width,
                    alignment: columns[3].alignment
                )
                
                // Multiplier (4)
                let multiplier = getMultiplier(item)
                valueCell(
                    text: String(format: "%.2f", multiplier),
                    width: columns[4].width,
                    alignment: columns[4].alignment,
                    isHighlighted: multiplier != 1.0
                )
                
                // Discount (5)
                valueCell(
                    text: String(format: "%.1f%%", item.discount),
                    width: columns[5].width,
                    alignment: columns[5].alignment,
                    isHighlighted: item.discount > 0,
                    textColor: item.discount > 0 ? .blue : nil
                )
                
                // Extended Partner Price (6)
                let extPartnerPrice = unitPartnerPrice * item.quantity
                valueCell(
                    text: formatCurrency(extPartnerPrice),
                    width: columns[6].width,
                    alignment: columns[6].alignment
                )
                
                // Extended List Price (7)
                let extListPrice = unitListPrice * item.quantity
                valueCell(
                    text: formatCurrency(extListPrice),
                    width: columns[7].width,
                    alignment: columns[7].alignment
                )
                
                // Extended Customer Price (8)
                valueCell(
                    text: formatCurrency(item.amount),
                    width: columns[8].width,
                    alignment: columns[8].alignment,
                    fontWeight: .semibold
                )
                
                // Total Profit (9)
                let profit = item.amount - extPartnerPrice
                valueCell(
                    text: formatCurrency(profit),
                    width: columns[9].width,
                    alignment: columns[9].alignment,
                    fontWeight: .semibold,
                    textColor: profit > 0 ? .green : .red
                )
                
                // Custom Tax (10)
                let hasCustomTax = getHasCustomTax(item)
                valueCell(
                    text: hasCustomTax ? "Yes" : "No",
                    width: columns[10].width,
                    alignment: columns[10].alignment,
                    textColor: hasCustomTax ? .blue : .secondary
                )
                
                // Actions (11)
                actionButtonsCell()
            }
        }
        .frame(height: 60)
    }
    
    // Product name cell with code
    private func productNameCell() -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.productName)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
            
            Text(item.productCode)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(width: columns[0].width, alignment: columns[0].alignment)
        .padding(.horizontal, 8)
    }
    
    // Standard value cell
    private func valueCell(
        text: String,
        width: CGFloat,
        alignment: Alignment,
        isHighlighted: Bool = false,
        fontWeight: Font.Weight = .regular,
        textColor: Color? = nil
    ) -> some View {
        Text(text)
            .font(.system(size: 14, weight: fontWeight))
            .foregroundColor(textColor)
            .frame(width: width, alignment: alignment)
            .padding(.horizontal, 4)
            .background(isHighlighted ? Color.gray.opacity(0.1) : Color.clear)
            .cornerRadius(4)
    }
    
    // Action buttons cell
    private func actionButtonsCell() -> some View {
        HStack(spacing: 12) {
            Button(action: {
                onEdit(item)
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
            
            Button(action: {
                onDelete(item)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .frame(width: columns[11].width, alignment: columns[11].alignment)
        .padding(.horizontal, 4)
    }
    
    // Helper functions from original code
    private func formatCurrency(_ value: Double) -> String {
        return String(format: "%.2f", value)
    }
    
    private func getMultiplier(_ item: ProposalItem) -> Double {
        if item.responds(to: Selector(("multiplier"))) {
            return item.value(forKey: "multiplier") as? Double ?? 1.0
        }
        return 1.0
    }
    
    private func getHasCustomTax(_ item: ProposalItem) -> Bool {
        if item.responds(to: Selector(("applyCustomTax"))) {
            return item.value(forKey: "applyCustomTax") as? Bool ?? false
        }
        return false
    }
}// Extensions for rounded corners if needed

// Edit Proposal Item View
// Fixed EditProposalItemView to match the same controls as when adding new items
// This addresses the empty edit page issue



struct EditProposalItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var item: ProposalItem
    
    @State private var quantity: Double
    @State private var discount: Double
    @State private var multiplier: Double = 1.0
    @State private var customDescription: String = ""
    @State private var applyCustomTax: Bool = false
    @State private var showActionSheet = false
    
    // Colors for visual enhancements
    let headerBackground = Color.black.opacity(0.05)
    let cardBackground = Color(UIColor.secondarySystemBackground)
    
    init(item: ProposalItem) {
        self.item = item
        _quantity = State(initialValue: item.quantity)
        _discount = State(initialValue: item.discount)
        
        // Try to get custom values if they exist
        if item.responds(to: Selector(("multiplier"))) {
            _multiplier = State(initialValue: item.value(forKey: "multiplier") as? Double ?? 1.0)
        }
        
        if item.responds(to: Selector(("customDescription"))) {
            _customDescription = State(initialValue: item.value(forKey: "customDescription") as? String ?? "")
        }
        
        if item.responds(to: Selector(("applyCustomTax"))) {
            _applyCustomTax = State(initialValue: item.value(forKey: "applyCustomTax") as? Bool ?? false)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Product info card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Selected Product")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.bottom, 4)
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.productName)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text(item.productCode)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 2)
                                
                                if let description = item.product?.desc, !description.isEmpty {
                                    Text(description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(cardBackground)
                    .cornerRadius(10)
                    
                    // Quantity section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quantity")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Stepper(value: $quantity, in: 1...100) {
                                Text("\(Int(quantity))")
                                    .font(.body)
                                    .frame(width: 50, alignment: .center)
                                    .padding(8)
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(8)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Show number pad or other input method
                                showActionSheet = true
                            }) {
                                Label("Edit", systemImage: "keyboard")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(cardBackground)
                    .cornerRadius(10)
                    
                    // Pricing section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pricing")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // Discount slider
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Discount")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(Int(discount))%")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            
                            Slider(value: $discount, in: 0...50, step: 1)
                                .accentColor(.blue)
                        }
                        
                        Divider()
                        
                        // Multiplier
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Multiplier")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(String(format: "%.2f", multiplier))×")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                TextField("Multiplier", value: $multiplier, formatter: NumberFormatter())
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                // Preset buttons for common multipliers
                                ForEach([0.5, 0.75, 1.0, 1.25, 1.5], id: \.self) { value in
                                    Button(action: {
                                        multiplier = value
                                    }) {
                                        Text(String(format: "%.2f", value))
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(multiplier == value ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(multiplier == value ? .white : .primary)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Apply custom tax toggle
                        Toggle("Apply Custom Tax", isOn: $applyCustomTax)
                    }
                    .padding()
                    .background(cardBackground)
                    .cornerRadius(10)
                    
                    // Custom description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Description")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $customDescription)
                            .frame(minHeight: 100)
                            .padding(4)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding()
                    .background(cardBackground)
                    .cornerRadius(10)
                    
                    // Price calculations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Price Calculation")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Group {
                            // Base prices
                            if let product = item.product {
                                HStack {
                                    Text("Unit List Price")
                                    Spacer()
                                    Text(String(format: "%.2f", product.listPrice))
                                }
                                
                                HStack {
                                    Text("Unit Partner Price")
                                    Spacer()
                                    Text(String(format: "%.2f", product.partnerPrice))
                                }
                                
                                Divider()
                            }
                            
                            // Final unit price
                            HStack {
                                Text("Unit Price")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(String(format: "%.2f", calculateUnitPrice()))
                                    .fontWeight(.medium)
                            }
                            
                            // Extended amount
                            HStack {
                                Text("Extended Amount")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(String(format: "%.2f", calculateAmount()))
                                    .fontWeight(.semibold)
                            }
                            
                            // Profit
                            let profit = calculateProfit()
                            HStack {
                                Text("Profit")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(String(format: "%.2f", profit))
                                    .fontWeight(.semibold)
                                    .foregroundColor(profit > 0 ? .green : .red)
                            }
                            
                            // Margin
                            let margin = calculateMargin()
                            HStack {
                                Text("Margin")
                                Spacer()
                                Text(String(format: "%.1f%%", margin))
                                    .foregroundColor(margin > 20 ? .green : (margin > 10 ? .orange : .red))
                            }
                        }
                        .font(.subheadline)
                    }
                    .padding()
                    .background(cardBackground)
                    .cornerRadius(10)
                    
                    // Action buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            saveChanges()
                        }) {
                            Text("Save Changes")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .navigationTitle("Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showActionSheet) {
                // This is simplified - in a real app you might want a custom input view
                Alert(
                    title: Text("Enter Quantity"),
                    message: Text("Current quantity: \(Int(quantity))"),
                    primaryButton: .default(Text("OK")),
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func calculateUnitPrice() -> Double {
        if let product = item.product {
            return product.listPrice * (1 - discount / 100) * multiplier
        }
        return 0
    }
    
    private func calculateAmount() -> Double {
        return calculateUnitPrice() * quantity
    }
    
    private func calculateProfit() -> Double {
        if let product = item.product {
            let partnerCost = product.partnerPrice * quantity
            return calculateAmount() - partnerCost
        }
        return 0
    }
    
    private func calculateMargin() -> Double {
        let amount = calculateAmount()
        if amount <= 0 {
            return 0
        }
        
        let profit = calculateProfit()
        return (profit / amount) * 100
    }
    
    private func saveChanges() {
        // Update the item with edited values
        item.quantity = quantity
        item.discount = discount
        item.unitPrice = calculateUnitPrice()
        item.amount = calculateAmount()
        
        // Try to set additional properties if available
        if item.responds(to: Selector(("setMultiplier:"))) {
            item.setValue(multiplier, forKey: "multiplier")
        }
        
        if item.responds(to: Selector(("setCustomDescription:"))) {
            item.setValue(customDescription, forKey: "customDescription")
        }
        
        if item.responds(to: Selector(("setApplyCustomTax:"))) {
            item.setValue(applyCustomTax, forKey: "applyCustomTax")
        }
        
        do {
            try viewContext.save()
            
            // Update proposal total if available
            if let proposal = item.proposal {
                let productsTotal = proposal.subtotalProducts
                let engineeringTotal = proposal.subtotalEngineering
                let expensesTotal = proposal.subtotalExpenses
                let taxesTotal = proposal.subtotalTaxes
                
                proposal.totalAmount = productsTotal + engineeringTotal + expensesTotal + taxesTotal
                
                try viewContext.save()
            }
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            print("Error saving changes: \(nsError), \(nsError.userInfo)")
        }
    }
}
