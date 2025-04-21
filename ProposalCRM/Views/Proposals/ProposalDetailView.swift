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
                        ProductsTableSection(
                            proposal: proposal,
                            onAdd: { showingItemSelection = true },
                            onEdit: { item in
                                itemToEdit = item
                                showEditItemSheet = true
                            },
                            onDelete: { item in
                                itemToDelete = item
                                showDeleteConfirmation = true
                            }
                        )
                        .id(refreshId)  // Force refresh when id changes
                        
                        // ENGINEERING SECTION
                        EngineeringTableSection(
                            proposal: proposal,
                            onAdd: { showingEngineeringForm = true },
                            onEdit: { engineering in
                                engineeringToEdit = engineering
                                showEditEngineeringSheet = true
                            },
                            onDelete: { engineering in
                                deleteEngineering(engineering)
                            }
                        )
                        
                        // EXPENSES SECTION
                        ExpensesTableSection(
                            proposal: proposal,
                            onAdd: { showingExpensesForm = true },
                            onEdit: { expense in
                                expenseToEdit = expense
                                showEditExpenseSheet = true
                            },
                            onDelete: { expense in
                                deleteExpense(expense)
                            }
                        )
                        
                        // CUSTOM TAXES SECTION
                        CustomTaxesTableSection(
                            proposal: proposal,
                            onAdd: { showingCustomTaxForm = true },
                            onEdit: { tax in
                                taxToEdit = tax
                                showEditTaxSheet = true
                            },
                            onDelete: { tax in
                                deleteTax(tax)
                            }
                        )
                        
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
