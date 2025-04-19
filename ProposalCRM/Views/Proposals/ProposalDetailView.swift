//
//  ProposalDetailView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


//
//  ProposalDetailView.swift
//  ProposalCRM
//

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
    
    // Task and activity state variables
    @State private var showingAddTask = false
    @State private var showingAddComment = false
    @State private var commentText = ""    
    @State private var taskListRefreshTrigger = UUID()    // State variables for product item editing
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
                    // Fixed header section using a separate component with action callback
                    ProposalHeaderSection(
                        proposal: proposal,
                        onEditTapped: {
                            showingEditProposal = true
                        }
                    )
                    
                    // Content sections with proper spacing
                    VStack(alignment: .leading, spacing: 20) {
                        // PRODUCTS SECTION
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
                            
                            ZStack {
                                // Solid background
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black.opacity(0.2))
                                
                                VStack(spacing: 0) {
                                    // Table header with scrollable view for all columns
                                    ScrollView(.horizontal, showsIndicators: true) {
                                        HStack(spacing: 0) {
                                            // Product Name
                                            Text("Product Name")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 180, alignment: .leading)
                                                .padding(.horizontal, 5)
                                            
                                            Divider().frame(height: 36)
                                            
                                            // Qty
                                            Text("Qty")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 50, alignment: .center)
                                                .padding(.horizontal, 5)
                                            
                                            Divider().frame(height: 36)
                                            
                                            // Unit Partner Price
                                            Text("Unit Partner Price")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 120, alignment: .trailing)
                                                .padding(.horizontal, 5)
                                            
                                            Divider().frame(height: 36)
                                            
                                            // Unit List Price
                                            Text("Unit List Price")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 120, alignment: .trailing)
                                                .padding(.horizontal, 5)
                                            
                                            Divider().frame(height: 36)
                                            
                                            // Multiplier
                                            Text("Multiplier")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 80, alignment: .center)
                                                .padding(.horizontal, 5)
                                            
                                            Divider().frame(height: 36)
                                            
                                            // Discount
                                            Text("Discount")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 80, alignment: .center)
                                                .padding(.horizontal, 5)
                                            
                                            Divider().frame(height: 36)
                                            
                                            // Ext Partner Price
                                            Text("Ext Partner Price")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 120, alignment: .trailing)
                                                .padding(.horizontal, 5)
                                            
                                            Divider().frame(height: 36)
                                            
                                            // Ext List Price
                                            Text("Ext List Price")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 120, alignment: .trailing)
                                                .padding(.horizontal, 5)
                                            
                                            Divider().frame(height: 36)
                                            
                                            // Ext Customer Price
                                            Text("Ext Customer Price")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 120, alignment: .trailing)
                                                .padding(.horizontal, 5)
                                            
                                            Divider().frame(height: 36)
                                            
                                            // Total Profit
                                            Text("Total Profit")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 100, alignment: .trailing)
                                                .padding(.horizontal, 5)
                                            
                                            Divider().frame(height: 36)
                                            
                                            // Custom Tax?
                                            Text("Custom Tax?")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 90, alignment: .center)
                                                .padding(.horizontal, 5)
                                            
                                            Divider().frame(height: 36)
                                            
                                            // Actions
                                            Text("Act")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 60, alignment: .center)
                                                .padding(.horizontal, 5)
                                        }
                                        .padding(.vertical, 10)
                                        .background(Color.black.opacity(0.3))
                                    }
                                    
                                    Divider().background(Color.gray)
                                    
                                    // Main table content with rows
                                    if proposal.itemsArray.isEmpty {
                                        Text("No products added yet")
                                            .foregroundColor(.gray)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                    } else {
                                        ScrollView {
                                            VStack(spacing: 0) {
                                                ForEach(proposal.itemsArray, id: \.self) { item in
                                                    ScrollView(.horizontal, showsIndicators: true) {
                                                        HStack(spacing: 0) {
                                                            // Product Name with code
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
                                                            
                                                            Divider().frame(height: 40)
                                                            
                                                            // Quantity
                                                            Text("\(Int(item.quantity))")
                                                                .font(.system(size: 14))
                                                                .frame(width: 50, alignment: .center)
                                                                .padding(.horizontal, 5)
                                                            
                                                            Divider().frame(height: 40)
                                                            
                                                            // Unit Partner Price
                                                            let partnerPrice = item.product?.partnerPrice ?? 0
                                                            Text(String(format: "%.2f", partnerPrice))
                                                                .font(.system(size: 14))
                                                                .frame(width: 120, alignment: .trailing)
                                                                .padding(.horizontal, 5)
                                                            
                                                            Divider().frame(height: 40)
                                                            
                                                            // Unit List Price
                                                            let listPrice = item.product?.listPrice ?? 0
                                                            Text(String(format: "%.2f", listPrice))
                                                                .font(.system(size: 14))
                                                                .frame(width: 120, alignment: .trailing)
                                                                .padding(.horizontal, 5)
                                                            
                                                            Divider().frame(height: 40)
                                                            
                                                            // Multiplier (calculated from price data)
                                                            Text(String(format: "%.2f", calculateMultiplier(item)))
                                                                .font(.system(size: 14))
                                                                .frame(width: 80, alignment: .center)
                                                                .padding(.horizontal, 5)
                                                            
                                                            Divider().frame(height: 40)
                                                            
                                                            // Discount
                                                            Text(String(format: "%.1f%%", item.discount))
                                                                .font(.system(size: 14))
                                                                .frame(width: 80, alignment: .center)
                                                                .padding(.horizontal, 5)
                                                            
                                                            Divider().frame(height: 40)
                                                            
                                                            // Ext Partner Price
                                                            let extPartnerPrice = partnerPrice * item.quantity
                                                            Text(String(format: "%.2f", extPartnerPrice))
                                                                .font(.system(size: 14))
                                                                .frame(width: 120, alignment: .trailing)
                                                                .padding(.horizontal, 5)
                                                            
                                                            Divider().frame(height: 40)
                                                            
                                                            // Ext List Price
                                                            let extListPrice = listPrice * item.quantity
                                                            Text(String(format: "%.2f", extListPrice))
                                                                .font(.system(size: 14))
                                                                .frame(width: 120, alignment: .trailing)
                                                                .padding(.horizontal, 5)
                                                            
                                                            Divider().frame(height: 40)
                                                            
                                                            // Ext Customer Price (amount)
                                                            Text(String(format: "%.2f", item.amount))
                                                                .font(.system(size: 14))
                                                                .frame(width: 120, alignment: .trailing)
                                                                .padding(.horizontal, 5)
                                                            
                                                            Divider().frame(height: 40)
                                                            
                                                            // Total Profit
                                                            let profit = item.amount - extPartnerPrice
                                                            Text(String(format: "%.2f", profit))
                                                                .font(.system(size: 14))
                                                                .foregroundColor(profit > 0 ? .green : .red)
                                                                .frame(width: 100, alignment: .trailing)
                                                                .padding(.horizontal, 5)
                                                            
                                                            Divider().frame(height: 40)
                                                            
                                                            // Custom Tax?
                                                            Text("No")
                                                                .font(.system(size: 14))
                                                                .frame(width: 90, alignment: .center)
                                                                .padding(.horizontal, 5)
                                                            
                                                            Divider().frame(height: 40)
                                                            
                                                            // Action buttons
                                                            HStack(spacing: 15) {
                                                                Button(action: {
                                                                    itemToEdit = item
                                                                    showEditItemSheet = true
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
                                                    }
                                                    .background(Color.black.opacity(0.2))
                                                    
                                                    Divider().background(Color.gray.opacity(0.5))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // ENGINEERING SECTION
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
                            
                            ZStack {
                                // Solid background
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black.opacity(0.2))
                                
                                // Table content
                                VStack(spacing: 0) {
                                    // Header
                                    HStack {
                                        Text("Description")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("Days")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .frame(width: 60, alignment: .center)
                                        
                                        Text("Rate")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .frame(width: 80, alignment: .trailing)
                                        
                                        Text("Amount")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .frame(width: 100, alignment: .trailing)
                                        
                                        Text("Act")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .frame(width: 60, alignment: .center)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.black.opacity(0.3))
                                    
                                    Divider().background(Color.gray)
                                    
                                    // Engineering rows or empty state
                                    if proposal.engineeringArray.isEmpty {
                                        Text("No engineering services added yet")
                                            .foregroundColor(.gray)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                    } else {
                                        ForEach(proposal.engineeringArray, id: \.self) { engineering in
                                            HStack {
                                                Text(engineering.desc ?? "")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                Text(String(format: "%.1f", engineering.days))
                                                    .font(.subheadline)
                                                    .frame(width: 60, alignment: .center)
                                                
                                                Text(String(format: "%.2f", engineering.rate))
                                                    .font(.subheadline)
                                                    .frame(width: 80, alignment: .trailing)
                                                
                                                Text(String(format: "%.2f", engineering.amount))
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                                    .frame(width: 100, alignment: .trailing)
                                                
                                                HStack(spacing: 15) {
                                                    Button(action: {
                                                        engineeringToEdit = engineering
                                                        showEditEngineeringSheet = true
                                                    }) {
                                                        Image(systemName: "pencil")
                                                            .foregroundColor(.blue)
                                                    }
                                                    
                                                    Button(action: {
                                                        deleteEngineering(engineering)
                                                    }) {
                                                        Image(systemName: "trash")
                                                            .foregroundColor(.red)
                                                    }
                                                }
                                                .frame(width: 60, alignment: .center)
                                            }
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(Color.black.opacity(0.1))
                                            
                                            Divider().background(Color.gray.opacity(0.3))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // EXPENSES SECTION
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
                            
                            ZStack {
                                // Solid background
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black.opacity(0.2))
                                
                                // Table content
                                VStack(spacing: 0) {
                                    // Header
                                    HStack {
                                        Text("Description")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("Amount")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .frame(width: 100, alignment: .trailing)
                                        
                                        Text("Act")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .frame(width: 60, alignment: .center)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.black.opacity(0.3))
                                    
                                    Divider().background(Color.gray)
                                    
                                    // Expense rows or empty state
                                    if proposal.expensesArray.isEmpty {
                                        Text("No expenses added yet")
                                            .foregroundColor(.gray)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                    } else {
                                        ForEach(proposal.expensesArray, id: \.self) { expense in
                                            HStack {
                                                Text(expense.desc ?? "")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                Text(String(format: "%.2f", expense.amount))
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                                    .frame(width: 100, alignment: .trailing)
                                                
                                                HStack(spacing: 15) {
                                                    Button(action: {
                                                        expenseToEdit = expense
                                                        showEditExpenseSheet = true
                                                    }) {
                                                        Image(systemName: "pencil")
                                                            .foregroundColor(.blue)
                                                    }
                                                    
                                                    Button(action: {
                                                        deleteExpense(expense)
                                                    }) {
                                                        Image(systemName: "trash")
                                                            .foregroundColor(.red)
                                                    }
                                                }
                                                .frame(width: 60, alignment: .center)
                                            }
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(Color.black.opacity(0.1))
                                            
                                            Divider().background(Color.gray.opacity(0.3))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // CUSTOM TAXES SECTION
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Custom Taxes")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: { showingCustomTaxForm = true }) {
                                    Label("Add", systemImage: "plus")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            ZStack {
                                // Solid background
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black.opacity(0.2))
                                
                                // Table content
                                VStack(spacing: 0) {
                                    // Header
                                    HStack {
                                        Text("Tax Name")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("Rate")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .frame(width: 80, alignment: .trailing)
                                        
                                        Text("Amount")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .frame(width: 100, alignment: .trailing)
                                        
                                        Text("Act")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .frame(width: 60, alignment: .center)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.black.opacity(0.3))
                                    
                                    Divider().background(Color.gray)
                                    
                                    // Custom tax rows or empty state
                                    if proposal.taxesArray.isEmpty {
                                        Text("No custom taxes added yet")
                                            .foregroundColor(.gray)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                    } else {
                                        ForEach(proposal.taxesArray, id: \.self) { tax in
                                            HStack {
                                                Text(tax.name ?? "")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                Text(String(format: "%.1f%%", tax.rate))
                                                    .font(.subheadline)
                                                    .frame(width: 80, alignment: .trailing)
                                                
                                                Text(String(format: "%.2f", tax.amount))
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                                    .frame(width: 100, alignment: .trailing)
                                                
                                                HStack(spacing: 15) {
                                                    Button(action: {
                                                        taxToEdit = tax
                                                        showEditTaxSheet = true
                                                    }) {
                                                        Image(systemName: "pencil")
                                                            .foregroundColor(.blue)
                                                    }
                                                    
                                                    Button(action: {
                                                        deleteTax(tax)
                                                    }) {
                                                        Image(systemName: "trash")
                                                            .foregroundColor(.red)
                                                    }
                                                }
                                                .frame(width: 60, alignment: .center)
                                            }
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(Color.black.opacity(0.1))
                                            
                                            Divider().background(Color.gray.opacity(0.3))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // FINANCIAL SUMMARY SECTION
                        financialSummarySection
                        
                        // TASK SECTION - IMPORTANT NEW ADDITION
                        taskSummarySection
                        
                        // ACTIVITY SECTION - IMPORTANT NEW ADDITION
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
        .sheet(isPresented: $showEditItemSheet) {
            if let item = itemToEdit {
                EditProposalItemView(item: item, didSave: $didSaveItemChanges)
                    .environment(\.managedObjectContext, viewContext)
                    .onDisappear {
                        if didSaveItemChanges {
                            // Force refresh the view when changes were saved
                            updateProposalTotal()
                            
                            // Reset the flag
                            didSaveItemChanges = false
                            
                            // Force UI refresh by triggering state change
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                // Just update any state variable to trigger refresh
                                showEditItemSheet = false
                            }
                        }
                    }
            }
        }
        // TASK PRESENTATION SHEET
        .sheet(isPresented: $showingAddTask, onDismiss: {
            print("DEBUG: Add Task sheet dismissed")
            
            // Force refresh the task list
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("DEBUG: Refreshing task list after sheet dismissal")
                self.taskListRefreshTrigger = UUID()
                
                // For very stubborn cases, try explicitly refreshing the Core Data fetch
                let context = PersistenceController.shared.container.viewContext
                context.refreshAllObjects()
            }
        }) {
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
    
    // MARK: - Task Summary Section
    private var taskSummarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // This forces view refresh when tasks change
            let _ = taskListRefreshTrigger
            
            HStack {
                Text("Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if proposal.tasksArray.count > 0 {
                    Text("(\(proposal.tasksArray.count))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    print("DEBUG: Add Task button tapped")
                    showingAddTask = true
                }) {
                    Label("Add", systemImage: "plus")
                        .foregroundColor(.blue)
                }
            }
            
            // For debugging, add this temporarily
            Text("DEBUG: Task count: \(proposal.tasksArray.count)")
                .font(.caption)
                .foregroundColor(.yellow)
                .padding(4)
                .background(Color.black)
                .cornerRadius(4)
            
            if proposal.tasksArray.isEmpty {
                Text("No tasks created yet")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
            } else {
                ZStack {
                    // Solid background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.2))
                    
                    VStack(spacing: 0) {
                        // Task list
                        ForEach(proposal.tasksArray.prefix(5), id: \.self) { task in
                            NavigationLink(destination: TaskDetailView(task: task)) {
                                HStack {
                                    Circle()
                                        .fill(task.statusColor)
                                        .frame(width: 12, height: 12)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(task.title ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .strikethrough(task.status == "Completed")
                                        
                                        HStack {
                                            Circle()
                                                .fill(task.priorityColor)
                                                .frame(width: 8, height: 8)
                                            
                                            Text(task.priority ?? "")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            
                                            if let dueDate = task.dueDate {
                                                Text("•")
                                                    .foregroundColor(.gray)
                                                
                                                Text(dueDate, style: .date)
                                                    .font(.caption)
                                                    .foregroundColor(task.isOverdue ? .red : .gray)
                                            }
                                            
                                            if task.isOverdue {
                                                Text("OVERDUE")
                                                    .font(.caption)
                                                    .padding(2)
                                                    .background(Color.red)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(4)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .background(Color.black.opacity(0.1))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                        
                        // Show more button if needed
                        if proposal.tasksArray.count > 5 {
                            NavigationLink(destination: TaskListViewForProposal(proposal: proposal)) {
                                Text("View All \(proposal.tasksArray.count) Tasks")
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            print("DEBUG: Task summary section appeared, task count: \(proposal.tasksArray.count)")
            print("DEBUG: Proposal ID: \(proposal.id?.uuidString ?? "unknown")")
            
            // Diagnostic: Try to fetch tasks directly
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "proposal.id == %@", proposal.id! as CVarArg)
            
            do {
                let fetchedTasks = try viewContext.fetch(fetchRequest)
                print("DEBUG: Directly fetched tasks count: \(fetchedTasks.count)")
                for task in fetchedTasks {
                    print("DEBUG: Task ID: \(task.id?.uuidString ?? "unknown"), Title: \(task.title ?? "no title")")
                }
            } catch {
                print("DEBUG: Error fetching tasks directly: \(error)")
            }
        }
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
            
            if proposal.activitiesArray.isEmpty {
                Text("No activity recorded yet")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
            } else {
                ZStack {
                    // Solid background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.2))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        // Only show the 5 most recent activities
                        ForEach(proposal.activitiesArray.prefix(5), id: \.self) { activity in
                            HStack(spacing: 12) {
                                // Timeline dot and line
                                VStack(spacing: 0) {
                                    Circle()
                                        .fill(activity.typeColor)
                                        .frame(width: 10, height: 10)
                                    
                                    if activity != proposal.activitiesArray.prefix(5).last {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 2)
                                    }
                                }
                                .frame(height: 50)
                                
                                // Activity summary
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(activity.description ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                    Text(activity.formattedTimestamp)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                        if proposal.activitiesArray.count > 5 {
                            NavigationLink(destination: ActivityDetailView(proposal: proposal)) {
                                Text("View All Activity")
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Financial Summary Section
    private var financialSummarySection: some View {
        ZStack {
            // Solid background
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
    
    // MARK: - Helper method to calculate multiplier value
    private func calculateMultiplier(_ item: ProposalItem) -> Double {
        if let product = item.product, product.listPrice > 0 {
            let discountFactor = 1.0 - (item.discount / 100.0)
            if discountFactor > 0 {
                return item.unitPrice / (product.listPrice * discountFactor)
            }
        }
        return 1.0 // Default value
    }
    
    // MARK: - Helper functions and structures
    private func logStatusChange(oldStatus: String, newStatus: String) {
        ActivityLogger.logStatusChanged(
            proposal: proposal,
            context: viewContext,
            oldStatus: oldStatus,
            newStatus: newStatus
        )
    }

    private func logProposalEdit(fieldChanged: String) {
        ActivityLogger.logProposalUpdated(
            proposal: proposal,
            context: viewContext,
            fieldChanged: fieldChanged
        )
    }
    
    private func addComment() {
        ActivityLogger.logCommentAdded(
            proposal: proposal,
            context: viewContext,
            comment: commentText
        )
        
        commentText = ""
    }

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
}
