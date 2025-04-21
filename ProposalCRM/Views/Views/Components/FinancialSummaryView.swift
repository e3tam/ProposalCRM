import SwiftUI
import CoreData
import Charts

struct FinancialSummaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Proposal.creationDate, ascending: false)],
        animation: .default)
    private var proposals: FetchedResults<Proposal>
    
    @State private var selectedTimePeriod = "All Time"
    
    let timePeriods = ["Last Month", "Last 3 Months", "Last 6 Months", "Last Year", "All Time"]
    private let statuses = ["Draft", "Pending", "Sent", "Won", "Lost"]
    
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
                
                // Chart: Proposal Value by Status
                VStack(alignment: .leading, spacing: 8) {
                    Text("Proposal Value by Status")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart {
                        ForEach(statuses, id: \.self) { status in
                            BarMark(
                                x: .value("Status", status),
                                y: .value("Total Value", proposalValueByStatus(status))
                            )
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
                
                // Status Overview Cards
                VStack(alignment: .leading, spacing: 10) {
                    Text("Proposal Status Overview")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(statuses, id: \.self) { status in
                                StatusCardView(
                                    title: status,
                                    count: proposalCountByStatus(status),
                                    value: proposalValueByStatus(status),
                                    color: colorForStatus(status)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Financial Summary Cards
                VStack(alignment: .leading, spacing: 10) {
                    Text("Financial Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        SummaryCardView(
                            title: "Total Proposed",
                            value: totalProposedAmount(),
                            subtitle: "\(filteredProposals.count) proposals",
                            color: .blue,
                            icon: "doc.text"
                        )
                        
                        SummaryCardView(
                            title: "Won Revenue",
                            value: proposalValueByStatus("Won"),
                            subtitle: "Success Rate: \(String(format: "%.1f%%", successRate()))",
                            color: .green,
                            icon: "checkmark.circle"
                        )
                        
                        SummaryCardView(
                            title: "Average Proposal Value",
                            value: averageProposalValue(),
                            subtitle: "Median: \(String(format: "%.2f", medianProposalValue()))",
                            color: .purple,
                            icon: "chart.bar"
                        )
                        
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
    
    // MARK: - Helpers
    
    private func colorForStatus(_ status: String) -> Color {
        switch status {
        case "Draft": return .gray
        case "Pending": return .orange
        case "Sent": return .blue
        case "Won": return .green
        case "Lost": return .red
        default: return .secondary
        }
    }
    
    var filteredProposals: [Proposal] {
        let all = Array(proposals)
        guard selectedTimePeriod != "All Time" else { return all }
        let cal = Calendar.current
        let now = Date()
        let cutoff: Date? = {
            switch selectedTimePeriod {
            case "Last Month":   return cal.date(byAdding: .month, value: -1, to: now)
            case "Last 3 Months":return cal.date(byAdding: .month, value: -3, to: now)
            case "Last 6 Months":return cal.date(byAdding: .month, value: -6, to: now)
            case "Last Year":    return cal.date(byAdding: .year,  value: -1, to: now)
            default: return nil
            }
        }()
        if let cutoff = cutoff {
            return all.filter { $0.creationDate ?? Date() >= cutoff }
        }
        return all
    }
    
    private func proposalCountByStatus(_ status: String) -> Int {
        filteredProposals.filter { $0.status == status }.count
    }
    
    private func proposalValueByStatus(_ status: String) -> Double {
        filteredProposals
            .filter { $0.status == status }
            .reduce(0) { $0 + $1.totalAmount }
    }
    
    private func totalProposedAmount() -> Double {
        filteredProposals.reduce(0) { $0 + $1.totalAmount }
    }
    
    private func averageProposalValue() -> Double {
        let vals = filteredProposals.map { $0.totalAmount }
        guard !vals.isEmpty else { return 0 }
        return vals.reduce(0, +) / Double(vals.count)
    }
    
    private func medianProposalValue() -> Double {
        let vals = filteredProposals.map { $0.totalAmount }.sorted()
        guard !vals.isEmpty else { return 0 }
        let mid = vals.count / 2
        return vals.count.isMultiple(of: 2)
            ? (vals[mid - 1] + vals[mid]) / 2
            : vals[mid]
    }
    
    private func totalProfit() -> Double {
        filteredProposals.reduce(0) {
            $0 + ($1.totalAmount - $1.totalCost)
        }
    }
    
    private func averageProfitMargin() -> Double {
        let margins = filteredProposals.map { $0.profitMargin }
        guard !margins.isEmpty else { return 0 }
        return margins.reduce(0, +) / Double(margins.count)
    }
    
    private func successRate() -> Double {
        guard !filteredProposals.isEmpty else { return 0 }
        let won = proposalCountByStatus("Won")
        return (Double(won) / Double(filteredProposals.count)) * 100
    }
}
