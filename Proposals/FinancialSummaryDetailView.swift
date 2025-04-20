// FinancialSummaryDetailView.swift
// Detailed financial analysis of a proposal

import SwiftUI

struct FinancialSummaryDetailView: View {
    @ObservedObject var proposal: Proposal
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Revenue Breakdown
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Revenue Breakdown")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Divider()
                        
                        // Placeholder for pie chart
                        Text("Revenue breakdown chart would go here")
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        
                        Group {
                            HStack {
                                Text("Products")
                                Spacer()
                                Text(String(format: "%.2f", proposal.subtotalProducts))
                            }
                            
                            HStack {
                                Text("Engineering")
                                Spacer()
                                Text(String(format: "%.2f", proposal.subtotalEngineering))
                            }
                            
                            HStack {
                                Text("Expenses")
                                Spacer()
                                Text(String(format: "%.2f", proposal.subtotalExpenses))
                            }
                            
                            HStack {
                                Text("Taxes")
                                Spacer()
                                Text(String(format: "%.2f", proposal.subtotalTaxes))
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Cost & Profit Analysis
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cost & Profit Analysis")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Divider()
                        
                        Group {
                            HStack {
                                Text("Total Revenue")
                                Spacer()
                                Text(String(format: "%.2f", proposal.totalAmount))
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Total Cost")
                                Spacer()
                                Text(String(format: "%.2f", proposal.totalCost))
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Gross Profit")
                                Spacer()
                                Text(String(format: "%.2f", proposal.grossProfit))
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Profit Margin")
                                Spacer()
                                Text(String(format: "%.1f%%", proposal.profitMargin))
                                    .fontWeight(.bold)
                                    .foregroundColor(proposal.profitMargin < 20 ? .red : .green)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .navigationTitle("Financial Analysis")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
