//
//  EnhancedDashboardView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


import SwiftUI
import Charts
import CoreData

struct EnhancedDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch proposals
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Proposal.creationDate, ascending: false)],
        animation: .default)
    private var proposals: FetchedResults<Proposal>
    
    // Fetch tasks
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.dueDate, ascending: true)],
        predicate: NSPredicate(format: "status != %@", "Completed"),
        animation: .default)
    private var pendingTasks: FetchedResults<Task>
    
    // Time period for chart data
    @State private var selectedTimePeriod = "3 Months"
    let timePeriods = ["1 Month", "3 Months", "6 Months", "1 Year", "All"]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Dashboard header
                dashboardHeader
                
                // Main content area - full screen, no sidebars
                ScrollView {
                    VStack(spacing: 20) {
                        // Key metrics row
                        keyMetricsRow
                        
                        // Charts grid
                        mainChartsGrid
                        
                        // Bottom section with tasks and activity
                        HStack(alignment: .top, spacing: 15) {
                            recentTasksSection
                            recentActivitySection
                        }
                    }
                    .padding()
                }
            }
            .frame(width: geometry.size.width) // Ensure full width
            .background(Color(UIColor.systemBackground))
            .edgesIgnoringSafeArea(.all)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Dashboard Header
    private var dashboardHeader: some View {
        HStack {
            Text("Dashboard")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.leading)
            
            Spacer()
            
            // Refresh button
            Button(action: {
                // Refresh action would go here
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .padding(.trailing)
        }
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Key Metrics Row
    private var keyMetricsRow: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            // Pending Tasks Card
            metricCard(
                title: "Pending Tasks",
                value: "\(pendingTasks.count)",
                detail: "\(overdueTasks) overdue",
                icon: "checklist",
                iconColor: overdueTasks > 0 ? .red : .orange,
                bgColor: Color(UIColor.systemGray6)
            )
            
            // Success Rate Card
            metricCard(
                title: "Success Rate",
                value: "\(formatPercent(successRate))%",
                detail: "\(wonProposalsCount) won proposals",
                icon: "chart.xyaxis.line",
                iconColor: .green,
                bgColor: Color(UIColor.systemGray6)
            )
            
            // Active Proposals Card
            metricCard(
                title: "Active Proposals",
                value: "\(activeProposalsCount)",
                detail: "$\(formatValue(activeProposalsValue))",
                icon: "doc.text.fill",
                iconColor: .blue,
                bgColor: Color(UIColor.systemGray6)
            )
            
            // Avg Deal Card
            metricCard(
                title: "Avg Deal Size",
                value: "$\(formatValue(avgDealSize))",
                detail: "\(closedProposalsCount) closed deals",
                icon: "dollarsign.circle",
                iconColor: .purple,
                bgColor: Color(UIColor.systemGray6)
            )
        }
    }
    
    // MARK: - Main Charts Grid
    private var mainChartsGrid: some View {
        VStack(spacing: 20) {
            // Task Status Grid
            HStack(spacing: 15) {
                // Task status donut chart
                taskStatusDonutChart
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                
                // Task status details
                taskStatusDetailPanel
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
            }
            .frame(height: 220)
            
            // Proposal Charts Grid
            VStack(spacing: 15) {
                // Proposal Value Chart
                VStack(alignment: .leading, spacing: 8) {
                    Text("Proposal Value by Status")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    proposalValueChart
                        .frame(height: 180)
                        .padding([.horizontal, .bottom])
                }
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                
                // Monthly Revenue Chart
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Monthly Revenue")
                            .font(.headline)
                        
                        Spacer()
                        
                        Picker("Time Period", selection: $selectedTimePeriod) {
                            ForEach(timePeriods, id: \.self) { period in
                                Text(period).tag(period)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                    }
                    .padding(.horizontal)
                    
                    monthlyRevenueChart
                        .frame(height: 180)
                        .padding([.horizontal, .bottom])
                }
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                
                // Win/Loss Ratio
                winLossRatioView
                    .frame(height: 100)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Task Status Donut Chart
    private var taskStatusDonutChart: some View {
        VStack {
            Text("Tasks by Status")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // Donut chart
            ZStack {
                Circle()
                    .stroke(Color(UIColor.systemGray4), lineWidth: 25)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(completedTasksRatio))
                    .stroke(Color.green, lineWidth: 25)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 150, height: 150)
                
                VStack {
                    Text("\(completedTasksCount)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("of \(totalTasksCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom)
        }
    }
    
    // MARK: - Task Status Details
    private var taskStatusDetailPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status Breakdown")
                .font(.headline)
                .padding(.horizontal)
            
            Spacer()
            
            // Task status rows
            let statuses = prepareTaskStatusCounts()
            
            taskStatusRow(status: "New", count: statuses["New"] ?? 0, color: .blue)
                .padding(.horizontal)
            
            taskStatusRow(status: "In Progress", count: statuses["In Progress"] ?? 0, color: .orange)
                .padding(.horizontal)
            
            taskStatusRow(status: "Completed", count: statuses["Completed"] ?? 0, color: .green)
                .padding(.horizontal)
            
            taskStatusRow(status: "Overdue", count: overdueTasks, color: .red)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Proposal Value Chart
    private var proposalValueChart: some View {
        // Extract and prepare data for the chart
        let statusList = ["Draft", "Pending", "Sent", "Won", "Lost"]
        let valueByStatus = prepareProposalValueData()
        
        return Chart {
            ForEach(statusList, id: \.self) { status in
                let value = valueByStatus[status] ?? 0
                
                BarMark(
                    x: .value("Status", status),
                    y: .value("Total Value", value)
                )
                .foregroundStyle(statusColor(for: status))
                .annotation(position: .top) {
                    if value > 0 {
                        Text("$\(formatValue(value))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Monthly Revenue Chart
    private var monthlyRevenueChart: some View {
        // Prepare monthly data
        let monthlyData = prepareMonthlyRevenueData()
        let avgRevenue = calculateAverageMonthlyRevenue(from: monthlyData)
        
        return Chart {
            ForEach(monthlyData, id: \.month) { dataPoint in
                BarMark(
                    x: .value("Month", dataPoint.month),
                    y: .value("Revenue", dataPoint.revenue)
                )
                .foregroundStyle(Color.blue.gradient)
            }
            
            // Average revenue line
            RuleMark(
                y: .value("Average", avgRevenue)
            )
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            .foregroundStyle(Color.green)
            .annotation(position: .top, alignment: .trailing) {
                Text("Avg: $\(formatValue(avgRevenue))")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
    }
    
    // MARK: - Win/Loss Ratio View
    private var winLossRatioView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Win/Loss Ratio")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 0) {
                // Prepare ratio data
                let winRatioValue = calculateWinRatio()
                let lossRatioValue = 1 - winRatioValue
                
                VStack(alignment: .leading) {
                    // Ratio visualization
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: UIScreen.main.bounds.width * 0.8 * CGFloat(winRatioValue), height: 30)
                        
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: UIScreen.main.bounds.width * 0.8 * CGFloat(lossRatioValue), height: 30)
                    }
                    .cornerRadius(8)
                    
                    // Labels
                    HStack {
                        Text("\(wonProposalsCount) Won")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(lostProposalsCount) Lost")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 8)
        }
    }
    
    
    
    // MARK: - Task Status Chart
    private var taskStatusChartSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tasks by Status")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                // Donut chart
                ZStack {
                    Circle()
                        .stroke(Color(UIColor.systemGray5), lineWidth: 25)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(completedTasksRatio))
                        .stroke(Color.green, lineWidth: 25)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 150, height: 150)
                    
                    VStack {
                        Text("\(completedTasksCount)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("of \(totalTasksCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 160, height: 160)
                
                // Task status breakdown
                VStack(alignment: .leading, spacing: 15) {
                    let statuses = prepareTaskStatusCounts()
                    
                    taskStatusRow(status: "New", count: statuses["New"] ?? 0, color: .blue)
                    taskStatusRow(status: "In Progress", count: statuses["In Progress"] ?? 0, color: .orange)
                    taskStatusRow(status: "Completed", count: statuses["Completed"] ?? 0, color: .green)
                    taskStatusRow(status: "Overdue", count: overdueTasks, color: .red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Win/Loss Ratio Chart
    private var winLossRatioChartSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Win/Loss Ratio")
                .font(.headline)
                .padding(.horizontal)
            
            ZStack {
                HStack(spacing: 0) {
                    // Prepare ratio data
                    let winRatioValue = calculateWinRatio()
                    let lossRatioValue = 1 - winRatioValue
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: UIScreen.main.bounds.width * 0.35 * CGFloat(winRatioValue), height: 40)
                    
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: UIScreen.main.bounds.width * 0.35 * CGFloat(lossRatioValue), height: 40)
                }
                .cornerRadius(8)
                
                HStack {
                    Spacer()
                        .frame(width: UIScreen.main.bounds.width * 0.35 * CGFloat(winRatio) * 0.5)
                    
                    Text("\(wonProposalsCount) Won")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                    
                    Spacer()
                        .frame(width: UIScreen.main.bounds.width * 0.35 * CGFloat(1 - winRatio) * 0.5)
                    
                    Text("\(lostProposalsCount) Lost")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Recent Tasks Section
    private var recentTasksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Upcoming Tasks")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: TaskListView()) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            upcomingTasksList
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
    
    private var upcomingTasksList: some View {
        VStack(spacing: 12) {
            if pendingTasks.isEmpty {
                Text("No upcoming tasks")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                // Limited to first 3 tasks for performance
                let tasksToDisplay = Array(pendingTasks.prefix(3))
                
                ForEach(tasksToDisplay, id: \.self) { task in
                    NavigationLink(destination: TaskDetailView(task: task)) {
                        upcomingTaskRow(task: task)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private func upcomingTaskRow(task: Task) -> some View {
        HStack {
            Circle()
                .fill(task.priorityColor)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title ?? "")
                    .font(.subheadline)
                    .lineLimit(1)
                
                if let dueDate = task.dueDate {
                    Text(dateFormatter.string(from: dueDate))
                        .font(.caption)
                        .foregroundColor(task.isOverdue ? .red : .secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(10)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: GlobalActivityView()) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            recentActivitiesList
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
    
    private var recentActivitiesList: some View {
        VStack(spacing: 12) {
            // Get recent activities safely
            let activities = fetchRecentActivities()
            
            if activities.isEmpty {
                Text("No recent activity")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(activities, id: \.self) { activity in
                    recentActivityRow(activity: activity)
                }
            }
        }
    }
    
    private func recentActivityRow(activity: Activity) -> some View {
        HStack(spacing: 12) {
            Image(systemName: activity.typeIcon)
                .foregroundColor(activity.typeColor)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color(UIColor.systemBackground)))
            
            VStack(alignment: .leading, spacing: 3) {
                Text(activity.description ?? "")
                    .font(.subheadline)
                    .lineLimit(1)
                
                if let timestamp = activity.timestamp {
                    Text(timeAgoFormatter.localizedString(for: timestamp, relativeTo: Date()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
    }
    
    // MARK: - Helper Components
    
    private func metricCard(title: String, value: String, detail: String, icon: String, iconColor: Color, bgColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text(detail)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bgColor)
        .cornerRadius(12)
    }
    
    private func taskStatusRow(status: String, count: Int, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(status)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
    
    // MARK: - Data Helper Methods
    
    // Format values for display
    private func formatValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    private func formatPercent(_ value: Double) -> String {
        return String(format: "%.1f", value)
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
    
    // Compute active proposals
    private var activeProposalsCount: Int {
        var count = 0
        for proposal in proposals {
            if let status = proposal.status, status != "Won" && status != "Lost" {
                count += 1
            }
        }
        return count
    }
    
    private var activeProposalsValue: Double {
        var total = 0.0
        for proposal in proposals {
            if let status = proposal.status, status != "Won" && status != "Lost" {
                total += proposal.totalAmount
            }
        }
        return total
    }
    
    // Compute overdue tasks
    private var overdueTasks: Int {
        var count = 0
        for task in pendingTasks {
            if task.isOverdue {
                count += 1
            }
        }
        return count
    }
    
    // Task status counts
    private func prepareTaskStatusCounts() -> [String: Int] {
        var counts: [String: Int] = [
            "New": 0,
            "In Progress": 0,
            "Completed": 0,
            "Deferred": 0
        ]
        
        // Safer approach to fetch all tasks
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        do {
            let allTasks = try viewContext.fetch(fetchRequest)
            for task in allTasks {
                if let status = task.status {
                    counts[status, default: 0] += 1
                }
            }
        } catch {
            print("Error fetching tasks: \(error)")
        }
        
        return counts
    }
    
    private var completedTasksCount: Int {
        let counts = prepareTaskStatusCounts()
        return counts["Completed"] ?? 0
    }
    
    private var totalTasksCount: Int {
        let counts = prepareTaskStatusCounts()
        let total = counts.values.reduce(0, +)
        return total > 0 ? total : 1 // Avoid division by zero
    }
    
    private var completedTasksRatio: Double {
        return Double(completedTasksCount) / Double(totalTasksCount)
    }
    
    // Proposal statistics
    private var wonProposalsCount: Int {
        var count = 0
        for proposal in proposals {
            if proposal.status == "Won" {
                count += 1
            }
        }
        return count
    }
    
    private var lostProposalsCount: Int {
        var count = 0
        for proposal in proposals {
            if proposal.status == "Lost" {
                count += 1
            }
        }
        return count
    }
    
    private var closedProposalsCount: Int {
        return wonProposalsCount + lostProposalsCount
    }
    
    private var successRate: Double {
        if closedProposalsCount == 0 {
            return 0
        }
        return Double(wonProposalsCount) / Double(closedProposalsCount) * 100
    }
    
    private var winRatio: Double {
        return calculateWinRatio()
    }
    
    private func calculateWinRatio() -> Double {
        if closedProposalsCount == 0 {
            return 0.5 // Default to 50/50 when no data
        }
        return Double(wonProposalsCount) / Double(closedProposalsCount)
    }
    
    private var avgDealSize: Double {
        var totalAmount = 0.0
        var count = 0
        
        for proposal in proposals {
            if proposal.status == "Won" {
                totalAmount += proposal.totalAmount
                count += 1
            }
        }
        
        if count == 0 {
            return 0
        }
        
        return totalAmount / Double(count)
    }
    
    // Helper method to prepare proposal value data
    private func prepareProposalValueData() -> [String: Double] {
        var values: [String: Double] = [:]
        
        for proposal in proposals {
            if let status = proposal.status {
                let currentValue = values[status] ?? 0
                values[status] = currentValue + proposal.totalAmount
            }
        }
        
        return values
    }
    
    // MARK: - Monthly Revenue Data
    
    private struct MonthlyData {
        let month: String
        let revenue: Double
    }
    
    private func prepareMonthlyRevenueData() -> [MonthlyData] {
        // Generate monthly data based on selected time period
        let calendar = Calendar.current
        let now = Date()
        var result: [MonthlyData] = []
        
        // Determine number of months to display
        let monthsToShow: Int
        switch selectedTimePeriod {
        case "1 Month": monthsToShow = 4  // Show 4 weeks
        case "3 Months": monthsToShow = 3
        case "6 Months": monthsToShow = 6
        case "1 Year": monthsToShow = 12
        default: monthsToShow = 6
        }
        
        // Generate the monthly labels and calculate revenue
        for i in 0..<monthsToShow {
            if let date = calendar.date(byAdding: .month, value: -(monthsToShow - 1 - i), to: now) {
                let month = getMonthString(from: date)
                let revenue = calculateRevenueForMonth(date)
                
                result.append(MonthlyData(month: month, revenue: revenue))
            }
        }
        
        return result
    }
    
    private func getMonthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    private func calculateRevenueForMonth(_ month: Date) -> Double {
        let calendar = Calendar.current
        
        var monthlyRevenue = 0.0
        for proposal in proposals {
            if proposal.status == "Won",
               let creationDate = proposal.creationDate,
               calendar.isDate(creationDate, equalTo: month, toGranularity: .month) {
                monthlyRevenue += proposal.totalAmount
            }
        }
        
        return monthlyRevenue
    }
    
    private func calculateAverageMonthlyRevenue(from data: [MonthlyData]) -> Double {
        if data.isEmpty {
            return 0
        }
        
        let totalRevenue = data.reduce(0) { $0 + $1.revenue }
        return totalRevenue / Double(data.count)
    }
    
    // MARK: - Recent Activities
    
    private func fetchRecentActivities() -> [Activity] {
        let fetchRequest = NSFetchRequest<Activity>(entityName: "Activity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Activity.timestamp, ascending: false)]
        fetchRequest.fetchLimit = 3
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching recent activities: \(error)")
            return []
        }
    }
    
    // MARK: - Formatters
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private var timeAgoFormatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }
}

// Preview provider
struct EnhancedDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EnhancedDashboardView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
