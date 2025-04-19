//
//  ProposalDetailView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


// ProposalDetailView.swift
// Shows the detailed view of a proposal with all its components

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
    
    // State variables for deletion confirmation
    @State private var showDeleteConfirmation = false
    @State private var itemToDelete: ProposalItem?
    
    // State variables for product item editing
    @State private var itemToEdit: ProposalItem?
    @State private var showEditItemSheet = false
    
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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Back button and proposal title
                HStack {
                    NavigationLink(destination: EmptyView()) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Customer Details")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Proposal Details")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showingEditProposal = true }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                
                // Proposal header
                ProposalHeaderView(proposal: proposal)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                
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
            .padding(.vertical)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
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
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(8)
            } else {
                // Use our custom ProductTableView with the proposal and callbacks
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
        .padding(.horizontal)
    }
    
    private var engineeringSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Engineering")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if proposal.engineeringArray.count > 0 {
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
            
            // Use our custom EngineeringTableView with direct callbacks instead of state variables
            EngineeringTableView(
                proposal,
                onDelete: { engineering in
                    viewContext.delete(engineering)
                    
                    do {
                        try viewContext.save()
                        updateProposalTotal()
                    } catch {
                        print("Error deleting engineering: \(error)")
                    }
                },
                onEdit: { engineering in
                    // Set the engineering to edit and show the sheet
                    engineeringToEdit = engineering
                    showEditEngineeringSheet = true
                }
            )
        }
        .padding(.horizontal)
        .sheet(isPresented: $showEditEngineeringSheet) {
            if let engineering = engineeringToEdit {
                NavigationView {
                    EngineeringEditMenu(
                        engineering: engineering,
                        isPresented: $showEditEngineeringSheet,
                        onSave: {
                            updateProposalTotal()
                        }
                    )
                    .navigationTitle("Edit Engineering")
                    .navigationBarItems(trailing: Button("Done") {
                        showEditEngineeringSheet = false
                    })
                }
            }
        }
    }
    
    private var expensesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Expenses")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if proposal.expensesArray.count > 0 {
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
            
            // Use our custom ExpensesTableView with direct callbacks
            ExpensesTableView(
                proposal,
                onDelete: { expense in
                    viewContext.delete(expense)
                    
                    do {
                        try viewContext.save()
                        updateProposalTotal()
                    } catch {
                        print("Error deleting expense: \(error)")
                    }
                },
                onEdit: { expense in
                    // Set the expense to edit and show the sheet
                    expenseToEdit = expense
                    showEditExpenseSheet = true
                }
            )
        }
        .padding(.horizontal)
        .sheet(isPresented: $showEditExpenseSheet) {
            if let expense = expenseToEdit {
                NavigationView {
                    ExpensesEditMenu(
                        expense: expense,
                        isPresented: $showEditExpenseSheet,
                        onSave: {
                            updateProposalTotal()
                        }
                    )
                    .navigationTitle("Edit Expense")
                    .navigationBarItems(trailing: Button("Done") {
                        showEditExpenseSheet = false
                    })
                }
            }
        }
    }
    
    private var customTaxesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Custom Taxes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if proposal.taxesArray.count > 0 {
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
            
            // Use our custom CustomTaxesTableView with direct callbacks
            CustomTaxesTableView(
                proposal,
                onDelete: { tax in
                    viewContext.delete(tax)
                    
                    do {
                        try viewContext.save()
                        updateProposalTotal()
                    } catch {
                        print("Error deleting tax: \(error)")
                    }
                },
                onEdit: { tax in
                    // Set the tax to edit and show the sheet
                    taxToEdit = tax
                    showEditTaxSheet = true
                }
            )
        }
        .padding(.horizontal)
        .sheet(isPresented: $showEditTaxSheet) {
            if let tax = taxToEdit {
                NavigationView {
                    CustomTaxEditMenu(
                        customTax: tax,
                        proposal: proposal,
                        isPresented: $showEditTaxSheet,
                        onSave: {
                            updateProposalTotal()
                        }
                    )
                    .navigationTitle("Edit Custom Tax")
                    .navigationBarItems(trailing: Button("Done") {
                        showEditTaxSheet = false
                    })
                }
            }
        }
    }
    
    private var financialSummarySection: some View {
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
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
    
    // Helper view for consistent financial summary rows
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
                updateProposalTotal()
            } catch {
                let nsError = error as NSError
                print("Error deleting item: \(nsError), \(nsError.userInfo)")
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
}
