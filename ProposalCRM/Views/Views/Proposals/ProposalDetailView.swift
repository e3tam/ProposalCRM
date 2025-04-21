import SwiftUI
import CoreData

struct ProposalDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var proposal: Proposal
    @Environment(\.colorScheme) private var colorScheme
    
    // State variables for showing different sheets
    @State private var showingItemSelection = false
    @State private var showingEngineeringForm = false
    @State private var showingExpensesForm = false
    @State private var showingCustomTaxForm = false
    @State private var showingEditProposal = false
    @State private var showingFinancialDetails = false
    @State private var showDeleteConfirmation = false
    @State private var itemToDelete: ProposalItem?
    
    // Task and activity state variables
    @State private var showingAddTask = false
    @State private var showingAddComment = false
    @State private var commentText = ""
    @State private var refreshId = UUID()  // Simple refresh trigger
    
    // State variables for product item editing
    @State private var itemToEdit: ProposalItem?
    @State private var showEditItemSheet = false
    @State private var didSaveItemChanges = false  // Track if changes were saved
    
    // State variables for engineering editing
    @State private var engineeringToEdit: Engineering?
    @State private var showEditEngineeringSheet = false
    
    // State variables for expense editing
    @State private var expenseToEdit: Expense?
    @State private var showEditExpenseSheet = false
    
    // State variables for custom tax editing
    @State private var taxToEdit: CustomTax?
    @State private var showEditTaxSheet = false
    
    var body: some View {
        ZStack {
            // Solid background to prevent drawing overlay issues
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Fixed header section
                    ProposalHeaderSection(
                        proposal: proposal,
                        onEditTapped: { showingEditProposal = true }
                    )
                    
                    // Content sections with proper spacing
                    VStack(alignment: .leading, spacing: 20) {
                        // PRODUCTS SECTION
                        productsSection
                            .id(refreshId)  // Force refresh when id changes
                        
                        // ENGINEERING SECTION
                        engineeringSection
                        
                        // EXPENSES SECTION
                        expensesSection
                        
                        // CUSTOM TAXES SECTION
                        customTaxesSection
                        
                        // FINANCIAL SUMMARY SECTION
                        financialSummarySection
                        
                        // TASK SECTION
                        taskSummarySection
                        
                        // ACTIVITY SECTION
                        activitySummarySection
                        
                        // NOTES SECTION
                        if let notes = proposal.notes, !notes.isEmpty {
                            notesSection(notes: notes)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationBarHidden(true)
        // SHEET PRESENTATIONS
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
        .sheet(isPresented: $showEditEngineeringSheet) {
            if let engineering = engineeringToEdit {
                NavigationView {
                    EditEngineeringView(engineering: engineering)
                        .navigationTitle("Edit Engineering")
                        .navigationBarItems(trailing: Button("Done") {
                            showEditEngineeringSheet = false
                            updateProposalTotal()
                        })
                }
            }
        }
        .sheet(isPresented: $showEditExpenseSheet) {
            if let expense = expenseToEdit {
                NavigationView {
                    EditExpenseView(expense: expense)
                        .navigationTitle("Edit Expense")
                        .navigationBarItems(trailing: Button("Done") {
                            showEditExpenseSheet = false
                            updateProposalTotal()
                        })
                }
            }
        }
        .sheet(isPresented: $showEditTaxSheet) {
            if let tax = taxToEdit {
                NavigationView {
                    EditCustomTaxView(customTax: tax, proposal: proposal)
                        .navigationTitle("Edit Custom Tax")
                        .navigationBarItems(trailing: Button("Done") {
                            showEditTaxSheet = false
                            updateProposalTotal()
                        })
                }
            }
        }
        .sheet(isPresented: $showEditItemSheet, onDismiss: {
            // Reset edit state
            itemToEdit = nil
            showEditItemSheet = false
            
            // Force complete view refresh
            if didSaveItemChanges {
                refreshId = UUID()
                didSaveItemChanges = false
            }
        }) {
            if let item = itemToEdit {
                ProposalItemDebugWrapper(
                    item: item,
                    didSave: $didSaveItemChanges,
                    onSave: {
                        // Force view refresh
                        DispatchQueue.main.async {
                            refreshId = UUID()
                        }
                    }
                )
                .environment(\.managedObjectContext, viewContext)
            }
        }
        // TASK PRESENTATION SHEET
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(proposal: proposal)
                .environment(\.managedObjectContext, viewContext)
        }
        // COMMENT ALERT
        .alert("Add Comment", isPresented: $showingAddComment) {
            TextField("Comment", text: $commentText)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if !commentText.isEmpty {
                    addComment()
                }
            }
        } message: {
            Text("Enter a comment for this proposal")
        }
        // DELETE CONFIRMATION
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
    
    private func openEditItemView(for item: ProposalItem) {
        itemToEdit = item
        showEditItemSheet = true
    }
    
    // MARK: - Products Section with Fixed Table Headers
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Products")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showingItemSelection = true }) {
                    Label("Add Products", systemImage: "plus")
                        .foregroundColor(.blue)
                }
            }
            
            if proposal.itemsArray.isEmpty {
                Text("No products added yet")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
            } else {
                // Product table with fixed header alignment
                VStack(spacing: 0) {
                    // Table header row - Fixed alignment
                    HStack(spacing: 0) {
                        TableHeaderCell(title: "Product Name", width: 180, alignment: .leading)
                        TableHeaderCell(title: "Qty", width: 50, alignment: .center)
                        TableHeaderCell(title: "Unit Partner Price", width: 120, alignment: .trailing)
                        TableHeaderCell(title: "Unit List Price", width: 120, alignment: .trailing)
                        TableHeaderCell(title: "Multiplier", width: 80, alignment: .center)
                        TableHeaderCell(title: "Discount", width: 80, alignment: .center)
                        TableHeaderCell(title: "Ext Partner Price", width: 120, alignment: .trailing)
                        TableHeaderCell(title: "Ext List Price", width: 120, alignment: .trailing)
                        TableHeaderCell(title: "Ext Customer Price", width: 120, alignment: .trailing)
                        TableHeaderCell(title: "Total Profit", width: 100, alignment: .trailing)
                        TableHeaderCell(title: "Custom Tax?", width: 90, alignment: .center)
                        TableHeaderCell(title: "Act", width: 60, alignment: .center, isLast: true)
                    }
                    .frame(height: 40)
                    .background(Color.black.opacity(0.3))
                    
                    Divider().background(Color.gray.opacity(0.5))
                    
                    // Data rows
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(proposal.itemsArray, id: \.self) { item in
                                HStack(spacing: 0) {
                                    // Product Name and code
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.productName)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                        Text(item.productCode)
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 180, alignment: .leading)
                                    .padding(.horizontal, 5)
                                    
                                    TableDivider()
                                    
                                    // Quantity
                                    Text("\(Int(item.quantity))")
                                        .font(.system(size: 14))
                                        .frame(width: 50, alignment: .center)
                                        .padding(.horizontal, 5)
                                    
                                    TableDivider()
                                    
                                    // Unit Partner Price
                                    let partnerPrice = item.product?.partnerPrice ?? 0
                                    Text(String(format: "%.2f", partnerPrice))
                                        .font(.system(size: 14))
                                        .frame(width: 120, alignment: .trailing)
                                        .padding(.horizontal, 5)
                                    
                                    TableDivider()
                                    
                                    // Unit List Price
                                    let listPrice = item.product?.listPrice ?? 0
                                    Text(String(format: "%.2f", listPrice))
                                        .font(.system(size: 14))
                                        .frame(width: 120, alignment: .trailing)
                                        .padding(.horizontal, 5)
                                    
                                    TableDivider()
                                    
                                    // Multiplier
                                    Text(String(format: "%.2f", calculateMultiplier(item)))
                                        .font(.system(size: 14))
                                        .frame(width: 80, alignment: .center)
                                        .padding(.horizontal, 5)
                                    
                                    TableDivider()
                                    
                                    // Discount
                                    Text(String(format: "%.1f%%", item.discount))
                                        .font(.system(size: 14))
                                        .frame(width: 80, alignment: .center)
                                        .padding(.horizontal, 5)
                                    
                                    TableDivider()
                                    
                                    // Extended Partner Price
                                    let extPartnerPrice = partnerPrice * item.quantity
                                    Text(String(format: "%.2f", extPartnerPrice))
                                        .font(.system(size: 14))
                                        .frame(width: 120, alignment: .trailing)
                                        .padding(.horizontal, 5)
                                    
                                    TableDivider()
                                    
                                    // Extended List Price
                                    let extListPrice = listPrice * item.quantity
                                    Text(String(format: "%.2f", extListPrice))
                                        .font(.system(size: 14))
                                        .frame(width: 120, alignment: .trailing)
                                        .padding(.horizontal, 5)
                                    
                                    TableDivider()
                                    
                                    // Extended Customer Price
                                    Text(String(format: "%.2f", item.amount))
                                        .font(.system(size: 14))
                                        .frame(width: 120, alignment: .trailing)
                                        .padding(.horizontal, 5)
                                    
                                    TableDivider()
                                    
                                    // Total Profit
                                    let profit = item.amount - extPartnerPrice
                                    Text(String(format: "%.2f", profit))
                                        .font(.system(size: 14))
                                        .foregroundColor(profit > 0 ? .green : .red)
                                        .frame(width: 100, alignment: .trailing)
                                        .padding(.horizontal, 5)
                                    
                                    TableDivider()
                                    
                                    // Custom Tax?
                                    Text("No")
                                        .font(.system(size: 14))
                                        .frame(width: 90, alignment: .center)
                                        .padding(.horizontal, 5)
                                    
                                    TableDivider()
                                    
                                    // Action buttons
                                    HStack(spacing: 15) {
                                        Button(action: {
                                            openEditItemView(for: item)
                                        }) {
                                            Image(systemName: "pencil")
                                                .foregroundColor(.blue)
                                        }
                                        
                                        Button(action: {
                                            itemToDelete = item
                                            showDeleteConfirmation = true
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .frame(width: 60, alignment: .center)
                                }
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.2))
                                
                                Divider().background(Color.gray.opacity(0.5))
                            }
                        }
                    }
                }
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Fixed Table Header Components
    private struct TableHeaderCell: View {
        let title: String
        let width: CGFloat
        let alignment: Alignment
        var isLast: Bool = false
        
        var body: some View {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: width, height: 40, alignment: alignment)
                .padding(.horizontal, 5)
                .background(Color.clear)
                .overlay(
                    Rectangle()
                        .frame(width: 1, height: 30)
                        .foregroundColor(Color.gray.opacity(0.5)),
                    alignment: .trailing
                )
                .opacity(isLast ? 0 : 1)
        }
    }
    
    private struct TableDivider: View {
        var body: some View {
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 1, height: 30)
        }
    }
    
    // MARK: - Engineering Section
    private var engineeringSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Engineering")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if !proposal.engineeringArray.isEmpty {
                    Text("(\(proposal.engineeringArray.count))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: { showingEngineeringForm = true }) {
                    Label("Add", systemImage: "plus")
                        .foregroundColor(.blue)
                }
            }
            
            EngineeringTableView(
                proposal,
                onDelete: { engineering in
                    deleteEngineering(engineering)
                },
                onEdit: { engineering in
                    engineeringToEdit = engineering
                    showEditEngineeringSheet = true
                }
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Expenses Section
    private var expensesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Expenses")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if !proposal.expensesArray.isEmpty {
                    Text("(\(proposal.expensesArray.count))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: { showingExpensesForm = true }) {
                    Label("Add", systemImage: "plus")
                        .foregroundColor(.blue)
                }
            }
            
            ExpensesTableView(
                proposal,
                onDelete: { expense in
                    deleteExpense(expense)
                },
                onEdit: { expense in
                    expenseToEdit = expense
                    showEditExpenseSheet = true
                }
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Custom Taxes Section
    private var customTaxesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Custom Taxes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if !proposal.taxesArray.isEmpty {
                    Text("(\(proposal.taxesArray.count))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: { showingCustomTaxForm = true }) {
                    Label("Add", systemImage: "plus")
                        .foregroundColor(.blue)
                }
            }
            
            CustomTaxesTableView(
                proposal,
                onDelete: { tax in
                    deleteTax(tax)
                },
                onEdit: { tax in
                    taxToEdit = tax
                    showEditTaxSheet = true
                }
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Financial Summary Section
    private var financialSummarySection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 15) {
                // Progress bar at the top
                Rectangle()
                    .frame(height: 4)
                    .foregroundColor(.gray.opacity(0.3))
                    .overlay(
                        GeometryReader { geometry in
                            Rectangle()
                                .frame(width: geometry.size.width * 0.65)
                                .foregroundColor(.white)
                        }
                    )
                    .cornerRadius(2)
                    .padding(.bottom, 20)
                
                HStack {
                    Text("Financial Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showingFinancialDetails = true }) {
                        Label("Details", systemImage: "chart.bar")
                            .foregroundColor(.blue)
                    }
                }
                
                Group {
                    SummaryRow(title: "Products Subtotal", value: proposal.subtotalProducts)
                    SummaryRow(title: "Engineering Subtotal", value: proposal.subtotalEngineering)
                    SummaryRow(title: "Expenses Subtotal", value: proposal.subtotalExpenses)
                    SummaryRow(title: "Taxes", value: proposal.subtotalTaxes)
                    
                    // Total with more prominent styling
                    HStack {
                        Text("Total")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text(String(format: "%.2f", proposal.totalAmount))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 5)
                    
                    Divider().background(Color.gray.opacity(0.5))
                    
                    // Partner Cost Section
                    let partnerCost = calculatePartnerCost()
                    SummaryRow(title: "Partner Cost", value: partnerCost, titleColor: .gray, valueColor: .gray)
                    
                    // Total Profit
                    let totalProfit = proposal.totalAmount - partnerCost
                    HStack {
                        Text("Total Profit")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text(String(format: "%.2f", totalProfit))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(totalProfit >= 0 ? .green : .red)
                    }
                    .padding(.vertical, 5)
                    
                    // Profit Margin
                    HStack {
                        Text("Profit Margin")
                            .foregroundColor(.white)
                        Spacer()
                        Text(String(format: "%.1f%%", proposal.totalAmount > 0 ? (totalProfit / proposal.totalAmount) * 100 : 0))
                            .fontWeight(.semibold)
                            .foregroundColor(totalProfit >= 0 ? .green : .red)
                    }
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Task Summary Section
    private var taskSummarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if !proposal.tasksArray.isEmpty {
                    Text("(\(proposal.tasksArray.count))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    showingAddTask = true
                }) {
                    Label("Add", systemImage: "plus")
                        .foregroundColor(.blue)
                }
            }
            
            TaskSummaryView(proposal: proposal)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Activity Summary Section
    private var activitySummarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Activity")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: { showingAddComment = true }) {
                        Label("Add Comment", systemImage: "text.bubble")
                            .foregroundColor(.blue)
                    }
                    
                    NavigationLink(destination: ActivityDetailView(proposal: proposal)) {
                        Label("View All", systemImage: "list.bullet")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            ActivityLogView(proposal: proposal)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Notes Section
    private func notesSection(notes: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Notes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Divider()
                    .background(Color.gray.opacity(0.5))
                
                Text(notes)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Components
    
    private struct SummaryRow: View {
        let title: String
        let value: Double
        var titleColor: Color = .white
        var valueColor: Color = .white
        
        var body: some View {
            HStack {
                Text(title)
                    .foregroundColor(titleColor)
                Spacer()
                Text(String(format: "%.2f", value))
                    .foregroundColor(valueColor)
            }
            .padding(.vertical, 3)
        }
    }
    
    // MARK: - Helper Methods
    
    // Helper method to calculate multiplier value
    private func calculateMultiplier(_ item: ProposalItem) -> Double {
        // Calculate it based on the formula
        let listPrice = item.product?.listPrice ?? 0
        if listPrice > 0 {
            let discountFactor = 1.0 - (item.discount / 100.0)
            if discountFactor > 0 {
                return item.unitPrice / (listPrice * discountFactor)
            }
        }
        return 1.0 // Default value
    }
    
    private func calculatePartnerCost() -> Double {
        var totalCost = 0.0
        
        // Sum partner cost for all products
        for item in proposal.itemsArray {
            let partnerPrice = item.product?.partnerPrice ?? 0
            totalCost += partnerPrice * item.quantity
        }
        
        // Add expenses
        totalCost += proposal.subtotalExpenses
        
        return totalCost
    }
    
    // MARK: - CRUD Operations
    
    private func deleteItem(_ item: ProposalItem) {
        withAnimation {
            // Log activity before deleting
            if let product = item.product {
                ActivityLogger.logItemRemoved(
                    proposal: proposal,
                    context: viewContext,
                    itemType: "Product",
                    itemName: product.name ?? "Unknown"
                )
            }
            
            viewContext.delete(item)
            
            do {
                try viewContext.save()
                updateProposalTotal()
                refreshId = UUID() // Force refresh
            } catch {
                let nsError = error as NSError
                print("Error deleting item: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteEngineering(_ engineering: Engineering) {
        withAnimation {
            // Log engineering removal
            ActivityLogger.logItemRemoved(
                proposal: proposal,
                context: viewContext,
                itemType: "Engineering",
                itemName: engineering.desc ?? "Engineering entry"
            )
            
            viewContext.delete(engineering)
            
            do {
                try viewContext.save()
                updateProposalTotal()
            } catch {
                let nsError = error as NSError
                print("Error deleting engineering: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteExpense(_ expense: Expense) {
        withAnimation {
            // Log expense removal
            ActivityLogger.logItemRemoved(
                proposal: proposal,
                context: viewContext,
                itemType: "Expense",
                itemName: expense.desc ?? "Expense entry"
            )
            
            viewContext.delete(expense)
            
            do {
                try viewContext.save()
                updateProposalTotal()
            } catch {
                let nsError = error as NSError
                print("Error deleting expense: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteTax(_ tax: CustomTax) {
        withAnimation {
            // Log tax removal
            ActivityLogger.logItemRemoved(
                proposal: proposal,
                context: viewContext,
                itemType: "Tax",
                itemName: tax.name ?? "Custom tax"
            )
            
            viewContext.delete(tax)
            
            do {
                try viewContext.save()
                updateProposalTotal()
            } catch {
                let nsError = error as NSError
                print("Error deleting tax: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Function to update the proposal total after changes
    private func updateProposalTotal() {
        // Calculate total amount from all components
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
    
    private func addComment() {
        ActivityLogger.logCommentAdded(
            proposal: proposal,
            context: viewContext,
            comment: commentText
        )
        
        commentText = ""
    }
}

// MARK: - Proposal Header Section
struct ProposalHeaderSection: View {
    let proposal: Proposal
    let onEditTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with action buttons
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(proposal.formattedNumber)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(proposal.customerName)
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: onEditTapped) {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                        .padding(10)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                }
            }
            .padding([.horizontal, .top])
            
            // Status and date
            HStack {
                // Status badge
                Text(proposal.formattedStatus)
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusColor(for: proposal.formattedStatus))
                    .foregroundColor(.white)
                    .cornerRadius(5)
                
                Text(proposal.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Amount
                Text(proposal.formattedTotal)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.top, 5)
        }
        .padding(.bottom, 10)
        .background(Color.black)
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "Draft": return .gray
        case "Pending": return .orange
        case "Sent": return .blue
        case "Won": return .green
        case "Lost": return .red
        case "Expired": return .purple
        default: return .gray
        }
    }
}
