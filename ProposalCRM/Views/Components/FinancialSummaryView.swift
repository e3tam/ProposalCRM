// FinancialSummaryDetailView.swift
// Detailed financial analysis of a proposal

import SwiftUI
import Charts

struct FinancialSummaryDetailView: View {
    @ObservedObject var proposal: Proposal
    @Environment(\.presentationMode) var presentationMode
    
    // Format currency to euros
    private func formatEuro(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "€\(String(format: "%.2f", value))"
    }
    
    // MARK: - Computed properties for financial analysis
    
    var productsByCategory: [(category: String, total: Double)] {
        var categoryTotals: [String: Double] = [:]
        
        for item in proposal.itemsArray {
            if let category = item.product?.category {
                categoryTotals[category, default: 0] += item.amount
            } else {
                categoryTotals["Uncategorized", default: 0] += item.amount
            }
        }
        
        return categoryTotals.map { ($0.key, $0.value) }
            .sorted { $0.total > $1.total }
    }
    
    var totalCostBreakdown: [(name: String, value: Double, color: Color)] {
        var costs: [(String, Double, Color)] = []
        
        // Products cost
        let productsCost = proposal.itemsArray.reduce(0.0) { total, item in
            let partnerPrice = item.product?.partnerPrice ?? 0
            return total + (partnerPrice * item.quantity)
        }
        if productsCost > 0 {
            costs.append(("Products", productsCost, .blue))
        }
        
        // Expenses
        if proposal.subtotalExpenses > 0 {
            costs.append(("Expenses", proposal.subtotalExpenses, .orange))
        }
        
        return costs
    }
    
    var profitByProductCategory: [(category: String, profit: Double, margin: Double)] {
        var categoryData: [String: (revenue: Double, cost: Double)] = [:]
        
        for item in proposal.itemsArray {
            let category = item.product?.category ?? "Uncategorized"
            let partnerCost = (item.product?.partnerPrice ?? 0) * item.quantity
            let revenue = item.amount
            
            let existing = categoryData[category, default: (0, 0)]
            categoryData[category] = (existing.revenue + revenue, existing.cost + partnerCost)
        }
        
        return categoryData.map { category, values in
            let profit = values.revenue - values.cost
            let margin = values.revenue > 0 ? (profit / values.revenue) * 100 : 0
            return (category, profit, margin)
        }.sorted { $0.profit > $1.profit }
    }
    
    var averageDiscountByCategory: [(category: String, avgDiscount: Double)] {
        var categoryDiscounts: [String: [Double]] = [:]
        
        for item in proposal.itemsArray {
            let category = item.product?.category ?? "Uncategorized"
            categoryDiscounts[category, default: []].append(item.discount)
        }
        
        return categoryDiscounts.map { category, discounts in
            let avgDiscount = discounts.reduce(0, +) / Double(discounts.count)
            return (category, avgDiscount)
        }.sorted { $0.avgDiscount > $1.avgDiscount }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Overall Summary Cards
                    overallSummarySection
                    
                    // Revenue Breakdown Pie Chart
                    revenueBreakdownSection
                    
                    // Product Category Performance
                    productCategoryPerformanceSection
                    
                    // Cost Structure Analysis
                    costStructureSection
                    
                    // Profit Analysis by Category
                    profitAnalysisSection
                    
                    // Discount Analysis
                    discountAnalysisSection
                    
                    // Tax Breakdown
                    taxBreakdownSection
                    
                    // Engineering Analysis
                    engineeringAnalysisSection
                    
                    // Key Financial Indicators
                    keyFinancialIndicatorsSection
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
    
    // MARK: - Component Sections
    
    private var overallSummarySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                SummaryMetricCard(
                    title: "Total Revenue",
                    value: formatEuro(proposal.totalAmount),
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )
                
                SummaryMetricCard(
                    title: "Total Cost",
                    value: formatEuro(proposal.totalCost),
                    icon: "arrow.down.circle.fill",
                    color: .red
                )
                
                SummaryMetricCard(
                    title: "Gross Profit",
                    value: formatEuro(proposal.grossProfit),
                    icon: "chart.line.uptrend.xyaxis",
                    color: proposal.grossProfit > 0 ? .green : .red
                )
                
                SummaryMetricCard(
                    title: "Profit Margin",
                    value: String(format: "%.1f%%", proposal.profitMargin),
                    icon: "percent",
                    color: proposal.profitMargin > 30 ? .green : (proposal.profitMargin > 15 ? .orange : .red)
                )
            }
        }
    }
    
    private var revenueBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Revenue Breakdown")
                .font(.title2)
                .fontWeight(.bold)
            
            // Pie Chart
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach([
                        ("Products", proposal.subtotalProducts, Color.blue),
                        ("Engineering", proposal.subtotalEngineering, Color.green),
                        ("Expenses", proposal.subtotalExpenses, Color.orange),
                        ("Taxes", proposal.subtotalTaxes, Color.red)
                    ], id: \.0) { item in
                        SectorMark(
                            angle: .value("Value", item.1),
                            innerRadius: .ratio(0.5),
                            angularInset: 1.5
                        )
                        .foregroundStyle(item.2)
                        .cornerRadius(5)
                    }
                }
                .frame(height: 250)
            }
            
            // Detailed breakdown
            VStack(spacing: 10) {
                RevenueRow(title: "Products", value: proposal.subtotalProducts, total: proposal.totalAmount, color: .blue)
                RevenueRow(title: "Engineering", value: proposal.subtotalEngineering, total: proposal.totalAmount, color: .green)
                RevenueRow(title: "Expenses", value: proposal.subtotalExpenses, total: proposal.totalAmount, color: .orange)
                RevenueRow(title: "Taxes", value: proposal.subtotalTaxes, total: proposal.totalAmount, color: .red)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private var productCategoryPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Product Category Performance")
                .font(.title2)
                .fontWeight(.bold)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(productsByCategory, id: \.category) { item in
                        BarMark(
                            x: .value("Category", item.category),
                            y: .value("Revenue", item.total)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }
                }
                .frame(height: 250)
            }
            
            // Category details
            ForEach(productsByCategory, id: \.category) { item in
                CategoryDetailRow(
                    category: item.category,
                    revenue: item.total,
                    percentage: (item.total / proposal.subtotalProducts) * 100
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private var costStructureSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Cost Structure")
                .font(.title2)
                .fontWeight(.bold)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(totalCostBreakdown, id: \.name) { item in
                        SectorMark(
                            angle: .value("Value", item.value),
                            innerRadius: .ratio(0.5),
                            angularInset: 1.5
                        )
                        .foregroundStyle(item.color)
                        .cornerRadius(5)
                    }
                }
                .frame(height: 200)
            }
            
            // Cost breakdown details
            ForEach(totalCostBreakdown, id: \.name) { item in
                CostRow(
                    title: item.name,
                    value: item.value,
                    percentage: (item.value / proposal.totalCost) * 100,
                    color: item.color
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private var profitAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Profit Analysis by Category")
                .font(.title2)
                .fontWeight(.bold)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(profitByProductCategory, id: \.category) { item in
                        BarMark(
                            x: .value("Category", item.category),
                            y: .value("Profit", item.profit)
                        )
                        .foregroundStyle(item.profit > 0 ? Color.green.gradient : Color.red.gradient)
                    }
                }
                .frame(height: 250)
            }
            
            // Profit details
            ForEach(profitByProductCategory, id: \.category) { item in
                ProfitRow(
                    category: item.category,
                    profit: item.profit,
                    margin: item.margin
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private var discountAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Discount Analysis")
                .font(.title2)
                .fontWeight(.bold)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(averageDiscountByCategory, id: \.category) { item in
                        BarMark(
                            x: .value("Category", item.category),
                            y: .value("Avg Discount", item.avgDiscount)
                        )
                        .foregroundStyle(Color.orange.gradient)
                    }
                }
                .frame(height: 200)
            }
            
            // Discount details
            ForEach(averageDiscountByCategory, id: \.category) { item in
                DiscountRow(
                    category: item.category,
                    avgDiscount: item.avgDiscount
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private var taxBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Tax Breakdown")
                .font(.title2)
                .fontWeight(.bold)
            
            if proposal.taxesArray.isEmpty {
                Text("No taxes applied")
                    .foregroundColor(.secondary)
            } else {
                ForEach(proposal.taxesArray, id: \.id) { tax in
                    TaxDetailRow(tax: tax, subtotal: proposal.subtotalProducts + proposal.subtotalEngineering + proposal.subtotalExpenses)
                }
                
                HStack {
                    Text("Total Taxes")
                        .font(.headline)
                    Spacer()
                    Text(formatEuro(proposal.subtotalTaxes))
                        .font(.headline)
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private var engineeringAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Engineering Services")
                .font(.title2)
                .fontWeight(.bold)
            
            if proposal.engineeringArray.isEmpty {
                Text("No engineering services")
                    .foregroundColor(.secondary)
            } else {
                let totalDays = proposal.engineeringArray.reduce(0.0) { $0 + $1.days }
                let avgRate = totalDays > 0 ? proposal.subtotalEngineering / totalDays : 0
                
                HStack {
                    SummaryMetricCard(
                        title: "Total Days",
                        value: String(format: "%.1f", totalDays),
                        icon: "calendar",
                        color: .green
                    )
                    
                    SummaryMetricCard(
                        title: "Avg Daily Rate",
                        value: formatEuro(avgRate),
                        icon: "dollarsign.circle",
                        color: .blue
                    )
                }
                
                ForEach(proposal.engineeringArray, id: \.id) { engineering in
                    EngineeringDetailRow(engineering: engineering)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private var keyFinancialIndicatorsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Key Financial Indicators")
                .font(.title2)
                .fontWeight(.bold)
            
            // Average margin per product
            let avgMarginPerProduct = proposal.itemsArray.isEmpty ? 0 : proposal.grossProfit / Double(proposal.itemsArray.count)
            
            // Average discount
            let avgDiscount = proposal.itemsArray.isEmpty ? 0 : proposal.itemsArray.reduce(0.0) { $0 + $1.discount } / Double(proposal.itemsArray.count)
            
            // Revenue per category
            let productCategories = Set(proposal.itemsArray.compactMap { $0.product?.category }).count
            let revPerCategory = productCategories > 0 ? proposal.subtotalProducts / Double(productCategories) : 0
            
            VStack(spacing: 10) {
                KPIRow(title: "Avg Margin per Product", value: formatEuro(avgMarginPerProduct))
                KPIRow(title: "Avg Product Discount", value: String(format: "%.1f%%", avgDiscount))
                KPIRow(title: "Revenue per Category", value: formatEuro(revPerCategory))
                KPIRow(title: "Engineering % of Revenue", value: String(format: "%.1f%%", proposal.totalAmount > 0 ? (proposal.subtotalEngineering / proposal.totalAmount) * 100 : 0))
                KPIRow(title: "Expenses % of Revenue", value: String(format: "%.1f%%", proposal.totalAmount > 0 ? (proposal.subtotalExpenses / proposal.totalAmount) * 100 : 0))
                KPIRow(title: "Tax Rate", value: String(format: "%.1f%%", proposal.totalAmount - proposal.subtotalTaxes > 0 ? (proposal.subtotalTaxes / (proposal.totalAmount - proposal.subtotalTaxes)) * 100 : 0))
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// MARK: - Supporting Views

struct SummaryMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
        }
        .padding()
        .frame(width: 150)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct RevenueRow: View {
    let title: String
    let value: Double
    let total: Double
    let color: Color
    
    // Format currency to euros
    private func formatEuro(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "€\(String(format: "%.2f", value))"
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(String(format: "%.1f%%", (value / total) * 100))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatEuro(value))
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 80, alignment: .trailing)
        }
    }
}

struct CategoryDetailRow: View {
    let category: String
    let revenue: Double
    let percentage: Double
    
    // Format currency to euros
    private func formatEuro(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "€\(String(format: "%.2f", value))"
    }
    
    var body: some View {
        HStack {
            Text(category)
                .font(.subheadline)
            
            Spacer()
            
            Text(String(format: "%.1f%%", percentage))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatEuro(revenue))
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 80, alignment: .trailing)
        }
    }
}

struct CostRow: View {
    let title: String
    let value: Double
    let percentage: Double
    let color: Color
    
    // Format currency to euros
    private func formatEuro(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "€\(String(format: "%.2f", value))"
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(String(format: "%.1f%%", percentage))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatEuro(value))
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 80, alignment: .trailing)
        }
    }
}

struct ProfitRow: View {
    let category: String
    let profit: Double
    let margin: Double
    
    // Format currency to euros
    private func formatEuro(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "€\(String(format: "%.2f", value))"
    }
    
    var body: some View {
        HStack {
            Text(category)
                .font(.subheadline)
            
            Spacer()
            
            Text(String(format: "%.1f%%", margin))
                .font(.caption)
                .foregroundColor(margin > 20 ? .green : (margin > 10 ? .orange : .red))
            
            Text(formatEuro(profit))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(profit > 0 ? .green : .red)
                .frame(width: 80, alignment: .trailing)
        }
    }
}

struct DiscountRow: View {
    let category: String
    let avgDiscount: Double
    
    var body: some View {
        HStack {
            Text(category)
                .font(.subheadline)
            
            Spacer()
            
            Text(String(format: "%.1f%%", avgDiscount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
                .frame(width: 80, alignment: .trailing)
        }
    }
}

struct TaxDetailRow: View {
    let tax: CustomTax
    let subtotal: Double
    
    // Format currency to euros
    private func formatEuro(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "€\(String(format: "%.2f", value))"
    }
    
    var body: some View {
        HStack {
            Text(tax.name ?? "Custom Tax")
                .font(.subheadline)
            
            Spacer()
            
            Text(String(format: "%.1f%%", tax.rate))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatEuro(tax.amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 80, alignment: .trailing)
        }
    }
}

struct EngineeringDetailRow: View {
    let engineering: Engineering
    
    // Format currency to euros
    private func formatEuro(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "€\(String(format: "%.2f", value))"
    }
    
    var body: some View {
        HStack {
            Text(engineering.desc ?? "Engineering Service")
                .font(.subheadline)
            
            Spacer()
            
            Text(String(format: "%.1f days @ %@", engineering.days, formatEuro(engineering.rate)))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatEuro(engineering.amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 80, alignment: .trailing)
        }
    }
}

struct KPIRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}
