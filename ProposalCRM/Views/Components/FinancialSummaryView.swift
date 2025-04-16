// FinancialSummaryView.swift
// Dashboard showing financial metrics for all proposals

import SwiftUI
import CoreData

struct FinancialSummaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Proposal.creationDate, ascending: false)],
        animation: .default)
    private var proposals: FetchedResults<Proposal>
    
    @State private var selectedTimePeriod = "All Time"
    
    let timePeriods = ["Last Month", "Last 3 Months", "Last 6 Months", "Last Year", "All Time"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time period picker
                Picker("Time Period", selection: $selectedTimePeriod) {
                    ForEach(timePeriods, id: \.self) { period in
                        Text(period).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Status Overview
                VStack(alignment: .leading, spacing: 10) {
                    Text("Proposal Status Overview")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            StatusCardView(
                                title: "Draft",
                                count: proposalCountByStatus("Draft"),
                                value: proposalValueByStatus("Draft"),
                                color: .gray
                            )
                            
                            StatusCardView(
                                title: "Pending",
                                count: proposalCountByStatus("Pending"),
                                value: proposalValueByStatus("Pending"),
                                color: .orange
                            )
                            
                            StatusCardView(
                                title: "Sent",
                                count: proposalCountByStatus("Sent"),
                                value: proposalValueByStatus("Sent"),
                                color: .blue
                            )
                            
                            StatusCardView(
                                title: "Won",
                                count: proposalCountByStatus("Won"),
                                value: proposalValueByStatus("Won"),
                                color: .green
                            )
                            
                            StatusCardView(
                                title: "Lost",
                                count: proposalCountByStatus("Lost"),
                                value: proposalValueByStatus("Lost"),
                                color: .red
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Financial Summary
                VStack(alignment: .leading, spacing: 10) {
                    Text("Financial Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        // Total proposed amount
                        SummaryCardView(
                            title: "Total Proposed",
                            value: totalProposedAmount(),
                            subtitle: "\(filteredProposals.count) proposals",
                            color: .blue,
                            icon: "doc.text"
                        )
                        
                        // Won amount
                        SummaryCardView(
                            title: "Won Revenue",
                            value: proposalValueByStatus("Won"),
                            subtitle: "Success Rate: \(String(format: "%.1f%%", successRate()))",
                            color: .green,
                            icon: "checkmark.circle"
                        )
                        
                        // Average proposal value
                        SummaryCardView(
                            title: "Average Proposal Value",
                            value: averageProposalValue(),
                            subtitle: "Median: \(String(format: "%.2f", medianProposalValue()))",
                            color: .purple,
                            icon: "chart.bar"
                        )
                        
                        // Average profit margin
                        SummaryCardView(
                            title: "Average Profit Margin",
                            value: averageProfitMargin(),
                            valueFormat: "%.1f%%",
                            subtitle: "Total Profit: \(String(format: "%.2f", totalProfit()))",
                            color: .orange,
                            icon: "chart.pie"
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Financial Dashboard")
    }
    
    // MARK: - Filtered Data
    
    var filteredProposals: [Proposal] {
        let filtered = Array(proposals)
        
        // If "All Time" is selected, return all proposals
        if selectedTimePeriod == "All Time" {
            return filtered
        }
        
        // Get cutoff date based on selected time period
        let calendar = Calendar.current
        let now = Date()
        var cutoffDate: Date?
        
        switch selectedTimePeriod {
        case "Last Month":
            cutoffDate = calendar.date(byAdding: .month, value: -1, to: now)
        case "Last 3 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -3, to: now)
        case "Last 6 Months":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now)
        case "Last Year":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now)
        default:
            cutoffDate = nil
        }
        
        // Filter proposals by date
        if let cutoffDate = cutoffDate {
            return filtered.filter { proposal in
                if let date = proposal.creationDate {
                    return date >= cutoffDate
                }
                return false
            }
        }
        
        return filtered
    }
    
    // MARK: - Financial Calculations
    
    private func proposalCountByStatus(_ status: String) -> Int {
        return filteredProposals.filter { $0.status == status }.count
    }
    
    private func proposalValueByStatus(_ status: String) -> Double {
        let statusProposals = filteredProposals.filter { $0.status == status }
        return statusProposals.reduce(0) { $0 + $1.totalAmount }
    }
    
    private func totalProposedAmount() -> Double {
        return filteredProposals.reduce(0) { $0 + $1.totalAmount }
    }
    
    private func averageProposalValue() -> Double {
        if filteredProposals.isEmpty {
            return 0
        }
        return totalProposedAmount() / Double(filteredProposals.count)
    }
    
    private func medianProposalValue() -> Double {
        let values = filteredProposals.map { $0.totalAmount }.sorted()
        
        if values.isEmpty {
            return 0
        }
        
        if values.count % 2 == 0 {
            let midIndex = values.count / 2
            return (values[midIndex - 1] + values[midIndex]) / 2
        } else {
            return values[values.count / 2]
        }
    }
    
    private func successRate() -> Double {
        let totalCompleted = proposalCountByStatus("Won") + proposalCountByStatus("Lost")
        if totalCompleted == 0 {
            return 0
        }
        return Double(proposalCountByStatus("Won")) / Double(totalCompleted) * 100
    }
    
    private func averageProfitMargin() -> Double {
        let relevantProposals = filteredProposals.filter { $0.totalAmount > 0 }
        if relevantProposals.isEmpty {
            return 0
        }
        
        let totalMargin = relevantProposals.reduce(0) { $0 + $1.profitMargin }
        return totalMargin / Double(relevantProposals.count)
    }
    
    private func totalProfit() -> Double {
        return filteredProposals.reduce(0) { $0 + $1.grossProfit }
    }
}
