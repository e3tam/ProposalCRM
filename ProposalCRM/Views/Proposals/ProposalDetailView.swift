// ProposalDetailView.swift
// View a proposal's details with the ability to edit components

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
                
                // Items Section
                SectionWithAddButton(
                    title: "Products",
                    count: proposal.itemsArray.count,
                    onAdd: { showingItemSelection = true }
                ) {
                    ForEach(proposal.itemsArray, id: \.self) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.productName)
                                    .font(.headline)
                                Text(item.productCode)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("\(Int(item.quantity))x")
                                    .font(.subheadline)
                                Text(item.formattedAmount)
                                    .font(.headline)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Engineering Section
                SectionWithAddButton(
                    title: "Engineering",
                    count: proposal.engineeringArray.count,
                    onAdd: { showingEngineeringForm = true }
                ) {
                    ForEach(proposal.engineeringArray, id: \.self) { engineering in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(engineering.description ?? "")
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
                            Text(expense.description ?? "")
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
                        
                        HStack {
                            Text("Profit Margin")
                            Spacer()
                            Text(String(format: "%.1f%%", proposal.profitMargin))
                                .foregroundColor(proposal.profitMargin < 20 ? .red : .green)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Notes Section
                if !proposal.notes!.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Divider()
                        
                        Text(proposal.notes ?? "")
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
}
