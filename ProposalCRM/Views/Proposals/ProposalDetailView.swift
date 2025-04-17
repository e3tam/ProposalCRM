// ProposalDetailView.swift
// View a proposal's details with the enhanced product table

import SwiftUI

struct ProposalDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var proposal: Proposal
    
    @State private var showingItemSelection = false
    @State private var showingEngineeringForm = false
    @State private var showingExpensesForm = false
    @State private var showingCustomTaxForm = false
    @State private var showingEditProposal = false
    @State private var showingFinancialDetails = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Proposal header
                ProposalHeaderView(proposal: proposal)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Items Section with enhanced table view
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
                    
                    // Our enhanced product table view
                    EnhancedProductTableView(proposal: proposal)
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
                
                // Financial Summary - Safe version without custom properties
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
}
