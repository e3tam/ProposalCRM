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
                
                // Products Section
                productsSection
                
                // Engineering Section
                engineeringSection
                
                // Expenses Section
                expensesSection
                
                // Custom Taxes Section
                customTaxesSection
                
                // Financial Summary
                financialSummarySection
                
                // Notes Section
                if let notes = proposal.notes, !notes.isEmpty {
                    notesSection(notes: notes)
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
    
    // MARK: - Sections
    
    // MARK: - Sections
    
    private var productsSection: some View {
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
            
            if proposal.itemsArray.isEmpty {
                Text("No products added yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
                    .cornerRadius(8)
            } else {
                // Based on the screenshot, need to handle item deletion and editing
                ProductTableView(
                    proposal,
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
    }
    
    private var engineeringSection: some View {
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
    }
    
    private var expensesSection: some View {
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
    }
    
    private var customTaxesSection: some View {
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
    }
    
    private var financialSummarySection: some View {
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
    }
    
    private func notesSection(notes: String) -> some View {
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
    
    // MARK: - Helper Functions
    
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

// MARK: - Supporting Views

struct EditProposalItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var item: ProposalItem
    
    @State private var quantity: Double
    @State private var discount: Double
    @State private var unitPrice: Double
    
    init(item: ProposalItem) {
        self.item = item
        _quantity = State(initialValue: item.quantity)
        _discount = State(initialValue: item.discount)
        _unitPrice = State(initialValue: item.unitPrice)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Details")) {
                    Text(item.productName)
                        .font(.headline)
                    
                    Text(item.productCode)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Quantity and Pricing")) {
                    Stepper("Quantity: \(Int(quantity))", value: $quantity, in: 1...100)
                    
                    HStack {
                        Text("Discount (%)")
                        Spacer()
                        Slider(value: $discount, in: 0...50, step: 1)
                        Text("\(Int(discount))%")
                            .frame(width: 50, alignment: .trailing)
                    }
                    
                    HStack {
                        Text("Unit Price")
                        Spacer()
                        TextField("Unit Price", value: $unitPrice, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        Text(String(format: "%.2f", calculateAmount()))
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    private func calculateAmount() -> Double {
        return unitPrice * quantity
    }
    
    private func saveChanges() {
        item.quantity = quantity
        item.discount = discount
        item.unitPrice = unitPrice
        item.amount = calculateAmount()
        
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

// Use the existing ProductTableView from the Products folder
